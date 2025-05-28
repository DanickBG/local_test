"""
Minimal Jsonnet I/O helpers.
Requires `jsonnet` and `jsonnetfmt` executables in PATH.
"""

from __future__ import annotations
from pathlib import Path
import subprocess, json

def load_jsonnet(path: Path) -> dict:
    raw = subprocess.check_output(
        ["jsonnet", "-J", "vendor", str(path)]
    ) 
    return json.loads(raw)

def save_jsonnet(obj: dict, path: Path) -> None:
    tmp = path.with_suffix(".json")
    print(tmp)
    tmp.write_text(json.dumps(obj, indent=2))
    # formatted = subprocess.check_output(
    #     ["jsonnetfmt", "-J", "vendor", str(tmp)]
    # )    
    # formatted = subprocess.check_output(["jsonnetfmt", str(tmp)])
    # path.write_bytes(formatted)
    # tmp.unlink()
