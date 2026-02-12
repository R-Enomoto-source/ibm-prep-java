"""
画像をバッチでテキスト化するスクリプト（88枚など大量画像向け）

使い方:
  1. 問題文用・解答解説用で画像を別フォルダに分ける
     例: images/questions/ と images/answers/
  2. バッチサイズを小さくして実行（5〜10枚推奨）
     python image_to_text.py --folder images/questions --batch 5
  3. 出力を手動で Chapter3_questions.md / Chapter3_answers.md に追記

負荷対策:
  - 88枚を一括だとタイムアウト・メモリ不足になりやすい
  - BATCH_SIZE を 5〜10 にすると安定
  - 問題文44枚 + 解答44枚など、分割して実行する
"""

import argparse
import os
import sys
from pathlib import Path

# バッチサイズ（デフォルト5枚＝負荷軽減）
DEFAULT_BATCH = 5

# 対応画像形式
IMAGE_EXTENSIONS = {".png", ".jpg", ".jpeg", ".gif", ".webp", ".bmp"}


def get_images_sorted(folder: Path) -> list[Path]:
    """フォルダ内の画像をファイル名でソートして返す"""
    images = []
    for f in folder.iterdir():
        if f.is_file() and f.suffix.lower() in IMAGE_EXTENSIONS:
            images.append(f)
    return sorted(images, key=lambda p: p.name)


def extract_text_pytesseract(image_path: Path, lang: str = "jpn+eng") -> str:
    """pytesseract でOCR（Tesseract必須）"""
    try:
        import pytesseract
        from PIL import Image
    except ImportError:
        print("pytesseract と Pillow が必要です: pip install pytesseract Pillow")
        sys.exit(1)

    img = Image.open(image_path)
    # 日本語＋英語
    text = pytesseract.image_to_string(img, lang=lang)
    return text.strip() if text else ""


def extract_text_easyocr(image_path: Path, lang_list: tuple = ("ja", "en")) -> str:
    """easyocr でOCR（Tesseract不要、初回はモデルDLあり）"""
    try:
        import easyocr
    except ImportError:
        print("easyocr が必要です: pip install easyocr")
        sys.exit(1)

    # 1回だけReaderを初期化（重いので再利用）
    if not hasattr(extract_text_easyocr, "_reader"):
        print("EasyOCR 初期化中（初回はダウンロードあり）...")
        extract_text_easyocr._reader = easyocr.Reader(lang_list, gpu=False)

    reader = extract_text_easyocr._reader
    result = reader.readtext(str(image_path), detail=0)
    return "\n".join(result).strip() if result else ""


def process_batch(
    image_paths: list[Path],
    engine: str,
    start_index: int = 0,
) -> list[tuple[int, str]]:
    """画像リストをOCRして (番号, テキスト) のリストを返す"""
    results = []
    for i, path in enumerate(image_paths, start=start_index + 1):
        print(f"  処理中: {path.name} ({i}/{start_index + len(image_paths)})")
        if engine == "easyocr":
            text = extract_text_easyocr(path)
        else:
            text = extract_text_pytesseract(path)
        results.append((i, text))
    return results


def main():
    parser = argparse.ArgumentParser(description="画像をバッチでテキスト化（88枚向け）")
    parser.add_argument(
        "--folder",
        "-f",
        required=True,
        help="画像フォルダパス（例: images/questions）",
    )
    parser.add_argument(
        "--batch",
        "-b",
        type=int,
        default=DEFAULT_BATCH,
        help=f"1回に処理する枚数（デフォルト{DEFAULT_BATCH}、負荷対策で小さく）",
    )
    parser.add_argument(
        "--engine",
        "-e",
        choices=["pytesseract", "easyocr"],
        default="easyocr",
        help="OCRエンジン（easyocr=Tesseract不要、pytesseract=軽いがTesseract要）",
    )
    parser.add_argument(
        "--output",
        "-o",
        help="出力ファイル（指定しない場合は標準出力）",
    )
    parser.add_argument(
        "--offset",
        type=int,
        default=0,
        help="開始インデックス（続きから処理する場合）",
    )
    args = parser.parse_args()

    folder = Path(args.folder)
    if not folder.is_dir():
        print(f"エラー: フォルダがありません: {folder}")
        sys.exit(1)

    images = get_images_sorted(folder)
    if not images:
        print(f"画像が見つかりません: {folder}")
        sys.exit(1)

    if args.offset > 0:
        images = images[args.offset:]
        print(f"先頭 {args.offset} 枚をスキップし、{len(images)} 枚を処理します。")
    total = len(images)
    print(f"画像 {total} 枚を検出。バッチサイズ {args.batch} で処理します。")
    print(f"エンジン: {args.engine}")
    print("-" * 40)

    all_results = []
    for batch_start in range(0, total, args.batch):
        batch_images = images[batch_start : batch_start + args.batch]
        batch_results = process_batch(
            batch_images,
            args.engine,
            start_index=args.offset + batch_start,
        )
        all_results.extend(batch_results)
        print(f"  → バッチ完了: {batch_start + len(batch_images)}/{total}")

    # 出力
    lines = []
    for num, text in all_results:
        lines.append(f"## {num}")
        lines.append("")
        lines.append(text if text else "(テキストなし)")
        lines.append("")
        lines.append("---")
        lines.append("")

    output_text = "\n".join(lines)

    if args.output:
        out_path = Path(args.output)
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(output_text, encoding="utf-8")
        print(f"\n出力: {out_path}")
    else:
        print("\n" + output_text)


if __name__ == "__main__":
    main()
