#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
WORDNET_APP="$ROOT/build/WordNet.app"
INSTALLER="$ROOT/build/WordNet Installer.app"
CONTENTS="$INSTALLER/Contents"
RESOURCES="$CONTENTS/Resources"

if [ ! -d "$WORDNET_APP" ]; then
    "$ROOT/build-app.sh"
fi

rm -rf "$INSTALLER"
mkdir -p "$CONTENTS/MacOS" "$RESOURCES"

swiftc -swift-version 5 -parse-as-library -O -framework AppKit \
    "$ROOT/InstallerApp.swift" \
    -o "$CONTENTS/MacOS/WordNetInstaller"
ditto "$WORDNET_APP" "$RESOURCES/WordNet.app"
cp "$ROOT/WordNet.icns" "$RESOURCES/WordNet.icns"

cat > "$CONTENTS/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>English</string>
    <key>CFBundleExecutable</key>
    <string>WordNetInstaller</string>
    <key>CFBundleIconFile</key>
    <string>WordNet</string>
    <key>CFBundleIdentifier</key>
    <string>com.mulle-kybernetik.wordnet.installer</string>
    <key>CFBundleName</key>
    <string>WordNet Installer</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.13</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

echo "Built $INSTALLER"
