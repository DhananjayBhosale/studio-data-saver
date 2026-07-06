#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${VERSION:-$(tr -d '[:space:]' < "$ROOT_DIR/VERSION")}"
BUILD_NUMBER="${BUILD_NUMBER:-$(date +%Y%m%d%H%M)}"
APP_NAME="Studio Data Saver"
ZIP_PATH="$ROOT_DIR/dist/$APP_NAME-$VERSION.zip"

VERSION="$VERSION" BUILD_NUMBER="$BUILD_NUMBER" "$ROOT_DIR/scripts/build_app.sh"

rm -f "$ZIP_PATH" "$ZIP_PATH.sha256"
(
  cd "$ROOT_DIR/dist"
  ditto -c -k --keepParent "$APP_NAME.app" "$ZIP_PATH"
  shasum -a 256 "$(basename "$ZIP_PATH")" > "$ZIP_PATH.sha256"
)

echo "Release zip: $ZIP_PATH"
echo "Checksum:    $ZIP_PATH.sha256"
