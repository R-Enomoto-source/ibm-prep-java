# Auto Git Commit Push Script (ASCII only for encoding compatibility)
# Loads Japanese messages from messages.json

param(
    [string]$ConfigPath = "config.json"
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$ConfigFile = Join-Path $ScriptDir $ConfigPath
$TempDir = Join-Path $RepoRoot ".git-auto-commit"
$LogDir = Join-Path $TempDir "logs"
$CommitMessageFile = Join-Path $TempDir "commit-message.txt"
$LastStatusFile = Join-Path $TempDir "last-status.txt"
$LastCommitTimeFile = Join-Path $TempDir "last-commit-time.txt"
$LockFile = Join-Path $TempDir "lock.pid"

$MessagesFile = Join-Path $ScriptDir "messages.json"
$M = @{}
if (Test-Path $MessagesFile) {
    try {
        $M = Get-Content $MessagesFile -Raw -Encoding UTF8 | ConvertFrom-Json
    } catch { }
}

function Get-Message { param([string]$Key) if ($M.$Key) { $M.$Key } else { $Key } }

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    Write-Host $logMessage
    
    try {
        if (-not (Test-Path $LogDir)) {
            New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
        }
        $dateStr = Get-Date -Format "yyyy-MM-dd"
        $logFile = Join-Path $LogDir "log-$dateStr.txt"
        $utf8Bom = New-Object System.Text.UTF8Encoding $true
        if (-not (Test-Path $logFile)) {
            [System.IO.File]::AppendAllText($logFile, $logMessage + "`r`n", $utf8Bom)
        } else {
            $utf8NoBom = New-Object System.Text.UTF8Encoding $false
            [System.IO.File]::AppendAllText($logFile, $logMessage + "`r`n", $utf8NoBom)
        }
    } catch {
    }
}

function Get-Config {
    if (Test-Path $ConfigFile) {
        try {
            $config = Get-Content $ConfigFile -Raw | ConvertFrom-Json
            return $config
        } catch {
            Write-Log (Get-Message "configLoadFailed") "WARN"
        }
    }
    
    return @{
        pollingInterval = 30
        debounceSeconds = 30
        minChangeCount = 1
        branchName = "main"
        watchPath = "."
        retryAttempts = 3
        retryDelaySeconds = 5
        activeHours = @{
            enabled = $false
            startTime = "08:00"
            endTime = "23:00"
        }
        logLevel = "INFO"
    }
}

function Test-ActiveHours {
    param($Config)
    
    if (-not $Config.activeHours.enabled) {
        return $true
    }
    
    $now = Get-Date
    $startTime = [DateTime]::Parse($Config.activeHours.startTime)
    $endTime = [DateTime]::Parse($Config.activeHours.endTime)
    $currentTime = [DateTime]::Parse($now.ToString("HH:mm"))
    
    if ($startTime -le $endTime) {
        return ($currentTime -ge $startTime -and $currentTime -le $endTime)
    } else {
        return ($currentTime -ge $startTime -or $currentTime -le $endTime)
    }
}

function Invoke-GitCommand {
    param(
        [string]$Command,
        [int]$RetryCount = 3,
        [int]$RetryDelay = 5,
        [switch]$SuppressCrlfWarnings
    )
    
    $attempt = 0
    while ($attempt -lt $RetryCount) {
        try {
            Push-Location $RepoRoot
            # Force use of store credential helper to avoid wincredman issues
            $env:GIT_CREDENTIAL_HELPER = "store"
            # Parse command and handle quoted arguments properly
            # Split by spaces but preserve quoted strings
            $argList = @()
            $currentArg = ""
            $inQuotes = $false
            for ($i = 0; $i -lt $Command.Length; $i++) {
                $char = $Command[$i]
                if ($char -eq '"') {
                    $inQuotes = -not $inQuotes
                    $currentArg += $char
                } elseif ($char -eq ' ' -and -not $inQuotes) {
                    if ($currentArg) {
                        $argList += $currentArg.Trim('"')
                        $currentArg = ""
                    }
                } else {
                    $currentArg += $char
                }
            }
            if ($currentArg) {
                $argList += $currentArg.Trim('"')
            }
            $output = & git @argList 2>&1
            $exitCode = $LASTEXITCODE
            if ($null -eq $exitCode) { $exitCode = 0 }
            
            # Filter out CRLF warnings if requested
            if ($SuppressCrlfWarnings) {
                $output = $output | Where-Object { 
                    $line = if ($null -eq $_) { "" } else { $_.ToString() }
                    $line -notmatch "CRLF will be replaced by LF"
                }
            }
            
            $outputParts = @($output) | ForEach-Object { if ($null -eq $_) { "" } else { $_.ToString() } }
            if (-not $outputParts -or $outputParts.Count -eq 0) { $outputParts = @("") }
            $outputStr = ([string]::Join(" ", $outputParts)).Trim()
            $isPushUpToDate = ($Command -like "push*") -and (
                $outputStr -like "*Everything*" -or
                $outputStr -like "*up-to-date*" -or
                $outputStr -match "up.to.date" -or
                $outputStr -match "Everything"
            )
            # CRLF warning only: git add/commit often exits non-zero on Windows but files are staged; treat as success
            # Even if we filtered warnings, check if only CRLF warnings were present
            $isCrlfWarningOnly = ($Command -like "add*" -or $Command -like "commit*") -and
                ($outputStr -match "CRLF will be replaced by LF" -or ($SuppressCrlfWarnings -and -not $outputStr)) -and
                $outputStr -notmatch "fatal:" -and
                $outputStr -notmatch "error:"
            # For git add, if exit code is non-zero but only CRLF warnings exist, treat as success
            if ($Command -like "add*" -and $exitCode -ne 0 -and $SuppressCrlfWarnings -and -not $outputStr) {
                # No output after filtering means only CRLF warnings were present
                return @{ Success = $true; Output = @() }
            }
            if ($exitCode -eq 0 -or $isPushUpToDate -or $isCrlfWarningOnly) {
                return @{ Success = $true; Output = $output }
            } else {
                throw "git $Command failed (exit code: $exitCode): $output"
            }
        } catch {
            $attempt++
            if ($attempt -ge $RetryCount) {
                return @{ Success = $false; Error = $_.Exception.Message }
            }
            Write-Log "$(Get-Message 'retry') $attempt/${RetryCount}: $_" "WARN"
            Start-Sleep -Seconds $RetryDelay
        } finally {
            Pop-Location
        }
    }
}

