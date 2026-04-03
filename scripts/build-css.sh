#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CSS_SRC="$ROOT_DIR/css/site.css"
CSS_MIN="$ROOT_DIR/css/site.min.css"
INDEX_HTML="$ROOT_DIR/index.html"
CLEANCSS="$ROOT_DIR/.npm-cache/_npx/73f5446b131a749d/node_modules/.bin/cleancss"
NODE="/usr/local/bin/node"

if [[ ! -f "$CSS_SRC" ]]; then
  echo "site.css が見つかりません" >&2
  exit 1
fi

# 1. site.min.css を再生成
"$NODE" "$CLEANCSS" -o "$CSS_MIN" "$CSS_SRC"
echo "Minified: $CSS_SRC => $CSS_MIN"

# 2. index.html の CSS バージョンを日時で更新 (例: cssmin20260403.1523)
VERSION="cssmin$(date +%Y%m%d.%H%M)"
perl -i -pe "s#(site\.min\.css\?v=)[^\"]+(\"|\')#\${1}$VERSION\${2}#g" "$INDEX_HTML"
echo "Updated CSS version => $VERSION"
echo "- $INDEX_HTML"
