# git_project_template

Windows 11 / PowerShell / Git / GitHub 用の共通プロジェクトテンプレート

## 目的

新規プロジェクト作成時に必要な共通設定、Git hooks、VBA export 運用、補助資料を一元管理する

このリポジトリ内の `hooks` ディレクトリを、各プロジェクトの `core.hooksPath` から直接参照する

## Agent作業時の共通ルール

Agentでこのリポジトリや適用先プロジェクトを編集する場合、作業前に以下を参照する

```text
C:\data\tools\gitRepos\rules\git.md
C:\data\tools\gitRepos\rules\edit_policy.md
C:\data\tools\gitRepos\rules\python.md
C:\data\tools\gitRepos\rules\vba.md
C:\data\tools\gitRepos\rules\writing_style.md
```

主な運用

- 作業前に `git branch --show-current; git status` を確認する
- `main` ブランチで直接編集しない
- `main` の場合は `wip/yyyy-MMdd-HHmm` ブランチを作成してから編集する
- commit / push はユーザーの明示許可がある場合のみ実行する
- hook失敗時に `--no-verify` で勝手に回避しない

## ディレクトリ構成

```text
git_project_template
├── .gitattributes
├── .gitignore
├── README.md
├── docs
│   ├── GIT_GITHUB_PROJECT_SETUP.md
│   ├── README.md
│   ├── VBA_EXPORT_GIT_FLOW.md
│   └── manual
│       ├── RSS_install_manual.xlsx
│       ├── git_guide.xlsm
│       └── open_Git_Guide.bat
├── hooks
│   ├── post-checkout
│   ├── pre-commit
│   └── pre-push
├── templates
│   ├── .gitattributes
│   └── .gitignore
└── vbaCode
    └── allExport.bas
```

## ルート設定ファイル

### .gitattributes

Git管理するテキストファイルの改行コードを固定する

```text
*.bas text eol=lf
*.cls text eol=lf
*.py text eol=lf
*.md text eol=lf
*.bat text eol=crlf
*.cmd text eol=crlf
```

方針

- `.bas` / `.cls` / `.py` / `.md` は LF
- `.bat` / `.cmd` は CRLF
- VBA exportファイルの差分を安定させる
- WindowsバッチはWindows標準のCRLFで扱う

### .gitignore

新規プロジェクトへ最初に入れる共通除外パターンを管理する

このリポジトリ自身の除外設定としても使用し、新規プロジェクト作成時はプロジェクトルートへコピーする

主な対象

```text
# Python
__pycache__/
*.pyc
.venv/
.env

# Excel temporary files
~$*.xlsm
~$*.xlsx

# Logs / runtime
logs/
runtime/
*.log

# OS / editor
.DS_Store
Thumbs.db
.vscode/
```

方針

- 新規プロジェクト作成時は、ルートの `.gitignore` をプロジェクトルートへコピーする
- `templates/.gitignore` は追加パターンを含む参照用テンプレートとして扱う
- 各プロジェクト固有の除外は、必要になった時点で個別追記する
- 実行ログ、runtime、一時ファイル、ExcelロックファイルはGit管理しない
- `.xlsm` を管理対象にするかどうかはプロジェクトごとに判断する

## 各ディレクトリの役割

### docs

Git / GitHub / VBA export / 新規プロジェクト作成などの運用マニュアルを置く

正本は `docs` 直下の Markdown とする

主要資料

```text
docs/GIT_GITHUB_PROJECT_SETUP.md
docs/VBA_EXPORT_GIT_FLOW.md
```

`docs/manual` は補助資料・参考資料置き場とする

```text
docs/manual/git_guide.xlsm
docs/manual/RSS_install_manual.xlsx
```

`docs/manual/open_Git_Guide.bat` は `docs/manual/git_guide.xlsm` を開く補助バッチとして扱う

### hooks

全プロジェクト共通の Git hooks を置く

各プロジェクトは、このディレクトリを直接参照する

```powershell
git config core.hooksPath C:/data/tools/gitRepos/git_project_template/hooks
```

管理対象の hook

```text
hooks/post-checkout
hooks/pre-commit
hooks/pre-push
```

### vbaCode

VBAコードをGit管理用にエクスポートするための標準テンプレートを置く

```text
vbaCode/allExport.bas
```

`allExport.bas` は、VBA付き `.xlsm` プロジェクトへコピーして使用する

VBA運用の正本は以下を参照する

```text
docs/VBA_EXPORT_GIT_FLOW.md
```

## 新規プロジェクトへの適用手順

詳細は以下を参照する

```text
docs/GIT_GITHUB_PROJECT_SETUP.md
```

