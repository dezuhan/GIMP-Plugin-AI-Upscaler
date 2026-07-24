#!/usr/bin/env bash
# AI Upscaler runner. Usage: run_upscaler.sh <in> <out> [scale=2] [model_name]
set -e

# Cross-platform script dir (macOS readlink fallback)
if readlink -f "$0" &>/dev/null; then
    SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
else
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
fi
# Pick the right binary for the platform
if [ -f "$SCRIPT_DIR/bin/realesrgan-ncnn-vulkan.exe" ]; then
    BINARY="$SCRIPT_DIR/bin/realesrgan-ncnn-vulkan.exe"
else
    BINARY="$SCRIPT_DIR/bin/realesrgan-ncnn-vulkan"
fi
MODEL_DIR="$SCRIPT_DIR/bin/models"

IN="$1"
OUT="$2"
SCALE="${3:-2}"
MODEL="${4:-realesrgan-x4plus}"

exec "$BINARY" -i "$IN" -o "$OUT" -s "$SCALE" -n "$MODEL" -m "$MODEL_DIR" -f png
