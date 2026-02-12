# 画像をバッチでテキスト化するツール（88枚向け）

88枚などの大量画像を一括でOCRすると、ロード時間が長く失敗しやすくなります。  
このツールは**バッチサイズを小さくして**少しずつ処理することで負荷を抑えます。

## 推奨運用

| 項目 | 推奨 |
|------|------|
| バッチサイズ | **5〜10枚** |
| 問題文・解答 | **別フォルダに分けて**それぞれ実行 |
| OCRエンジン | **easyocr**（Tesseract不要） |

## セットアップ

```bash
cd LearningTools/image-to-text-batch
pip install -r requirements.txt
```

## 使い方

### 1. 画像をフォルダに配置

```
images/
  questions/   ← 問題文の画像（例: 44枚）
  answers/     ← 解答・解説の画像（例: 44枚）
```

### 2. 問題文をテキスト化（5枚ずつ）

```bash
python image_to_text.py --folder images/questions --batch 5 --output ../../java_blackbook/local_problems/answers/Chapter3_questions.md
```

### 3. 解答・解説をテキスト化（5枚ずつ）

```bash
python image_to_text.py --folder images/answers --batch 5 --output ../../java_blackbook/local_problems/questions/Chapter3_answers.md
```

### オプション

- `--batch 5` … 1回あたり5枚ずつ処理（負荷対策）
- `--engine easyocr` … Tesseract不要（デフォルト）
- `--engine pytesseract` … 軽量だが Tesseract のインストールが必要
- `--offset 20` … 21枚目から処理（続きから実行する場合）

## 別の方法：Cursorで少量ずつ依頼

1. **5〜10枚ずつ**画像をCursorに添付
2. 「この画像のテキストを正確に起こしてください」と依頼
3. 出力を手動で `Chapter3_questions.md` または `Chapter3_answers.md` に追記
4. 次の5〜10枚に進む

88枚 ÷ 10枚 ≒ 9回に分ければ、1回あたりの負荷が軽くなり完了しやすくなります。
