# 環境構築（Java プロジェクトの初期設定）

`.project`、`.classpath`、`.settings/` は `.gitignore` で除外されているため、リポジトリを clone した直後は存在しません。  
以下で **LearningTools 内のテンプレからコピー** して Java プロジェクトとして認識させてください。

## 手順（PowerShell）

```powershell
cd pre-joining-learning

# 1. プロジェクト定義
Copy-Item LearningTools\project-setup-example\.project.example .project
Copy-Item LearningTools\project-setup-example\.classpath.example .classpath

# 2. コンパイラ・エンコーディング設定
New-Item -ItemType Directory -Force -Path .settings | Out-Null
Copy-Item LearningTools\project-setup-example\.settings.example\org.eclipse.jdt.core.prefs .settings\
```

## 必要なもの

- **JDK 25**（例: [Eclipse Temurin](https://adoptium.net/)）。JDK 21 を使う場合は、コピー後に `.classpath` の `JavaSE-25` を `JavaSE-21` に変更し、`<attributes>…</attributes>` を追加してください。
- **Cursor / VS Code** と **Extension Pack for Java**
- **ワークスペースルート**（このリポジトリの親フォルダ）の `.vscode/settings.json` に、使用する JDK を `java.configuration.runtimes` で指定（未設定の場合は「Java: Configure Java Runtime」で追加）

## 注意

- `sukkiri_Java_reference_code` を使う場合は、`.classpath` に該当する `<classpathentry kind="src" path="..."/>` を追加してください。存在しないパスを指定すると警告の原因になります。
