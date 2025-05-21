# agent/ast.py
from __future__ import annotations
import json, re, subprocess, pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
DASH_PATH = ROOT / "main.libsonnet"   # adjust

class Panel:
    def __init__(self, node: dict):
        self.node = node
    @property
    def title(self) -> str:
        return self.node.get("title", "")
    def set_fixed_color(self, color: str):
        self.node.setdefault("fieldConfig", {}) \
                 .setdefault("defaults", {}) \
                 .setdefault("color", {})["fixedColor"] = color
        self.node["fieldConfig"]["defaults"]["color"]["mode"] = "fixed"

class Dashboard:
    def __init__(self, json_obj: dict):
        self.json = json_obj
    @classmethod
    def load(cls, path=DASH_PATH) -> "Dashboard":
        # jsonnet --> JSON string
        out = subprocess.check_output(["jsonnet", str(path)])
        return cls(json.loads(out))
    def save(self, path=DASH_PATH):
        tmp = path.with_suffix(".json")
        tmp.write_text(json.dumps(self.json, indent=2))
        # optional: fmt round-trip
        fmt = subprocess.check_output(["jsonnetfmt", str(tmp)])
        path.write_text(fmt.decode())
        tmp.unlink()
    # --- query helpers ---
    def find_stat_by_title(self, title: str) -> Panel | None:
        for p in self.json.get("panels", []):
            if p.get("type") == "stat" and re.fullmatch(title, p.get("title", "")):
                return Panel(p)
        return None