function Get-CommitMessage {
    $generateScript = Join-Path $ScriptDir "generate-commit-msg.ps1"
    
    if (Test-Path $generateScript) {
        try {
            $message = & $generateScript -RepoPath $RepoRoot
            return $message
        } catch {
            Write-Log "$(Get-Message 'commitMsgFailed'): $_" "ERROR"
        }
    }
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    return "Auto commit: $timestamp"
}

function Invoke-CommitAndPush {
    param($Config)
    
    if (-not (Test-ActiveHours -Config $Config)) {
        Write-Log (Get-Message "outsideActiveHours") "INFO"
        return $false
    }
    
    $statusResult = Invoke-GitCommand "status --porcelain"
    if (-not $statusResult.Success) {
        Write-Log "$(Get-Message 'gitStatusFailed'): $($statusResult.Error)" "ERROR"
        return $false
    }
    
    $statusOutput = $statusResult.Output -join "`n"
    
    if (-not $statusOutput -or $statusOutput.Trim() -eq "") {
        return $false
    }
    
    $lastStatus = ""
    if (Test-Path $LastStatusFile) {
        $lastStatus = Get-Content $LastStatusFile -Raw -ErrorAction SilentlyContinue
    }
    
    if ($statusOutput -eq $lastStatus) {
        Write-Log (Get-Message "sameAsLast") "INFO"
        return $false
    }
    
    $changeCount = ($statusOutput -split "`n" | Where-Object { $_.Trim() -ne "" }).Count
    
    if ($changeCount -lt $Config.minChangeCount) {
        Write-Log "$(Get-Message 'changeCountMin') ($changeCount -lt $($Config.minChangeCount))" "INFO"
        return $false
    }
    
    Write-Log "$(Get-Message 'changesDetected') ($changeCount $(Get-Message 'files')). $(Get-Message 'runningCommitPush')" "INFO"
    
    $commitMessage = Get-CommitMessage
    if (-not $commitMessage) {
        Write-Log (Get-Message "commitMsgFailed") "ERROR"
        return $false
    }
    
    $commitMessage | Out-File -FilePath $CommitMessageFile -Encoding UTF8 -Force
    
    Write-Log (Get-Message "gitAddRunning") "INFO"
    # Suppress CRLF warnings by redirecting stderr warnings to null for git add
    $addResult = Invoke-GitCommand "add ." -RetryCount $Config.retryAttempts -RetryDelay $Config.retryDelaySeconds -SuppressCrlfWarnings
    if (-not $addResult.Success) {
        Write-Log "$(Get-Message 'gitAddFailed'): $($addResult.Error)" "ERROR"
        return $false
    }
    
    Write-Log (Get-Message "gitCommitRunning") "INFO"
    # Execute git commit directly with proper path handling
    $commitAttempt = 0
    $commitSuccess = $false
    while ($commitAttempt -lt $Config.retryAttempts -and -not $commitSuccess) {
        try {
            Push-Location $RepoRoot
            $env:GIT_CREDENTIAL_HELPER = "store"
            $output = & git commit -F $CommitMessageFile 2>&1
            $exitCode = $LASTEXITCODE
            if ($null -eq $exitCode) { $exitCode = 0 }
            if ($exitCode -eq 0) {
                $commitSuccess = $true
                $commitResult = @{ Success = $true; Output = $output }
            } else {
                throw "git commit failed (exit code: $exitCode): $output"
            }
        } catch {
            $commitAttempt++
            if ($commitAttempt -ge $Config.retryAttempts) {
                $commitResult = @{ Success = $false; Error = $_.Exception.Message }
            } else {
                Write-Log "$(Get-Message 'retry') $commitAttempt/$($Config.retryAttempts): $_" "WARN"
                Start-Sleep -Seconds $Config.retryDelaySeconds
            }
        } finally {
            Pop-Location
        }
    }
    if (-not $commitResult.Success) {
        Write-Log "$(Get-Message 'gitCommitFailed'): $($commitResult.Error)" "ERROR"
        return $false
    }
    
    Write-Log "$(Get-Message 'gitPushRunning') origin $($Config.branchName)" "INFO"
    # Use -c option to force credential.helper=store for this command
    $pushResult = Invoke-GitCommand "-c credential.helper=store push origin $($Config.branchName)" -RetryCount $Config.retryAttempts -RetryDelay $Config.retryDelaySeconds
    if (-not $pushResult.Success) {
        if ($pushResult.Error -and ($pushResult.Error -like "*Everything*up*date*" -or $pushResult.Error -like "*up-to-date*")) {
            Write-Log (Get-Message "commitPushDone") "INFO"
            $statusOutput | Out-File -FilePath $LastStatusFile -Encoding UTF8 -Force
            (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") | Out-File -FilePath $LastCommitTimeFile -Encoding UTF8 -Force
            return $true
        }
        Write-Log "$(Get-Message 'gitPushFailed'): $($pushResult.Error)" "ERROR"
        return $false
    }
    
    Write-Log (Get-Message "commitPushDone") "INFO"
    
    $statusOutput | Out-File -FilePath $LastStatusFile -Encoding UTF8 -Force
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") | Out-File -FilePath $LastCommitTimeFile -Encoding UTF8 -Force
    
    return $true
}

function Main {
    Write-Log (Get-Message "scriptStarted") "INFO"
    Write-Log "$(Get-Message 'repoPath'): $RepoRoot" "INFO"
    
    if (Test-Path $LockFile) {
        try {
            $lockPid = Get-Content $LockFile -ErrorAction SilentlyContinue
            if ($lockPid) {
                $lockProcess = Get-Process -Id $lockPid -ErrorAction SilentlyContinue
                if ($lockProcess) {
                    Write-Log "$(Get-Message 'anotherInstance') (PID: $lockPid). $(Get-Message 'exiting')." "WARN"
                    exit 0
                } else {
                    Remove-Item $LockFile -Force -ErrorAction SilentlyContinue
                }
            }
        } catch {
        }
    }
    
    $PID | Out-File -FilePath $LockFile -Encoding ASCII -Force
    
    # Use credential store for this repo so scheduled/non-interactive push works (avoids wincredman failure)
    try {
        Push-Location $RepoRoot
        # Remove all credential helpers and set store as the only one for this repo
        & git config --unset-all credential.helper 2>$null
        & git config --add credential.helper store
        # Set environment variable to force use of store helper (overrides global config)
        $env:GIT_CREDENTIAL_HELPER = "store"
        Pop-Location
    } catch { Pop-Location; throw }
    
    $config = Get-Config
    $polling = $config.pollingInterval
    $debounce = $config.debounceSeconds
    Write-Log "$(Get-Message 'configLoaded') ($(Get-Message 'pollingIntervalLabel'): $polling$(Get-Message 'pollingSec'), $(Get-Message 'debounceLabel'): $debounce$(Get-Message 'pollingSec'))" "INFO"
    
    $lastChangeTime = $null
    $lastStatus = ""
    
    Register-EngineEvent PowerShell.Exiting -Action {
        Write-Log "$(Get-Message 'scriptExiting') ($(Get-Message 'shutdownReboot'))" "INFO"
    } | Out-Null
    
    try {
        [Console]::TreatControlCAsInput = $false
    } catch {
    }
    
    try {
        while ($true) {
            $statusResult = Invoke-GitCommand "status --porcelain"
            
            if ($statusResult.Success) {
                $currentStatus = $statusResult.Output -join "`n"
                
                if ($currentStatus -and $currentStatus.Trim() -ne "") {
                    if ($currentStatus -ne $lastStatus) {
                        Write-Log (Get-Message "changesDetected") "INFO"
                        $lastChangeTime = Get-Date
                        $lastStatus = $currentStatus
                    }
                    
                    if ($lastChangeTime -and 
                        ((Get-Date) - $lastChangeTime).TotalSeconds -ge $config.debounceSeconds) {
                        
                        $success = Invoke-CommitAndPush -Config $config
                        
                        if ($success) {
                            $lastChangeTime = $null
                            $lastStatus = ""
                        } else {
                            $lastChangeTime = Get-Date
                        }
                    }
                } else {
                    $lastChangeTime = $null
                    $lastStatus = ""
                }
            } else {
                Write-Log "$(Get-Message 'gitStatusFailed'): $($statusResult.Error)" "ERROR"
            }
            
            Start-Sleep -Seconds $config.pollingInterval
        }
    } catch {
        Write-Log "$(Get-Message 'unexpectedError'): $_" "ERROR"
        Write-Log $_.ScriptStackTrace "ERROR"
    } finally {
        Write-Log (Get-Message "scriptExiting") "INFO"
        if (Test-Path $LockFile) {
            Remove-Item $LockFile -Force -ErrorAction SilentlyContinue
        }
    }
}

Main
