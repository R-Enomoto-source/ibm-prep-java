# Auto Git Commit Push Script
# Runs at PC startup, monitors file changes and auto commit/push

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
            Write-Log "Failed to load config file. Using defaults." "WARN"
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
        [int]$RetryDelay = 5
    )
    
    $attempt = 0
    while ($attempt -lt $RetryCount) {
        try {
            Push-Location $RepoRoot
            $output = Invoke-Expression "git $Command" 2>&1
            $exitCode = $LASTEXITCODE
            
            if ($exitCode -eq 0) {
                return @{ Success = $true; Output = $output }
            } else {
                throw "git $Command failed (exit code: $exitCode): $output"
            }
        } catch {
            $attempt++
            if ($attempt -ge $RetryCount) {
                return @{ Success = $false; Error = $_.Exception.Message }
            }
            Write-Log "Retry $attempt/${RetryCount}: $_" "WARN"
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
            Write-Log "Failed to generate commit message: $_" "ERROR"
        }
    }
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    return "Auto commit: $timestamp"
}

function Invoke-CommitAndPush {
    param($Config)
    
    if (-not (Test-ActiveHours -Config $Config)) {
        Write-Log "Skipping commit (outside active hours)" "INFO"
        return $false
    }
    
    $statusResult = Invoke-GitCommand "status --porcelain"
    if (-not $statusResult.Success) {
        Write-Log "git status failed: $($statusResult.Error)" "ERROR"
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
        Write-Log "Skipping (same changes as last time)" "INFO"
        return $false
    }
    
    $changeCount = ($statusOutput -split "`n" | Where-Object { $_.Trim() -ne "" }).Count
    
    if ($changeCount -lt $Config.minChangeCount) {
        Write-Log "Skipping (change count $changeCount < $($Config.minChangeCount))" "INFO"
        return $false
    }
    
    Write-Log "Changes detected ($changeCount files). Running commit and push." "INFO"
    
    $commitMessage = Get-CommitMessage
    if (-not $commitMessage) {
        Write-Log "Failed to generate commit message" "ERROR"
        return $false
    }
    
    $commitMessage | Out-File -FilePath $CommitMessageFile -Encoding UTF8 -Force
    
    Write-Log "Running git add ." "INFO"
    $addResult = Invoke-GitCommand "add ." -RetryCount $Config.retryAttempts -RetryDelay $Config.retryDelaySeconds
    if (-not $addResult.Success) {
        Write-Log "git add failed: $($addResult.Error)" "ERROR"
        return $false
    }
    
    Write-Log "Running git commit" "INFO"
    $commitResult = Invoke-GitCommand "commit -F `"$CommitMessageFile`"" -RetryCount $Config.retryAttempts -RetryDelay $Config.retryDelaySeconds
    if (-not $commitResult.Success) {
        Write-Log "git commit failed: $($commitResult.Error)" "ERROR"
        return $false
    }
    
    Write-Log "Running git push origin $($Config.branchName)" "INFO"
    $pushResult = Invoke-GitCommand "push origin $($Config.branchName)" -RetryCount $Config.retryAttempts -RetryDelay $Config.retryDelaySeconds
    if (-not $pushResult.Success) {
        Write-Log "git push failed: $($pushResult.Error)" "ERROR"
        return $false
    }
    
    Write-Log "Commit and push completed" "INFO"
    
    $statusOutput | Out-File -FilePath $LastStatusFile -Encoding UTF8 -Force
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") | Out-File -FilePath $LastCommitTimeFile -Encoding UTF8 -Force
    
    return $true
}

function Main {
    Write-Log "Auto Git Commit script started" "INFO"
    Write-Log "Repo path: $RepoRoot" "INFO"
    
    if (Test-Path $LockFile) {
        try {
            $lockPid = Get-Content $LockFile -ErrorAction SilentlyContinue
            if ($lockPid) {
                $lockProcess = Get-Process -Id $lockPid -ErrorAction SilentlyContinue
                if ($lockProcess) {
                    Write-Log "Another instance running (PID: $lockPid). Exiting." "WARN"
                    exit 0
                } else {
                    Remove-Item $LockFile -Force -ErrorAction SilentlyContinue
                }
            }
        } catch {
        }
    }
    
    $PID | Out-File -FilePath $LockFile -Encoding ASCII -Force
    
    $config = Get-Config
    Write-Log "Config loaded (polling: $($config.pollingInterval)s, debounce: $($config.debounceSeconds)s)" "INFO"
    
    $lastChangeTime = $null
    $lastStatus = ""
    
    Register-EngineEvent PowerShell.Exiting -Action {
        Write-Log "Script exiting (shutdown/reboot)" "INFO"
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
                        Write-Log "Changes detected" "INFO"
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
                Write-Log "git status failed: $($statusResult.Error)" "ERROR"
            }
            
            Start-Sleep -Seconds $config.pollingInterval
        }
    } catch {
        Write-Log "Unexpected error: $_" "ERROR"
        Write-Log $_.ScriptStackTrace "ERROR"
    } finally {
        Write-Log "Script exiting" "INFO"
        if (Test-Path $LockFile) {
            Remove-Item $LockFile -Force -ErrorAction SilentlyContinue
        }
    }
}

Main
