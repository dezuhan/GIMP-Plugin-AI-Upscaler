#!/usr/bin/env bash
# AI Upscaler — Quick Install
# Downloads the Real-ESRGAN Vulkan binary. Works on Linux, macOS, Windows (Git Bash).
set -e

case "$(uname -s)" in
    Linux*)
        GIMP_PLUGINS="$HOME/.config/GIMP/3.2/plug-ins"
        BINARY_URL="https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesrgan-ncnn-vulkan-20220424-ubuntu.zip"
        BINARY_NAME="realesrgan-ncnn-vulkan"
        ;;
    Darwin*)
        GIMP_PLUGINS="$HOME/Library/Application Support/GIMP/3.2/plug-ins"
        BINARY_URL="https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesrgan-ncnn-vulkan-20220424-macos.zip"
        BINARY_NAME="realesrgan-ncnn-vulkan"
        ;;
    CYGWIN*|MINGW*|MSYS*)
        GIMP_PLUGINS="$APPDATA/GIMP/3.2/plug-ins"
        GIMP_PLUGINS="$(echo "$GIMP_PLUGINS" | sed 's|\\|/|g' | sed 's|C:|/c|')"
        BINARY_URL="https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesrgan-ncnn-vulkan-20220424-windows.zip"
        BINARY_NAME="realesrgan-ncnn-vulkan.exe"
        ;;
esac

PLUGIN_DIR="$(dirname "$(readlink -f "$0")")"
PLUGINS_PATH="$GIMP_PLUGINS/ai-upscaler"
BIN_DIR="$PLUGINS_PATH/bin"

echo "============================================"
echo " AI Upscaler — Install"
echo "============================================"

# Download binary if not present
if [ ! -f "$BIN_DIR/$BINARY_NAME" ]; then
    echo "[→] Downloading Real-ESRGAN Vulkan binary..."
    mkdir -p "$BIN_DIR"
    if command -v wget &> /dev/null; then
        wget -q "$BINARY_URL" -O /tmp/realesrgan-ncnn.zip
    elif command -v curl &> /dev/null; then
        curl -sL "$BINARY_URL" -o /tmp/realesrgan-ncnn.zip
    else
        echo "[!] wget or curl required. Install one and retry."
        exit 1
    fi
    unzip -oq /tmp/realesrgan-ncnn.zip -d /tmp/realesrgan-extract/
    mv /tmp/realesrgan-extract/$BINARY_NAME "$BIN_DIR/" 2>/dev/null || \
        mv /tmp/realesrgan-extract/realesrgan-ncnn-vulkan "$BIN_DIR/$BINARY_NAME" 2>/dev/null || \
        mv /tmp/realesrgan-extract/realesrgan-ncnn-vulkan.exe "$BIN_DIR/$BINARY_NAME" 2>/dev/null
    mv /tmp/realesrgan-extract/models "$BIN_DIR/" 2>/dev/null || true
    chmod +x "$BIN_DIR/$BINARY_NAME" 2>/dev/null || true
    rm -rf /tmp/realesrgan-ncnn.zip /tmp/realesrgan-extract
    echo "[✓] Binary installed"
else
    echo "[✓] Binary already installed"
fi

# Install plugin files
mkdir -p "$PLUGINS_PATH"
cp "$PLUGIN_DIR/ai-upscaler.py" "$PLUGINS_PATH/"
cp "$PLUGIN_DIR/run_upscaler.sh" "$PLUGINS_PATH/"
chmod +x "$PLUGINS_PATH/ai-upscaler.py" 2>/dev/null || true
chmod +x "$PLUGINS_PATH/run_upscaler.sh" 2>/dev/null || true

# Flatpak permission (Linux only)
if command -v flatpak &> /dev/null && flatpak info org.gimp.GIMP &> /dev/null 2>/dev/null; then
    flatpak override --user --talk-name=org.freedesktop.Flatpak org.gimp.GIMP 2>/dev/null || true
fi

echo "[✓] Installed to $PLUGINS_PATH"
echo ""
echo "Restart GIMP → Filters → Enhance → AI Upscaler"
