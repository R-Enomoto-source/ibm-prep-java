# PDF Structure Master 起動スクリプト
# 使い方: .\run.ps1  または  PowerShell で実行
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

# 依存関係の簡易チェック
try {
    $null = python -c "import streamlit; import fitz"
} catch {
    Write-Host "依存パッケージをインストールしています..." -ForegroundColor Yellow
    pip install -r requirements.txt
}

Write-Host "PDF Structure Master を起動しています..." -ForegroundColor Green
Write-Host "ブラウザが開いたら PDF をアップロードしてください。" -ForegroundColor Cyan
streamlit run pdf_master.py --server.headless $true
