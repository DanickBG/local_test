from __future__ import annotations
from pathlib import Path
from pydantic import BaseModel, Field

from grafana_ast import load_jsonnet, save_jsonnet


class ChangeColorArgs(BaseModel):
    path: Path       = Field(..., description="Path to .libsonnet file")
    title: str       = Field(..., description="Exact Stat panel title")
    color: str       = Field(..., description="Hex like #ff0000")


def change_panel_color(args: ChangeColorArgs) -> str:
    """Locate a Stat panel by title and overwrite fixedColor."""
    dash = load_jsonnet(args.path)

    for p in dash.get("panels", []):
        if p.get("type") == "stat" and p.get("title") == args.title:
            (
                p
                .setdefault("fieldConfig", {})
                .setdefault("defaults", {})
                .setdefault("color", {})
            )["fixedColor"] = args.color
            p["fieldConfig"]["defaults"]["color"]["mode"] = "fixed"
            save_jsonnet(dash, args.path)
            return "done"

    raise ValueError(f"Stat panel titled '{args.title}' not found")
