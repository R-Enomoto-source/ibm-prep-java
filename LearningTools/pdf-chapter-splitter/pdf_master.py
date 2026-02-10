"""
PDF Structure Master - PDFを章ごとに分割し、画像化してフォルダ整理するGUIアプリ
- 目次あり: 埋め込み目次を利用
- 目次なし: フォントサイズ解析で章を自動検出
- 出力: 分割PDF または 章フォルダ内の連番JPEG（ZIP）
起動: streamlit run pdf_master.py
"""
import streamlit as st
import fitz  # PyMuPDF
import io
import zipfile
import tempfile
import os
import shutil
from dataclasses import dataclass
from typing import List

try:
    import ocrmypdf
    OCR_AVAILABLE = shutil.which("tesseract") is not None
except (ImportError, AttributeError):
    OCR_AVAILABLE = False

# --- データ構造 ---
@dataclass
class ChapterInfo:
    title: str
    page_num: int
    level: int
    source: str
    selected: bool = True

# --- コアロジック ---
class PDFProcessor:
    def __init__(self, file_stream, filename):
        self.file_bytes = file_stream.read()
        self.filename = filename
        self.book_title = os.path.splitext(filename)[0]
        self.doc = fitz.open(stream=self.file_bytes, filetype="pdf")

    def run_ocr(self, language='jpn+eng') -> bool:
        if not OCR_AVAILABLE:
            return False
        with tempfile.TemporaryDirectory() as temp_dir:
            input_path = os.path.join(temp_dir, "input.pdf")
            output_path = os.path.join(temp_dir, "output.pdf")
            with open(input_path, "wb") as f:
                f.write(self.file_bytes)
            try:
                ocrmypdf.ocr(
                    input_path, output_path, language=language,
                    force_ocr=True, deskew=True, progress_bar=False
                )
                with open(output_path, "rb") as f:
                    self.file_bytes = f.read()
                self.doc.close()
                self.doc = fitz.open(stream=self.file_bytes, filetype="pdf")
                return True
            except Exception as e:
                st.error(f"OCR処理エラー: {e}")
                return False

    def get_existing_toc(self) -> List[ChapterInfo]:
        toc = self.doc.get_toc()
        chapters = []
        if toc:
            for item in toc:
                lvl, title, page = item
                if page > 0:
                    chapters.append(ChapterInfo(title=title, page_num=page, level=lvl, source="既存目次"))
        return chapters

    def detect_chapters_by_style(
        self,
        header_scale: float = 1.3,
        min_page_gap: int = 2,
        top_ratio: float = 0.5,
    ) -> List[ChapterInfo]:
        font_counts = {}
        sample_pages = range(min(20, len(self.doc)))
        for page_num in sample_pages:
            try:
                page = self.doc[page_num]
                blocks = page.get_text("dict")["blocks"]
                for b in blocks:
                    if "lines" in b:
                        for l in b["lines"]:
                            for s in l["spans"]:
                                size = round(s["size"], 1)
                                font = s["font"]
                                key = (size, font)
                                font_counts[key] = font_counts.get(key, 0) + len(s["text"].strip())
            except Exception:
                continue
        if not font_counts:
            return []
        body_style = max(font_counts, key=font_counts.get)
        body_size = body_style[0]
        min_header_size = body_size * header_scale
        candidates = []
        for page_index in range(len(self.doc)):
            page = self.doc[page_index]
            page_height = page.rect.height
            page_no = page_index + 1

            if candidates and (page_no - candidates[-1].page_num) < min_page_gap:
                continue

            blocks = page.get_text("dict")["blocks"]
            page_candidates = []
            for b in blocks:
                if "lines" in b:
                    for l in b["lines"]:
                        line_top = l.get("bbox", [0, 0, 0, 0])[1]
                        if line_top > page_height * top_ratio:
                            continue
                        for s in l["spans"]:
                            text = s["text"].strip()
                            if 1 < len(text) < 60 and s["size"] >= min_header_size:
                                page_candidates.append(text)
            if page_candidates:
                title = " ".join(page_candidates[:1])
                candidates.append(ChapterInfo(title=title, page_num=page_no, level=1, source="自動検出"))
        return candidates

    def process_export(self, chapters: List[ChapterInfo], export_mode: str, img_zoom: float = 2.0) -> bytes:
        zip_buffer = io.BytesIO()
        sorted_chapters = sorted(chapters, key=lambda x: x.page_num)
        path_stack = []

        with zipfile.ZipFile(zip_buffer, "w", zipfile.ZIP_DEFLATED) as zf:
            for i, chapter in enumerate(sorted_chapters):
                start_page = chapter.page_num - 1
                if i == len(sorted_chapters) - 1:
                    end_page = len(self.doc)
                else:
                    end_page = sorted_chapters[i + 1].page_num - 1
                if start_page >= end_page:
                    continue

                while path_stack and path_stack[-1][0] >= chapter.level:
                    path_stack.pop()
                safe_title = "".join(c for c in chapter.title if c.isalnum() or c in (' ', '-', '_', '.', '(', ')')).strip()
                if not safe_title:
                    safe_title = f"Chapter_{i+1}"
                path_stack.append((chapter.level, safe_title))
                folder_parts = [self.book_title] + [p[1] for p in path_stack]

                if export_mode == "pdf":
                    filename = f"{path_stack[-1][1]}.pdf"
                    parent_folder_parts = [self.book_title] + [p[1] for p in path_stack[:-1]]
                    full_path = f"{'/'.join(parent_folder_parts)}/{filename}"
                    new_doc = fitz.open()
                    new_doc.insert_pdf(self.doc, from_page=start_page, to_page=end_page - 1)
                    zf.writestr(full_path, new_doc.tobytes())
                    new_doc.close()

                elif export_mode == "image":
                    current_folder = "/".join(folder_parts)
                    for p_idx in range(start_page, end_page):
                        page = self.doc[p_idx]
                        mat = fitz.Matrix(img_zoom, img_zoom)
                        pix = page.get_pixmap(matrix=mat)
                        img_data = pix.tobytes("jpg")
                        local_num = p_idx - start_page + 1
                        img_name = f"{local_num:03d}.jpg"
                        zf.writestr(f"{current_folder}/{img_name}", img_data)

        zip_buffer.seek(0)
        return zip_buffer.getvalue()


