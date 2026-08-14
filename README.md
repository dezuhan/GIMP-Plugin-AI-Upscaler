# AI Upscaler for GIMP 3.2

Enhance image sharpness with [Real-ESRGAN](https://github.com/xinntao/Real-ESRGAN) Vulkan GPU. Upscales 2x or 4x, then scales back to original size — **sharper image, same dimensions**. Cross-platform: Linux, Windows, macOS. No Python or CUDA required.

## Requirements

- GIMP 3.2+
- **GPU with Vulkan support** — no CPU fallback available
- `wget` or `curl` + `unzip` (install-time only)

## Dependencies

| Layer | Dependency | Required | Notes |
|-------|-----------|:--------:|-------|
| System | Vulkan driver | Required | NVIDIA / AMD / Intel / MoltenVK (Apple) |
| System | `wget` or `curl` + `unzip` | Install-time | Download & extract binary |
| Binary | `realesrgan-ncnn-vulkan` | Required | Standalone C++, ~11 MB (auto-downloaded) |
| Models | `realesrgan-x4plus.bin` + `.param` | Required | 32 MB, photos (included) |
| Models | `realesrgan-x4plus-anime` | Optional | 9 MB, anime (included) |
| Models | `realesr-animevideov3-x4` | Optional | 1 MB, animation (included) |
| Python | Python 3 (GIMP built-in) | Required | Plugin glue only, not the AI engine |

**Total install size**: ~55 MB.

### GPU / Platform Support

| Platform | GPU | Vulkan Support | Status |
|----------|-----|:-------------:|:------:|
| Linux | NVIDIA / AMD / Intel | Vulkan driver | Works |
| Windows | NVIDIA / AMD / Intel | Vulkan driver | Works |
| macOS | Apple Silicon / AMD / Intel | MoltenVK | Works |
| Any | CPU-only | No Vulkan | **Does not work** |

## Install

### Automatic (recommended)

**Linux / macOS:**
```bash
chmod +x install.sh && ./install.sh
```

**Windows:** Install [Git Bash](https://git-scm.com/downloads/win), right-click the plugin folder → **Git Bash Here**, then:
```bash
chmod +x install.sh && ./install.sh
```

---

### Manual Install

#### Linux / macOS

```bash
# 1. Download the Real-ESRGAN Vulkan binary
#    Linux (Ubuntu):
wget https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesrgan-ncnn-vulkan-20220424-ubuntu.zip
#    macOS:
curl -L https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesrgan-ncnn-vulkan-20220424-macos.zip -o realesrgan.zip

# 2. Extract
unzip realesrgan-ncnn-vulkan-20220424-ubuntu.zip -d /tmp/realesrgan/
# or macOS: unzip realesrgan.zip -d /tmp/realesrgan/

# 3. Copy binary and models to plugin folder
PLUGINS=~/.config/GIMP/3.2/plug-ins
mkdir -p "$PLUGINS/ai-upscaler/bin/models"
cp /tmp/realesrgan/realesrgan-ncnn-vulkan "$PLUGINS/ai-upscaler/bin/"
cp bin/models/*.bin bin/models/*.param "$PLUGINS/ai-upscaler/bin/models/"

# 4. Copy plugin files
cp ai-upscaler.py run_upscaler.sh "$PLUGINS/ai-upscaler/"
chmod +x "$PLUGINS/ai-upscaler/ai-upscaler.py"
chmod +x "$PLUGINS/ai-upscaler/run_upscaler.sh"
chmod +x "$PLUGINS/ai-upscaler/bin/realesrgan-ncnn-vulkan"

# 5. Flatpak only — grant host access
flatpak override --user --talk-name=org.freedesktop.Flatpak org.gimp.GIMP
```

#### Windows

```bash
# Run all commands in Git Bash

# 1. Download the Real-ESRGAN Vulkan binary
curl -L https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesrgan-ncnn-vulkan-20220424-windows.zip -o /tmp/realesrgan.zip

# 2. Extract
unzip /tmp/realesrgan.zip -d /tmp/realesrgan/

# 3. Set target path (Git Bash format)
PLUGINS="$APPDATA/GIMP/3.2/plug-ins"
PLUGINS="$(echo "$PLUGINS" | sed 's|\\\\|/|g' | sed 's|C:|/c|')"
mkdir -p "$PLUGINS/ai-upscaler/bin/models"

# 4. Copy binary and models
cp /tmp/realesrgan/realesrgan-ncnn-vulkan.exe "$PLUGINS/ai-upscaler/bin/"
cp bin/models/*.bin bin/models/*.param "$PLUGINS/ai-upscaler/bin/models/"

# 5. Copy plugin files
cp ai-upscaler.py run_upscaler.sh "$PLUGINS/ai-upscaler/"

# 6. Restart GIMP → Filters → Enhance → AI Upscaler
```

## Usage

1. Select a layer
2. **Filters > Enhance > AI Upscaler...**
3. Choose **Scale** (2x or 4x) and **Model** from the dropdown
4. New layer `[name] (enhanced 2x)` appears — same size, better quality

## Models

Three models are included by default. Drop additional `.bin` + `.param` pairs into `bin/models/` — they appear in the dropdown after restart.

| Model | Best for | Size |
|---|---|---|
| `realesrgan-x4plus` | Photos, general purpose | 32 MB |
| `realesrgan-x4plus-anime` | Anime, illustrations | 9 MB |
| `realesr-animevideov3-x4` | Animation, video frames | 1 MB |

**Get more models:** [upscayl/custom-models](https://github.com/upscayl/custom-models) · [OpenModelDB](https://openmodeldb.info/)

## How it works

The plugin uses `realesrgan-ncnn-vulkan`, a standalone C++ binary (NCNN + Vulkan). On Flatpak GIMP, `flatpak-spawn --host` escapes the sandbox.

## Credits & Attribution

All models are free for commercial use.

| Model / Software | Creator | License |
|---|---|---|
| Real-ESRGAN | [Xintao Wang](https://github.com/xinntao/Real-ESRGAN) | BSD 3-Clause |
| realesrgan-x4plus / animevidev3 | Xintao Wang | BSD / MIT |
| NMKD models | [Philip Hofmann (NMKD)](https://upscale.wiki/wiki/User:NMKD) | CC-BY 4.0 |
| NCNN | [Tencent/nihui](https://github.com/Tencent/ncnn) | BSD 3-Clause |

## Related Plugins

- [Remove Background](https://github.com/dezuhan/GIMP-Plugin-Remove-Background) — AI background removal
- [Smart Object Selection](https://github.com/dezuhan/GIMP-Plugin-Smart-Object-Selection) — AI-powered object selection

## License

GNU General Public License v3.0. See [LICENSE](LICENSE).

## Support

If this plugin helps your workflow, consider donating to support further development.

[Support on Ko-fi](https://ko-fi.com/dezuhan)
