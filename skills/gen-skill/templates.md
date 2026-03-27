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