新規プロジェクト作成時は、共通設定ファイルとして `.gitignore` と `.gitattributes` を最初にプロジェクトルートへ配置する

基本手順

```powershell
$projectName = "new_project_name"
$repoRoot = "C:\data\tools\gitRepos"
$templateRoot = "C:\data\tools\gitRepos\git_project_template"
$hooksPath = Join-Path $templateRoot "hooks"

$projectPath = Join-Path $repoRoot $projectName

if (-not (Test-Path $projectPath)) {
    New-Item -ItemType Directory -Path $projectPath | Out-Null
}

Set-Location $projectPath

git init
git branch -M main

$ts = Get-Date -Format "yyyy-MMdd-HHmm"
$wip = "wip/$ts"
git switch -c $wip

git config core.hooksPath $hooksPath

Copy-Item (Join-Path $templateRoot ".gitignore") .gitignore -Force
Copy-Item (Join-Path $templateRoot ".gitattributes") .gitattributes -Force
```

設定確認

```powershell
git config --show-origin --get core.hooksPath
```

期待値

```text
file:.git/config    C:/data/tools/gitRepos/git_project_template/hooks
```

## 既存プロジェクトへの適用手順

対象プロジェクトのルートへ移動する

```powershell
cd C:\data\tools\gitRepos\既存プロジェクト名
```

共通 hooksPath を設定する

```powershell
git config core.hooksPath C:/data/tools/gitRepos/git_project_template/hooks
```

設定を確認する

```powershell
git config --show-origin --get core.hooksPath
```

## hook 動作確認

任意のファイルを変更し、`wip/` ブランチ上であることを確認する

```powershell
$wip = git branch --show-current
if ($wip -eq "main") { throw "ERROR: You are on main. Switch to your wip branch first." }
```

ユーザーの明示許可がある場合のみ commit する

```powershell
git add .
git commit -m "chore: test shared git hooks"
```

`pre-commit` が有効なら、共通 hook の処理が実行される

## hook 更新時の流れ

`hooks` 配下のファイルを編集する

```powershell
notepad C:\data\tools\gitRepos\git_project_template\hooks\pre-commit
```

変更後は差分を確認する

```powershell
cd C:\data\tools\gitRepos\git_project_template

git diff --name-only
git status
```

ユーザーの明示許可がある場合のみ `wip/` ブランチ上で commit する

```powershell
$wip = git branch --show-current
if ($wip -eq "main") { throw "ERROR: You are on main. Switch to your wip branch first." }

git add hooks/pre-commit
git commit -m "chore: update shared pre-commit hook"
```

main への反映と push は、wip を main へ merge した後、ユーザーの明示許可がある場合のみ実行する

```powershell
git switch main
git merge --no-ff $wip
git push
```

各プロジェクトは `git_project_template/hooks` を直接参照しているため、ローカルでは hook 更新が即時反映される

## GitHub への初回登録

GitHub 側で `git_project_template` という空リポジトリを作成する

その後、ローカルで remote まで設定する

```powershell
cd C:\data\tools\gitRepos\git_project_template

git remote add origin https://github.com/kakato-p/git_project_template.git
```

ユーザーの明示許可がある場合のみ `wip/` ブランチ上で commit する

```powershell
$wip = git branch --show-current
if ($wip -eq "main") { throw "ERROR: You are on main. Switch to your wip branch first." }

git add .
git commit -m "chore: add git project template"
```

main への反映と初回 push は、wip を main へ merge した後、ユーザーの明示許可がある場合のみ実行する

```powershell
git switch main
git merge --no-ff $wip
git push -u origin main
```

## 別PCへの復元

GitHub から clone する

```powershell
cd C:\data\tools\gitRepos

git clone https://github.com/kakato-p/git_project_template.git
```

各プロジェクトで hooksPath を設定する

```powershell
git config core.hooksPath C:/data/tools/gitRepos/git_project_template/hooks
```

## 運用方針

このリポジトリの `hooks` を正とする

今後編集する hook は以下に限定する

```text
C:\data\tools\gitRepos\git_project_template\hooks
```

旧共通 hook 置き場がある場合、原則として編集しない

```text
C:\data\tools\gitRepos\_githooks
```

## 注意点

`core.hooksPath` はブランチ単位ではなく、リポジトリ単位の設定

どのブランチで設定してもよい

ただし、必ず hook を適用したいプロジェクトのルートで実行する

誤り

```powershell
cd C:\data\tools\gitRepos\git_project_template
git config core.hooksPath C:/data/tools/gitRepos/git_project_template/hooks
```

これは `git_project_template` 自身への設定になる

正しい例

```powershell
cd C:\data\tools\gitRepos\quote_recorder
git config core.hooksPath C:/data/tools/gitRepos/git_project_template/hooks
```
