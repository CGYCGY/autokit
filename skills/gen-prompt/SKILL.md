---
name: gen-prompt
description: Structures user ideas into well-formatted prompts following a fixed standard. Use when user asks to "create prompt", "generate prompt", "write a prompt", "make a command", or wants to structure a one-time or reusable prompt.
argument-hint: [--save <name> | --output] <prompt idea>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
context: fork
user-invocable: true
---

# Prompt Generator

## Purpose

Structure user ideas into well-formatted prompts following a consistent standard, either for one-time use or saved as reusable commands.

## Variables

USER_INPUT: $ARGUMENTS

### Flags
- `--output` or `-o`: (default) Display structured prompt in chat without saving
- `--save <name>` or `-s <name>`: Save to `.claude/commands/<name>.md` with frontmatter

## Instructions

### Operation Detection

- **Create**: Generate a new structured prompt from the user's idea
- **Update**: User references an existing command to modify — read it first, apply only requested changes

### Output Mode

- **Display** (`--output`, default): Show the structured prompt in chat. No frontmatter.
- **Save** (`--save <name>`): Write to `.claude/commands/<name>.md`. Include frontmatter (`description`, optionally `argument-hint`).

### Prompt Standard

Every generated prompt follows this section structure (include only what's needed):

- **Purpose**: Always. One-liner describing what this prompt does.
- **Variables**: When the prompt needs user input or references configurable values.
- **Instructions**: When the prompt has rules, constraints, or focus areas.
- **Workflow**: When the prompt has sequential steps to follow.
- **Output Contract**: Always. Defines success and failure output.

### Section Weighing

- Most prompts need: Purpose + Instructions + Output Contract
- Add Variables when prompt takes `$ARGUMENTS` or references paths
- Add Workflow when prompt has a clear sequential process (3+ steps)
- If idea needs Cookbook, multiple execution paths, or supporting files — suggest gen-skill instead

### Size Constraint

Generated prompts must stay under 500 lines. Single file only, no supporting directories. If content exceeds 500 lines, the idea is too complex for a prompt — suggest gen-skill.

### Description Writing (Saved Prompts Only)

- Format: `<What it does>. <When to use it>.`
- Include trigger terms
- Max 1024 characters

### `$ARGUMENTS` Handling

- Analyze the idea to detect if it needs user input
- If yes: use `$ARGUMENTS` in the body and add `argument-hint` to frontmatter (saved prompts only)
- If no: skip — prompt operates on current context without arguments

### Anti-patterns

- Do not generate Cookbook sections (that is a skill pattern)
- Do not create supporting files (prompts are single-file)
- Do not add frontmatter for display-only prompts
- Do not write prompts that cover multiple unrelated tasks

## Workflow

### Phase 1: Parse & Classify

1. Parse user arguments for prompt idea and flags (`--save`, `--output`)
2. Determine operation: create or update
3. For updates: read existing `.claude/commands/<name>.md`
4. If idea is vague, ask user to clarify each missing dimension explicitly:
   - **Purpose**: what specific task should the prompt perform?
   - **Input**: does it need `$ARGUMENTS`? If so, what shape?
   - **Output**: what should the prompt produce — file, chat output, structured report?
   - **Mode**: one-time display, or save as a reusable `/command`?
   Do not generate until Purpose and Output are clear.

### Phase 2: Load References

1. **Read** `reference.md` for the prompt standard and available frontmatter
2. **Read** `best-practices.md` for prompt authoring conventions
3. **Read** `examples.md` for reference patterns

### Phase 3: Weigh Sections

Based on the user's idea, determine which sections to include:

1. Purpose (always)
2. Analyze idea for user input needs -> Variables
3. Analyze idea for rules/constraints -> Instructions
4. Analyze idea for sequential steps -> Workflow
5. Output Contract (always)
6. Estimate line count; if > 500, suggest gen-skill instead

### Phase 4: Generate Prompt

1. If saved: compose frontmatter (`description`, optionally `argument-hint`)
2. Write Purpose section
3. Write included sections based on Phase 3 weighing
4. Apply output mode (`--save` or `--output`)

### Phase 5: Validate

1. Run through `validation-checklist.md` checks
2. Verify line count under 500
3. Verify Output Contract is present
4. Verify single file, no supporting directories
5. If saved: confirm file location with user
6. If saved: suggest testing — "Try invoking with: `/<name> <test input>`"

## Supporting Files

- `reference.md` - Prompt standard sections and available frontmatter for saved prompts
- `best-practices.md` - Prompt authoring conventions
- `validation-checklist.md` - Pre and post-generation validation
- `examples.md` - Example prompt generations for reference

## Report

- Show the generated prompt (display mode) or file location (save mode)
- Summarize which sections were included and why
- If saved: suggest testing — "Try invoking with: `/<name> <test input>`"
