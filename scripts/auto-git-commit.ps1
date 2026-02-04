# 自動Gitコミット・プッシュスクリプト
# PC起動時に自動実行され、ファイル変更を監視して自動でコミット・プッシュします

param(
    [string]$ConfigPath = "config.json"
)

$ErrorActionPreference = "Stop"

# スクリプトのディレクトリを取得
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$ConfigFile = Join-Path $ScriptDir $ConfigPath
$TempDir = Join-Path $RepoRoot ".git-auto-commit"
$LogFile = Join-Path $TempDir "log.txt"
$CommitMessageFile = Join-Path $TempDir "commit-message.txt"
$LastStatusFile = Join-Path $TempDir "last-status.txt"
$LastCommitTimeFile = Join-Path $TempDir "last-commit-time.txt"
$LockFile = Join-Path $TempDir "lock.pid"

# ログ関数
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # コンソールに出力（バックグラウンド実行時は見えないが、ログに記録）
    Write-Host $logMessage
    
    # ログファイルに書き込み
    try {
        # ログファイルのディレクトリが存在しない場合は作成
        $logDir = Split-Path -Parent $LogFile
        if (-not (Test-Path $logDir)) {
            New-Item -ItemType Directory -Path $logDir -Force | Out-Null
        }
        Add-Content -Path $LogFile -Value $logMessage -Encoding UTF8 -ErrorAction SilentlyContinue
    } catch {
        # ログファイルへの書き込みに失敗しても続行
    }
}

# 設定ファイルの読み込み
function Get-Config {
    if (Test-Path $ConfigFile) {
        try {
            $config = Get-Content $ConfigFile -Raw | ConvertFrom-Json
            return $config
        } catch {
            Write-Log "設定ファイルの読み込みに失敗しました。デフォルト設定を使用します。" "WARN"
        }
    }
    
    # デフォルト設定
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

# アクティブ時間のチェック
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
        # 日をまたぐ場合（例: 22:00-08:00）
        return ($currentTime -ge $startTime -or $currentTime -le $endTime)
    }
}

# git操作の実行
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

# コミットメッセージの生成
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
    
    # フォールバック: シンプルなメッセージ
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    return "Auto commit: $timestamp"
}

