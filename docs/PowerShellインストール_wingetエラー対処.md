# winget エラー「0x80070005 : Access is denied」の原因と対処法

## 1. 原因の特定

### エラーの意味
- **0x80070005** = **Access is denied（アクセスが拒否されました）**
- winget が「パッケージソース（Microsoft のアプリ一覧）」を更新する際、**キャッシュや設定を書き込むフォルダへアクセスする権限がない**ために発生しています。

### 主な原因候補
| 原因 | 説明 |
|------|------|
| **管理者権限不足** | winget のソース更新は `C:\Program Files\WindowsApps` やキャッシュフォルダなどへの書き込みが必要で、管理者権限が必要な場合がある |
| **UAC（ユーザーアカウント制御）** | 昇格ダイアログをキャンセルした、または通常ユーザーで実行している |
| **App Installer の不具合** | winget の実体である「App Installer」が古い、または破損している |
| **セキュリティソフト** | フォルダ／レジストリへの書き込みをブロックしている |
| **キャッシュ破損** | 過去の winget キャッシュが壊れ、正常にソースを開けない |

---

## 2. 対処法（順に試す）

### 方法A: 管理者で winget のソースをリセット（まず試す）

1. **管理者として PowerShell または コマンドプロンプト を開く**
   - スタートメニューで「PowerShell」または「cmd」と入力
   - **「管理者として実行」** を選ぶ

2. 次のコマンドを実行してソースをリセットする：
   ```powershell
   winget source reset --force
   ```

3. 成功したら、PowerShell をインストール：
   ```powershell
   winget install Microsoft.PowerShell --accept-source-agreements --accept-package-agreements
   ```

---

### 方法B: App Installer（winget）を更新する

winget の実体は **Microsoft Store の「App Installer」** です。古いバージョンだと不具合が出やすいです。

1. **Microsoft Store** を開く
2. **「App Installer」** で検索
3. 更新があれば **「更新」** を実行
4. 再度 **管理者として** コマンドプロンプトまたは PowerShell を開き、方法Aの `winget source reset --force` からやり直す

---

### 方法C: winget を使わずに PowerShell 7 をインストール（確実な方法）

winget がどうしても動かない場合は、**インストーラー（MSI）を直接ダウンロード**してインストールします。

1. **ダウンロードページを開く**
   - https://github.com/PowerShell/PowerShell/releases
   - または短縮URL: https://aka.ms/powershell-release-page

2. **最新の安定版（Stable）を選ぶ**
   - 例: **PowerShell-7.4.x-win-x64.msi**（64bit Windows の場合）

3. **MSI を実行**
   - ダウンロードした `.msi` をダブルクリック
   - 画面の指示に従ってインストール（管理者権限のダイアログが出たら「はい」）

4. **インストール後の確認**
   - 新しいターミナルを開き、次を実行：
     ```powershell
     pwsh -Command "$PSVersionTable.PSVersion"
     ```
   - バージョン（例: 7.4.x）が表示されれば OK

---

## 3. まとめ

| 状況 | やること |
|------|----------|
| winget で「0x80070005」「ソースを更新できませんでした」 | **管理者**で `winget source reset --force` → その後 `winget install Microsoft.PowerShell` |
| 上記でも解消しない | Microsoft Store で **App Installer** を更新 → 再度 winget を試す |
| winget を諦めたい | **GitHub の MSI** をダウンロードして PowerShell 7 を直接インストール |

**PowerShell 7** は Windows 標準の **PowerShell 5.1** と併存するため、5.1 は残ったまま、新しい「PowerShell 7」が追加されます。ターミナルで `pwsh` と入力すると PowerShell 7 が起動します。
