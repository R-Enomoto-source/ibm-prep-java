@echo off
cd /d "%~dp0"
python -m streamlit run pdf_to_image.py --server.headless true
pause
