# Prompt Best Practices

## Frontmatter (Saved Prompts Only)

### Format Rules
- Delimit with `---` on its own line (top and bottom)
- Use spaces, never tabs
- Boolean values are lowercase: `true` / `false`
- No frontmatter for display-only prompts

### Recommended Fields
- `description`: What it does + when to use it
- `argument-hint`: When prompt takes `$ARGUMENTS`

## Naming (Saved Prompts)

- Lowercase only
- Hyphens for word separation
- Descriptive and concise: `gen-makefile`, `update-docs`, `check-deps`
- Avoid generic names: `helper`, `run`, `do`

## Description Writing

### Format
```
<What it does>. <When to use it>.
```

### Rules
- First sentence: what the prompt does (action-oriented)
- Second part: when to use it with trigger terms
- Maximum 1024 characters
- Be specific, not generic

## Prompt Quality

### Core Principle
Every line must be actionable. Prompts are consumed by an AI agent, not read by humans.

### Writing Style
- Use imperative mood: "Generate...", "Analyze...", "Check..."
- Be specific about expected behavior
- Define constraints clearly
- Avoid vague instructions like "make it good" or "be thorough"

### What to Include
- Clear purpose statement
- Specific rules and constraints
- Expected output format (Output Contract)
- Input handling (`$ARGUMENTS` when needed)

### What to Exclude
- Explanatory text meant for human readers
- Redundant restatements of the purpose
- Generic advice that applies to everything

## Content Structure

### Single File Only
- Prompts are always single `.md` files
- No supporting directories
- No referenced external files
- If content needs supporting files, it should be a skill

### Size Limit
- Maximum 500 lines
- If exceeding this, suggest gen-skill instead

### Section Order
```
Purpose > Variables > Instructions > Workflow > Output Contract
```

### Section Weighing
- **Most prompts**: Purpose + Instructions + Output Contract
- **With input**: Add Variables
- **With steps**: Add Workflow
- **Too complex?**: Suggest gen-skill

## Output Contract

### Rules
- Always present
- Must have `### On Success` and `### On Failure`
- Format is flexible — whatever fits the prompt's domain
- On Failure should state what went wrong and any partial output

## `$ARGUMENTS` Handling

### When to Include
- Prompt needs user-specified input (file path, name, option)
- Prompt behavior changes based on what the user provides

### When to Skip
- Prompt operates on current project/context
- No user input needed — prompt does the same thing every time

### Frontmatter Pairing
- If `$ARGUMENTS` is used, add `argument-hint` to frontmatter (saved prompts only)
- Use `<required>` and `[optional]` notation in hint

## Anti-patterns

- **Adding Cookbook sections**: Prompts don't have conditional branches. Use gen-skill for that.
- **Creating supporting files**: Prompts are single-file. Use gen-skill for multi-file.
- **Over-engineering**: A prompt is not a skill. Keep it focused and simple.
- **Missing Output Contract**: Every prompt must define success/failure output.
- **Adding frontmatter to display-only prompts**: Only saved prompts get frontmatter.
