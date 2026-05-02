# Agent Best Practices

## YAML Frontmatter

### Format Rules
- Delimit with `---` on its own line (top and bottom)
- Use spaces, never tabs
- Consistent 2-space indentation for nested values
- String values with special characters must be quoted
- Boolean values are lowercase: `true` / `false`

### Required Fields
- `name`: Agent identifier. Lowercase, hyphens only
- `description`: When Claude should delegate to this agent

### Common Optional Fields
- **`tools`**: Comma-separated list of allowed tools. Omit to inherit all
- **`disallowedTools`**: Comma-separated list of denied tools
- **`model`**: Model preference (`sonnet`, `opus`, `haiku`, or full ID). Omit to inherit
- **`effort`**: Effort level override (`low`, `medium`, `high`, `xhigh` (Opus 4.7+), `max`). Omit to inherit
- **`permissionMode`**: Permission handling mode. Default: `default`
- **`maxTurns`**: Maximum agentic turns. Omit for unlimited
- **`skills`**: Skills to preload into agent context
- **`mcpServers`**: MCP servers scoped to this agent
- **`memory`**: Persistent memory scope (`user`, `project`, `local`)
- **`hooks`**: Lifecycle hooks (`PreToolUse`, `PostToolUse`, `Stop`)
- **`background`**: `true` to always run in background
- **`isolation`**: `worktree` for isolated git worktree execution

See `reference.md` for full field details, types, and defaults.

## Naming Conventions

- Lowercase only
- Hyphens for word separation (no underscores, no spaces)
- Descriptive but concise: `code-reviewer`, `db-reader`, `api-tester`
- Avoid generic names: `helper`, `agent`, `worker`
- Avoid redundant suffixes: `reviewer-agent`, `tester-agent`

## Description Writing

### Format
```
<What the agent does>. <When to delegate to it>.
```

### Rules
- First sentence: what the agent does (role-oriented)
- Second part: when Claude should delegate to it
- Maximum 1024 characters
- Be specific: "Reviews code for quality and security" not "Reviews code"
- Include delegation triggers: "Use proactively after code changes"
- Do not repeat the agent name in the description

## System Prompt Style

### Core Principle
The agent body is a system prompt — it defines **who the agent is**, not **what steps to follow**.

### Writing Style
- Start with role definition: "You are a...", "You specialize in..."
- Use imperative mood for guidelines: "Focus on...", "Prioritize...", "Always check..."
- Write behavioral rules, not procedural steps
- The agent receives different tasks each time — the prompt must be task-agnostic

### What to Include
- Role and expertise definition
- Domain-specific knowledge and focus areas
- Quality standards and priorities
- How to approach tasks in this domain
- Output format expectations (Output Contract)

### What to Exclude
- Sequential task steps (that is a skill pattern)
- Activation/trigger logic (handled by `description`)
- Explanatory text for human readers
- Redundant restatements of the description

## Content Structure

### Required Sections
- **System Prompt Body**: Role definition and behavioral guidelines (the markdown body itself)
- **Output Contract**: Defines success and failure response format. Always include.

### Optional Sections (Weigh Before Including)

- **Instructions**: When agent has specific rules, constraints, or focus areas
  - Use subsections for grouping related rules
  - Each instruction must be actionable

- **Workflow**: Rare — only when agent always follows a fixed process regardless of task
  - Example: a deployment agent that always validates → builds → deploys → verifies
  - Most agents should NOT have this section

### Section Order
```
System Prompt Body > Instructions > Workflow > Output Contract
```

## Output Contract

### Rules
- Always present in generated agents
- Defines what the agent returns on success and on failure
- Format is flexible — JSON, plain text, structured markdown, whatever fits
- Must have `### On Success` and `### On Failure` subsections
- On Failure should include what went wrong and any partial results

### Format
```markdown
## Output Contract

### On Success
<description of what the agent returns when task completes successfully>

### On Failure
<description of what the agent returns when task fails or partially completes>
```

## Subsection Rules

- **`- **Bold Label**:`** for simple groupings (2-4 items, short descriptions)
- **`### Heading`** for substantial content blocks (5+ items, nested content)
- Do not mix both styles within the same parent section

## Agent Focus & Scope

### One Agent = One Role
- An agent should specialize in one domain
- If an agent covers unrelated domains, split into separate agents
- Agents can be chained from the main conversation for multi-step workflows

### Scope Indicators
- **Too narrow**: Agent only handles one specific file or pattern
- **Too broad**: Agent covers testing, deployment, and documentation
- **Right size**: Focused on one domain (code review, debugging, data analysis)

## Supporting Directories

Create only when content justifies a separate file:

| Directory | When to Create | Content |
|-----------|---------------|---------|
| `prompts/` | Agent needs reusable prompt templates | Template files |
| `reference/` | Agent needs detailed domain reference material | Reference docs |
| `scripts/` | Agent needs executable helper scripts | Bash/Python scripts |

### Rules
- Do not create empty directories
- Do not create a directory for fewer than 3 files (inline instead)
- Keep references one level deep
- File names should be descriptive

## Anti-patterns (Non-obvious Only)

- **Writing task steps in agent body**: Agent body is a system prompt, not a procedure. The task comes from delegation.
- **Omitting Output Contract**: Every agent must define success/failure responses so the caller knows what to expect.
- **Over-restricting tools**: Only restrict when security matters. Too-tight restrictions cause agent failures.
- **Using `permissionMode: bypassPermissions` casually**: Only for trusted, well-tested agents.
- **Preloading too many skills**: Each preloaded skill adds to context. Only preload what the agent always needs.
- **Setting `memory` without purpose**: Only enable memory when the agent benefits from cross-session learning.
