from openai import OpenAI
from pydantic_ai import Agent
from pydantic_ai.models.openai import OpenAIModel
import dotenv, os
dotenv.load_dotenv()             # loads .env into os.environ

from pydantic_ai import Agent, RunContext

roulette_agent = Agent(  
    'openai:gpt-4o-mini',
    deps_type=int,
    output_type=bool,
    system_prompt=(
        'Use the `roulette_wheel` function to see if the '
        'customer has won based on the number they provide.'
    ),
)


@roulette_agent.tool
async def roulette_wheel(ctx: RunContext[int], square: int) -> str:  
    """check if the square is a winner"""
    return 'winner' if square == ctx.deps else 'loser'


# Run the agent
success_number = 18  
result = roulette_agent.run_sync('Put my money on square eighteen', deps=success_number)
print(result.output)  
#> True

result = roulette_agent.run_sync('I bet five is the winner', deps=success_number)
print(result.output)
#> False


# completion = client.chat.completions.create(
#   model="gpt-4o-mini",
#   store=True,
#   messages=[
#     {"role": "user", "content": "write a haiku about ai"}
#   ]
# )

# print(completion.choices[0].message)



# response = client.responses.create(
#     model="gpt-4o-mini",
#     input="Write a one-sentence bedtime story about a unicorn."
# )

# print(response.output_text)