# --- Streamlit UI ---
st.set_page_config(page_title="PDF Structure Master", layout="wide", page_icon="📚")
st.title("📚 PDF Structure Master")
st.markdown("PDFを解析し、**章ごとのフォルダ構造**に再構築します。「分割PDF」または「連番画像（自炊用）」として出力可能です。")

with st.sidebar:
    st.header("⚙️ 設定・操作")
    st.subheader("1. OCR (文字認識)")
    if OCR_AVAILABLE:
        ocr_btn = st.button("🔍 OCRを実行 (スキャン画像用)")
    else:
        st.warning("⚠️ Tesseractが見つかりません。OCR機能は無効です。")
        ocr_btn = False
    st.divider()
    st.subheader("2. 出力モード")
    export_mode_radio = st.radio("形式を選択:", ["PDFとして分割", "画像(JPEG)フォルダ化"], index=1)
    img_zoom = 2.0
    if export_mode_radio == "画像(JPEG)フォルダ化":
        quality = st.select_slider("画質 (解像度)", options=["標準", "高画質", "超高画質"], value="高画質")
        if quality == "標準":
            img_zoom = 1.0
        elif quality == "高画質":
            img_zoom = 2.0
        else:
            img_zoom = 3.0

    st.subheader("3. 章検出のきめ細かさ (目次なし用)")
    sensitivity = st.select_slider(
        "自動検出の粒度",
        options=["細かい", "標準", "粗い"],
        value="標準",
        help="PDFに埋め込み目次がない場合に使用されます。『粗い』ほど少ない章にまとまります。",
    )
    header_scale = 1.3
    min_page_gap = 2
    if sensitivity == "細かい":
        header_scale = 1.1
        min_page_gap = 1
    elif sensitivity == "標準":
        header_scale = 1.3
        min_page_gap = 3
    else:
        header_scale = 1.5
        min_page_gap = 5
    st.session_state.header_scale = header_scale
    st.session_state.min_page_gap = min_page_gap

if 'processor' not in st.session_state:
    st.session_state.processor = None
if 'chapters' not in st.session_state:
    st.session_state.chapters = []
