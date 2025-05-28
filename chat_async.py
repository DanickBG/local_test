# chat_async.py  ── put this next to grafana_agent.py
import asyncio
from pathlib import Path
import traceback
import dotenv, os
dotenv.load_dotenv() 
from grafana_agent import agent   # ← the Agent object you already have

DASH_PATH = Path("main.libsonnet")   # adjust if needed

result = None
while True:
    prompt = input(">>> ").strip()
    if prompt.lower() in {"exit", "quit"}:
        break
    try:
        if result:
            # First run the result is none, so checking before proceeding
            result = agent.run_sync(prompt, message_history=result.all_messages(), deps=DASH_PATH)
            print("With history:")
        else:
            result = agent.run_sync(prompt, deps=DASH_PATH)
            print("without history:")

        print(result.output)        # usually prints 'done'
        print(result.all_messages_json())

    except Exception as e:
        print(e)
        print(traceback.format_exc())

