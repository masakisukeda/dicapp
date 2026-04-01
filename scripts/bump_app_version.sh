#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_JS="$ROOT_DIR/app.js"
INDEX_HTML="$ROOT_DIR/index.html"

if [[ ! -f "$APP_JS" || ! -f "$INDEX_HTML" ]]; then
  echo "app.js または index.html が見つかりません" >&2
  exit 1
fi

# Fixed rule: YYYYMMDD.HHMM (JST local time)
VERSION="$(date +%Y%m%d.%H%M)"

perl -0777 -i -pe "s/const CONTENT_ASSET_VERSION = '[^']+';/const CONTENT_ASSET_VERSION = '$VERSION';/g" "$APP_JS"
perl -0777 -i -pe "s#(\./app\.js\?v=)[^\"']+(\" defer></script>)#\${1}$VERSION\${2}#g" "$INDEX_HTML"

echo "Updated app asset version => $VERSION"
echo "- $APP_JS"
echo "- $INDEX_HTML"
