# AGENTS.md (辞書アプリ)

このプロジェクトを編集する AI / 自動化ツール向けの「最初に読む」運用メモです。

## 共通ルール（最優先）
- 共通指示書（最新版URL）: `https://drsp.cc/app/AGENTS.md`
- ローカル編集元: `/Users/masakisukeda/Library/CloudStorage/GoogleDrive-masaki.sukeda@gmail.com/マイドライブ/Playground/AGENTS.md`
- スコープは `/app` `/chat` `/dic` `/mng` のみ。無関係フォルダの編集・デプロイは禁止。
- 通常デプロイは `main` へ push -> GitHub Actions で実施（直接FTPアップロードは禁止）。

## 0. 最初にやること
1. この `AGENTS.md` を最後まで読む。
2. 変更対象を最小化する（無関係なファイルは触らない）。
3. 作業後は構文チェック・表示確認をしてから反映する。

## 1. プロジェクト概要
- 公開URL: `https://drsp.cc/dic/`
- 主要構成:
  - `index.html`: 画面構造
  - `app.js`: 主要ロジック（検索、辞書くん、モーダル、描画）
  - `css/site.css` / `css/site.min.css`: スタイル
  - `data/`: 記事・カテゴリ・カリキュラム・用語データ
  - `api/`: コメント等のAPI

## 2. 変更ルール（重要）
- 変更は原則「最小差分」。
- UI文言は日本語トーンを維持する。
- 入力系モーダルは誤タップで閉じない設計を優先（閉じるは `×` など明示操作）。
- `app.js` の構文エラーを出さない（編集後に `node --check app.js`）。
- CSSビルドは GitHub Actions の deploy ワークフローで自動実行されるため、通常は手動実行不要。
  - `bash scripts/build-css.sh` が `site.min.css` 再生成 + `index.html` の CSS バージョン番号更新を自動で行う。
  - 手動で `site.min.css` を編集したりバージョン番号を書き換えたりしない。

## 3. 辞書くん修正時の注意
- 主要関数:
  - `answerFromDictionary`
  - `findDirectDictionaryMatches`
  - `findGuidedDictionaryMatch`
- 用語系の改善は以下も確認:
  - `GLOSSARY_TERMS`
  - `DICT_KUN_GUIDE_MAP`
  - `DICT_KUN_SYNONYM_GROUPS`
- ヒットしない語は、記事検索だけでなく用語集フォールバックも検討する。

## 4. 本番反映
- 原則: `main` へ push -> GitHub Actions 自動デプロイ
- 緊急障害対応時のみ、ユーザー明示指示がある場合に限り直接FTP反映を許可（事後に `main` へ同内容を反映すること）。
- スクリプト実行内容:
  1. `app.js` のバージョン更新
  2. `sitemap/robots/llms` 再生成
  3. 本番アップロード
- 実行には環境変数 `FTP_USER` / `FTP_PASS` が必要。
- GitHub Actions 自動デプロイを使う場合は、以下のSecretsを設定:
  - `DIC_FTP_HOST`（例: `s137.coreserver.jp`）
  - `DIC_FTP_USER`
  - `DIC_FTP_PASS`
  - `DIC_FTP_BASE`（例: `ftp://s137.coreserver.jp/public_html/drsp.cc/dic`）
- GitHub Actions の `deploy.yml` は FTP デプロイ前に `bash scripts/build-css.sh` を実行する（CSS編集有無にかかわらず毎回実行）。
- 通常デプロイのロールバックは `git revert <commit>` -> `git push origin main` -> 公開URLのHTTP `200`確認で行う。

例:
```bash
cd /Users/masakisukeda/dicapp
FTP_USER='***' FTP_PASS='***' ./scripts/deploy_prod.sh
```

## 5. 反映確認
- `index.html` の `app.js?v=...` が更新されているか。
- 本番JSに修正コードが載っているか。

例:
```bash
curl -fsSL 'https://drsp.cc/dic/index.html' | rg 'app.js\?v='
curl -fsSL 'https://drsp.cc/dic/app.js?v=xxxx' | rg '確認したい関数名'
```

### デバッグメモ（2026-04-03 / toolsカテゴリ）
- 対象URL: `https://drsp.cc/dic/?view=category&id=tools`
- 変更内容: カテゴリ項目に `対象ツール: ...` を表示
- デバッグ回数: 3回
  - 1回目（21:40 JST）: `node --check app.js` OK / ローカル表示で `対象ツール:` を確認
  - 2回目（21:40 JST）: `node --check app.js` OK / ローカル表示で `対象ツール:` を確認
  - 3回目（21:40 JST）: `node --check app.js` OK / ローカル表示で `対象ツール:` を確認
- 補足: 本番URLへの `curl` GET はWAFで `403` になることがあるため、ブラウザ経由（Playwright screenshot）で表示確認する。

## 6. NG
- 指示のない大規模リファクタ。
- 無関係なデザイン変更。
- デプロイなしで「反映済み」と報告。
- 機密値のハードコード。
