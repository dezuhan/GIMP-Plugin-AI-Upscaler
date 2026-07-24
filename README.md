# AI Upscaler for GIMP 3.2

Enhance image sharpness with [Real-ESRGAN](https://github.com/xinntao/Real-ESRGAN) Vulkan GPU. Upscales 2x or 4x, then scales back to original size — **sharper image, same dimensions**. Cross-platform: Linux, Windows, macOS. No Python or CUDA required.

## Requirements

- GIMP 3.2+
- **Any GPU** with Vulkan — NVIDIA, AMD, Intel Arc, iGPU, Apple Silicon (MoltenVK)

## Install

### Linux / macOS

```bash
chmod +x install.sh && ./install.sh
```

### Windows

Install [Git Bash](https://git-scm.com/downloads/win), right-click the plugin folder → **Git Bash Here**, then run:

```bash
chmod +x install.sh && ./install.sh
```

This downloads the Real-ESRGAN Vulkan binary (~11 MB), copies plugin files, and grants Flatpak permissions.

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
