#tools.py
from __future__ import annotations
from pathlib import Path
from pydantic import BaseModel, Field
import os
import json
from typing import Optional
from grafana_ast import load_jsonnet, save_jsonnet

# ─────────────────────────────────────────────────────────────
# 1.  helper: scan exported dashboards
# ─────────────────────────────────────────────────────────────
def find_all_json_with_key_value(folder_path, search_key, search_value):
    """
    Searches all JSON files in a folder and returns a list of file paths
    where the JSON contains the specified key-value pair.

    Args:
        folder_path (str): Path to the folder containing JSON files.
        search_key (str): The key to look for.
        search_value: The value to match.

    Returns:
        list: List of file paths with matching key-value pair.
    """
    matching_files = []
    for filename in os.listdir(folder_path):
        if filename.endswith(".json"):
            file_path = os.path.join(folder_path, filename)
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    if search_key == "id":
                        if data.get("dashboard").get(search_key) == search_value:
                            matching_files.append(file_path)
                    if search_key == "uid":
                        if data.get("dashboard", {}).get(search_key) == search_value:
                            matching_files.append(file_path)
            except (json.JSONDecodeError, IOError):
                continue  # Skip unreadable or malformed files
    return matching_files



def resolve_dashboard_path(key, val) -> Path:
    folder = Path("backup/dashboards")
    matches = find_all_json_with_key_value(folder, key, val)
    if not matches:
        raise FileNotFoundError(f"No dashboard where {key} == {val!r}")
    return matches[0]

# ─────────────────────────────────────────────────────────────
# 3.  mutation: change colour inside .libsonnet
# ─────────────────────────────────────────────────────────────
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
