# Skill Structure Templates

## Minimal Skill (No Optional Sections)

```markdown
---
name: skill-name
description: Does X. Use when user asks to "do X", "run X".
user-invocable: true
---

# Skill Title

## Purpose

One-liner description of what this skill does.
```

## Standard Skill (Internal Variables, No Flags)

```markdown
---
name: skill-name
description: Does X with Y. Use when user asks to "do X", "run X", "configure Y".
allowed-tools: Bash, Read, Write
user-invocable: true
---

# Skill Title

## Purpose

One-liner description.

## Variables

SOME_PATH: ${CLAUDE_SKILL_DIR}/tools
CONFIG_FILE: path/to/config

## Instructions

- Rule 1
- Rule 2

## Workflow

1. Step one
2. Step two
3. Step three

## Report

- Summary of what was done
- Confirm output location
```

## Toolkit Skill (Tools Only — No Workflow/Cookbook)

Use when the skill is a thin router over executable scripts, with no per-tool branching logic in prose.

```markdown
---
name: skill-name
description: <what it does> during development. Use when user says "<trigger>", "/skill-name <input>".
argument-hint: <input> [--tool <name>]
allowed-tools: Bash, Read, Write
user-invocable: true
---

# Skill Title

## Purpose

One-liner.

## Variables

USER_INPUT: $ARGUMENTS

### Flags
- `--tool`: Which tool to run (default: `<first-tool>`)

## Tools

### tool-a
- **Run:** `uv run tools/tool_a.py --input "$INPUT"`
- **Args:** `input (str, required)`
- **Does:** What tool A does in one line.
- **Triggers:** "do thing A", "run a"

### tool-b
- **Run:** `uv run tools/tool_b.py`
- **Args:** none
- **Does:** What tool B does in one line.
- **Triggers:** "do thing B"

## Supporting Files

- `tools/tool_a.py` - Implementation of tool-a (run with uv)
- `tools/tool_b.py` - Implementation of tool-b (run with uv)

## Report

- Show which tool ran and the args used
- Show tool's stdout
- Surface non-zero exit clearly
```

## Hybrid Skill (Tools + Workflow)

Use when tools are invoked from sequential phases.

```markdown
---
name: skill-name
description: <what it does>. Use when user says "<trigger>".
allowed-tools: Bash, Read, Write
user-invocable: true
---

# Skill Title

## Purpose

One-liner.

## Tools

### build
- **Run:** `bun run tools/build.ts`
- **Args:** none
- **Does:** Compiles the project.
- **Triggers:** "build"

### deploy
- **Run:** `bash tools/deploy.sh "$ENV"`
- **Args:** `env (str, required) — staging|prod`
- **Does:** Pushes built artifacts to the target env.
- **Triggers:** "deploy", "push"

## Workflow

### Phase 1: Build
1. Run `build` tool
2. Verify exit code 0

### Phase 2: Deploy
1. Run `deploy` tool with the user-supplied env
2. Tail deploy logs until "OK"

## Supporting Files

- `tools/build.ts` - Build script (run with Bun)
- `tools/deploy.sh` - Deploy script (run with bash)

## Report

- Show which phase reached, which tools fired, and final status
```

## Full Skill (Flags + Supporting Files)

```markdown
---
name: skill-name
description: Does X, Y, Z with multiple modes. Use when user asks to "do X", "run Y", "configure Z".
argument-hint: <input> [--mode a|b|c] [--output path]
allowed-tools: Read, Write, Bash, Glob, Grep
context: fork
user-invocable: true
---

# Skill Title

## Purpose

One-liner description.

## Variables

USER_INPUT: $ARGUMENTS

### Flags
- `--mode`: Execution mode (default: `a`)
- `--output`: Output path (default: current directory)

## Instructions

### Category Rules
- Rule 1
- Rule 2

## Workflow

### Phase 1: Name
**Read:** `workflows/phase-1.md`
1. High-level step
2. High-level step

### Phase 2: Name
**Read:** `workflows/phase-2.md`
1. High-level step
2. High-level step

## Cookbook

### Route A
- **IF:** condition A
- **THEN:** action A
- **EXAMPLES:** "phrase 1", "phrase 2"

### Route B
- **IF:** condition B
- **THEN:** action B
- **EXAMPLES:** "phrase 3", "phrase 4"

## Supporting Files

- `workflows/phase-1.md` - Phase 1 detailed procedure
- `workflows/phase-2.md` - Phase 2 detailed procedure
- `templates/output.template.md` - Output template
- `tools/helper.ts` - Helper script (run with Bun)

## Report

- Show created file structure (tree format)
- Confirm output location
- Summarize what was generated
```
