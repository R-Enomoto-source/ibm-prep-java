# 自動起動設定スクリプト
# Windowsタスクスケジューラに自動起動タスクを登録します
# 管理者権限で実行することを推奨します

param(
    [switch]$Remove
)

$ErrorActionPreference = "Stop"

# スクリプトのディレクトリを取得
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$MainScript = Join-Path $ScriptDir "auto-git-commit.ps1"
$TaskName = "Auto Git Commit"

# 管理者権限のチェック
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# タスクの削除
if ($Remove) {
    Write-Host "タスク '$TaskName' を削除します..."
    
    try {
        $existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
        if ($existingTask) {
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
            Write-Host "タスクを削除しました。" -ForegroundColor Green
        } else {
            Write-Host "タスクが見つかりませんでした。" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "タスクの削除に失敗しました: $_" -ForegroundColor Red
        exit 1
    }
    
    exit 0
}

# 管理者権限の確認
if (-not (Test-Administrator)) {
    Write-Host "警告: 管理者権限で実行していません。" -ForegroundColor Yellow
    Write-Host "管理者権限で実行することを推奨します。" -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "続行しますか？ (Y/N)"
    if ($continue -ne "Y" -and $continue -ne "y") {
        exit 0
    }
}

# メインスクリプトの存在確認
if (-not (Test-Path $MainScript)) {
    Write-Host "エラー: メインスクリプトが見つかりません: $MainScript" -ForegroundColor Red
    exit 1
}

Write-Host "自動起動設定を開始します..." -ForegroundColor Cyan
Write-Host "タスク名: $TaskName" -ForegroundColor Cyan
Write-Host "スクリプトパス: $MainScript" -ForegroundColor Cyan
Write-Host ""

# 既存のタスクを削除（存在する場合）
try {
    $existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($existingTask) {
        Write-Host "既存のタスクを削除します..." -ForegroundColor Yellow
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        Write-Host "既存のタスクを削除しました。" -ForegroundColor Green
    }
} catch {
    Write-Host "既存タスクの削除に失敗しました（新規作成を続行します）: $_" -ForegroundColor Yellow
}

# タスクのアクションを定義
Write-Host "タスクのアクションを設定します..." -ForegroundColor Cyan
$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$MainScript`"" `
    -WorkingDirectory $ScriptDir

# トリガーを定義（PC起動時）
Write-Host "トリガーを設定します（PC起動時）..." -ForegroundColor Cyan
$trigger = New-ScheduledTaskTrigger -AtStartup

# 設定を定義
Write-Host "タスクの設定を定義します..." -ForegroundColor Cyan
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RestartCount 3 `
    -RestartInterval (New-TimeSpan -Minutes 1) `
    -ExecutionTimeLimit (New-TimeSpan -Hours 0) `
    -MultipleInstances IgnoreNew

# プリンシパルを定義（最上位の特権で実行）
Write-Host "実行権限を設定します..." -ForegroundColor Cyan
$principal = New-ScheduledTaskPrincipal `
    -UserId "$env:USERDOMAIN\$env:USERNAME" `
    -LogonType Interactive `
    -RunLevel Highest

# タスクを登録
Write-Host "タスクを登録します..." -ForegroundColor Cyan
try {
    Register-ScheduledTask -TaskName $TaskName `
        -Action $action `
        -Trigger $trigger `
        -Settings $settings `
        -Principal $principal `
        -Description "PC起動時に自動でgitコミット・プッシュを実行" | Out-Null
    
    Write-Host ""
    Write-Host "自動起動設定が完了しました！" -ForegroundColor Green
    Write-Host ""
    Write-Host "設定内容:" -ForegroundColor Cyan
    Write-Host "  - タスク名: $TaskName" -ForegroundColor White
    Write-Host "  - 実行タイミング: PC起動時" -ForegroundColor White
    Write-Host "  - スクリプト: $MainScript" -ForegroundColor White
    Write-Host ""
    Write-Host "次のステップ:" -ForegroundColor Cyan
    Write-Host "  1. PCを再起動すると、自動でスクリプトが開始されます" -ForegroundColor White
    Write-Host "  2. タスクマネージャーで 'powershell.exe' プロセスを確認できます" -ForegroundColor White
    Write-Host "  3. ログファイル: $RepoRoot\.git-auto-commit\log.txt" -ForegroundColor White
    Write-Host ""
    Write-Host "タスクを削除する場合:" -ForegroundColor Yellow
    Write-Host "  .\setup-auto-start.ps1 -Remove" -ForegroundColor White
    Write-Host ""
    
} catch {
    Write-Host ""
    Write-Host "エラー: タスクの登録に失敗しました" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "対処方法:" -ForegroundColor Yellow
    Write-Host "  1. 管理者権限でPowerShellを開いて再実行してください" -ForegroundColor White
    Write-Host "  2. タスクスケジューラを手動で開いて設定してください" -ForegroundColor White
    Write-Host ""
    exit 1
}

# タスクの確認
Write-Host "登録されたタスクを確認します..." -ForegroundColor Cyan
try {
    $registeredTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($registeredTask) {
        Write-Host "タスクが正常に登録されました。" -ForegroundColor Green
        Write-Host "  状態: $($registeredTask.State)" -ForegroundColor White
    } else {
        Write-Host "警告: タスクの確認に失敗しました。" -ForegroundColor Yellow
    }
} catch {
    Write-Host "警告: タスクの確認中にエラーが発生しました: $_" -ForegroundColor Yellow
}
