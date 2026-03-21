# Prompt Reference

## Prompt Standard Sections

Generated prompts follow this structure. Include only what's needed.

| Section | When to Include | Required? |
|---------|----------------|-----------|
| **Purpose** | Always | Yes |
| **Variables** | When prompt needs user input or configurable values | No |
| **Instructions** | When prompt has rules, constraints, or focus areas | No |
| **Workflow** | When prompt has sequential steps (3+ steps) | No |
| **Output Contract** | Always | Yes |

### Purpose
One-liner describing what the prompt does. Present in every generated prompt.

### Variables
User inputs the prompt accepts. Use `$ARGUMENTS` for all arguments or `$ARGUMENTS[N]`/`$N` for positional access.

### Instructions
Rules, constraints, and focus areas. Each instruction should be actionable.

### Workflow
Sequential steps to follow. Number the steps. Keep it concise — if steps need detailed sub-procedures, the idea is better suited as a skill.

### Output Contract
Defines what the prompt produces on success and failure. Always present.

```markdown
## Output Contract

### On Success
<what the prompt produces when task completes>

### On Failure
<what happens when task fails or partially completes>
```

## Frontmatter (Saved Prompts Only)

Saved prompts (`.claude/commands/<name>.md`) can include frontmatter. Display-only prompts do not.

| Field | Required | Description |
|-------|----------|-------------|
| `description` | Recommended | What the prompt does and when to use it. |
| `argument-hint` | No | Hint for expected arguments. e.g. `[project-path]`, `[filename]`. |
| `allowed-tools` | No | Tools the prompt can use. Omit to allow all. |
| `disable-model-invocation` | No | `true` to prevent Claude from auto-invoking. |
| `model` | No | Model to use. Omit to inherit. |
| `effort` | No | Effort level override. Options: `low`, `medium`, `high`, `max`. |

### Notes

- Saved prompts support the same frontmatter as skills, but most fields are unnecessary for simple prompts
- `description` and `argument-hint` are the most commonly used
- `allowed-tools` is useful when the prompt should be restricted (e.g., read-only prompts)

## String Substitutions

Available in prompt content:

| Variable | Description |
|----------|-------------|
| `$ARGUMENTS` | All arguments passed when invoking the prompt. |
| `$ARGUMENTS[N]` | Access a specific argument by 0-based index. |
| `$N` | Shorthand for `$ARGUMENTS[N]`. |
| `${CLAUDE_SESSION_ID}` | Current session ID. |

## Complexity Threshold

If any of these are true, suggest gen-skill instead:

- Needs multiple execution paths (Cookbook)
- Needs supporting files or directories
- Exceeds 500 lines
- Has more than 2 distinct modes of operation
- Needs `context: fork` or agent delegation
