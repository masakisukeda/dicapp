# AGENTS.md (辞書アプリ)

このプロジェクトを編集する AI / 自動化ツール向けの「最初に読む」運用メモです。

## 共通ルール（最優先）
- 共通指示書（最新版URL）: `https://drsp.cc/app/AGENTS.md`
- ローカル編集元: `/Users/masakisukeda/Library/CloudStorage/GoogleDrive-masaki.sukeda@gmail.com/マイドライブ/Playground/AGENTS.md`
- スコープは `/app` `/chat` `/dic` `/mng` のみ。無関係フォルダの編集・デプロイは禁止。
- デプロイはFTP経由。`/dic` 以外へアップロードしないこと。

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
- CSSを変更した場合は必ず `bash scripts/build-css.sh` を実行すること。
  - `site.min.css` 再生成 + `index.html` の CSS バージョン番号を自動更新する。
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
- 推奨: `./scripts/deploy_prod.sh`
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

## 6. NG
- 指示のない大規模リファクタ。
- 無関係なデザイン変更。
- デプロイなしで「反映済み」と報告。
- 機密値のハードコード。
