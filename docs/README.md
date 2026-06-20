# git_project_template

Windows 11 / PowerShell / Git / GitHub 用の共通プロジェクトテンプレート。

## 目的

新規プロジェクト作成時に必要な共通設定・Git hooks・運用マニュアルを一元管理する。

このリポジトリ内の `hooks` ディレクトリを、各プロジェクトの `core.hooksPath` から直接参照する。

## ディレクトリ構成

```text
git_project_template
├── .gitattributes
├── .gitignore
├── README.md
├── docs
│   ├── GIT_GITHUB_PROJECT_SETUP.md
│   ├── README.md
│   └── VBA_EXPORT_GIT_FLOW.md
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

## 各ディレクトリの役割

### hooks

全プロジェクト共通の Git hooks を置く。

各プロジェクトは、このディレクトリを直接参照する。

```powershell
git config core.hooksPath C:/data/tools/gitRepos/git_project_template/hooks
```

### docs

Git / GitHub / VBA export / 新規プロジェクト作成などの運用マニュアルを置く。

例：

```text
docs
├── GIT_GITHUB_PROJECT_SETUP.md
├── README.md
└── VBA_EXPORT_GIT_FLOW.md
```

### templates

新規プロジェクト向けの参照用テンプレートファイルを置く。

例：

```text
templates
├── .gitattributes
└── .gitignore
```

新規プロジェクト作成手順では、現行コマンドに合わせてルートの `.gitignore` と `.gitattributes` をコピーする。

### rules

Agent作業時は、対象プロジェクトの指示に加えて以下の共通rulesを参照する。

```text
C:\data\tools\gitRepos\rules\git.md
C:\data\tools\gitRepos\rules\edit_policy.md
C:\data\tools\gitRepos\rules\python.md
C:\data\tools\gitRepos\rules\vba.md
C:\data\tools\gitRepos\rules\writing_style.md
```

主な運用：

- 作業前に `git branch --show-current; git status` を確認する
- `main` ブランチで直接編集しない
- `main` の場合は `wip/yyyy-MMdd-HHmm` ブランチを作成してから編集する
- commit / push はユーザーの明示許可がある場合のみ実行する
- hook失敗時に `--no-verify` で勝手に回避しない

## 新規プロジェクトへの適用手順

対象プロジェクトのルートへ移動する。

```powershell
cd C:\data\tools\gitRepos\新規プロジェクト名
```

Git 未初期化なら初期化する。

```powershell
git init
```

共通 hooksPath を設定する。

```powershell
git config core.hooksPath C:/data/tools/gitRepos/git_project_template/hooks
```

設定を確認する。

```powershell
git config --get core.hooksPath
```

期待値：

```text
C:/data/tools/gitRepos/git_project_template/hooks
```

## 既存プロジェクトへの適用手順

対象プロジェクトのルートへ移動する。

```powershell
cd C:\data\tools\gitRepos\既存プロジェクト名
```

hooksPath を変更する。

```powershell
git config core.hooksPath C:/data/tools/gitRepos/git_project_template/hooks
```

確認する。

```powershell
git config --get core.hooksPath
```

## hook 動作確認

任意のファイルを変更し、`wip/` ブランチ上であることを確認する。

```powershell
$wip = git branch --show-current
if ($wip -eq "main") { throw "ERROR: You are on main. Switch to your wip branch first." }
```

ユーザーの明示許可がある場合のみ commit する。

```powershell
git add .
git commit -m "chore: test shared git hooks"
```

`pre-commit` が有効なら、共通 hook の処理が実行される。

例：

```text
Running local test gate...
```

## 運用方針

このリポジトリの `hooks` を正とする。

今後は以下を編集しない。

```text
C:\data\tools\gitRepos\_githooks
```

今後編集する場所：

```text
C:\data\tools\gitRepos\git_project_template\hooks
```

## hook 更新時の流れ

`hooks` 配下のファイルを編集する。

例：

```powershell
notepad C:\data\tools\gitRepos\git_project_template\hooks\pre-commit
```

変更後は差分を確認する。

```powershell
cd C:\data\tools\gitRepos\git_project_template

git diff --name-only
git status
```

ユーザーの明示許可がある場合のみ `wip/` ブランチ上で commit する。

```powershell
$wip = git branch --show-current
if ($wip -eq "main") { throw "ERROR: You are on main. Switch to your wip branch first." }

git add hooks/pre-commit
git commit -m "chore: update shared pre-commit hook"
```

main への反映と push は、wip を main へ merge した後、ユーザーの明示許可がある場合のみ実行する。

```powershell
git switch main
git merge --no-ff $wip
git push
```

各プロジェクトは `git_project_template/hooks` を直接参照しているため、ローカルでは hook 更新が即時反映される。

## GitHub への初回登録

GitHub 側で `git_project_template` という空リポジトリを作成する。

その後、ローカルで remote まで設定する。

```powershell
cd C:\data\tools\gitRepos\git_project_template

git remote add origin https://github.com/kakato-p/git_project_template.git
```

ユーザーの明示許可がある場合のみ `wip/` ブランチ上で commit する。

```powershell
$wip = git branch --show-current
if ($wip -eq "main") { throw "ERROR: You are on main. Switch to your wip branch first." }

git add .
git commit -m "chore: add git project template"
```

main への反映と初回 push は、wip を main へ merge した後、ユーザーの明示許可がある場合のみ実行する。

```powershell
git switch main
git merge --no-ff $wip
git push -u origin main
```

## 別PCへの復元

GitHub から clone する。

```powershell
cd C:\data\tools\gitRepos

git clone https://github.com/kakato-p/git_project_template.git
```

各プロジェクトで hooksPath を設定する。

```powershell
git config core.hooksPath C:/data/tools/gitRepos/git_project_template/hooks
```

## 注意点

`core.hooksPath` はブランチ単位ではなく、リポジトリ単位の設定。

どのブランチで設定してもよい。

ただし、必ず hook を適用したいプロジェクトのルートで実行する。

誤り：

```powershell
cd C:\data\tools\gitRepos\git_project_template
git config core.hooksPath C:/data/tools/gitRepos/git_project_template/hooks
```

これは `git_project_template` 自身への設定になる。

正しい例：

```powershell
cd C:\data\tools\gitRepos\quote_recorder
git config core.hooksPath C:/data/tools/gitRepos/git_project_template/hooks
```
