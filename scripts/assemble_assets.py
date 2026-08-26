#!/usr/bin/env python3
import json
import os
import shutil
import subprocess
from pathlib import Path

SRC = Path("/Users/belzephyrus/.cursor/projects/Users-belzephyrus-Documents-gambling-21AUG/assets")
DEST = Path("/Users/belzephyrus/Documents/gambling/21AUG/App03_GramVault/GramVault/Assets.xcassets")

SPECS = [
    ("gvt_AppIcon.png", 1024, 1024, False),
    ("gvt_Splash.png", 1290, 2796, True),
    ("gvt_Onboarding1.png", 1024, 1536, True),
    ("gvt_Onboarding2.png", 1024, 1536, True),
    ("gvt_Onboarding3.png", 1024, 1536, True),
    ("gvt_EmptyLog.png", 1024, 1024, True),
    ("gvt_EmptySearch.png", 1024, 1024, True),
    ("gvt_EmptyPlan.png", 1024, 1024, True),
    ("gvt_EmptyWish.png", 1024, 1024, True),
    ("gvt_SlotVaultA.png", 512, 512, True),
    ("gvt_SlotVaultB.png", 512, 512, True),
    ("gvt_SlotVaultC.png", 512, 512, True),
    ("gvt_SlotLooseChange.png", 512, 512, True),
    ("gvt_MacroProtein.png", 512, 512, True),
    ("gvt_MacroCarbs.png", 512, 512, True),
    ("gvt_MacroFat.png", 512, 512, True),
    ("gvt_ProductPlaceholder.png", 600, 600, True),
    ("gvt_CardBackdrop.png", 1200, 800, True),
    ("gvt_Texture.png", 2048, 2048, True),
    ("gvt_ControlFace.png", 512, 512, True),
    ("gvt_ScanOverlay.png", 1024, 1024, True),
    ("gvt_TwistHero.png", 1024, 1024, True),
    ("gvt_SuccessMark.png", 512, 512, True),
    ("gvt_HeaderDecor.png", 1200, 600, True),
]

COLORS = {
    "background": (44, 51, 56),
    "surface": (55, 62, 68),
    "ink": (232, 236, 239),
    "accent": (255, 179, 0),
    "gvt_accent": (255, 179, 0),
    "muted": (138, 147, 154),
}


def run(cmd):
    subprocess.check_call(cmd)


def imageset(name: str, filename: str):
    folder = DEST / f"{name}.imageset"
    folder.mkdir(parents=True, exist_ok=True)
    shutil.copy2(filename, folder / Path(filename).name)
    payload = {
        "images": [{"filename": Path(filename).name, "idiom": "universal", "scale": "1x"}],
        "info": {"author": "xcode", "version": 1},
    }
    (folder / "Contents.json").write_text(json.dumps(payload, indent=2))


def colorset(name: str, rgb):
    folder = DEST / f"{name}.colorset"
    folder.mkdir(parents=True, exist_ok=True)
    r, g, b = rgb
    payload = {
        "colors": [
            {
                "color": {
                    "color-space": "srgb",
                    "components": {
                        "alpha": "1.000",
                        "red": f"{r/255:.3f}",
                        "green": f"{g/255:.3f}",
                        "blue": f"{b/255:.3f}",
                    },
                },
                "idiom": "universal",
            }
        ],
        "info": {"author": "xcode", "version": 1},
    }
    (folder / "Contents.json").write_text(json.dumps(payload, indent=2))


def punch_overlay(path: Path):
    try:
        from PIL import Image, ImageDraw
    except ImportError:
        return
    im = Image.open(path).convert("RGBA")
    w, h = im.size
    overlay = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    overlay.paste(im, (0, 0))
    draw = ImageDraw.Draw(overlay)
    inset = int(min(w, h) * 0.18)
    draw.rectangle((inset, inset, w - inset, h - inset), fill=(0, 0, 0, 0))
    # Re-draw only a frame: keep original corners, clear center
    cleared = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    cleared.paste(im, (0, 0))
    mask = Image.new("L", (w, h), 255)
    md = ImageDraw.Draw(mask)
    md.rectangle((inset, inset, w - inset, h - inset), fill=0)
    # keep a thin inner rim
    rim = 18
    md.rectangle((inset, inset, w - inset, h - inset), fill=0)
    md.rectangle((inset, inset, w - inset, inset + rim), fill=255)
    md.rectangle((inset, h - inset - rim, w - inset, h - inset), fill=255)
    md.rectangle((inset, inset, inset + rim, h - inset), fill=255)
    md.rectangle((w - inset - rim, inset, w - inset, h - inset), fill=255)
    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    out.paste(im, (0, 0))
    pixels = out.load()
    for y in range(inset + rim, h - inset - rim):
        for x in range(inset + rim, w - inset - rim):
            pixels[x, y] = (0, 0, 0, 0)
    out.save(path)


def main():
    DEST.mkdir(parents=True, exist_ok=True)
    work = Path("/tmp/gvt_assets")
    work.mkdir(exist_ok=True)
    for name, w, h, allow_alpha in SPECS:
        src = SRC / name
        if not src.exists():
            raise SystemExit(f"missing {src}")
        dest = work / name
        shutil.copy2(src, dest)
        run(["sips", "-z", str(h), str(w), str(dest)])
        if not allow_alpha:
            jpg = work / "tmp.jpg"
            run(["sips", "-s", "format", "jpeg", str(dest), "--out", str(jpg)])
            run(["sips", "-s", "format", "png", str(jpg), "--out", str(dest)])
            jpg.unlink(missing_ok=True)
        if name == "gvt_ScanOverlay.png":
            punch_overlay(dest)
        imageset(name.replace(".png", ""), str(dest))
        if name == "gvt_AppIcon.png":
            icon_dir = DEST / "AppIcon.appiconset"
            icon_dir.mkdir(parents=True, exist_ok=True)
            shutil.copy2(dest, icon_dir / "gvt_AppIcon.png")
            (icon_dir / "Contents.json").write_text(
                json.dumps(
                    {
                        "images": [
                            {
                                "filename": "gvt_AppIcon.png",
                                "idiom": "universal",
                                "platform": "ios",
                                "size": "1024x1024",
                            }
                        ],
                        "info": {"author": "xcode", "version": 1},
                    },
                    indent=2,
                )
            )
    for name, rgb in COLORS.items():
        colorset(name, rgb)
    accent = DEST / "AccentColor.colorset"
    accent.mkdir(parents=True, exist_ok=True)
    (accent / "Contents.json").write_text(
        json.dumps(
            {
                "colors": [
                    {
                        "color": {
                            "color-space": "srgb",
                            "components": {"alpha": "1.000", "red": "1.000", "green": "0.702", "blue": "0.000"},
                        },
                        "idiom": "universal",
                    }
                ],
                "info": {"author": "xcode", "version": 1},
            },
            indent=2,
        )
    )
    print("assets assembled")


if __name__ == "__main__":
    main()
