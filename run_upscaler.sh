#!/usr/bin/env bash
# AI Upscaler runner. Usage: run_upscaler.sh <in> <out> [scale=2] [model_name]
set -e

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
BINARY="$SCRIPT_DIR/bin/realesrgan-ncnn-vulkan"
MODEL_DIR="$SCRIPT_DIR/bin/models"

IN="$1"
OUT="$2"
SCALE="${3:-2}"
MODEL="${4:-realesrgan-x4plus}"

exec "$BINARY" -i "$IN" -o "$OUT" -s "$SCALE" -n "$MODEL" -m "$MODEL_DIR" -f png
