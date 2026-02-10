# Auto-start setup script for Windows Task Scheduler
# Register a task to run auto-git-commit at logon (ASCII only to avoid encoding issues)

param(
    [switch]$Remove
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
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
    Write-Host "Removing task '$TaskName'..."
    try {
        $existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
        if ($existingTask) {
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
            Write-Host "Task removed." -ForegroundColor Green
        } else {
            Write-Host "Task not found." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Failed to remove task: $_" -ForegroundColor Red
        exit 1
    }
    exit 0
}

if (-not (Test-Administrator)) {
    Write-Host "Warning: Not running as Administrator. Running as current user." -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "Continue? (Y/N)"
    if ($continue -ne "Y" -and $continue -ne "y") { exit 0 }
}

if (-not (Test-Path $MainScript)) {
    Write-Host "Error: Main script not found: $MainScript" -ForegroundColor Red
    exit 1
}

Write-Host "Registering auto-start task..." -ForegroundColor Cyan
Write-Host "Task: $TaskName" -ForegroundColor Cyan
Write-Host "Script: $MainScript" -ForegroundColor Cyan
Write-Host ""

try {
    $existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($existingTask) {
        Write-Host "Removing existing task..." -ForegroundColor Yellow
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        Write-Host "Removed." -ForegroundColor Green
    }
} catch {
    Write-Host "Failed to remove existing task (continuing): $_" -ForegroundColor Yellow
}

Write-Host "Setting task action..." -ForegroundColor Cyan
$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$MainScript`"" `
    -WorkingDirectory $ScriptDir

Write-Host "Setting trigger (1 minute after logon)..." -ForegroundColor Cyan
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME -Delay (New-TimeSpan -Minutes 1)

Write-Host "Setting task options..." -ForegroundColor Cyan
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RestartCount 3 `
    -RestartInterval (New-TimeSpan -Minutes 1) `
    -ExecutionTimeLimit (New-TimeSpan -Hours 0) `
    -MultipleInstances IgnoreNew

Write-Host "Setting principal (current user)..." -ForegroundColor Cyan
$principal = New-ScheduledTaskPrincipal `
    -UserId "$env:USERDOMAIN\$env:USERNAME" `
    -LogonType Interactive `
    -RunLevel Limited

Write-Host "Registering task..." -ForegroundColor Cyan
try {
    Register-ScheduledTask -TaskName $TaskName `
        -Action $action `
        -Trigger $trigger `
        -Settings $settings `
        -Principal $principal `
        -Description "Auto git commit and push at logon" | Out-Null

    Write-Host ""
    Write-Host "Done. Task registered successfully." -ForegroundColor Green
    Write-Host ""
    Write-Host "  Task name: $TaskName" -ForegroundColor White
    Write-Host "  Trigger: 1 minute after logon" -ForegroundColor White
    Write-Host "  Script: $MainScript" -ForegroundColor White
    Write-Host ""
    Write-Host "Logs: $ScriptDir\.git-auto-commit\logs\ (log-yyyy-MM-dd.txt)" -ForegroundColor White
    Write-Host ""
    Write-Host "To remove task: .\setup-auto-start.ps1 -Remove" -ForegroundColor Yellow
    Write-Host ""

} catch {
    Write-Host ""
    Write-Host "Error: Failed to register task" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Try running PowerShell as Administrator and run this script again." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host "Verifying task..." -ForegroundColor Cyan
try {
    $registeredTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($registeredTask) {
        Write-Host "Task registered. State: $($registeredTask.State)" -ForegroundColor Green
    } else {
        Write-Host "Warning: Could not verify task." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Warning: $_" -ForegroundColor Yellow
}
