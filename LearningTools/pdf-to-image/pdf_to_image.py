"""
PDFを画質を落とさずに画像化するアプリ

調査結果（RESEARCH.md）に基づく実装:
- PyMuPDF使用（追加のシステム依存なし）
- デフォルト 300 DPI（印刷・OCR品質）
- デフォルト PNG（可逆・劣化ゼロ）
- DPI・形式・ページ範囲をGUIで選択可能

起動: streamlit run pdf_to_image.py
"""
import io
import os
import tempfile
import zipfile
from pathlib import Path

import fitz  # PyMuPDF
import streamlit as st

# ページ設定
st.set_page_config(
    page_title="PDF→画像 高画質変換",
    page_icon="🖼️",
    layout="centered",
)

st.title("PDF を高画質で画像化")
st.caption("画質を落とさずにPDFの各ページをPNG/JPEG画像に変換します。")

# サイドバー：設定
st.sidebar.header("設定")

# DPI選択
dpi_options = {
    "72 DPI（標準・軽量）": 72,
    "150 DPI（画面表示向け）": 150,
    "200 DPI（バランス）": 200,
    "300 DPI（印刷・OCR・推奨）": 300,
    "400 DPI（高品位）": 400,
}
dpi_label = st.sidebar.selectbox(
    "解像度（DPI）",
    options=list(dpi_options.keys()),
    index=3,  # 300 DPI をデフォルト
)
dpi = dpi_options[dpi_label]

# 画像形式
fmt = st.sidebar.radio(
    "出力形式",
    ["PNG（可逆・推奨）", "JPEG（軽量）"],
    index=0,
)
use_png = fmt.startswith("PNG")

if not use_png:
    jpg_quality = st.sidebar.slider("JPEG品質", 70, 100, 95)

# ページ範囲
page_range_mode = st.sidebar.radio(
    "ページ範囲",
    ["すべて", "指定範囲"],
    index=0,
)
page_start = 1
page_end = 9999
if page_range_mode == "指定範囲":
    col1, col2 = st.sidebar.columns(2)
    with col1:
        page_start = st.number_input("開始ページ", min_value=1, value=1)
    with col2:
        page_end = st.number_input("終了ページ", min_value=1, value=10)

# 保存先フォルダ
st.sidebar.divider()
st.sidebar.subheader("保存先")
base_dir = Path(__file__).resolve().parent.parent.parent
default_out = str(base_dir / "local_data" / "pdf_output")
save_dir = st.sidebar.text_input(
    "画像の保存先フォルダ",
    value=default_out,
    help="変換した画像を保存するフォルダ。存在しない場合は自動作成されます。",
)

# アップロード or パス指定
input_mode = st.radio(
    "入力方法",
    ["ファイルをアップロード", "フォルダ内のPDFを指定"],
    horizontal=True,
)

pdf_path = None
uploaded_file = None

if input_mode == "ファイルをアップロード":
    uploaded_file = st.file_uploader("PDFファイル", type=["pdf"])
    if uploaded_file:
        # 一時ファイルに保存
        with tempfile.NamedTemporaryFile(delete=False, suffix=".pdf") as tmp:
            tmp.write(uploaded_file.read())
            pdf_path = tmp.name

else:
    default_path = str(base_dir / "local_data")
    pdf_dir = st.text_input(
        "PDFが入っているフォルダパス",
        value=default_path,
    )
    if pdf_dir and Path(pdf_dir).exists():
        pdf_files = list(Path(pdf_dir).rglob("*.pdf"))
        if pdf_files:
            selected = st.selectbox(
                "PDFファイルを選択",
                [str(f) for f in pdf_files],
                format_func=lambda x: Path(x).name,
            )
            if selected:
                pdf_path = str(selected)  # 文字列に明示的に変換
        else:
            st.warning(f"フォルダ内にPDFが見つかりません: {pdf_dir}")

