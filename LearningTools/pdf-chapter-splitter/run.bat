@echo off
chcp 65001 >nul
cd /d "%~dp0"

echo PDF Structure Master を起動しています...
python -c "import streamlit; import fitz" 2>nul || (
    echo 依存パッケージをインストールしています...
    pip install -r requirements.txt
)

streamlit run pdf_master.py --server.headless true
pause
