# Skill Reference

## Frontmatter Fields

All fields are optional. Only `description` is recommended.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `name` | string | directory name | Display name, becomes `/slash-command`. Lowercase, numbers, hyphens only (max 64 chars). |
| `description` | string | first paragraph of content | What the skill does and when to use it. Claude uses this to decide when to load it. |
| `argument-hint` | string | — | Hint shown during autocomplete. e.g. `[issue-number]`, `[filename] [format]`. |
| `disable-model-invocation` | boolean | `false` | `true` = only user can invoke. Prevents Claude from auto-loading. |
| `user-invocable` | boolean | `true` | `false` = hidden from `/` menu. Only Claude can invoke. |
| `allowed-tools` | string/array | all tools | Tools Claude can use without asking permission when skill is active. |
| `model` | string | inherit | Model to use when skill is active. e.g. `sonnet`, `opus`, `haiku`, or full model ID. |
| `effort` | string | inherit from session | Effort level override. Options: `low`, `medium`, `high`, `xhigh` (Opus 4.7+), `max`. |
| `context` | string | — | Set to `fork` to run in a forked subagent context. |
| `agent` | string | `general-purpose` | Subagent type when `context: fork` is set. Built-in: `Explore`, `Plan`, `general-purpose`, or custom from `.claude/agents/`. |
| `hooks` | object | — | Hooks scoped to skill lifecycle. Supported types: `PreToolUse`, `PostToolUse`, `Stop`. |

### Notes

- `agent` only takes effect when `context: fork` is set
- `Plan` agent is read-only (no Write/Edit tools) — use `general-purpose` if skill writes files
- `allowed-tools` grants permission without user approval when skill is active
- `effort` overrides the session effort level for this skill only

## String Substitutions

Available in skill content (the markdown body, not frontmatter):

| Variable | Description |
|----------|-------------|
| `$ARGUMENTS` | All arguments passed when invoking the skill. If not present in content, arguments are appended as `ARGUMENTS: <value>`. |
| `$ARGUMENTS[N]` | Access a specific argument by 0-based index. e.g. `$ARGUMENTS[0]` for the first argument. |
| `$N` | Shorthand for `$ARGUMENTS[N]`. e.g. `$0` for first, `$1` for second. |
| `${CLAUDE_SESSION_ID}` | Current session ID. Useful for logging or session-specific files. |
| `${CLAUDE_SKILL_DIR}` | Directory containing the skill's SKILL.md. Use to reference bundled scripts or files regardless of working directory. |

### `${CLAUDE_SKILL_DIR}` Usage

Replaces the old `<absolute-path-to-this-skill>` pattern. Use it to reference files bundled with the skill:

```markdown
## Variables

SKILL_TOOLS: ${CLAUDE_SKILL_DIR}/tools
SKILL_ASSETS: ${CLAUDE_SKILL_DIR}/assets
```

This works regardless of where the user invokes the skill from.
