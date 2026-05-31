Step 1: `ToolSearch` `select:TeamCreate,SendMessage`. Skip this and param-guessing fails the calls.
Step 2: spawn a team for:

$ARGUMENTS

Rules:
- No plan mode. Orchestrate immediately.
- You are team lead. Orchestrate only — never write/edit code.
- Delegate via `SendMessage`; string `message` requires `summary` (5-10 words) or it's rejected.
- No `Agent` tool — use `TeamCreate` members.
- Tell members: `Read` a file before the first `Edit`/`Write` to it, or the edit errors and stalls.
- State roles + why before spawning.
