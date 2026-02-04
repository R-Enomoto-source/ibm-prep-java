# 自動Gitコミット・プッシュスクリプト
# PC起動時に自動実行され、ファイル変更を監視して自動でコミット・プッシュします

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
            Write-Log "設定ファイルの読み込みに失敗しました。デフォルト設定を使用します。" "WARN"
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
                throw "git $Command が失敗しました (終了コード: $exitCode): $output"
            }
        } catch {
            $attempt++
            if ($attempt -ge $RetryCount) {
                return @{ Success = $false; Error = $_.Exception.Message }
            }
            Write-Log "リトライ $attempt/${RetryCount}: $_" "WARN"
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
            Write-Log "コミットメッセージ生成に失敗しました: $_" "ERROR"
        }
    }
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    return "Auto commit: $timestamp"
}

function Invoke-CommitAndPush {
    param($Config)
    
    if (-not (Test-ActiveHours -Config $Config)) {
        Write-Log "アクティブ時間外のため、コミットをスキップします" "INFO"
        return $false
    }
    
    $statusResult = Invoke-GitCommand "status --porcelain"
    if (-not $statusResult.Success) {
        Write-Log "git statusの実行に失敗しました: $($statusResult.Error)" "ERROR"
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
        Write-Log "変更内容が前回と同じため、スキップします" "INFO"
        return $false
    }
    
    $changeCount = ($statusOutput -split "`n" | Where-Object { $_.Trim() -ne "" }).Count
    
    if ($changeCount -lt $Config.minChangeCount) {
        Write-Log "変更ファイル数が最小値未満のため、スキップします ($changeCount が $($Config.minChangeCount) 未満)" "INFO"
        return $false
    }
    
    Write-Log "変更を検出しました ($changeCount ファイル)。コミット・プッシュを実行します。" "INFO"
    
    $commitMessage = Get-CommitMessage
    if (-not $commitMessage) {
        Write-Log "コミットメッセージの生成に失敗しました" "ERROR"
        return $false
    }
    
    $commitMessage | Out-File -FilePath $CommitMessageFile -Encoding UTF8 -Force
    
    Write-Log "git add . を実行中..." "INFO"
    $addResult = Invoke-GitCommand "add ." -RetryCount $Config.retryAttempts -RetryDelay $Config.retryDelaySeconds
    if (-not $addResult.Success) {
        Write-Log "git add に失敗しました: $($addResult.Error)" "ERROR"
        return $false
    }
    
    Write-Log "git commit を実行中..." "INFO"
    $commitResult = Invoke-GitCommand "commit -F `"$CommitMessageFile`"" -RetryCount $Config.retryAttempts -RetryDelay $Config.retryDelaySeconds
    if (-not $commitResult.Success) {
        Write-Log "git commit に失敗しました: $($commitResult.Error)" "ERROR"
        return $false
    }
    
    Write-Log "git push origin $($Config.branchName) を実行中..." "INFO"
    $pushResult = Invoke-GitCommand "push origin $($Config.branchName)" -RetryCount $Config.retryAttempts -RetryDelay $Config.retryDelaySeconds
    if (-not $pushResult.Success) {
        Write-Log "git push に失敗しました: $($pushResult.Error)" "ERROR"
        return $false
    }
    
    Write-Log "コミット・プッシュが完了しました" "INFO"
    
    $statusOutput | Out-File -FilePath $LastStatusFile -Encoding UTF8 -Force
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") | Out-File -FilePath $LastCommitTimeFile -Encoding UTF8 -Force
    
    return $true
}

function Main {
    Write-Log "自動Gitコミット・プッシュスクリプトを開始します" "INFO"
    Write-Log "リポジトリパス: $RepoRoot" "INFO"
    
    if (Test-Path $LockFile) {
        try {
            $lockPid = Get-Content $LockFile -ErrorAction SilentlyContinue
            if ($lockPid) {
                $lockProcess = Get-Process -Id $lockPid -ErrorAction SilentlyContinue
                if ($lockProcess) {
                    Write-Log "既に実行中のインスタンスがあります（PID: $lockPid）。終了します。" "WARN"
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
    Write-Log "設定を読み込みました (ポーリング間隔: $($config.pollingInterval)秒, デバウンス: $($config.debounceSeconds)秒)" "INFO"
    
    $lastChangeTime = $null
    $lastStatus = ""
    
    Register-EngineEvent PowerShell.Exiting -Action {
        Write-Log "スクリプトを終了します（PCシャットダウン/再起動）" "INFO"
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
                        Write-Log "変更を検出しました" "INFO"
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
                Write-Log "git statusの実行に失敗しました: $($statusResult.Error)" "ERROR"
            }
            
            Start-Sleep -Seconds $config.pollingInterval
        }
    } catch {
        Write-Log "予期しないエラーが発生しました: $_" "ERROR"
        Write-Log $_.ScriptStackTrace "ERROR"
    } finally {
        Write-Log "スクリプトを終了します" "INFO"
        if (Test-Path $LockFile) {
            Remove-Item $LockFile -Force -ErrorAction SilentlyContinue
        }
    }
}

Main
