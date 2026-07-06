#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${VERSION:-$(tr -d '[:space:]' < "$ROOT_DIR/VERSION")}"
BUILD_NUMBER="${BUILD_NUMBER:-$(date +%Y%m%d%H%M)}"
APP_NAME="Studio Data Saver"
ZIP_PATH="$ROOT_DIR/dist/$APP_NAME-$VERSION.zip"
DMG_PATH="$ROOT_DIR/dist/$APP_NAME-$VERSION.dmg"
DMG_STAGING="$ROOT_DIR/dist/dmg-staging"

VERSION="$VERSION" BUILD_NUMBER="$BUILD_NUMBER" "$ROOT_DIR/scripts/build_app.sh"

rm -f "$ZIP_PATH" "$ZIP_PATH.sha256" "$DMG_PATH" "$DMG_PATH.sha256"
rm -rf "$DMG_STAGING"
(
  cd "$ROOT_DIR/dist"
  ditto -c -k --keepParent "$APP_NAME.app" "$ZIP_PATH"
  shasum -a 256 "$(basename "$ZIP_PATH")" > "$ZIP_PATH.sha256"
)

mkdir -p "$DMG_STAGING"
ditto "$ROOT_DIR/dist/$APP_NAME.app" "$DMG_STAGING/$APP_NAME.app"
ln -s /Applications "$DMG_STAGING/Applications"
hdiutil create \
  -volname "$APP_NAME" \
  -srcfolder "$DMG_STAGING" \
  -ov \
  -format UDZO \
  "$DMG_PATH" >/dev/null
shasum -a 256 "$DMG_PATH" > "$DMG_PATH.sha256"
rm -rf "$DMG_STAGING"

echo "Release zip: $ZIP_PATH"
echo "Zip checksum: $ZIP_PATH.sha256"
echo "Release dmg: $DMG_PATH"
echo "DMG checksum: $DMG_PATH.sha256"
