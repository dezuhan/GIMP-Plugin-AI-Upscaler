#!/usr/bin/env python3
"""
GIMP 3.2 plugin: AI Upscaler
Upscales using Real-ESRGAN Vulkan with selectable models.
Drop .bin + .param pairs into bin/models/.
"""
import gi
gi.require_version('Gimp', '3.0')
gi.require_version('GimpUi', '3.0')
from gi.repository import Gimp, GimpUi, GLib, Gio, GObject

import os
import shutil
import subprocess
import sys
import tempfile
import time

PLUGIN_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_DIR = os.path.join(PLUGIN_DIR, "bin", "models")
IS_FLATPAK = os.path.exists("/.flatpak-info")
IS_WINDOWS = sys.platform == "win32"

_BASH_EXE = None


def _find_bash():
    """Locate bash.exe on Windows (Git Bash / MSYS2)."""
    global _BASH_EXE
    if _BASH_EXE is not None:
        return _BASH_EXE
    bash = shutil.which("bash")
    if bash:
        _BASH_EXE = bash
        return _BASH_EXE
    for candidate in [
        r"C:\Program Files\Git\bin\bash.exe",
        r"C:\Program Files (x86)\Git\bin\bash.exe",
        r"C:\Git\bin\bash.exe",
        r"C:\msys64\usr\bin\bash.exe",
    ]:
        if os.path.exists(candidate):
            _BASH_EXE = candidate
            return _BASH_EXE
    _BASH_EXE = "bash"
    return _BASH_EXE


def _find_models():
    models = []
    try:
        for f in sorted(os.listdir(MODEL_DIR)):
            if f.endswith(".bin"):
                base = f[:-4]
                param = os.path.join(MODEL_DIR, base + ".param")
                if os.path.exists(param):
                    models.append((base, base.replace("_", " ")))
    except FileNotFoundError:
        pass
    if not models:
        models.append(("realesrgan-x4plus", "Real-ESRGAN x4plus (built-in)"))
    return models


def _build_command(script, args):
    if IS_FLATPAK:
        return ["flatpak-spawn", "--host", script] + args
    if IS_WINDOWS:
        return [_find_bash(), script] + args
    return [script] + args


def _run_worker_with_progress(title, args):
    script = os.path.join(PLUGIN_DIR, "run_upscaler.sh")
    Gimp.progress_init(title)
    proc = subprocess.Popen(
        _build_command(script, args),
        stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True
    )
    while proc.poll() is None:
        Gimp.progress_pulse()
        time.sleep(0.12)
    stdout, stderr = proc.communicate()
    Gimp.progress_end()
    return proc.returncode, stdout, stderr


def _(s):
    return s


class AIUpscalerGPU(Gimp.PlugIn):

    def do_query_procedures(self):
        return ["plug-in-ai-upscaler-gpu"]

    def do_create_procedure(self, name):
        procedure = Gimp.ImageProcedure.new(
            self, name, Gimp.PDBProcType.PLUGIN, self.run, None
        )
        procedure.set_image_types("*")
        procedure.set_sensitivity_mask(Gimp.ProcedureSensitivityMask.DRAWABLE)
        procedure.set_menu_label(_("AI Upscaler..."))
        procedure.add_menu_path("<Image>/Filters/Enhance")
        procedure.set_documentation(
            _("Enhance sharpness using AI upscale-then-downscale"),
            _("Upscales with Real-ESRGAN Vulkan GPU, then scales back to "
              "original size. Pick any model from the models folder."),
            name,
        )
        procedure.set_attribution("Dzuhan", "Dzuhan", "2026")

        # Scale choice
        scale_choice = Gimp.Choice.new()
        scale_choice.add("2", -1, _("2x"), _("Double — fast, good"))
        scale_choice.add("4", -1, _("4x"), _("Quadruple — best quality"))
        procedure.add_choice_argument(
            "scale", _("Scale"), _("AI upscale factor before downscale"),
            scale_choice, "2", GObject.ParamFlags.READWRITE
        )

        # Model choice — populated dynamically at run time
        models = _find_models()
        model_choice = Gimp.Choice.new()
        for model_id, model_label in models:
            model_choice.add(model_id, -1, model_label, "")
        default_model = models[0][0] if models else "realesrgan-x4plus"
        procedure.add_choice_argument(
            "model", _("Model"), _("AI model to use (place .bin + .param in models/)"),
            model_choice, default_model, GObject.ParamFlags.READWRITE
        )

        return procedure

    def run(self, procedure, run_mode, image, drawables, config, data):
        script = os.path.join(PLUGIN_DIR, "run_upscaler.sh")
        if not os.path.exists(script):
            Gimp.message("run_upscaler.sh not found. Reinstall the plugin.")
            return procedure.new_return_values(
                Gimp.PDBStatusType.CALLING_ERROR, GLib.Error())

        if not drawables:
            Gimp.message("No active layer selected.")
            return procedure.new_return_values(
                Gimp.PDBStatusType.CALLING_ERROR, GLib.Error())

        drawable = drawables[0]
        orig_w = drawable.get_width()
        orig_h = drawable.get_height()

        # ---------- Show dialog ----------
        GimpUi.init("ai-upscaler")
        dialog = GimpUi.ProcedureDialog.new(
            procedure, config, _("AI Upscaler")
        )
        dialog.fill()

        if not dialog.run():
            dialog.destroy()
            return procedure.new_return_values(
                Gimp.PDBStatusType.CANCEL, GLib.Error())

        dialog.destroy()

        scale = config.get_property("scale")
        model = config.get_property("model")

        Gimp.context_push()
        image.undo_group_start()

        try:
            tmp_dir = tempfile.mkdtemp(prefix="gimp-upscale-")
            in_path = os.path.join(tmp_dir, "input.png")
            up_path = os.path.join(tmp_dir, "upscaled.png")

            # Export active layer only (not whole project)
            tmp_img = Gimp.Image.new(orig_w, orig_h, Gimp.ImageBaseType.RGB)
            tmp_layer = Gimp.Layer.new_from_drawable(drawable, tmp_img)
            tmp_img.insert_layer(tmp_layer, None, 0)
            in_file = Gio.File.new_for_path(in_path)
            Gimp.file_save(Gimp.RunMode.NONINTERACTIVE, tmp_img, in_file, None)
            tmp_img.delete()

            rc, stdout, stderr = _run_worker_with_progress(
                "Enhancing with {} ({}x)...".format(model, scale),
                [in_path, up_path, scale, model]
            )
            if rc != 0 or not os.path.exists(up_path):
                Gimp.message("AI enhance failed:\n" + (stderr or "unknown error"))
                return procedure.new_return_values(
                    Gimp.PDBStatusType.EXECUTION_ERROR, GLib.Error())

            up_file = Gio.File.new_for_path(up_path)
            loaded_img = Gimp.file_load(Gimp.RunMode.NONINTERACTIVE, up_file)
            loaded_layer = loaded_img.get_layers()[0]

            new_layer = Gimp.Layer.new_from_drawable(loaded_layer, image)
            new_layer.set_name(drawable.get_name() + " (enhanced {}x)".format(scale))
            image.insert_layer(new_layer, None, -1)
            loaded_img.delete()

            new_layer.scale(orig_w, orig_h, True)
            new_layer.set_offsets(0, 0)

            Gimp.displays_flush()

        finally:
            image.undo_group_end()
            Gimp.context_pop()

        return procedure.new_return_values(Gimp.PDBStatusType.SUCCESS, GLib.Error())


Gimp.main(AIUpscalerGPU.__gtype__, __import__("sys").argv)