if 'ocr_done' not in st.session_state:
    st.session_state.ocr_done = False

uploaded_file = st.file_uploader("PDFファイルをここにドラッグ＆ドロップ", type=["pdf"])

if uploaded_file is not None:
    if st.session_state.processor is None or getattr(st.session_state, 'last_filename', '') != uploaded_file.name:
        with st.spinner("PDFを読み込んでいます..."):
            st.session_state.processor = PDFProcessor(uploaded_file, uploaded_file.name)
            st.session_state.last_filename = uploaded_file.name
            st.session_state.chapters = []
            st.session_state.ocr_done = False
            st.session_state.chapters = st.session_state.processor.get_existing_toc()
            if not st.session_state.chapters:
                header_scale = st.session_state.get("header_scale", 1.3)
                min_page_gap = st.session_state.get("min_page_gap", 2)
                st.session_state.chapters = st.session_state.processor.detect_chapters_by_style(
                    header_scale, min_page_gap
                )

    processor = st.session_state.processor

    if ocr_btn and not st.session_state.ocr_done:
        with st.spinner("OCR処理中... ページ数によっては数分かかります☕"):
            if processor.run_ocr():
                st.session_state.ocr_done = True
                header_scale = st.session_state.get("header_scale", 1.3)
                min_page_gap = st.session_state.get("min_page_gap", 2)
                st.session_state.chapters = processor.detect_chapters_by_style(header_scale, min_page_gap)
                st.success("OCR完了！テキスト情報を取得しました。")
                st.rerun()

    if not st.session_state.chapters:
        st.error("章の区切りが見つかりませんでした。OCRを実行するか、ファイルを確認してください。")
    else:
        st.subheader("🛠 フォルダ構成の編集")
        st.caption("『階層(Lv)』を調整すると、フォルダの入れ子構造を作成できます (Lv1=親フォルダ, Lv2=サブフォルダ...)。")
        if st.button("🔁 見出し自動検出をやり直す（目次なし用）"):
            header_scale = st.session_state.get("header_scale", 1.3)
            min_page_gap = st.session_state.get("min_page_gap", 2)
            st.session_state.chapters = processor.detect_chapters_by_style(header_scale, min_page_gap)
            st.success("現在の設定で見出しを再検出しました。")
            st.rerun()
        df_data = [
            {"Selected": c.selected, "Level": c.level, "Page": c.page_num, "Title": c.title, "Source": c.source}
            for c in st.session_state.chapters
        ]
        edited_df = st.data_editor(
            df_data,
            column_config={
                "Selected": st.column_config.CheckboxColumn("出力", width="small"),
                "Level": st.column_config.NumberColumn("階層 Lv", min_value=1, max_value=5, width="small"),
                "Page": st.column_config.NumberColumn("開始P", width="small"),
                "Title": st.column_config.TextColumn("フォルダ/ファイル名", width="large"),
                "Source": st.column_config.TextColumn("検出元", disabled=True, width="small"),
            },
            use_container_width=True,
            num_rows="dynamic",
            height=400,
        )

        export_label = "画像に変換して保存" if export_mode_radio == "画像(JPEG)フォルダ化" else "分割PDFを保存"
        if st.button(f"🚀 {export_label}", type="primary"):
            final_chapters = []
            for row in edited_df:
                if row["Selected"]:
                    final_chapters.append(ChapterInfo(
                        title=str(row["Title"]),
                        page_num=int(row["Page"]),
                        level=int(row["Level"]),
                        source="User"
                    ))
            if not final_chapters:
                st.warning("出力対象が選択されていません。")
            else:
                mode_str = "image" if export_mode_radio == "画像(JPEG)フォルダ化" else "pdf"
                with st.spinner("処理中... フォルダを作成し書き出しています..."):
                    try:
                        zip_bytes = processor.process_export(final_chapters, mode_str, img_zoom)
                        dl_name = f"{processor.book_title}_{mode_str}.zip"
                        st.balloons()
                        st.download_button(
                            label=f"📦 ZIPファイルをダウンロード ({dl_name})",
                            data=zip_bytes,
                            file_name=dl_name,
                            mime="application/zip",
                        )
                    except Exception as e:
                        st.error(f"書き出しエラー: {e}")
