# agent/run_agent.py
import os, dotenv
from pydantic_ai import Agent
from .tools import change_panel_color

dotenv.load_dotenv()    # loads OPENAI_API_KEY
agent = Agent(
    llm="o4-mini",                # OpenAI GPT-4o mini
    tools=[change_panel_color],
    system="You are a Grafana-as-code assistant. "
           "Always call a tool; never answer free-form."
)

if __name__ == "__main__":
    while True:
        q = input(">>> ")
        if q in {"exit", "quit"}:
            break
        print(agent(q))
