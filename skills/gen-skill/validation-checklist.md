# Skill Validation Checklist

## Pre-Creation Checks

- [ ] `best-practices.md` read and understood
- [ ] `reference.md` reviewed for available frontmatter fields and substitutions
- [ ] `examples.md` reviewed for reference patterns
- [ ] Skill idea is clear enough to proceed (asked user for clarification if vague)
- [ ] Operation type confirmed: create or update

## Pre-Update Checks (Updates Only)

- [ ] Existing `.claude/skills/<skill-name>/SKILL.md` read in full
- [ ] Changes requested by user are clearly understood
- [ ] Unchanged sections identified and will be preserved
- [ ] Supporting files checked for impact of changes

## YAML Frontmatter Validation

- [ ] Opens with `---` on its own line
- [ ] Closes with `---` on its own line
- [ ] No tabs used (spaces only)
- [ ] Consistent indentation (2 spaces for nested values)
- [ ] `description` field present
- [ ] No trailing spaces after values
- [ ] Boolean values are lowercase: `true` / `false`

## Naming Validation

- [ ] All lowercase
- [ ] Hyphens for word separation (no underscores, no spaces, no dots)
- [ ] Maximum 64 characters
- [ ] Descriptive and specific (not `helper`, `utils`, `tool`)
- [ ] No redundant suffix (`-skill`, `-tool`)
- [ ] Name matches directory name in `.claude/skills/`

## Description Validation

- [ ] First sentence describes what the skill does (action verb)
- [ ] Second part describes when to use it with trigger terms
- [ ] Under 1024 characters total
- [ ] Includes relevant trigger phrases: "Use when user asks to..."
- [ ] Specific, not generic ("Runs Go tests with coverage" not "Tests code")
- [ ] Does not simply repeat the skill name
- [ ] Trigger terms cover common variations (create/generate/make/build)

## Optional Fields Validation

### allowed-tools
- [ ] Only specified if restriction is necessary
- [ ] All listed tools are valid Claude Code tool names
- [ ] Not overly restrictive (does not prevent skill from functioning)

### context
- [ ] Set to `fork` for complex, multi-step skills
- [ ] Omitted for simple, quick skills (uses default shared context)

### agent
- [ ] Only set when `context: fork` is present
- [ ] `Plan` only for read-only skills (no Write/Edit)
- [ ] `general-purpose` or omitted for skills that write files

### effort
- [ ] Valid value: `low`, `medium`, `high`, or `max`
- [ ] `max` only with Opus 4.6

### user-invocable
- [ ] `true` if user should trigger via `/skill-name`
- [ ] `false` if only invoked by other skills/agents

### disable-model-invocation
- [ ] `true` only for skills with side effects user should control (deploy, commit, send)
- [ ] `false` or omitted for normal skills

### hooks
- [ ] Hook commands are valid and tested
- [ ] Hook triggers are appropriate (`PreToolUse`, `PostToolUse`, `Stop`)

## File Location Validation

- [ ] Skill directory: `.claude/skills/<skill-name>/`
- [ ] Main file: `.claude/skills/<skill-name>/SKILL.md`
- [ ] Directory name matches `name` field in frontmatter
- [ ] For `--simple` mode: single SKILL.md, no subdirectories
- [ ] For `--output` mode: no files written, content displayed in chat

## Content Validation

### Purpose
- [ ] Present (required)
- [ ] One-liner (1-2 sentences max)
- [ ] Describes what the skill does, not how

### Variables (if present)
- [ ] Internal variables use `${CLAUDE_SKILL_DIR}` for skill-relative paths
- [ ] Flags listed under a `### Flags` subsection (if applicable)
- [ ] Variables are actually used in workflow/instructions
- [ ] Most skills don't need flags — only present when skill parses arguments

### Instructions (if present)
- [ ] Each instruction is actionable (a rule, not an explanation)
- [ ] No human-oriented explanatory text
- [ ] Subsection formatting is consistent (all `- **Bold**:` or all `###`)

### Workflow (if present)
- [ ] Phases are numbered sequentially
- [ ] Each phase has a clear outcome
- [ ] References to supporting files use: `**Read:** \`path/to/file.md\``
- [ ] Phase descriptions are 2-5 lines (detailed content in supporting files)

### Cookbook (if present)
- [ ] Every route follows IF-THEN-EXAMPLES format
- [ ] IF conditions are observable/testable (not vague)
- [ ] THEN actions are specific and actionable
- [ ] EXAMPLES are natural user phrases
- [ ] Route names are descriptive

### Report (if present)
- [ ] Defines what to show user after execution
- [ ] Consistent output format

### Supporting Files
- [ ] All referenced files actually exist
- [ ] No empty directories created
- [ ] No directory with fewer than 3 files (inline instead)
- [ ] File references are one level deep (no nested subdirectories)
- [ ] File names are descriptive (`detect-environment.md`, not `step1.md`)

## Size & Progressive Loading Validation

- [ ] SKILL.md targets 80-120 lines (hard max 500)
- [ ] No code block, interface definition, or table > 5 lines inlined in SKILL.md
- [ ] Reference content (type defs, lookup tables, full examples) is in supporting files
- [ ] Supporting files are referenced with `**Read:** \`path/to/file\``
- [ ] Supporting directories match content type (reference/, workflows/, templates/ — not all in one folder)

## Final Checks

- [ ] Skill created/updated successfully (files written without errors)
- [ ] File location confirmed to user
- [ ] Testing suggestion provided: "Try invoking with: `/skill-name <test input>`"
- [ ] No activation/trigger logic in the body (handled by frontmatter)
- [ ] No duplicate content between description and body
- [ ] No obvious anti-patterns from `best-practices.md`

## Quick Red Flags

Stop and fix if any of these are true:

- Description is just the skill name restated
- Cookbook routes use vague conditions: "IF: user wants X"
- SKILL.md exceeds 500 lines with no supporting files
- Variables are listed but never referenced in workflow/instructions
- Multiple unrelated capabilities crammed into one skill
- Trigger terms missing from description
- Tabs used anywhere in YAML frontmatter
- Supporting files referenced but not created
- Empty directories exist in the skill folder
- `agent: Plan` used but skill writes files
- All supporting files dumped into a single directory type (should match content type)
- SKILL.md has inlined code blocks, tables, or interfaces > 5 lines (move to supporting files)
