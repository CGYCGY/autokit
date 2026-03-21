# Prompt Validation Checklist

## Pre-Creation Checks

- [ ] `best-practices.md` read and understood
- [ ] `reference.md` reviewed for prompt standard sections
- [ ] `examples.md` reviewed for reference patterns
- [ ] Prompt idea is clear enough to proceed (asked user for clarification if vague)
- [ ] Operation type confirmed: create or update
- [ ] Confirmed idea is a prompt, not a skill (no Cookbook, no supporting files, single file)

## Pre-Update Checks (Updates Only)

- [ ] Existing `.claude/commands/<name>.md` read in full
- [ ] Changes requested by user are clearly understood
- [ ] Unchanged sections identified and will be preserved

## Complexity Check

- [ ] Idea does not need multiple execution paths (no Cookbook)
- [ ] Idea does not need supporting files
- [ ] Estimated content is under 500 lines
- [ ] Idea does not have more than 2 distinct modes
- [ ] If any of these fail, suggest gen-skill instead

## Frontmatter Validation (Saved Prompts Only)

- [ ] Opens with `---` on its own line
- [ ] Closes with `---` on its own line
- [ ] No tabs used (spaces only)
- [ ] `description` field present
- [ ] `argument-hint` present if `$ARGUMENTS` is used in body
- [ ] No trailing spaces after values
- [ ] Boolean values are lowercase: `true` / `false`
- [ ] No frontmatter for display-only prompts

## Naming Validation (Saved Prompts Only)

- [ ] All lowercase
- [ ] Hyphens for word separation
- [ ] Descriptive and specific
- [ ] No redundant suffixes (`-prompt`, `-command`)

## Content Validation

### Purpose
- [ ] Present (required)
- [ ] One-liner (1-2 sentences max)
- [ ] Describes what the prompt does

### Variables (if present)
- [ ] `$ARGUMENTS` used correctly in the body
- [ ] `argument-hint` matches the expected input format (saved prompts only)
- [ ] Variables are actually referenced in the prompt body

### Instructions (if present)
- [ ] Each instruction is actionable
- [ ] No human-oriented explanatory text
- [ ] Subsection formatting is consistent

### Workflow (if present)
- [ ] Steps are numbered sequentially
- [ ] Each step has a clear outcome
- [ ] No references to external supporting files

### Output Contract
- [ ] Present (required)
- [ ] Has `### On Success` subsection
- [ ] Has `### On Failure` subsection
- [ ] Format fits the prompt's purpose
- [ ] On Failure includes what went wrong and any partial output

## Size Validation

- [ ] Prompt is under 500 lines
- [ ] Single file only, no supporting directories
- [ ] If over 500 lines, recommend gen-skill instead

## Final Checks

- [ ] Prompt created/updated successfully
- [ ] Output mode correct (display vs save)
- [ ] If saved: file location confirmed to user
- [ ] If saved: testing suggestion provided — "Try invoking with: `/<name> <test input>`"
- [ ] No Cookbook sections present
- [ ] No supporting file references
- [ ] No duplicate content between description and body
- [ ] Output Contract is present
