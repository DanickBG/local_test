# agent/tools.py
from pydantic import BaseModel, Field
from pydantic_ai import Tool
from .ast import Dashboard

class ChangePanelColorArgs(BaseModel):
    panel_title: str = Field(..., description="Exact Grafana panel title")
    color: str       = Field(..., description="Hex or Grafana fixed colour name")

@Tool
def change_panel_color(args: ChangePanelColorArgs) -> str:
    """
    Change the fixed background colour of a Stat panel in demo.libsonnet
    """
    db = Dashboard.load()
    panel = db.find_stat_by_title(args.panel_title)
    if panel is None:
        return f"Panel '{args.panel_title}' not found."
    panel.set_fixed_color(args.color)
    db.save()
    return f"Set colour of '{args.panel_title}' to {args.color}."
