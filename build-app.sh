#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
APP="$ROOT/build/WordNet.app"
CONTENTS="$APP/Contents"
RESOURCES="$CONTENTS/Resources"
LOCALIZED="$RESOURCES/English.lproj"

rm -rf "$APP"
mkdir -p "$CONTENTS/MacOS" "$LOCALIZED"

clang \
    -fno-objc-arc \
    -DUNIX -Dunix \
    -I"$ROOT" \
    -I"$ROOT/WordNetAccess.subproj" \
    -I"$ROOT/WordNetAccess.subproj/wnlib.subproj" \
    "$ROOT/WordNet_main.m" \
    "$ROOT/WNAppController.m" \
    "$ROOT/WNSearchWindowController.m" \
    "$ROOT/WNTextView.m" \
    "$ROOT/WordNetAccess.subproj/WNController.m" \
    "$ROOT/WordNetAccess.subproj/WNResult.m" \
    "$ROOT/WordNetAccess.subproj/wnlib.subproj/binsrch.c" \
    "$ROOT/WordNetAccess.subproj/wnlib.subproj/morph.c" \
    "$ROOT/WordNetAccess.subproj/wnlib.subproj/search.c" \
    "$ROOT/WordNetAccess.subproj/wnlib.subproj/setutil.c" \
    "$ROOT/WordNetAccess.subproj/wnlib.subproj/wnglobal.c" \
    "$ROOT/WordNetAccess.subproj/wnlib.subproj/wnhelp.c" \
    "$ROOT/WordNetAccess.subproj/wnlib.subproj/wnrtl.c" \
    "$ROOT/WordNetAccess.subproj/wnlib.subproj/wnutil.c" \
    -framework Cocoa \
    -o "$CONTENTS/MacOS/WordNet"

cp "$ROOT/WordNetInfo-macos.plist" "$CONTENTS/Info.plist"
/usr/libexec/PlistBuddy -c 'Set :CFBundleIdentifier com.mulle-kybernetik.wordnet' "$CONTENTS/Info.plist"
cp -R "$ROOT/Database" "$RESOURCES/"
cp -R "$ROOT/English.lproj/License.nib" "$LOCALIZED/"
cp -R "$ROOT/English.lproj/SearchWindow.nib" "$LOCALIZED/"
cp -R "$ROOT/English.lproj/WordNet.nib" "$LOCALIZED/"
cp "$ROOT/English.lproj/WordNet.nib/NSAppleMenuImage.tiff" "$LOCALIZED/"
cp "$ROOT/WordNetAccess.subproj/SearchTypes.strings" "$LOCALIZED/"
cp "$ROOT/English.lproj/Credits.rtf" "$LOCALIZED/"
cp "$ROOT/WordNet.icns" "$RESOURCES/"
cp "$ROOT/WordNet.tiff" "$RESOURCES/"

echo "Built $APP"
