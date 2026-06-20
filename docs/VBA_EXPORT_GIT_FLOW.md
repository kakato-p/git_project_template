# VBA Export / Git Flow

## 目的

この文書は、VBAコードをGitで管理するための標準運用をまとめる。

このプロジェクトに含まれる `vbaCode/allExport.bas` は、VBAコードをGit管理用にエクスポートするための標準テンプレートである。

このプロジェクト自身が、VBA付き業務アプリケーションとして開発されているわけではない。

## このプロジェクトで管理するもの

このプロジェクトでは、以下をテンプレートとして管理する。

```text
vbaCode/allExport.bas
```

`allExport.bas` は、新規または既存の `.xlsm` プロジェクトにコピーして使用する。

## allExport.bas の位置づけ

`allExport.bas` は、Excel VBAの標準モジュールをGit管理用のテキストファイルとしてエクスポートするためのコードである。

主な役割は以下。

- VBAモジュールを `vbaCode/` 配下へエクスポートする
- Gitで差分確認できる形式にする
- `.xlsm` 内部だけにVBAコードが閉じ込められる状態を避ける
- VBAコードの履歴管理・レビュー・復元をしやすくする
- エクスポートした `.bas` / `.cls` の文字コードをGit管理向けに正規化する

## 文字コード方針

VBAからエクスポートされたテキストファイルは、環境によって文字コードが `Shift_JIS` 系になることがある。

このプロジェクトの `allExport.bas` では、Git管理時の文字化けや差分確認の問題を避けるため、エクスポート後の `.bas` / `.cls` を `UTF-8(BOM)` に正規化する。

処理方針は以下。

```text
.bas  : UTF-8(BOM) に変換する
.cls  : UTF-8(BOM) に変換する
.frm  : 変換しない
.frx  : 変換しない
.xlsm : 変換しない
```

`.bas` / `.cls` は、`allExport.bas` 内の `NormalizeTextFileToUtf8Bom` により、`Shift_JIS` として読み込み、`UTF-8(BOM)` として上書き保存する。

`.frm` は、ユーザーフォームに紐づく `.frx` バイナリファイルとの関係があるため、自動変換対象外にする。

`.xlsm` はバイナリファイルであり、文字コード変換の対象外にする。

## Attribute行の扱い

VBAコードを手動編集する場合は、共通 `vba.md` のルールに従う。

- `.bas` / `.cls` を1行でも編集した場合、行頭が `Attribute ` で始まる行をすべて削除する
- 削除対象例は `Attribute VB_Name = ...`、`Attribute ...VB_Invoke_Func = ...`
- `.frm` は `Attribute ` 行の削除対象外とし、削除しない
- `.frm` のフォーム定義、プロパティ、デザイナ由来の行は目的外に変更しない

このリポジトリの `vbaCode/allExport.bas` に残っている `Attribute ` 行は、今回のMD整合修正では変更対象外とする。

## 文字コード運用上の注意

VBAコードを変更した場合は、コミット前に必ず `allExport.bas` を実行し、`vbaCode/` 配下の `.bas` / `.cls` を最新状態かつ `UTF-8(BOM)` に正規化する。

Git上で差分確認する主対象は、`.xlsm` ではなく `vbaCode/` 配下のテキストファイルである。

`.bas` / `.cls` を手動編集した場合は、文字コードが変わらないように注意する。

原則として、VBAコードの正規化は手動変換ではなく `allExport.bas` に任せる。

## 新規 .xlsm プロジェクトでの使い方

新規に `.xlsm` プロジェクトを作成する場合は、以下の流れで使用する。

1. 既存の `.xlsm` を開く
2. VBEを開く
3. `vbaCode/allExport.bas` を新規ブックへドラッグ＆ドロップコピーする

ただし、既存の `.xlsm` が見当たらない場合は、以下の流れで使用する。

1. 対象プロジェクトに `vbaCode/` フォルダを作成する
2. このプロジェクトの `vbaCode/allExport.bas` を対象ブックへコピーする
3. 対象ブック側で `allExport.bas` を実行する
4. VBAモジュールを `vbaCode/` 配下へエクスポートする
5. エクスポートされた `.bas` / `.cls` / `.frm` をGit管理対象にする

例。

```text
project_root
├── docs
│   └── VBA_EXPORT_GIT_FLOW.md
├── vbaCode
│   ├── allExport.bas
│   ├── module1.bas
│   ├── module2.bas
│   └── class1.cls
└── workbook.xlsm
```

## Gitで管理する対象

原則として、以下をGit管理対象にする。

```text
docs/VBA_EXPORT_GIT_FLOW.md
vbaCode/allExport.bas
vbaCode/*.bas
vbaCode/*.cls
vbaCode/*.frm
```

`.xlsm` ファイルをGit管理対象にするかどうかは、プロジェクトごとに判断する。

`.xlsm` を管理する場合でも、VBAコードの差分確認・レビュー・履歴管理は `vbaCode/` 配下のテキストファイルを主対象にする。

## .xlsm ファイルの扱い

`.xlsm` ファイルはバイナリファイルであるため、Git上で詳細な差分確認ができない。

そのため、`.xlsm` は実行用・配布用のブックとして扱い、VBAソースの実質的な管理は `vbaCode/` 配下で行う。

## VBAコード変更時の運用

VBAコードを変更した場合は、コミット前に必ず `allExport.bas` を実行し、最新のVBAコードを `vbaCode/` 配下へエクスポートする。

基本手順。

```powershell
git status
```

Excel側でVBAコードを修正する。

その後、対象ブックで `allExport.bas` を実行する。

```powershell
git diff
git status
```

差分を確認し、問題なければステージする。

```powershell
git add vbaCode
```

必要に応じて `.xlsm` もステージする。

```powershell
git add workbook.xlsm
```

ユーザーの明示許可がある場合のみコミットする。

```powershell
git commit -m "fix: VBAコードを修正 (vbaCode)"
```

## コミット前の確認

コミット前に、少なくとも以下を確認する。

```powershell
git status
git diff
git diff --staged --name-status
```

確認観点。

- `vbaCode/` 配下に最新のVBAコードがエクスポートされている
- `.bas` / `.cls` が `UTF-8(BOM)` に正規化されている
- `.bas` / `.cls` に行頭 `Attribute ` 行が残っていない
- `.frm` の `Attribute ` 行を削除していない
- 変更意図と異なるモジュールが差分に含まれていない
- `.xlsm` のみが変更され、`vbaCode/` が更新されていない状態になっていない
- 不要な一時ファイルが含まれていない

## 注意事項

`vbaCode/allExport.bas` は、各 `.xlsm` プロジェクトへコピーして使用する標準テンプレートである。

このプロジェクトに置いている `allExport.bas` は、Git運用テンプレートとして管理する。

各プロジェクトで使用する場合は、対象プロジェクト側の構成に合わせて、エクスポート先や除外対象を確認する。

## まとめ

- `allExport.bas` はVBAコードをGit管理用にエクスポートするための標準テンプレート
- 新規 `.xlsm` 作成時は、対象ブックへコピーして使用する
- `.bas` / `.cls` は `UTF-8(BOM)` に正規化する
- `.bas` / `.cls` の行頭 `Attribute ` 行は削除対象
- `.frm` の `Attribute ` 行は削除しない
- `.frm` / `.frx` / `.xlsm` は文字コード変換対象外にする
- `.xlsm` はバイナリファイルのため、VBAソース差分は `vbaCode/` 配下で確認する
- VBA変更後は、コミット前に必ずエクスポートする
- `docs/VBA_EXPORT_GIT_FLOW.md` は、その運用方針を明文化する文書
