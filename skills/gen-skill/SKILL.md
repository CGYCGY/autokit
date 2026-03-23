---
name: gen-skill
description: Creates, generates, and updates Claude Code skills from user ideas. Use when user asks to "create skill", "generate skill", "update skill", "modify skill", "new skill", or describes a skill idea.
argument-hint: [--file | --simple | --output] <skill idea or update description>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
context: fork
user-invocable: true
---

# Skill Generator

## Purpose

Generate or update Claude Code skills from user ideas, producing well-structured SKILL.md files with optional supporting directories.

## Variables

USER_INPUT: $ARGUMENTS

### Flags
- `--file` or `-f`: (default) Save to `.claude/skills/<skill-name>/SKILL.md` with supporting dirs
- `--simple` or `-s`: Single SKILL.md only, no subdirectories
- `--output` or `-o`: Display generated content without saving files

## Instructions

### Operation Detection

- **Create**: No existing skill with that name in `.claude/skills/`
- **Update**: Existing skill found, or user says "update", "modify", "change", "fix"
- For updates: read existing SKILL.md first, apply only requested changes, preserve unchanged sections

### Size & Progressive Loading

- Target 80-120 lines for SKILL.md. Hard max 500 lines.
- SKILL.md is consumed by an agent, not read by humans. Every line must be actionable.
- Code blocks, interfaces, tables, or examples longer than 5 lines MUST go in supporting files, referenced with `**Read:** \`path/to/file.md\``
- Inline only: purpose, variables, high-level rules, workflow phase summaries (2-5 lines each), cookbook route headers
- Reference: detailed procedures, type definitions, lookup tables, full examples, templates

### Description Writing

- Format: `<what it does>. <when to use it>.`
- Include trigger terms users would say to invoke it
- Max 1024 characters
- Be specific, not generic

### Section Weighing

Evaluate the user's idea and include only relevant sections:

- **Variables**: Include when idea mentions configurable options, models, flags, toggles, settings
- **Instructions**: Include when idea has rules, constraints, conditions, decision logic
- **Workflow**: Include when idea has sequential steps, process flow, phases
- **Cookbook**: Include when idea has multiple tools, paths, modes, conditional branches

### Subsection Formatting

- Use `- **Bold Label**:` for simple groupings within a section (2-4 items, no deep nesting)
- Use `### Heading` for substantial content blocks (5+ items, nested content, multi-paragraph)

### Cookbook Format (Fixed)

Every cookbook route must follow:
```
### Route Name
- **IF:** <condition>
- **THEN:** <action>
- **EXAMPLES:** <trigger phrases>
```

### Supporting Directories

Match directory type to content type — do not dump everything into one folder:
- `reference/`: Lookup material — interfaces, type tables, configuration docs, API specs
- `workflows/`: Step-by-step procedures, checklists, multi-phase processes
- `templates/`: Scaffolds and boilerplate to copy/fill
- `cookbook/`: Detailed procedure files for cookbook routes
- `prompts/`: Reusable prompt templates
- `tools/`: Executable scripts (bash, python)

Create only when needed. Do not create empty directories or directories with fewer than 3 files (inline instead).

### Anti-patterns

- Do not generate activation/trigger sections in the body (frontmatter handles this)
- Do not include explanatory text meant for human readers (optimize for agent execution)
- Do not duplicate what the description already says
- Do not create empty supporting directories
- Do not dump all supporting files into one directory type (match dir to content type)

## Workflow

### Phase 1: Parse & Classify

1. Parse user arguments for skill idea and flags (`--file`, `--simple`, `--output`)
2. Determine operation: create or update
3. For updates: read existing `.claude/skills/<skill-name>/SKILL.md`
4. If idea is vague, ask user to clarify: purpose, triggers, inputs/outputs

### Phase 2: Load References

1. **Read** `reference.md` for available frontmatter fields and string substitutions
2. **Read** `best-practices.md` for skill-specific conventions
3. **Read** `templates.md` for structure templates
4. **Read** `examples.md` for reference patterns

### Phase 3: Weigh Sections & Plan Loading

Based on the user's idea, determine which sections to include:

1. Analyze idea for configurable options -> Variables
2. Analyze idea for rules/constraints -> Instructions
3. Analyze idea for sequential steps -> Workflow
4. Analyze idea for conditional branches -> Cookbook
5. For each section, split inline vs reference:
   - Any code block, interface, table, or example > 5 lines → supporting file
   - Workflow phase details > 5 lines → supporting file
   - Instruction with embedded reference data → supporting file
6. Plan supporting directory structure (match dir type to content type)
7. Target 80-120 lines for SKILL.md (hard max 500)

### Phase 4: Generate Skill

1. Compose YAML frontmatter (name, description, and relevant optional fields from `reference.md`)
2. Write Purpose section (one-liner)
3. Write included sections — inline only rules and summaries, use `**Read:** \`path/to/file\`` for reference content
4. Create supporting files grouped by type (reference/, workflows/, templates/, etc.)
5. Apply output mode (`--file`, `--simple`, or `--output`)

### Phase 5: Validate

1. Run through `validation-checklist.md` checks
2. Verify YAML frontmatter format
3. Verify line count under 500
4. Verify description format and length
5. Confirm file location with user
6. Suggest testing: "Try invoking with: /skill-name <test input>"

## Cookbook

### Simple Skill (No Subdirs)

- **IF:** Idea is straightforward, single-purpose, few rules
- **THEN:** Generate single SKILL.md with inline content, suggest `--simple` if not set
- **EXAMPLES:** "create a skill that formats JSON", "make a lint skill"

### Complex Skill (With Subdirs)

- **IF:** Idea has multiple modes, phases, templates, or extensive logic
- **THEN:** Generate SKILL.md + supporting directories (cookbook/, prompts/, workflows/, etc.)
- **EXAMPLES:** "create a skill that generates API documentation with multiple output formats"

### Update Existing Skill

- **IF:** User says "update", "modify", "change", "fix" and skill name matches existing
- **THEN:** Read existing skill, apply changes, preserve unchanged sections
- **EXAMPLES:** "update my deploy skill to add a staging flag", "modify test-runner to support parallel mode"

### Display Only

- **IF:** `--output` flag is set
- **THEN:** Print generated content to chat without writing files
- **EXAMPLES:** "generate a skill for X --output", "show me what a deploy skill would look like"

## Supporting Files

- `reference.md` - All frontmatter fields and string substitutions available for skills
- `best-practices.md` - Skill authoring conventions and rules
- `validation-checklist.md` - Pre and post-generation validation
- `examples.md` - Example skill generations for reference
- `templates.md` - Skill structure templates (minimal, standard, full)
- `claude-docs.md` - Official documentation URLs (for updating gen-skill itself, not used during generation)

## Report

- Show created file structure (tree format)
- Confirm file location
- Summarize which sections were included and why
- Suggest testing: "Try invoking with: `/skill-name <test input>`"

## Key Principles

1. **Context Efficiency**: Every line in generated SKILL.md must be actionable or provide decision-making value
2. **Progressive Loading**: Keep SKILL.md small, reference supporting files for detailed content
3. **One Skill = One Capability**: Each generated skill should do one thing well
4. **Anti-patterns Only Non-obvious**: Do not list obvious opposites of good practices
