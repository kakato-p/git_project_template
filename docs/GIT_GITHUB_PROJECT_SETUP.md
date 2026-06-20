# Git/GitHub 新規プロジェクト導入手順

## 目的

新規プロジェクトに Git を導入し、共通 hook を適用し、GitHub の空リポジトリへ連携する。

この手順では、最初にプロジェクト名を 1 回入力するだけで、基本設定を自動実行できる PowerShell コマンドを用意する。

---

## 概要

1. 新規プロジェクト作成から Git 初期設定まで自動実行
2. 初回コミット
3. GitHub 側で空リポジトリを作成し、remote を設定
4. 明示許可後に main へマージして GitHub に push
5. 以後の標準作業フロー
6. チェックリスト
7. 重要ポイント

---

## 前提

### 標準ディレクトリ

```text
C:\data\tools\gitRepos
```

### 共通 hook ディレクトリ

```text
C:\data\tools\gitRepos\git_project_template\hooks
```

### GitHub アカウント

```text
kakato-p
```

### 今回のテンプレート管理プロジェクト名

```text
git_project_template
```

このリポジトリは、各プロジェクトへ直接コピーして使うものではなく、Git/GitHub 導入手順・共通 hook・運用マニュアルを管理する専用リポジトリとして扱う。

### 共通rules

Agent作業時は、対象プロジェクトの固有手順に加えて以下を参照する。

```text
C:\data\tools\gitRepos\rules\git.md
C:\data\tools\gitRepos\rules\edit_policy.md
C:\data\tools\gitRepos\rules\python.md
C:\data\tools\gitRepos\rules\vba.md
C:\data\tools\gitRepos\rules\writing_style.md
```

### Git運用の前提

- 作業前に `git branch --show-current; git status` を確認する
- `main` ブランチで直接編集しない
- `main` の場合は `wip/yyyy-MMdd-HHmm` ブランチを作成してから編集する
- commit / push はユーザーの明示許可がある場合のみ実行する
- hook失敗時は原因を直すか、修正不能な理由を報告する
- hook失敗時に `--no-verify` で勝手に回避しない

---

# 1. 新規プロジェクト作成から Git 初期設定まで自動実行

## 1-1. プロジェクト名を指定して実行

以下を PowerShell で実行する。

```powershell
# ==========================================================
# 設定値
# ==========================================================

# ↓ここを毎回書き換える↓
$projectName = "new_project_name"

# 通常は変更不要
$githubUser = "kakato-p"
$repoRoot = "C:\data\tools\gitRepos"
$templateRoot = "C:\data\tools\gitRepos\git_project_template"
$hooksPath = Join-Path $templateRoot "hooks"

$projectPath = Join-Path $repoRoot $projectName

# $projectPath のフォルダが存在しない場合だけ、新しくフォルダを作成する
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

# 共通 .gitignore を配置
if (-not (Test-Path ".gitignore")) {
    Copy-Item (Join-Path $templateRoot ".gitignore") .gitignore
}

# 共通 .gitattributes を配置
if (-not (Test-Path ".gitattributes")) {
    Copy-Item (Join-Path $templateRoot ".gitattributes") .gitattributes
}

# README.md が存在しない場合、新規生成
if (-not (Test-Path "README.md")) {
@"
# $projectName

## 概要

このプロジェクトの説明を記載する。
"@ | Set-Content -Path "README.md" -Encoding UTF8
}

git status
git config --show-origin --get core.hooksPath
```

---

## 1-2. 実行後に確認すること

```powershell
git status
```

期待例：

```text
On branch wip/yyyy-MMdd-HHmm

No commits yet

Untracked files:
  .gitattributes
  .gitignore
  README.md
```

hook 設定確認：

```powershell
git config --show-origin --get core.hooksPath
```

期待例：

```text
file:.git/config    C:/data/tools/gitRepos/git_project_template/hooks
```

---

# 2. 初回コミット

main 直コミット防止 hook があるため、初回ファイル追加も `wip/` ブランチで行う。

作業前にブランチと状態を確認する。

```powershell
git branch --show-current
git status
```

現在ブランチが `main` の場合は、編集・commit 前に `wip/` ブランチを作成する。

```powershell
$ts = Get-Date -Format "yyyy-MMdd-HHmm"
$wip = "wip/$ts"
git switch -c $wip
git branch
```

ユーザーの明示許可がある場合のみ、初期ファイルを追加して commit する。

```powershell
git add .
git commit -m "chore: 初期ファイルを追加"
```

hook が失敗した場合、`--no-verify` で回避せず、原因を直すか修正不能な理由を報告する。

---

# 3. GitHub 側で空リポジトリを作成し、remote を設定

GitHub で空リポジトリを作成する。

