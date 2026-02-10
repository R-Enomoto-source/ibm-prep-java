# 自動起動設定スクリプト
# Windowsタスクスケジューラに自動起動タスクを登録します
# 管理者権限で実行することを推奨します
# ※ 日本語表示のため UTF-8 BOM で保存しています。エディタで編集後は「UTF-8 with BOM」で再保存してください。

param(
    [switch]$Remove
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
# Find repo root (directory containing .git) so script works from LearningTools/auto-git-commit/
$RepoRoot = $ScriptDir
while ($RepoRoot) {
    if (Test-Path (Join-Path $RepoRoot ".git")) { break }
    $parent = Split-Path -Parent $RepoRoot
    if (-not $parent -or $parent -eq $RepoRoot) { $RepoRoot = Split-Path -Parent $ScriptDir; break }
    $RepoRoot = $parent
}
$MainScript = Join-Path $ScriptDir "auto-git-commit.ps1"
$TaskName = "Auto Git Commit"

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

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

if (-not (Test-Administrator)) {
    Write-Host "警告: 管理者権限で実行していません。管理者での実行を推奨します。" -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "続行しますか? (Y/N)"
    if ($continue -ne "Y" -and $continue -ne "y") { exit 0 }
}

if (-not (Test-Path $MainScript)) {
    Write-Host "エラー: メインスクリプトが見つかりません: $MainScript" -ForegroundColor Red
    exit 1
}

Write-Host "自動起動設定を開始します..." -ForegroundColor Cyan
Write-Host "タスク名: $TaskName" -ForegroundColor Cyan
Write-Host "スクリプト: $MainScript" -ForegroundColor Cyan
Write-Host ""

try {
    $existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($existingTask) {
        Write-Host "既存のタスクを削除します..." -ForegroundColor Yellow
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        Write-Host "削除しました。" -ForegroundColor Green
    }
} catch {
    Write-Host "既存タスクの削除に失敗しました（続行します）: $_" -ForegroundColor Yellow
}

Write-Host "タスクのアクションを設定します..." -ForegroundColor Cyan
$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$MainScript`"" `
    -WorkingDirectory $ScriptDir

Write-Host "トリガーを設定します（ログオンから1分後）..." -ForegroundColor Cyan
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME -Delay (New-TimeSpan -Minutes 1)

Write-Host "タスクの設定を定義します..." -ForegroundColor Cyan
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RestartCount 3 `
    -RestartInterval (New-TimeSpan -Minutes 1) `
    -ExecutionTimeLimit (New-TimeSpan -Hours 0) `
    -MultipleInstances IgnoreNew

Write-Host "実行権限を設定します（通常ユーザー）..." -ForegroundColor Cyan
$principal = New-ScheduledTaskPrincipal `
    -UserId "$env:USERDOMAIN\$env:USERNAME" `
    -LogonType Interactive `
    -RunLevel Limited

Write-Host "タスクを登録します..." -ForegroundColor Cyan
try {
    Register-ScheduledTask -TaskName $TaskName `
        -Action $action `
        -Trigger $trigger `
        -Settings $settings `
        -Principal $principal `
        -Description "ログオン時に自動でgitコミット・プッシュを実行" | Out-Null

    Write-Host ""
    Write-Host "自動起動設定が完了しました。" -ForegroundColor Green
    Write-Host ""
    Write-Host "  - タスク名: $TaskName" -ForegroundColor White
    Write-Host "  - 実行タイミング: ログオン時" -ForegroundColor White
    Write-Host "  - スクリプト: $MainScript" -ForegroundColor White
    Write-Host ""
    Write-Host "次回ログオン時（またはログオフして再ログオン）で、自動でスクリプトが開始されます。" -ForegroundColor Cyan
    Write-Host "ログフォルダ: $ScriptDir\.git-auto-commit\logs\ （日ごとに log-yyyy-MM-dd.txt）" -ForegroundColor White
    Write-Host ""
    Write-Host "タスクを削除する場合: .\setup-auto-start.ps1 -Remove" -ForegroundColor Yellow
    Write-Host ""

} catch {
    Write-Host ""
    Write-Host "エラー: タスクの登録に失敗しました" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "管理者権限でPowerShellを開いて再実行してください。" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host "登録されたタスクを確認しています..." -ForegroundColor Cyan
try {
    $registeredTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($registeredTask) {
        Write-Host "タスクが正常に登録されました。状態: $($registeredTask.State)" -ForegroundColor Green
    } else {
        Write-Host "警告: タスクの確認に失敗しました。" -ForegroundColor Yellow
    }
} catch {
    Write-Host "警告: $_" -ForegroundColor Yellow
}
