#!/usr/bin/env bash
# AI Upscaler — Quick Install
# Downloads the Real-ESRGAN Vulkan binary and installs the plugin.
# No Python or CUDA required — just Vulkan GPU.
set -e

PLUGIN_DIR="$(dirname "$(readlink -f "$0")")"
PLUGINS_PATH="$HOME/.config/GIMP/3.2/plug-ins/ai-upscaler"
BIN_DIR="$PLUGINS_PATH/bin"
BINARY_URL="https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesrgan-ncnn-vulkan-20220424-ubuntu.zip"

echo "============================================"
echo " AI Upscaler — Install"
echo "============================================"

# Download binary if not present
if [ ! -f "$BIN_DIR/realesrgan-ncnn-vulkan" ]; then
    echo "[→] Downloading Real-ESRGAN Vulkan binary..."
    mkdir -p "$BIN_DIR"
    wget -q "$BINARY_URL" -O /tmp/realesrgan-ncnn.zip
    unzip -oq /tmp/realesrgan-ncnn.zip -d /tmp/realesrgan-extract/
    mv /tmp/realesrgan-extract/realesrgan-ncnn-vulkan "$BIN_DIR/"
    mv /tmp/realesrgan-extract/models "$BIN_DIR/" 2>/dev/null || true
    chmod +x "$BIN_DIR/realesrgan-ncnn-vulkan"
    rm -rf /tmp/realesrgan-ncnn.zip /tmp/realesrgan-extract
    echo "[✓] Binary installed"
else
    echo "[✓] Binary already installed"
fi

# Install plugin files
cp "$PLUGIN_DIR/ai-upscaler.py" "$PLUGINS_PATH/"
cp "$PLUGIN_DIR/run_upscaler.sh" "$PLUGINS_PATH/"
chmod +x "$PLUGINS_PATH/ai-upscaler.py"
chmod +x "$PLUGINS_PATH/run_upscaler.sh"

# Flatpak permission
if command -v flatpak &> /dev/null && flatpak info org.gimp.GIMP &> /dev/null; then
    flatpak override --user --talk-name=org.freedesktop.Flatpak org.gimp.GIMP 2>/dev/null || true
fi

echo "[✓] Installed to $PLUGINS_PATH"
echo ""
echo "Restart GIMP → Filters → Enhance → AI Upscaler"
