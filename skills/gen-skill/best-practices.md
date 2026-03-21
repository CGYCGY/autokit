# Skill Best Practices

## YAML Frontmatter

### Format Rules
- Delimit with `---` on its own line (top and bottom)
- Use spaces, never tabs
- Consistent 2-space indentation for nested values
- String values with special characters must be quoted
- Version numbers must be quoted: `version: "1.0.0"`

### Required Fields
- `name`: Skill identifier (see naming rules below)
- `description`: What it does + when to use it (see description rules below)

### Optional Fields

- **`argument-hint`**: Hint shown to users for expected input. Use `<required>` and `[optional]` notation
- **`allowed-tools`**: Comma-separated list of tools the skill may use. Omit to allow all tools
- **`model`**: Model preference (`sonnet`, `opus`, `haiku`). Omit to use default
- **`context`**: How context is managed
  - `fork`: Isolated context, skill runs in its own thread (recommended for complex skills)
  - Omit for default shared context
- **`agent`**: Agent type for execution
  - `Plan`: For multi-step planning and execution
  - `general-purpose`: For straightforward tasks
  - Omit for default agent
- **`user-invocable`**: `true` if user can trigger directly via `/skill-name`. Default: `false`
- **`disable-model-invocation`**: `true` to prevent model from auto-invoking. Default: `false`
- **`version`**: Semantic version string, quoted: `"1.0.0"`
- **`mode`**: Execution mode if applicable
- **`license`**: License identifier if distributing
- **`hooks`**: Pre/post execution hooks (advanced)

## Naming Conventions

- Lowercase only
- Hyphens for word separation (no underscores, no spaces)
- Maximum 64 characters
- Descriptive but concise: `test-runner`, `api-docs`, `deploy-staging`
- Avoid generic names: `helper`, `utils`, `tool`
- Avoid redundant suffixes: `skill-skill`, `tool-skill`

## Description Writing

### Format
```
<What it does>. <When to use it / trigger terms>.
```

### Rules
- First sentence: what the skill does (action-oriented)
- Second part: when to use it, including natural trigger phrases
- Maximum 1024 characters
- Be specific: "Runs Go unit tests with coverage" not "Tests code"
- Include trigger terms users would say: "Use when user asks to 'run tests', 'check coverage'"
- Do not repeat the skill name in the description

### Trigger Term Patterns
- Use verb phrases: "create X", "generate X", "run X", "deploy X"
- Include variations: "create", "generate", "make", "build" for creation skills
- Include the domain noun: "tests", "docs", "migrations", "deployment"

## Context Efficiency

### Core Principle
SKILL.md is consumed by an AI agent, not read by humans. Every line must earn its place.

### Progressive Loading
- Keep SKILL.md under 500 lines
- Move detailed procedures to supporting files: `workflows/`, `cookbook/`, `prompts/`
- Reference supporting files with: `**Read:** \`path/to/file.md\``
- Agent loads supporting files only when that phase/route is reached

### What to Inline vs Reference
- **Inline**: Purpose, variables, high-level workflow steps, cookbook route headers
- **Reference**: Detailed step-by-step procedures, templates, lengthy examples, extraction logic

### What to Exclude
- Activation/trigger logic (handled by frontmatter `description`)
- Explanatory text for human readers
- Redundant restatements of the description
- Obvious anti-patterns (only include non-obvious, subtle mistakes)

## Content Structure

### Required Section
- **Purpose**: One-liner describing what the skill does. Always present.

### Optional Sections (Weigh Before Including)

- **Variables**: When the skill has configurable options, flags, toggles, settings
  - List each variable with format: `- \`--flag\`: description`
  - Include defaults where applicable

- **Instructions**: When the skill has rules, constraints, conditions, decision logic
  - Use subsections for grouping related rules
  - Each instruction must be actionable (a rule the agent follows)

- **Workflow**: When the skill has sequential steps or phases
  - Number the phases
  - Each phase references supporting files if detailed
  - Keep phase descriptions to 2-5 lines in SKILL.md

- **Cookbook**: When the skill handles multiple paths, modes, or conditional branches
  - Fixed format per route (see below)
  - Routes are pattern-matched by the agent at runtime

### Section Order
```
Purpose > Variables > Instructions > Workflow > Cookbook > Supporting Files
```

## Subsection Rules

- **`- **Bold Label**:`** for simple groupings
  - 2-4 items with short descriptions
  - No deep nesting needed
  - Example: listing 3 output modes

- **`### Heading`** for substantial content blocks
  - 5+ items or nested content
  - Multi-paragraph explanations
  - Contains its own sub-items

Do not mix both styles within the same parent section.

## Cookbook Format (Fixed)

Every cookbook route follows this exact structure:

```markdown
### Route Name
- **IF:** <condition that triggers this route>
- **THEN:** <what the skill does in this case>
- **EXAMPLES:** <example user phrases that match this route>
```

### Rules
- Route Name should be descriptive: "Docker Environment", "Local Development", "New Project"
- IF condition should be evaluable (file exists, flag set, pattern detected)
- THEN should be actionable (run command, read file, generate output)
- EXAMPLES should be natural phrases a user would say
- For complex routes, THEN can reference a supporting file: `**Read:** \`cookbook/route-name.md\``

## Skill Focus & Scope

### One Skill = One Capability
- A skill should do one thing well
- If a skill has unrelated branches, split into separate skills
- Skills can invoke other skills for composition

### Scope Indicators
- **Too narrow**: Skill has only one cookbook route with no variables
- **Too broad**: Skill has 10+ cookbook routes spanning different domains
- **Right size**: 2-6 cookbook routes within a single domain, or a focused workflow

### When to Split
- If two routes share no variables, instructions, or workflow steps
- If the description needs "and" to explain unrelated capabilities
- If supporting files serve completely different purposes

## Supporting Directories

Create only when content justifies a separate file:

| Directory | When to Create | Content |
|-----------|---------------|---------|
| `cookbook/` | Cookbook routes need detailed procedures (>10 lines each) | Route procedure files |
| `prompts/` | Skill needs reusable prompt templates | Template files |
| `tools/` | Skill needs executable scripts | Bash/Python scripts |
| `templates/` | Skill generates files from boilerplate | Template files |
| `workflows/` | Multi-phase processes need detailed steps | Phase procedure files |

### Rules
- Do not create empty directories
- Do not create a directory for fewer than 3 files (inline instead)
- Keep references one level deep (no `workflows/sub/deep/file.md`)
- File names should be descriptive: `detect-environment.md`, not `step1.md`

## Anti-patterns (Non-obvious Only)

- **Embedding full procedures in SKILL.md**: Leads to context bloat. Reference supporting files instead.
- **Generic cookbook conditions**: `IF: user wants X` is untestable. Use observable conditions: `IF: Dockerfile exists`.
- **Mixing agent instructions with human docs**: Agent needs rules and procedures, not explanations of why.
- **Over-specifying allowed-tools**: Restricting tools too tightly causes skill failures. Only restrict when security matters.
- **Putting trigger terms in the body**: The `description` field handles activation. Body instructions are for execution.
- **Creating skills that duplicate built-in commands**: Check if Claude Code already handles it natively.
- **Version field without quotes**: YAML interprets `1.0` as a float. Always quote: `"1.0.0"`.
