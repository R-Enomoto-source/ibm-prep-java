"""
PDFを画質を落とさずに画像化するアプリ

調査結果（RESEARCH.md）に基づく実装:
- PyMuPDF使用（追加のシステム依存なし）
- デフォルト 300 DPI（印刷・OCR品質）
- デフォルト PNG（可逆・劣化ゼロ）
- DPI・形式・ページ範囲をGUIで選択可能
- 日本語フォルダ名・ファイル名: NFKC正規化＋用語マップ＋オプションで python-slugify により安全な英数字名に変換（RESEARCH.md 7章）

起動: streamlit run pdf_to_image.py
"""
import io
import os
import re
import tempfile
import unicodedata
import zipfile
from pathlib import Path

import fitz  # PyMuPDF
import streamlit as st

# オプション: python-slugify があれば Unicode→読みやすいASCII（日本語はローマ字近似）に利用
try:
    from slugify import slugify as _slugify
    _HAS_SLUGIFY = True
except ImportError:
    _HAS_SLUGIFY = False

# Windows でファイル名に使えない文字（Microsoft Docs に基づく）
_WIN_FORBIDDEN_CHARS = re.compile(r'[\\/:*?"<>|\x00-\x1f]')

# 日本語の言い換え用語マップ（様々な書籍・フォルダ名に対応。RESEARCH.md 7章参照）
_JAPANESE_TO_ALNUM_PHRASES = [
    ("第", " "),
    ("章", " "),
    ("巻", " "),
    ("問題集", " questions "),
    ("解説", " explanation "),
    ("徹底攻略", " guide "),
    ("攻略", " guide "),
    ("対応", " edition "),
    ("黒本", " "),
    ("白本", " "),
    ("コピー", " copy "),
    ("複製", " copy "),
    ("上巻", " vol1 "),
    ("下巻", " vol2 "),
    ("志賀澄人", " "),
    ("　", " "),
]


def _to_safe_alnum_only(s: str) -> str:
    """英数字・ハイフン・アンダースコア以外を _ にし、連続 _ を1つにまとめる。"""
    s = re.sub(r"[^a-zA-Z0-9_\-]", "_", s)
    s = re.sub(r"_+", "_", s)
    return s.strip("_")


def to_short_alnum_name(original_name: str, max_length: int = 48) -> str:
    """
    様々な日本語を含むフォルダ名・ファイル名を、短く安全な英数字の名前に変換する。
    処理: NFKC正規化 → 章番号検出(chN) → 用語マップ → slugifyまたは英数字のみ抽出 → Windows禁止文字除去。
    """
    if not original_name or not original_name.strip():
        return "pdf"
    s = unicodedata.normalize("NFKC", original_name.strip())
    prefix = ""
    chapter_match = re.search(r"第?\s*(\d+)\s*章", s)
    if chapter_match:
        prefix = f"ch{chapter_match.group(1)}"
    for jp, en in _JAPANESE_TO_ALNUM_PHRASES:
        s = s.replace(jp, en)
    if _HAS_SLUGIFY:
        try:
            slug = _slugify(s, separator="_", lowercase=False, max_length=max_length)
            safe = _to_safe_alnum_only(slug)
        except Exception:
            safe = _to_safe_alnum_only(s)
    else:
        safe = _to_safe_alnum_only(s)
    if safe:
        parts = [p for p in safe.split("_") if len(p) > 0]
        if prefix and parts and parts[0].isdigit() and parts[0] == prefix.lstrip("ch"):
            parts = parts[1:]
        combined = "_".join(parts[:8]) if parts else ""
        if len(combined) > max_length:
            combined = combined[:max_length].rstrip("_")
    else:
        combined = ""
    if prefix:
        result = f"{prefix}_{combined}" if combined else prefix
    else:
        result = combined or "pdf"
    if len(result) > max_length:
        result = result[:max_length].rstrip("_")
    result = _WIN_FORBIDDEN_CHARS.sub("_", result)
    result = re.sub(r"_+", "_", result).strip("_")
    return result or "pdf"

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
            # フォルダ名・ファイル名用: アップロード時は元のファイル名、パス指定時は親フォルダ名も考慮
            if uploaded_file:
                base_name = Path(uploaded_file.name).stem
            else:
                p = Path(pdf_path_str)
                stem = p.stem
                parent_name = p.parent.name
                # 親フォルダ名に意味がある場合（日本語や章など）は含めて変換の材料にする
                if parent_name and parent_name not in (".", "local_data", "pdf_output", ""):
                    base_name = f"{parent_name}_{stem}"
                else:
                    base_name = stem

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

            # 保存用に短い英数字のベース名を生成（フォルダ名・ファイル名の文字化け・長さ対策）
            short_base = to_short_alnum_name(base_name)

            # 保存先に「PDF名を元にしたフォルダ」を作成し、その中に画像を保存
            save_dir_path = Path(save_dir).resolve() if save_dir.strip() else None
            if save_dir_path:
                output_folder_name = f"{short_base}_images"
                output_folder = save_dir_path / output_folder_name
                output_folder.mkdir(parents=True, exist_ok=True)
                for page_no, img_bytes in images_data:
                    fname = f"{short_base}_page_{page_no:04d}.{ext}"
                    out_path = output_folder / fname
                    out_path.write_bytes(img_bytes)
                st.success(f"フォルダに保存しました: **{output_folder}**")

            # ZIPでダウンロード（ZIP内のファイル名も短い英数字に統一）
            zip_buffer = io.BytesIO()
            with zipfile.ZipFile(zip_buffer, "w", zipfile.ZIP_DEFLATED) as zf:
                for page_no, img_bytes in images_data:
                    name = f"{short_base}_page_{page_no:04d}.{ext}"
                    zf.writestr(name, img_bytes)

            zip_buffer.seek(0)
            st.download_button(
                label=f"📥 画像をZIPでダウンロード ({num_pages}枚)",
                data=zip_buffer,
                file_name=f"{short_base}_images_{dpi}dpi.{ext}.zip",
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
st.sidebar.caption("日本語→安全なファイル名: NFKC＋用語マップ。より自然な変換は pip install python-slugify で有効化")
