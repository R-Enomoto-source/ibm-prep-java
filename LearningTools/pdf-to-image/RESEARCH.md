# PDFを画質を落とさずに画像化する方法 - 調査まとめ

## 1. 調査概要

PDFを高画質で画像化するための最良の方法を、インターネット調査および公式ドキュメントに基づきまとめました。

---

## 2. 主要ツールの比較

| ツール | 特徴 | 画質 | 依存関係 | 推奨度 |
|--------|------|------|----------|--------|
| **PyMuPDF (fitz)** | 軽量・高速・高画質 | ◎ | なし（純Python依存） | ★★★★★ |
| pdf2image | pdftoppm/pdftocairo ラッパー | ◎ | Poppler必須 | ★★★★ |
| ImageMagick/Wand | 細かい制御可能 | ○ | ImageMagick必須 | ★★★ |

**結論**: **PyMuPDF** を採用。既存の pdf-chapter-splitter と技術スタックを統一でき、追加のシステム依存が不要。

---

## 3. 画質を落とさないためのポイント

### 3.1 解像度（DPI）

| 用途 | 推奨DPI | 備考 |
|------|---------|------|
| 印刷・高品位 | **300 DPI** | 印刷業界標準 |
| OCR・テキスト認識 | **300 DPI** 以上 | 文字のエッジが鮮明に |
| 画面表示・Web | 150〜200 DPI | ファイルサイズと品質のバランス |
| 最低限 | 72 DPI | PDFのデフォルト（画質低下の原因） |

**重要**: PDFのデフォルトレンダリングは72 DPI。これが画質低下の主因。300 DPI以上を指定することで、スクリーンショット以上の鮮明さが得られる。

### 3.2 画像形式

| 形式 | 特徴 | 推奨用途 |
|------|------|----------|
| **PNG** | 非圧縮・可逆・文字・線画に最適 | **文書・図表・テキスト中心のPDF** |
| JPEG | 可逆圧縮・ファイルサイズ小 | 写真中心のPDF、容量を抑えたい場合 |
| TIFF | 高品質・大容量 | 専門用途 |

**結論**: **PNGをデフォルト**とする。画質劣化ゼロ。JPEGは容量削減が必要な場合に quality=95 以上で使用。

### 3.3 PyMuPDFでの実装方法

**デフォルト**: 72 DPI でレンダリングされる。

**高解像度化**: 変換行列（Matrix）でズーム係数を指定。

```python
# 300 DPI を得るには
zoom = 300 / 72  # ≈ 4.17
mat = fitz.Matrix(zoom, zoom)
pix = page.get_pixmap(matrix=mat)
```

**DPIメタデータの埋め込み**（オプション）:
```python
pix.set_dpi(300, 300)
pix.save(output_path)
```

**JPEG品質指定**（JPEG使用時）:
```python
pix.save(output_path, jpg_quality=95)
```

**透明部分の保持**（PNG、図形・ロゴ等）:
```python
pix = page.get_pixmap(alpha=True)
```

---

## 4. 公式・信頼ソースからの引用

### Artifex (PyMuPDF公式ブログ)

- PyMuPDFは複雑なPDF（フォント、画像、ベクター図形）を高品質に処理できる
- `get_pixmap(matrix=Matrix(zoom, zoom))` による高解像度化が推奨
- zoom=2.0 で約144 DPI相当

### Stack Overflow / コミュニティ

- 300 DPI = zoom 300/72
- `set_dpi()` で画像メタデータにDPIを埋め込める
- 高解像度は最初から指定することが重要（後から拡大しても情報は復元できない）

### 日本語資料

- 印刷用は300 DPI以上を推奨
- PNGはテキスト・線画の劣化が少ない
- スクリーンショットは元データを活用しないため画質低下しやすい

---

## 5. 本アプリでの採用方針

| 項目 | 採用値 | 理由 |
|------|--------|------|
| エンジン | PyMuPDF (fitz) | 既存ツールとの統一、追加依存なし |
| デフォルトDPI | **300** | 画質劣化なしの基準値 |
| デフォルト形式 | **PNG** | 可逆・劣化ゼロ |
| オプション | DPI選択、PNG/JPEG切替、ページ範囲 | 用途に応じた柔軟性 |
| GUI | Streamlit | 既存 pdf-chapter-splitter と同様 |

---

## 6. 参考文献

- [Artifex: Converting PDFs to Images with PyMuPDF](https://artifex.com/blog/converting-pdfs-to-images-with-pymupdf-a-complete-guide)
- [Stack Overflow: PDF to JPG highest quality Python](https://stackoverflow.com/questions/71303643/how-to-convert-a-pdf-to-a-jpg-png-in-python-with-the-highest-possible-quality)
- [Stack Overflow: PyMuPDF 300 DPI](https://stackoverflow.com/questions/69415164/pymupdf-how-to-convert-pdf-to-image-using-the-original-document-settings-for)
- [PyMuPDF Documentation](https://pymupdf.readthedocs.io/)
- 本リポジトリ: `docs/PDF_CHAPTER_SPLIT_IMAGE_APP_GUIDE.md`
