@echo off
cd /d "%~dp0"
chcp 65001 >nul
echo PDF→画像アプリを起動しています...
echo.

set "PY="

REM 1. よくあるインストール先の python.exe を直接使う（ダブルクリックで確実に動く）
for %%V in (312 311 310 313 39 38) do (
    if exist "%LocalAppData%\Programs\Python\Python%%V\python.exe" (
        set "PY=%LocalAppData%\Programs\Python\Python%%V\python.exe"
        goto :found
    )
)
if exist "%ProgramFiles%\Python312\python.exe" set "PY=%ProgramFiles%\Python312\python.exe" & goto :found
if exist "%ProgramFiles%\Python311\python.exe" set "PY=%ProgramFiles%\Python311\python.exe" & goto :found

REM 2. PATH の python / py
where python >nul 2>&1
if %errorlevel% equ 0 ( set "PY=python" & goto :found )
where py >nul 2>&1
if %errorlevel% equ 0 ( set "PY=py" & goto :found )

echo [エラー] Python が見つかりません。
echo.
echo 対処: このフォルダで PowerShell を開き、次を実行してください。
echo   streamlit run pdf_to_image.py
echo.
pause
exit /b 1

:found
"%PY%" -m streamlit run pdf_to_image.py --server.headless true
set "EXIT_CODE=%errorlevel%"
if %EXIT_CODE% neq 0 (
    echo.
    echo 起動に失敗しました (終了コード %EXIT_CODE%)。
    echo 上記のメッセージを確認するか、PowerShell で streamlit run pdf_to_image.py を試してください。
)
echo.
pause
exit /b %EXIT_CODE%
