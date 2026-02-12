@echo off
cd /d "%~dp0"
chcp 65001 >nul
echo PDF→画像アプリを起動しています...
echo.

REM Windowsでは py ランチャーを優先（ダブルクリック時も動きやすい）
where py >nul 2>&1
if %errorlevel% equ 0 (
    py -m streamlit run pdf_to_image.py --server.headless true
    goto :done
)
where python >nul 2>&1
if %errorlevel% equ 0 (
    python -m streamlit run pdf_to_image.py --server.headless true
    goto :done
)

echo [エラー] Python が見つかりません。
echo.
echo 対処法:
echo   1. PowerShell または コマンドプロンプト を「開く」で起動し、
echo      cd %~dp0
echo      streamlit run pdf_to_image.py
echo   2. または Python をインストールし、インストール時に
echo      「Add Python to PATH」にチェックを入れてから再度お試しください。
echo.
pause
exit /b 1

:done
if %errorlevel% neq 0 (
    echo.
    echo 起動中にエラーが発生しました。上のメッセージを確認してください。
)
echo.
pause