if pdf_path:
    try:
        # パスを文字列に変換（PyMuPDF の互換性のため）
        pdf_path_str = str(pdf_path)
        doc = fitz.open(pdf_path_str)
        total_pages = len(doc)

        st.success(f"PDFを読み込みました: **{total_pages}** ページ")

        page_end_val = min(page_end, total_pages) if page_range_mode == "指定範囲" else total_pages
        page_start_val = max(1, page_start) if page_range_mode == "指定範囲" else 1
        page_start_val = min(page_start_val, total_pages)

        pages_to_convert = range(page_start_val - 1, page_end_val)  # 0-indexed
        num_pages = len(pages_to_convert)

        st.info(f"変換対象: {num_pages} ページ（{page_start_val}〜{page_end_val}ページ目）")
        st.caption(f"解像度: {dpi} DPI / 形式: {'PNG' if use_png else 'JPEG'}")

        if st.button("画像に変換", type="primary"):
            zoom = dpi / 72.0
            mat = fitz.Matrix(zoom, zoom)
            ext = "png" if use_png else "jpg"
            # フォルダ名・ファイル名用: アップロード時は元のファイル名を使用
            base_name = Path(uploaded_file.name).stem if uploaded_file else Path(pdf_path_str).stem

            with st.spinner("変換中..."):
                images_data = []
                for i, page_idx in enumerate(pages_to_convert):
                    page = doc[page_idx]
                    pix = page.get_pixmap(matrix=mat, alpha=use_png)
                    try:
                        pix.set_dpi(dpi, dpi)
                    except AttributeError:
                        pass  # 一部バージョンでは未対応

                    # pix.save() はファイルパスを期待するため、tobytes() を使用
                    if use_png:
                        img_bytes = pix.tobytes("png")
                    else:
                        # JPEG の場合は一時ファイル経由で品質指定
                        with tempfile.NamedTemporaryFile(delete=False, suffix=".jpg") as tmp:
                            tmp_path = tmp.name
                        pix.save(tmp_path, output="jpg", jpg_quality=jpg_quality)
                        with open(tmp_path, "rb") as f:
                            img_bytes = f.read()
                        os.unlink(tmp_path)
                    images_data.append((page_idx + 1, img_bytes))

            doc.close()

            # 一時ファイルの削除（アップロード時）
            if uploaded_file and os.path.exists(pdf_path_str):
                try:
                    os.unlink(pdf_path_str)
                except Exception:
                    pass

            # 保存先に「PDF名を元にしたフォルダ」を作成し、その中に画像を保存
            save_dir_path = Path(save_dir).resolve() if save_dir.strip() else None
            if save_dir_path:
                # 画像化元のPDFファイル名を参考にした分かりやすいフォルダ名
                output_folder_name = f"{base_name}_images"
                output_folder = save_dir_path / output_folder_name
                output_folder.mkdir(parents=True, exist_ok=True)
                for page_no, img_bytes in images_data:
                    fname = f"{base_name}_page_{page_no:04d}.{ext}"
                    out_path = output_folder / fname
                    out_path.write_bytes(img_bytes)
                st.success(f"フォルダに保存しました: **{output_folder}**")

            # ZIPでダウンロード
            zip_buffer = io.BytesIO()
            with zipfile.ZipFile(zip_buffer, "w", zipfile.ZIP_DEFLATED) as zf:
                for page_no, img_bytes in images_data:
                    name = f"{base_name}_page_{page_no:04d}.{ext}"
                    zf.writestr(name, img_bytes)

            zip_buffer.seek(0)
            st.download_button(
                label=f"📥 画像をZIPでダウンロード ({num_pages}枚)",
                data=zip_buffer,
                file_name=f"{base_name}_images_{dpi}dpi.{ext}.zip",
                mime="application/zip",
            )

    except Exception as e:
        st.error(f"エラー: {e}")
        import traceback
        st.code(traceback.format_exc())
else:
    st.info("PDFファイルを選択してください。")

# フッター
st.sidebar.divider()
st.sidebar.caption("調査内容は RESEARCH.md を参照")
