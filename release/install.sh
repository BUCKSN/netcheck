#!/usr/bin/env bash
set -e

APP_NAME="netcheck"
BINARY_PATH="/usr/local/bin/netcheck"
INSTALL_PREFIX="$HOME/.local"
SHARE_DIR="$INSTALL_PREFIX/share/$APP_NAME"
ICON_DEST="$HOME/.local/share/icons/hicolor/32x32/apps"
DESKTOP_FILE="$INSTALL_PREFIX/share/applications/$APP_NAME.desktop"

# --- БЛОК ПРОВЕРКИ СУЩЕСТВУЮЩЕЙ УСТАНОВКИ ---
if [ -f "$BINARY_PATH" ] || [ -d "$SHARE_DIR" ] || [ -f "$DESKTOP_FILE" ]; then
    echo "Обнаружена существующая установка $APP_NAME."
    read -p "Переустановить? (y/n): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo "Удаление старой версии..."
        sudo rm -rf "$BINARY_PATH"
        rm -rf "$SHARE_DIR"
        rm -rf "$DESKTOP_FILE"
        rm -rf "$ICON_DEST/netcheck.png"
        echo "Старые файлы удалены. Продолжаем установку..."
    else
        echo "Установка отменена."
        exit 0
    fi
fi
# --------------------------------------------

REPO_USER="BUCKSN"
REPO_NAME="netcheck"
ARCHIVE_URL="https://raw.githubusercontent.com/${REPO_USER}/${REPO_NAME}/main/release/netcheck.tar.gz"

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
# Удаляем архив после распаковки, чтобы он не скопировался в SHARE_DIR
rm -f netcheck.tar.gz

echo "Installing to $INSTALL_PREFIX..."
mkdir -p "$SHARE_DIR"

# Сначала устанавливаем бинарник, затем копируем остальные ассеты
if [ -f "$TMP_DIR/$APP_NAME" ]; then
    install -m 0755 "$TMP_DIR/$APP_NAME" "$SHARE_DIR/$APP_NAME"
fi
cp -r "$TMP_DIR/"* "$SHARE_DIR/"

echo "Creating symlink in /usr/local/bin..."
sudo ln -sf "$SHARE_DIR/$APP_NAME" "$BINARY_PATH"

echo "Installing icon"
mkdir -p "$ICON_DEST"
cp "$SHARE_DIR/data/flutter_assets/assets/images/icon.png" "$ICON_DEST/netcheck.png"

echo "Creating desktop entry..."
mkdir -p "$(dirname "$DESKTOP_FILE")"
tee "$DESKTOP_FILE" > /dev/null <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=netcheck
Comment=A network availability checker for Linux
Exec=$BINARY_PATH
Icon=$ICON_DEST/netcheck.png
Terminal=false
Categories=Network;Utility;
EOF

echo "desktop update"
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$INSTALL_PREFIX/share/applications" >/dev/null 2>&1 || true
fi

echo "Done. Run '$APP_NAME' from menu or from terminal."
