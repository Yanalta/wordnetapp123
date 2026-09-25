#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
APP="$ROOT/build/WordNet.app"
INSTALL_DIR="${1:-$HOME/Applications}"

if [ ! -d "$APP" ]; then
    "$ROOT/build-app.sh"
fi

mkdir -p "$INSTALL_DIR"
INSTALL_DIR=$(CDPATH= cd -- "$INSTALL_DIR" && pwd)
TARGET="$INSTALL_DIR/WordNet.app"
STAGING=$(mktemp -d "$INSTALL_DIR/.WordNet-install.XXXXXX")
BACKUP="$STAGING/Previous-WordNet.app"

cleanup()
{
    if [ -e "$BACKUP" ] && [ ! -e "$TARGET" ]; then
        mv "$BACKUP" "$TARGET"
    fi
    rm -rf "$STAGING"
}
trap cleanup EXIT HUP INT TERM

ditto "$APP" "$STAGING/WordNet.app"
if [ -e "$TARGET" ]; then
    mv "$TARGET" "$BACKUP"
fi
if ! mv "$STAGING/WordNet.app" "$TARGET"; then
    exit 1
fi

echo "Installed WordNet.app to $TARGET"
