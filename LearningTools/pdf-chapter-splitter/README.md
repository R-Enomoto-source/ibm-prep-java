# PDF Structure Master（章分割・画像化アプリ）

PDFを**章ごとに分割**し、**分割した範囲を画像（JPEG）に変換**して、本タイトル・章名のフォルダに整理するGUIアプリです。

## 機能

- **目次あり**: PDFの埋め込み目次（アウトライン）を利用して章を特定
- **目次なし**: フォントサイズ解析で「見出し」を自動検出
- **OCR**: スキャンPDFの場合はボタンでOCR（Tesseract）を実行してから解析
- **出力**: 「分割PDF」または「章フォルダ内の連番JPEG」をZIPでダウンロード
- **階層**: Level 1=章、Level 2=節 などでフォルダの入れ子を編集可能

## 必要な環境

- Python 3.9+
- **OCRを使う場合**: システムに [Tesseract](https://github.com/UB-Mannheim/tesseract/wiki) と Ghostscript をインストールし、PATH を通す

## セットアップ

```powershell
cd LearningTools\pdf-chapter-splitter
pip install -r requirements.txt
```

## 起動

**方法1（推奨）** — ダブルクリックまたはコマンドで起動:

- **run.bat** … ダブルクリック、または `run.bat` を実行（必要なときだけ依存関係をインストール）
- **run.ps1** … PowerShell で `.\run.ps1` を実行

**方法2** — 手動で起動:

```powershell
cd LearningTools\pdf-chapter-splitter
streamlit run pdf_master.py
```

ブラウザが開くので、PDFをアップロードして操作してください。

## 出力例（画像モード）

ZIPを解凍すると次のような構成になります。

```
[本のタイトル]/
  ├── 第1章 はじめに/
  │     ├── 001.jpg, 002.jpg, ...
  └── 第2章 実践編/
        ├── 第1節 準備/
        │     ├── 001.jpg, ...
        └── 第2節 実行/
              ├── 001.jpg, ...
```

## 詳細ガイド

プロジェクトルートの `docs/PDF_CHAPTER_SPLIT_IMAGE_APP_GUIDE.md` に、設計のまとめ・ネット調査に基づく最良の方法の根拠・拡張のヒントを記載しています。
