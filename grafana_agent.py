# grafana_agent.py  – trimmed to the essentials
from pathlib import Path
from pydantic import BaseModel, Field
from pydantic_ai import Agent, RunContext

from tools import change_panel_color,ChangeColorArgs   # your helper that edits the file
import dotenv, os
dotenv.load_dotenv() 
# ────────────────────────────────────────────────────────────
# 1️⃣  create & export the Agent instance
# ────────────────────────────────────────────────────────────
agent = Agent(
    "openai:gpt-4o-mini",
    deps_type=Path,        # ctx.deps will be a Path to the dashboard
    output_type=str,       # we’ll return the string "done"
    system_prompt=(
        "You are a Grafana-as-code assistant.\n"
        "Use the available tool(s) to modify the dashboard passed as `deps`.\n"
        "Please, ask the user always for confirmation before making any changes.\n"
        "Provide the user with the file name you want to modify. and modify only if they accept it.\n"
    ),
)

# ────────────────────────────────────────────────────────────
# 2️⃣  register the single tool
# ────────────────────────────────────────────────────────────
class SetColorArgs(BaseModel):
    panel_title: str = Field(..., description="Exact Stat panel title")
    color: str       = Field(..., description="Hex or named colour")

@agent.tool
def set_color(
    ctx: RunContext[Path],
    panel_title: str,
    color: str,
) -> str:
    """Change the fixed background colour of a Stat panel."""
    ok = change_panel_color(ChangeColorArgs(path=ctx.deps, title=panel_title, color=color))
    return "done" if ok else f"Panel '{panel_title}' not found."

