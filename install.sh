#!/usr/bin/env bash
set -e

APP_NAME="netcheck"
INSTALL_PREFIX="$HOME/.local"
SHARE_DIR="$INSTALL_PREFIX/share/$APP_NAME"
DESKTOP_FILE="$INSTALL_PREFIX/share/applications/$APP_NAME.desktop"

REPO_USER="BUCKSN"
REPO_NAME="netcheck"
ARCHIVE_URL="https://raw.githubusercontent.com/${REPO_USER}/${REPO_NAME}/main/netcheck.tar.gz"

TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

echo "Downloading $APP_NAME archive..."
curl -fsSL "$ARCHIVE_URL" -o "$TMP_DIR/netcheck.tar.gz"

echo "Unpacking..."
cd "$TMP_DIR"
tar xzf netcheck.tar.gz

APP_SRC_DIR="$TMP_DIR"

echo "Installing to $INSTALL_PREFIX..."
mkdir -p "$SHARE_DIR"

install -m 0755 "$APP_SRC_DIR/$APP_NAME" "$SHARE_DIR/$APP_NAME"
cp -r "$APP_SRC_DIR/"* "$SHARE_DIR/"

echo "Creating desktop entry..."
mkdir -p "$(dirname "$DESKTOP_FILE")"
tee "$DESKTOP_FILE" > /dev/null <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=netcheck
Comment=A network availability checker for Linux
Exec=$SHARE_DIR/$APP_NAME
Icon=$SHARE_DIR/data/flutter_assets/assets/images/icon.png
Terminal=false
Categories=Network;Utility;
EOF

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database >/dev/null 2>&1 || true
fi

echo "Done. Run '$APP_NAME' from menu or from terminal."
