# Agent Reference

## Frontmatter Fields

`name` and `description` are required. All other fields are optional.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `name` | string | — | **Required.** Unique identifier. Lowercase letters and hyphens only. |
| `description` | string | — | **Required.** When Claude should delegate to this agent. Used for automatic delegation decisions. |
| `tools` | string/array | all tools | Tools the agent can use. Inherits all tools if omitted. Supports `Agent(type)` syntax to restrict spawnable sub-agents. |
| `disallowedTools` | string/array | — | Tools to deny, removed from inherited or specified list. Applied before `tools`. |
| `model` | string | `inherit` | Model to use: `sonnet`, `opus`, `haiku`, full model ID (e.g. `claude-opus-4-6`), or `inherit`. |
| `effort` | string | inherit from session | Effort level override. Options: `low`, `medium`, `high`, `max` (Opus 4.6 only). |
| `permissionMode` | string | `default` | Permission handling: `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan`. |
| `maxTurns` | number | — | Maximum number of agentic turns before the agent stops. |
| `skills` | string/array | — | Skills to preload into the agent's context at startup. Full skill content is injected. |
| `mcpServers` | array | — | MCP servers available to this agent. Either a server name (string) or inline definition (object). |
| `hooks` | object | — | Lifecycle hooks scoped to this agent. Supported: `PreToolUse`, `PostToolUse`, `Stop`. |
| `memory` | string | — | Persistent memory scope: `user`, `project`, or `local`. Enables cross-session learning. |
| `background` | boolean | `false` | `true` to always run as a background task. |
| `isolation` | string | — | Set to `worktree` to run in a temporary git worktree (isolated copy of repo). |

### Notes

- `name` and `description` are both **required** (unlike skills where only `description` is recommended)
- `tools` uses allowlist approach; `disallowedTools` uses denylist. If both set, `disallowedTools` applied first
- `tools` supports `Agent(worker, researcher)` syntax to restrict which sub-agents can be spawned
- `permissionMode: bypassPermissions` should be used with caution
- `memory` scopes: `user` = `~/.claude/agent-memory/<name>/`, `project` = `.claude/agent-memory/<name>/`, `local` = `.claude/agent-memory-local/<name>/`
- `skills` injects full skill content at startup — agent does not inherit skills from parent conversation
- `mcpServers` can scope MCP servers to an agent without exposing them to the main conversation
- Plugin agents do not support `hooks`, `mcpServers`, or `permissionMode` fields

## Agent Body

The markdown body after frontmatter becomes the agent's **system prompt**. It defines the agent's role, personality, and behavioral guidelines — not procedural task steps.

The agent receives only this system prompt plus basic environment details. It does not receive the full Claude Code system prompt.
