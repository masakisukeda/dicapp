#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SKIP_PREPARE="${SKIP_PREPARE:-0}"

FTP_HOST="${FTP_HOST:-s137.coreserver.jp}"
FTP_USER="${FTP_USER:-}"
FTP_PASS="${FTP_PASS:-}"
FTP_BASE="${FTP_BASE:-ftp://$FTP_HOST/public_html/drsp.cc/dic}"

if [[ -z "$FTP_USER" || -z "$FTP_PASS" ]]; then
  echo "FTP_USER / FTP_PASS を環境変数で指定してください" >&2
  exit 1
fi

if [[ "$SKIP_PREPARE" != "1" ]]; then
  echo "[1/3] app.js バージョン更新"
  "$ROOT_DIR/scripts/bump_app_version.sh"

  echo "[2/3] sitemap / robots / llms 再生成"
  node "$ROOT_DIR/scripts/build-search-assets.js"
else
  echo "[1/3] prepare step skipped (SKIP_PREPARE=1)"
  echo "[2/3] prepare step skipped (SKIP_PREPARE=1)"
fi

echo "[3/3] 本番アップロード"
files=(
  "$ROOT_DIR/index.html"
  "$ROOT_DIR/app.js"
  "$ROOT_DIR/css/site.css"
  "$ROOT_DIR/css/site.min.css"
  "$ROOT_DIR/robots.txt"
  "$ROOT_DIR/sitemap.xml"
  "$ROOT_DIR/llms.txt"
)

for file in "${files[@]}"; do
  name="$(basename "$file")"
  echo "- upload: $name"
  curl --fail --silent --show-error \
    -T "$file" \
    -u "$FTP_USER:$FTP_PASS" \
    "$FTP_BASE/$name" >/dev/null
 done

echo "Deploy complete"
