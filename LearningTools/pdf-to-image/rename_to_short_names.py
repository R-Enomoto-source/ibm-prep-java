"""
既存の pdf_output 内フォルダ・ファイルを短い英数字名にリネームする。
使い方: python rename_to_short_names.py
対象: local_data/pdf_output のうち _images で終わるフォルダ（1つのみ指定可）
"""
import re
from pathlib import Path


def to_short_alnum_name(original_name: str, max_length: int = 48) -> str:
    if not original_name or not original_name.strip():
        return "pdf"
    s = original_name.strip()
    prefix = ""
    chapter_match = re.search(r"第?\s*(\d+)\s*章", s)
    if chapter_match:
        prefix = f"ch{chapter_match.group(1)}"
    safe = re.sub(r"[^a-zA-Z0-9_\-]", "_", s)
    safe = re.sub(r"_+", "_", safe)
    safe = safe.strip("_")
    if safe:
        parts = [p for p in safe.split("_") if len(p) > 0]
        if prefix and parts and parts[0].isdigit() and parts[0] == prefix.lstrip("ch"):
            parts = parts[1:]
        combined = "_".join(parts[:6]) if parts else ""
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
    return result or "pdf"


def main():
    base_dir = Path(__file__).resolve().parent.parent.parent / "local_data" / "pdf_output"
    if not base_dir.exists():
        print(f"フォルダが存在しません: {base_dir}")
        return

    # 対象: 3章__JavaSE17Silver_..._images のようなフォルダ（_images で終わるもの）
    target_folder_name = "3章__JavaSE17Silver_黒本徹底攻略Java SE 17 Silver問題集[1Z0-825]対応 志賀澄人 (1) - コピー_images"
    target_path = base_dir / target_folder_name

    if not target_path.exists():
        # 名前が一致しない場合は _images で終わるフォルダを探す
        candidates = [d for d in base_dir.iterdir() if d.is_dir() and d.name.endswith("_images")]
        if len(candidates) == 0:
            print("対象の _images フォルダが見つかりません。")
            return
        if len(candidates) > 1:
            print("複数の _images フォルダがあります。最初のものを使用します:", candidates[0].name)
        target_path = candidates[0]

    original_folder_name = target_path.name
    # フォルダ名から "_images" を除いた部分をベース名に
    base_stem = original_folder_name[:-7] if original_folder_name.endswith("_images") else original_folder_name
    short_base = to_short_alnum_name(base_stem)
    new_folder_name = f"{short_base}_images"
    new_folder_path = base_dir / new_folder_name

    if target_path == new_folder_path:
        print("フォルダ名は既に短い名前です。ファイルのみリネームします。")
        work_dir = target_path
    else:
        if new_folder_path.exists():
            print(f"リネーム先が既に存在します: {new_folder_path}")
            return
        target_path.rename(new_folder_path)
        print(f"フォルダ名を変更しました: {original_folder_name} -> {new_folder_name}")
        work_dir = new_folder_path

    # ファイル名を short_base_page_0001.png 形式に統一
    page_pattern = re.compile(r"_page_(\d+)\.(png|jpg|jpeg)$", re.IGNORECASE)
    renamed_count = 0
    for f in sorted(work_dir.iterdir()):
        if not f.is_file():
            continue
        m = page_pattern.search(f.name)
        if m:
            page_no = int(m.group(1))
            ext = m.group(2).lower()
            if ext == "jpeg":
                ext = "jpg"
            new_name = f"{short_base}_page_{page_no:04d}.{ext}"
            if f.name != new_name:
                new_path = f.parent / new_name
                if new_path.exists() and new_path != f:
                    print(f"スキップ（既存）: {f.name}")
                    continue
                f.rename(new_path)
                print(f"  {f.name} -> {new_name}")
                renamed_count += 1

    print(f"完了。フォルダ: {work_dir}")
    print(f"ファイルリネーム数: {renamed_count}")


if __name__ == "__main__":
    main()