# コミット・プッシュの実行
function Invoke-CommitAndPush {
    param($Config)
    
    # アクティブ時間のチェック
    if (-not (Test-ActiveHours -Config $Config)) {
        Write-Log "アクティブ時間外のため、コミットをスキップします" "INFO"
        return $false
    }
    
    # git statusをチェック
    $statusResult = Invoke-GitCommand "status --porcelain"
    if (-not $statusResult.Success) {
        Write-Log "git statusの実行に失敗しました: $($statusResult.Error)" "ERROR"
        return $false
    }
    
    $statusOutput = $statusResult.Output -join "`n"
    
    # 変更がない場合
    if (-not $statusOutput -or $statusOutput.Trim() -eq "") {
        return $false
    }
    
    # 前回のstatusと比較（同じ場合はスキップ）
    $lastStatus = ""
    if (Test-Path $LastStatusFile) {
        $lastStatus = Get-Content $LastStatusFile -Raw -ErrorAction SilentlyContinue
    }
    
    if ($statusOutput -eq $lastStatus) {
        Write-Log "変更内容が前回と同じため、スキップします" "INFO"
        return $false
    }
    
    # 変更ファイル数をカウント
    $changeCount = ($statusOutput -split "`n" | Where-Object { $_.Trim() -ne "" }).Count
    
    if ($changeCount -lt $Config.minChangeCount) {
        Write-Log "変更ファイル数が最小値未満のため、スキップします ($changeCount が $($Config.minChangeCount) 未満)" "INFO"
        return $false
    }
    
    Write-Log "変更を検出しました ($changeCount ファイル)。コミット・プッシュを実行します。" "INFO"
    
    # コミットメッセージを生成
    $commitMessage = Get-CommitMessage
    if (-not $commitMessage) {
        Write-Log "コミットメッセージの生成に失敗しました" "ERROR"
        return $false
    }
    
    # コミットメッセージを一時ファイルに保存
    $commitMessage | Out-File -FilePath $CommitMessageFile -Encoding UTF8 -Force
    
    # git add
    Write-Log "git add . を実行中..." "INFO"
    $addResult = Invoke-GitCommand "add ." -RetryCount $Config.retryAttempts -RetryDelay $Config.retryDelaySeconds
    if (-not $addResult.Success) {
        Write-Log "git add に失敗しました: $($addResult.Error)" "ERROR"
        return $false
    }
    
    # git commit
    Write-Log "git commit を実行中..." "INFO"
    $commitResult = Invoke-GitCommand "commit -F `"$CommitMessageFile`"" -RetryCount $Config.retryAttempts -RetryDelay $Config.retryDelaySeconds
    if (-not $commitResult.Success) {
        Write-Log "git commit に失敗しました: $($commitResult.Error)" "ERROR"
        return $false
    }
    
    # git push
    Write-Log "git push origin $($Config.branchName) を実行中..." "INFO"
    $pushResult = Invoke-GitCommand "push origin $($Config.branchName)" -RetryCount $Config.retryAttempts -RetryDelay $Config.retryDelaySeconds
    if (-not $pushResult.Success) {
        Write-Log "git push に失敗しました: $($pushResult.Error)" "ERROR"
        return $false
    }
    
    # 成功時の処理
    Write-Log "コミット・プッシュが完了しました" "INFO"
    
    # 最後のstatusを保存
    $statusOutput | Out-File -FilePath $LastStatusFile -Encoding UTF8 -Force
    
    # 最後のコミット時刻を保存
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") | Out-File -FilePath $LastCommitTimeFile -Encoding UTF8 -Force
    
    return $true
}

# メイン処理
function Main {
    Write-Log "自動Gitコミット・プッシュスクリプトを開始します" "INFO"
    Write-Log "リポジトリパス: $RepoRoot" "INFO"
    
    # 既に実行中のインスタンスをチェック（ロックファイル方式）
    if (Test-Path $LockFile) {
        try {
            $lockPid = Get-Content $LockFile -ErrorAction SilentlyContinue
            if ($lockPid) {
                $lockProcess = Get-Process -Id $lockPid -ErrorAction SilentlyContinue
                if ($lockProcess) {
                    Write-Log "既に実行中のインスタンスがあります（PID: $lockPid）。終了します。" "WARN"
                    exit 0
                } else {
                    # プロセスが存在しない場合は古いロックファイルを削除
                    Remove-Item $LockFile -Force -ErrorAction SilentlyContinue
                }
            }
        } catch {
            # ロックファイルの読み込みに失敗した場合は無視
        }
    }
    
    # ロックファイルを作成
    $PID | Out-File -FilePath $LockFile -Encoding ASCII -Force
    
    # 設定を読み込み
    $config = Get-Config
    Write-Log "設定を読み込みました (ポーリング間隔: $($config.pollingInterval)秒, デバウンス: $($config.debounceSeconds)秒)" "INFO"
    
    # デバウンス用の変数
    $lastChangeTime = $null
    $lastStatus = ""
    
    # 終了処理の登録
    Register-EngineEvent PowerShell.Exiting -Action {
        Write-Log "スクリプトを終了します（PCシャットダウン/再起動）" "INFO"
    } | Out-Null
    
    # シグナルハンドラ（Ctrl+C）
    try {
        [Console]::TreatControlCAsInput = $false
    } catch {
        # 無視（バックグラウンド実行時は利用できない）
    }
    
    # メインループ
    try {
        while ($true) {
            # git statusをチェック
            $statusResult = Invoke-GitCommand "status --porcelain"
            
            if ($statusResult.Success) {
                $currentStatus = $statusResult.Output -join "`n"
                
                # 変更がある場合
                if ($currentStatus -and $currentStatus.Trim() -ne "") {
                    # 前回のstatusと異なる場合
                    if ($currentStatus -ne $lastStatus) {
                        Write-Log "変更を検出しました" "INFO"
                        $lastChangeTime = Get-Date
                        $lastStatus = $currentStatus
                    }
                    
                    # デバウンス時間が経過しているかチェック
                    if ($lastChangeTime -and 
                        ((Get-Date) - $lastChangeTime).TotalSeconds -ge $config.debounceSeconds) {
                        
                        # コミット・プッシュを実行
                        $success = Invoke-CommitAndPush -Config $config
                        
                        if ($success) {
                            $lastChangeTime = $null
                            $lastStatus = ""
                        } else {
                            # 失敗した場合、次回のチェックで再試行
                            $lastChangeTime = Get-Date
                        }
                    }
                } else {
                    # 変更がない場合
                    $lastChangeTime = $null
                    $lastStatus = ""
                }
            } else {
                Write-Log "git statusの実行に失敗しました: $($statusResult.Error)" "ERROR"
            }
            
            # ポーリング間隔だけ待機
            Start-Sleep -Seconds $config.pollingInterval
        }
    } catch {
        Write-Log "予期しないエラーが発生しました: $_" "ERROR"
        Write-Log $_.ScriptStackTrace "ERROR"
    } finally {
        Write-Log "スクリプトを終了します" "INFO"
        # ロックファイルを削除
        if (Test-Path $LockFile) {
            Remove-Item $LockFile -Force -ErrorAction SilentlyContinue
        }
    }
}

# スクリプトの実行
Main
