# agent/run_agent.py
import os, dotenv
from pydantic_ai import Agent
from .tools import change_panel_color
import asyncio

dotenv.load_dotenv()    # loads OPENAI_API_KEY
agent = Agent(
    llm="o4-mini",                # OpenAI GPT-4o mini
    tools=[change_panel_color],
    system="You are a Grafana-as-code assistant. "
           "Always call a tool; never answer free-form.",
    # budget_usd=0.05
)

# if __name__ == "__main__":
#     while True:
#         q = input(">>> ")
#         if q.lower() in {"exit", "quit"}:
#             break
#         # ------------- await the coroutine -----------------
#         response = asyncio.run(agent.run(q))
#         print(response)         # <— use .chat instead of ()

if __name__ == "__main__":
    prompt = "Make the background of the KPI Visits panel red"
    response = asyncio.run(agent.run(prompt))    # await the coroutine
    print(response)      