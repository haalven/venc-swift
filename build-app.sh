#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "Building release binary..."
swift build -c release

BINARY=".build/release/venc"
APP_DIR="venc.app/Contents"

echo "assembling venc.app bundle..."
rm -rf venc.app
mkdir -p "$APP_DIR/MacOS" "$APP_DIR/Resources"
cp "$BINARY" "$APP_DIR/MacOS/venc"
cp Info.plist "$APP_DIR/Info.plist"

# Ad-hoc codesign (allows running without Gatekeeper issues locally)
codesign --force --sign - venc.app

echo "Done! Run with: open venc.app"