```text
https://github.com/
```

手順：

1. GitHub にアクセスする
2. 右上の ＋ をクリック
3. New repository をクリック
4. Repository name に `$projectName` に指定した名前を入力する
5. Description は任意。空欄でOK
6. Visibility は Private を選択
7. 画面下の初期化オプションは全部オフ
8. Create repository をクリック

Repository name 例：

```text
tradingLog
```

## remote を設定する

GitHub 側で空リポジトリを作成したあと、ローカル側で remote を設定する。

```powershell
git remote remove origin 2>$null
git remote add origin "https://github.com/kakato-p/$projectName.git"
git remote -v
```

期待例：

```text
origin  https://github.com/kakato-p/<projectName>.git (fetch)
origin  https://github.com/kakato-p/<projectName>.git (push)
```


注意：

- README を作成しない
- .gitignore を作成しない
- LICENSE を作成しない
- ローカル側に既に初期ファイルがあるため、GitHub 側は空リポジトリにする

---

# 4. 明示許可後に main へマージして GitHub に push

main への反映と push は、ユーザーの明示許可がある場合のみ実行する。

実行前に、現在ブランチが `wip/` であることを確認する。

```powershell
$wip = git branch --show-current
if ($wip -eq "main") { throw "ERROR: You are on main. Switch to your wip branch first." }

git switch main
git merge --no-ff $wip
git push -u origin main
```

`git push -u origin main` が pre-push hook で拒否された場合は、`git log --oneline --graph --decorate -5` で `main` の先頭が merge commit になっているか確認する。

確認：

```powershell
git status
```

期待例：

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```


---

# 5. 以後の標準作業フロー

## 作業開始

```powershell
git branch --show-current
git status

git switch main
git pull --ff-only

$ts = Get-Date -Format "yyyy-MMdd-HHmm"
$wip = "wip/$ts"
git switch -c $wip

git status
```

## 作業後

commit はユーザーの明示許可がある場合のみ実行する。

```powershell
git diff --name-only
git add -A
git diff --staged --name-status
# 適時書き換え ↓
git commit -m "chore: xlsm初期状態の登録 (recorder.xlsm)"
git status
```

## main へ反映

main への merge / push はユーザーの明示許可がある場合のみ実行する。

```powershell
$wip = git branch --show-current
if ($wip -eq "main") { throw "ERROR: You are on main. Switch to your wip branch first." }

git switch main
git pull --ff-only
git merge --no-ff $wip -m "Merge $wip"
git push
```


## main へwipが反映済みか確認

```powershell
git branch --merged main
```

## wipが反映済みなら、削除

```powershell
git branch -d $wip
```

---

# 6. チェックリスト

```text
□ プロジェクトフォルダ作成済み
□ git init 済み
□ main ブランチ化済み
□ .gitignore 作成済み
□ .gitattributes 作成済み
□ README.md 作成済み
□ core.hooksPath 設定済み
□ git config --show-origin --get core.hooksPath で確認済み
□ main 直編集禁止を確認済み
□ wipブランチ作成済み
□ GitHub に空リポジトリ作成済み
□ origin 設定済み
□ ユーザー明示許可後に初回コミット済み
□ ユーザー明示許可後に main へ --no-ff merge 済み
□ ユーザー明示許可後に git push -u origin main 済み
□ git status が clean
```

---


# 7. 重要ポイント

## core.hooksPath はプロジェクトごとの local 設定

以下のコマンドで設定した `core.hooksPath` は、その Git リポジトリの `.git/config` に保存される。

```powershell
git config core.hooksPath C:/data/tools/gitRepos/git_project_template/hooks
```

そのため、新規プロジェクトごとに 1 回設定する。

## 共通 hook を編集した場合

```text
C:\data\tools\gitRepos\git_project_template\hooks\pre-commit
C:\data\tools\gitRepos\git_project_template\hooks\pre-push
C:\data\tools\gitRepos\git_project_template\hooks\post-checkout
```

これらを編集すると、保存後すぐに反映される。

各プロジェクトでコピーし直す必要はない。

## GitHub に保存するもの

この `git_project_template` リポジトリには、以下を保存する。

```text
git_project_template
├── .gitattributes
├── .gitignore
├── README.md
├── docs
│   ├── GIT_GITHUB_PROJECT_SETUP.md
│   └── VBA_EXPORT_GIT_FLOW.md
└── hooks
    ├── pre-commit
    ├── pre-push
    └── post-checkout
```

各プロジェクトで実際に参照する hook は以下を標準とする。

```text
C:\data\tools\gitRepos\git_project_template\hooks
```
git_project_template/hooks は GitHub 管理対象であり、各プロジェクトから直接参照する共通 hook 置き場として扱う。
