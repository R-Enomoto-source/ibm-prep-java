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
import re
import platform
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import List


def notify_ocr_complete():
    """OCR完了時に通知を出す（デスクトップポップアップ・音）"""
    # デスクトップ通知（ブラウザ非表示でも画面 corner に表示）
    try:
        from plyer import notification
        notification.notify(
            title="PDF Structure Master",
            message="OCRが完了しました。",
            app_name="PDF Structure Master",
            timeout=10,
        )
    except Exception:
        pass
    # システム音で補足
    try:
        if platform.system() == "Windows":
            import winsound
            winsound.MessageBeep(winsound.MB_OK)
        elif platform.system() == "Darwin":
            subprocess.Popen(["afplay", "/System/Library/Sounds/Glass.aiff"], stderr=subprocess.DEVNULL)
    except Exception:
        pass

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


# さまざまな書籍で使われやすい「章タイトル」のパターン（グループ化）
CHAPTER_PATTERN_GROUPS = [
    {
        "id": "ja_chapter",
        "label": "日本語: 第1章 / 1章 / 第一章",
        "patterns": [
            re.compile(r"第?\s*[0-9０-９一二三四五六七八九十百千ⅠⅡⅢⅣⅤⅥⅦⅧⅨⅩ]+\s*章"),
            re.compile(r"[0-9０-９一二三四五六七八九十]+\s*章"),
        ],
    },
    {
        "id": "ja_part",
        "label": "日本語: 第1部 / 編 / 講 / 回",
        "patterns": [
            re.compile(r"第?\s*[0-9０-９一二三四五六七八九十]+\s*(部|編|講|回)"),
        ],
    },
    {
        "id": "en_chapter",
        "label": "英語: Chapter / CHAPTER / Chap.",
        "patterns": [
            re.compile(r"\bchapter\s+[0-9ivxlcdm]+\b", re.IGNORECASE),
            re.compile(r"\bchap\.\s*[0-9ivxlcdm]+\b", re.IGNORECASE),
        ],
    },
    {
        "id": "en_part_lesson",
        "label": "英語: Part / Lesson",
        "patterns": [
            re.compile(r"\bpart\s+[0-9ivxlcdm]+\b", re.IGNORECASE),
            re.compile(r"\blesson\s+[0-9ivxlcdm]+\b", re.IGNORECASE),
        ],
    },
    {
        "id": "eu_chapter",
        "label": "その他: Kapitel / Chapitre / Capítulo / Capitolo / Глава など",
        "patterns": [
            re.compile(
                r"\b(kapitel|chapitre|cap[ií]tulo|capitolo|capitulo|glava|глава)\s+[0-9ivxlcdm一二三四五六七八九十]+\b",
                re.IGNORECASE,
            ),
        ],
    },
]

# すべてのパターンを平坦化したリスト（デフォルト用）
CHAPTER_TITLE_REGEXES = [p for g in CHAPTER_PATTERN_GROUPS for p in g["patterns"]]

# 目次行のパターン（章パターンに加え、「1. はじめに」「1) はじめに」などにも対応）
TOC_ENTRY_PATTERNS = [
    re.compile(r"^\d+[\.\)]\s"),  # "1. " or "1) "
    re.compile(r"^\d+\s+[^\d]"),  # "1 はじめに" (数字+スペース+非数字)
] + CHAPTER_TITLE_REGEXES


