# grafana_agent.py  – trimmed to the essentials
from pathlib import Path
from pydantic import BaseModel, Field
from pydantic_ai import Agent, RunContext
from converter5 import convert_grafana_json_to_grafonnet
from dataclasses import dataclass

from tools import (
    ChangeColorArgs,
    resolve_dashboard_path, change_panel_color,
)   # your helper that edits the file
import dotenv, os
dotenv.load_dotenv() 

@dataclass
class Deps:
    panel_title: str #= Field(..., description="Exact Stat panel title")
    color: str       #= Field(..., description="Hex or named colour")
    title: str | None 
    uid: str | None  
    id: int | None  
# ────────────────────────────────────────────────────────────
# 1️⃣  create & export the Agent instance
# ────────────────────────────────────────────────────────────
agent = Agent(
    "openai:gpt-4o-mini",
    # deps_type=Path,        # ctx.deps will be a Path to the dashboard
    output_type=str,       # we’ll return the string "done"
    system_prompt=(
        "You are a Grafana-as-code assistant.\n"
        "The user will give you a dashboard's id, uid or title. The id is an integer, uid is one-word-string and title is string. If not clear ask the user what is provided.\n"
        "Use 'find_dashboard' tool to find the dashboard file.\n"
        "Use the available tool 'set_color' to modify the dashboard's panel's colour.\n"
        "Please, ask the user always for confirmation before making any changes.\n"
        "Provide the user with the file name you want to modify. and modify only if they accept it.\n"
    ),
    deps_types = Deps,
)

# ────────────────────────────────────────────────────────────
# 2️⃣  register the single tool
# ────────────────────────────────────────────────────────────
# class SetColorArgs(BaseModel):
#     panel_title: str = Field(..., description="Exact Stat panel title")
#     color: str       = Field(..., description="Hex or named colour")
#     title: str | None = Field(
#         None, description="Dashboard title (optional)"
#     )
#     uid: str | None   = Field(
#         None, description="Dashboard UID (optional)"
#     )
#     id: int | None    = Field(
#         None, description="Dashboard numeric id (optional)"
#     )

@agent.tool
def find_dashboard(ctx: RunContext[Deps],title: str, uid: str, id: int) -> str:
    """
    Find a dashboard by title, uid or id.
    Returns the path to the dashboard file.
    """
    print("Resolving dashboard path with args:", title, uid, id)
    val = None
    key = None
    if len(uid)>1:
        val = uid
        key = "uid"  
    elif len(str(id))>1:
        val = id 
        key = "id"
    elif len(title)> 1:
        val = title 
        key = "title"
    else:
        val = None 
    print(f"Using key: {key}, value: {val}")
    dash_json_path = resolve_dashboard_path(key, val)
    return f"Dashboard found at: {dash_json_path}"

@agent.tool
def set_color(ctx: RunContext[Deps],panel_title: str, color: str, dash_json_path:str) -> str:
    """
    Recolour a Stat panel given dashboard.
    """
    libsonnet_path = Path(dash_json_path).with_suffix(".libsonnet")
    if not libsonnet_path.exists():
        print(f"Creating {libsonnet_path.name} from {dash_json_path}")
        # run converter5.py to produce it
        convert_grafana_json_to_grafonnet(dash_json_path,libsonnet_path.name)
    
    """Change the fixed background colour of a Stat panel."""
    ok = change_panel_color(ChangeColorArgs(path=libsonnet_path.name, title=panel_title, color=color))
    return "done" if ok else f"Panel '{panel_title}' not found."

