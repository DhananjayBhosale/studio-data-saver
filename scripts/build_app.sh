#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="Studio Data Saver"
VERSION="${VERSION:-$(tr -d '[:space:]' < "$ROOT_DIR/VERSION")}"
BUILD_NUMBER="${BUILD_NUMBER:-1}"
SWIFT_TARGET="${SWIFT_TARGET:-arm64-apple-macosx14.0}"
CODESIGN_IDENTITY="${CODESIGN_IDENTITY:--}"

BUILD_DIR="$ROOT_DIR/StudioDataSaverSwift/Build"
DIST_DIR="$ROOT_DIR/dist"
APP_DIR="$DIST_DIR/$APP_NAME.app"
BINARY_PATH="$BUILD_DIR/StudioDataSaverNative"

rm -rf "$APP_DIR"
mkdir -p "$BUILD_DIR" "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"

sources=()
while IFS= read -r -d '' source_file; do
  sources+=("$source_file")
done < <(find "$ROOT_DIR/StudioDataSaverSwift/Sources" -name '*.swift' -print0 | sort -z)

swiftc \
  -module-cache-path "$BUILD_DIR/ModuleCache" \
  -target "$SWIFT_TARGET" \
  -parse-as-library \
  -o "$BINARY_PATH" \
  "${sources[@]}"

cp "$BINARY_PATH" "$APP_DIR/Contents/MacOS/$APP_NAME"
chmod +x "$APP_DIR/Contents/MacOS/$APP_NAME"

cp "$ROOT_DIR/StudioDataSaverSwift/Packaging/Info.plist" "$APP_DIR/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "$APP_DIR/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUMBER" "$APP_DIR/Contents/Info.plist"

if command -v iconutil >/dev/null 2>&1 && [ -d "$ROOT_DIR/StudioDataSaver.iconset" ]; then
  iconutil -c icns "$ROOT_DIR/StudioDataSaver.iconset" -o "$APP_DIR/Contents/Resources/StudioDataSaver.icns"
elif [ -f "$ROOT_DIR/StudioDataSaver.icns" ]; then
  cp "$ROOT_DIR/StudioDataSaver.icns" "$APP_DIR/Contents/Resources/StudioDataSaver.icns"
fi

printf 'APPL????' > "$APP_DIR/Contents/PkgInfo"
codesign --force --deep --sign "$CODESIGN_IDENTITY" "$APP_DIR"

echo "Built $APP_DIR"