def suggest_chapter_pattern_ids(chapters: List[ChapterInfo]) -> List[str]:
    """
    OCR などで検出した見出しタイトルから、
    どの章タイトルパターンが実際に使われていそうかを推定する。
    """
    if not chapters:
        return [g["id"] for g in CHAPTER_PATTERN_GROUPS]

    used_ids = set()
    for ch in chapters:
        title = (ch.title or "").strip()
        if not title:
            continue
        for g in CHAPTER_PATTERN_GROUPS:
            if any(pat.search(title) for pat in g["patterns"]):
                used_ids.add(g["id"])
    if not used_ids:
        return [g["id"] for g in CHAPTER_PATTERN_GROUPS]
    return sorted(used_ids)


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

    def _get_page_body_size(self, page) -> float | None:
        """ページ内の本文フォントサイズ（最頻出）を返す。"""
        font_counts = {}
        try:
            for b in page.get_text("dict").get("blocks", []):
                for line in b.get("lines", []):
                    for s in line.get("spans", []):
                        sz = round(s.get("size", 0), 1)
                        if sz > 0:
                            text_len = len((s.get("text") or "").strip())
                            font_counts[sz] = font_counts.get(sz, 0) + text_len
        except Exception:
            return None
        if not font_counts:
            return None
        return max(font_counts, key=font_counts.get)

    def _get_doc_body_size(self, max_pages: int = 20) -> float | None:
        """ドキュメント全体の本文フォントサイズ（最頻出）を返す。"""
        font_counts = {}
        for pi in range(min(max_pages, len(self.doc))):
            try:
                bs = self._get_page_body_size(self.doc[pi])
                if bs is not None:
                    font_counts[bs] = font_counts.get(bs, 0) + 1
            except Exception:
                continue
        return max(font_counts, key=font_counts.get) if font_counts else None

    def detect_chapters_by_style(
        self,
        header_scale: float = 1.3,
        min_page_gap: int = 2,
        top_ratio: float = 0.5,
        per_page_font: bool = True,
    ) -> List[ChapterInfo]:
        """
        フォントサイズ解析で見出しを検出。
        per_page_font=True のとき、各ページごとに本文サイズを推定し、
        そのページ内で「本文より大きい」テキストだけを見出し候補にする（ロバスト性向上）。
        """
        fallback_body = self._get_doc_body_size()
        if not per_page_font and fallback_body is None:
            return []

        candidates = []
        for page_index in range(len(self.doc)):
            page = self.doc[page_index]
            page_no = page_index + 1
            page_height = page.rect.height

            if candidates and (page_no - candidates[-1].page_num) < min_page_gap:
                continue

            body_size = self._get_page_body_size(page) if per_page_font else fallback_body
            if body_size is None:
                body_size = fallback_body
            if body_size is None:
                continue

            min_header_size = body_size * header_scale
            blocks = page.get_text("dict").get("blocks", [])
            page_candidates = []
            for b in blocks:
                if "lines" not in b:
                    continue
                for line in b["lines"]:
                    line_top = line.get("bbox", [0, 0, 0, 0])[1]
                    if line_top > page_height * top_ratio:
                        continue
                    for s in line.get("spans", []):
                        text = (s.get("text") or "").strip()
                        if 1 < len(text) < 60 and s.get("size", 0) >= min_header_size:
                            page_candidates.append(text)
            if page_candidates:
                title = " ".join(page_candidates[:1])
                candidates.append(ChapterInfo(title=title, page_num=page_no, level=1, source="自動検出"))
        return candidates

    def detect_chapters_by_pattern(
        self,
        min_page_gap: int = 2,
        top_ratio: float = 0.45,
        margin_ratio: float = 0.12,
        min_size_ratio: float = 0.0,
    ) -> List[ChapterInfo]:
        """
        OCR後のPDF向け: パターンにマッチする行を章として検出。
        - top_ratio: ページ上部（高さの top_ratio 以内）のテキストのみ対象（フッター除外）
        - margin_ratio: 左右マージン（幅の margin_ratio ずつ）を除外。サイドバー「第○章」の誤検出を防ぐ。
        - min_size_ratio: 本文フォントに対する最小倍率（0=無効）。0.85以上でフッターの小文字を除外可能。
        """
        body_size = None
        if min_size_ratio > 0:
            font_counts = {}
            for pi in range(min(20, len(self.doc))):
                try:
                    for b in self.doc[pi].get_text("dict").get("blocks", []):
                        for line in b.get("lines", []):
                            for s in line.get("spans", []):
                                sz = round(s.get("size", 0), 1)
                                if sz > 0:
                                    font_counts[sz] = font_counts.get(sz, 0) + len((s.get("text") or "").strip())
                except Exception:
                    continue
            if font_counts:
                body_size = max(font_counts, key=font_counts.get)

        candidates = []
        for page_index in range(len(self.doc)):
            page = self.doc[page_index]
            page_no = page_index + 1
            page_height = page.rect.height
            page_width = page.rect.width

            if candidates and (page_no - candidates[-1].page_num) < min_page_gap:
                continue

            blocks = page.get_text("dict").get("blocks", [])
            page_matched = False
            for b in blocks:
                if "lines" not in b or page_matched:
                    continue
                for line in b["lines"]:
                    if page_matched:
                        break
                    line_bbox = line.get("bbox", [0, 0, 0, 0])
                    # ページ上部のみ対象（フッターの「第○章」を除外）
                    if line_bbox[1] > page_height * top_ratio:
                        continue
                    # 左右マージン（サイドバー「第○章」など）を除外
                    center_x = (line_bbox[0] + line_bbox[2]) / 2
                    if center_x < page_width * margin_ratio or center_x > page_width * (1 - margin_ratio):
                        continue
                    for span in line.get("spans", []):
                        text = (span.get("text") or "").strip()
                        if not text or len(text) > 80:
                            continue
                        # フォントサイズでフィルタ（本文より小さい=フッターの可能性）
                        if body_size and min_size_ratio > 0:
                            sz = span.get("size", 0)
                            if sz < body_size * min_size_ratio:
                                continue
                        for pat in CHAPTER_TITLE_REGEXES:
                            if pat.search(text):
                                candidates.append(
                                    ChapterInfo(
                                        title=text[:60],
                                        page_num=page_no,
                                        level=1,
                                        source="パターン検出(OCR)",
                                    )
                                )
                                page_matched = True
                                break
        return candidates

    def detect_chapters_from_toc_pages(
        self,
        toc_max_pages: int = 25,
    ) -> List[ChapterInfo]:
        """
        目次ページを特定し、章タイトルと開始ページを抽出する。
        目次フォーマットは書籍により異なるが、「第1章 ... 15」のように
        行末にページ番号がある形式を想定する。
        """
        toc_page_indices = []
        for pi in range(min(toc_max_pages, len(self.doc))):
            try:
                text = self.doc[pi].get_text()
                if not text:
                    continue
                # 「目次」「Contents」などが含まれるページを候補に
                if any(kw in text for kw in ("目次", "Contents", "CONTENTS", "Table of Contents")):
                    toc_page_indices.append(pi)
            except Exception:
                continue

        if not toc_page_indices:
            return []

        chapters = []
        seen_pages = set()
        for pi in toc_page_indices:
            try:
                blocks = self.doc[pi].get_text("dict").get("blocks", [])
            except Exception:
                continue
            for b in blocks:
                for line in b.get("lines", []):
                    line_text = " ".join(s.get("text", "") for s in line.get("spans", []))
                    line_text = line_text.strip()
                    if not line_text or len(line_text) > 120:
                        continue
                    # 目次行として有効か（章パターン or 「1. はじめに」形式）
                    if not any(pat.search(line_text) for pat in TOC_ENTRY_PATTERNS):
                        continue
                    # 行末のページ番号を抽出（.... 15, ……… 15, 15 など複数フォーマット）
                    page_match = re.search(r"[\s.\・…－\-ー]*(\d{1,4})\s*$", line_text)
                    if not page_match:
                        continue
                    page_num = int(page_match.group(1))
                    if page_num < 1 or page_num > len(self.doc):
                        continue
                    if page_num in seen_pages:
                        continue
                    seen_pages.add(page_num)
                    title = re.sub(r"[\s.\・…－\-ー]*\d{1,4}\s*$", "", line_text).strip()
                    if not title:
                        title = line_text[:50]
                    chapters.append(
                        ChapterInfo(
                            title=title[:60],
                            page_num=page_num,
                            level=1,
                            source="目次",
                        )
                    )
        return sorted(chapters, key=lambda c: c.page_num)

    def filter_major_chapters(
        self,
        chapters: List[ChapterInfo],
        selected_pattern_ids: List[str] | None = None,
        keyword: str | None = None,
        min_distance: int = 5,
    ) -> List[ChapterInfo]:
        """
        章だけを残すためのフィルタ:
        - タイトルが章タイトルらしいものだけを残す
          （キーワード、または CHAPTER_TITLE_REGEXES にマッチ）
        - 同じタイトルが近いページに繰り返し出る場合は、最初の1つだけ残す
        """
        if not chapters:
            return []

        filtered: List[ChapterInfo] = []
        seen_pages_by_title = {}

        # どのパターンを使うか決定（チェックボックスで未選択なら全パターン）
        if selected_pattern_ids:
            active_patterns = []
            for g in CHAPTER_PATTERN_GROUPS:
                if g["id"] in selected_pattern_ids:
                    active_patterns.extend(g["patterns"])
        else:
            active_patterns = CHAPTER_TITLE_REGEXES

        for ch in sorted(chapters, key=lambda c: c.page_num):
            title = (ch.title or "").strip()
            if not title:
                continue

            looks_like_chapter = False
            if keyword and keyword in title:
                looks_like_chapter = True
            else:
                for pat in active_patterns:
                    if pat.search(title):
                        looks_like_chapter = True
                        break

            if not looks_like_chapter:
                continue

            norm_title = re.sub(r"\s+", "", title)
            last_page = seen_pages_by_title.get(norm_title)
            if last_page is not None and (ch.page_num - last_page) < min_distance:
                continue

            seen_pages_by_title[norm_title] = ch.page_num
            filtered.append(ch)

        return filtered

    def process_export(
        self,
        chapters: List[ChapterInfo],
        export_mode: str,
        img_zoom: float = 2.0,
        output_base_dir: str | Path | None = None,
    ) -> tuple[bytes, list[str]]:
        """
        ZIP形式で出力。export_mode=="image" かつ output_base_dir が指定された場合、
        指定フォルダにも保存する。
        戻り値: (zip_bytes, saved_folder_paths)
        """
        zip_buffer = io.BytesIO()
        sorted_chapters = sorted(chapters, key=lambda x: x.page_num)
        path_stack = []
        saved_folders: list[str] = []

        base_path = Path(output_base_dir).resolve() if output_base_dir else None
        safe_book_title = "".join(
            c for c in self.book_title if c.isalnum() or c in (" ", "-", "_", ".", "(", ")")
        ).strip() or "book"
        book_folder = base_path / safe_book_title if base_path else None
        if book_folder:
            book_folder.mkdir(parents=True, exist_ok=True)

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
                safe_title = "".join(
                    c for c in chapter.title if c.isalnum() or c in (" ", "-", "_", ".", "(", ")")
                ).strip()
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
                    chapter_folder_disk = None
                    if book_folder:
                        chapter_folder_disk = book_folder / safe_title
                        chapter_folder_disk.mkdir(parents=True, exist_ok=True)
                        saved_folders.append(str(chapter_folder_disk))

                    for p_idx in range(start_page, end_page):
                        page = self.doc[p_idx]
                        mat = fitz.Matrix(img_zoom, img_zoom)
                        pix = page.get_pixmap(matrix=mat)
                        img_data = pix.tobytes("jpg")
                        local_num = p_idx - start_page + 1
                        img_name = f"{local_num:03d}.jpg"
                        zf.writestr(f"{current_folder}/{img_name}", img_data)

                        if chapter_folder_disk:
                            (chapter_folder_disk / img_name).write_bytes(img_data)

        zip_buffer.seek(0)
        return zip_buffer.getvalue(), saved_folders


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

    st.subheader("4. 画像の保存先フォルダ")
    default_output_dir = r"C:\Users\20171\Learning\PDF_PICTURE"
    output_base_dir = st.text_input(
        "保存先（本フォルダ・章フォルダがここに作成されます）",
        value=default_output_dir,
        help="同一タイトルの本がなければ本フォルダを作成し、分割されたPDFの画像を章フォルダとして保存します。",
    )

    st.subheader("5. 章タイトル判定ルール")
    chapter_pattern_ids = [g["id"] for g in CHAPTER_PATTERN_GROUPS]
    if "chapter_pattern_selected" not in st.session_state:
        st.session_state.chapter_pattern_selected = chapter_pattern_ids
    if "chapter_pattern_manual" not in st.session_state:
        st.session_state.chapter_pattern_manual = False

    selected_ids = st.multiselect(
        "章タイトルとして扱うパターン",
        options=chapter_pattern_ids,
        default=st.session_state.chapter_pattern_selected,
        format_func=lambda id_: next(g["label"] for g in CHAPTER_PATTERN_GROUPS if g["id"] == id_),
        help="本の言語や構成に合わせて、章タイトルとして使われそうなパターンだけを有効にできます。",
        key="chapter_pattern_rules",
    )
    if set(selected_ids) != set(st.session_state.chapter_pattern_selected):
        st.session_state.chapter_pattern_selected = selected_ids
        st.session_state.chapter_pattern_manual = True

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
                st.session_state.chapters = st.session_state.processor.detect_chapters_from_toc_pages()
            if not st.session_state.chapters:
                header_scale = st.session_state.get("header_scale", 1.3)
                min_page_gap = st.session_state.get("min_page_gap", 2)
                st.session_state.chapters = st.session_state.processor.detect_chapters_by_style(
                    header_scale, min_page_gap
                )
            if not st.session_state.chapters:
                min_page_gap = st.session_state.get("min_page_gap", 2)
                st.session_state.chapters = st.session_state.processor.detect_chapters_by_pattern(
                    min_page_gap, top_ratio=0.45, min_size_ratio=0.85
                )
            # まだユーザーが明示的に変更していない場合は、検出された見出しから
            # 章タイトル判定ルールのおすすめセットを自動で推定する
            if not st.session_state.get("chapter_pattern_manual", False):
                st.session_state.chapter_pattern_selected = suggest_chapter_pattern_ids(
                    st.session_state.chapters
                )

    processor = st.session_state.processor

    if ocr_btn and not st.session_state.ocr_done:
        with st.spinner("OCR処理中... ページ数によっては数分かかります☕"):
            if processor.run_ocr():
                st.session_state.ocr_done = True
                header_scale = st.session_state.get("header_scale", 1.3)
                min_page_gap = st.session_state.get("min_page_gap", 2)
                st.session_state.chapters = processor.detect_chapters_by_style(header_scale, min_page_gap)
                if not st.session_state.chapters:
                    st.session_state.chapters = processor.detect_chapters_from_toc_pages()
                if not st.session_state.chapters:
                    # パターン検出（ページ上部のみ・フッター除外・本文85%以上）
                    st.session_state.chapters = processor.detect_chapters_by_pattern(
                        min_page_gap, top_ratio=0.45, min_size_ratio=0.85
                    )
                if not st.session_state.get("chapter_pattern_manual", False):
                    st.session_state.chapter_pattern_selected = suggest_chapter_pattern_ids(
                        st.session_state.chapters
                    )
                st.session_state.ocr_complete_toast = True
                notify_ocr_complete()
                st.success("OCR完了！テキスト情報を取得しました。")
                st.rerun()

    if not st.session_state.chapters:
        st.error("章の区切りが見つかりませんでした。OCRを実行するか、ファイルを確認してください。")
        col_toc, col_pat = st.columns(2)
        with col_toc:
            if st.button("📑 目次ページから検出"):
                st.session_state.chapters = processor.detect_chapters_from_toc_pages()
                if st.session_state.chapters:
                    st.session_state.chapter_pattern_selected = suggest_chapter_pattern_ids(
                        st.session_state.chapters
                    )
                    st.success(f"{len(st.session_state.chapters)}件の章を検出しました。")
                    st.rerun()
                else:
                    st.warning("目次ページが見つからないか、解析できませんでした。")
        with col_pat:
            if st.button("🔎 パターン検出を試す（ページ上部のみ）"):
                min_page_gap = st.session_state.get("min_page_gap", 2)
                st.session_state.chapters = processor.detect_chapters_by_pattern(
                    min_page_gap, top_ratio=0.45, min_size_ratio=0.85
                )
                if st.session_state.chapters:
                    st.session_state.chapter_pattern_selected = suggest_chapter_pattern_ids(
                        st.session_state.chapters
                    )
                    st.success(f"{len(st.session_state.chapters)}件の章を検出しました。")
                    st.rerun()
                else:
                    st.warning("パターンに一致する見出しも見つかりませんでした。")
    else:
        if st.session_state.pop("ocr_complete_toast", False):
            st.toast("OCRが完了しました", icon="✅")
        st.subheader("🛠 フォルダ構成の編集")
        st.caption("『階層(Lv)』を調整すると、フォルダの入れ子構造を作成できます (Lv1=親フォルダ, Lv2=サブフォルダ...)。")
        col1, col2 = st.columns(2)
        with col1:
            if st.button("🔁 見出し自動検出をやり直す"):
                header_scale = st.session_state.get("header_scale", 1.3)
                min_page_gap = st.session_state.get("min_page_gap", 2)
                st.session_state.chapters = processor.detect_chapters_by_style(header_scale, min_page_gap)
                if not st.session_state.chapters:
                    st.session_state.chapters = processor.detect_chapters_from_toc_pages()
                if not st.session_state.chapters:
                    st.session_state.chapters = processor.detect_chapters_by_pattern(
                        min_page_gap, top_ratio=0.45, min_size_ratio=0.85
                    )
                if not st.session_state.get("chapter_pattern_manual", False):
                    st.session_state.chapter_pattern_selected = suggest_chapter_pattern_ids(
                        st.session_state.chapters
                    )
                st.success("見出しを再検出しました。" if st.session_state.chapters else "見出しが見つかりませんでした。")
                st.rerun()
        with col2:
            if st.button("📑 『章』だけに自動整理（重複除去）"):
                selected_ids = st.session_state.get("chapter_pattern_selected")
                filtered = processor.filter_major_chapters(
                    st.session_state.chapters,
                    selected_pattern_ids=selected_ids,
                    keyword=None,
                    min_distance=5,
                )
                if not filtered:
                    st.warning("章レベルの見出しが自動では判定できませんでした。必要に応じて手動で調整してください。")
                else:
                    st.session_state.chapters = filtered
                    st.success(f"{len(filtered)}件の章レベル見出しに絞り込みました。")
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
            width="stretch",
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
                out_dir = output_base_dir.strip() if mode_str == "image" else None
                with st.spinner("処理中... フォルダを作成し書き出しています..."):
                    try:
                        zip_bytes, saved_folders = processor.process_export(
                            final_chapters, mode_str, img_zoom,
                            output_base_dir=out_dir if out_dir else None,
                        )
                        dl_name = f"{processor.book_title}_{mode_str}.zip"
                        st.balloons()
                        if saved_folders:
                            book_path = Path(saved_folders[0]).parent if saved_folders else Path(output_base_dir)
                            st.success(
                                f"フォルダに保存しました: **{book_path}** （章フォルダ: {len(saved_folders)} 件）"
                            )
                        st.download_button(
                            label=f"📦 ZIPファイルをダウンロード ({dl_name})",
                            data=zip_bytes,
                            file_name=dl_name,
                            mime="application/zip",
                        )
                    except Exception as e:
                        st.error(f"書き出しエラー: {e}")
