---
name: gen-agent
description: Creates, generates, and updates Claude Code agents from user ideas. Use when user asks to "create agent", "generate agent", "new agent", "update agent", "modify agent", or describes an agent idea.
argument-hint: [--file | --simple | --output] <agent idea or update description>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
context: fork
user-invocable: true
---

# Agent Generator

## Purpose

Generate or update Claude Code agent `.md` files from user ideas, producing well-structured agent definitions.

## Variables

USER_INPUT: $ARGUMENTS

### Flags
- `--file` or `-f`: (default) Save to `.claude/agents/<agent-name>.md`
- `--output` or `-o`: Display generated content without saving files

## Instructions

### Operation Detection

- **Create**: No existing agent with that name in `.claude/agents/`
- **Update**: Existing agent found, or user says "update", "modify", "change", "fix"
- For updates: read existing `.claude/agents/<agent-name>.md` first, apply only requested changes, preserve unchanged sections

### Agent vs Skill Awareness

- Agents define *who the agent is* (system prompt), not *what steps to follow* (task instructions)
- Agent body should read as a role/personality: "You are a...", "Focus on...", "When analyzing..."
- Do not write agent body as procedural steps — that is a skill pattern
- If user's idea is better suited as a skill, suggest using gen-skill instead

### Size Constraint

Generated agent file must stay under 500 lines. If content exceeds this, move detailed content to supporting files in `.claude/agents/<agent-name>/` and reference them from the agent file.

### Description Writing

- Format: `<what the agent does>. <when to delegate to it>.`
- Include delegation trigger terms Claude would recognize
- Max 1024 characters
- Be specific, not generic

### Section Weighing

Evaluate the user's idea and include only relevant sections:

- **Instructions**: When agent has rules, focus areas, priorities, domain constraints
- **Output Contract**: Always include — defines success/failure response format
- **Workflow**: Rare — only when agent always follows a fixed process regardless of task

### Subsection Formatting

- Use `- **Bold Label**:` for simple groupings within a section (2-4 items, no deep nesting)
- Use `### Heading` for substantial content blocks (5+ items, nested content, multi-paragraph)

### Anti-patterns

- Do not write agent body as sequential task steps (that is a skill)
- Do not add activation/trigger sections in the body (frontmatter handles this)
- Do not include explanatory text meant for human readers (optimize for agent execution)
- Do not duplicate what the description already says

## Workflow

### Phase 1: Parse & Classify

1. Parse user arguments for agent idea and flags (`--file`, `--simple`, `--output`)
2. Determine operation: create or update
3. For updates: read existing `.claude/agents/<agent-name>.md`
4. Scan recent conversation for context the user implicitly references:
   - Phrases like "what we discussed", "as before", "the same way", "what i said earlier" → look back through prior turns
   - Look for: role/domain framing, delegation triggers, tool-access constraints, things the user explicitly rejected, output-format preferences
   - Treat anything found as a HARD constraint on the generated agent
5. If idea is still vague after the conversation scan, ask user to clarify each missing dimension explicitly:
   - **Role**: what is the agent's area of expertise?
   - **Delegation triggers**: when should Claude delegate to it?
   - **Capabilities**: read-only, or also makes changes?
   - **Output**: findings, fixes, reports, or something else?
   - **Memory**: should it learn across sessions?
   Do not generate until at least Role and Delegation triggers are clear.

### Phase 2: Load References

1. **Read** `reference.md` for available agent frontmatter fields
2. **Read** `best-practices.md` for agent-specific conventions
3. **Read** `templates.md` for structure templates
4. **Read** `examples.md` for reference patterns

### Phase 3: Weigh Sections

Based on the user's idea, determine which sections to include:

1. Compose system prompt body (role, personality, focus areas)
2. Analyze idea for rules/constraints -> Instructions
3. Define Output Contract (always included)
4. Analyze idea for fixed sequential process -> Workflow (rare)
5. Estimate line count; plan supporting files in `.claude/agents/<agent-name>/` if > 500 lines

### Phase 4: Generate Agent

1. Compose YAML frontmatter (`name`, `description`, and relevant optional fields from `reference.md`)
2. Write system prompt body (role definition, behavioral guidelines)
3. Write included sections based on Phase 3 weighing
4. Create supporting files in `.claude/agents/<agent-name>/` directory if needed (only when > 500 lines)
5. Apply output mode (`--file` or `--output`)

### Phase 5: Validate

1. Run through `validation-checklist.md` checks
2. Verify YAML frontmatter format
3. Verify line count under 500
4. Verify description format and length
5. Verify Output Contract is present
6. Confirm file location with user
7. Suggest testing: "Try delegating: ask Claude to use the agent-name agent to <test task>"

## Cookbook

### Simple Agent

- **IF:** Idea is straightforward, focused role, few rules, under 500 lines
- **THEN:** Generate `.claude/agents/<agent-name>.md` (single flat file)
- **EXAMPLES:** "create an agent that reviews code", "make a debugging agent"

### Complex Agent (With Supporting Files)

- **IF:** Idea has detailed domain knowledge, reference material, or content exceeds 500 lines
- **THEN:** Generate `.claude/agents/<agent-name>.md` + supporting directory `.claude/agents/<agent-name>/` with reference files
- **EXAMPLES:** "create an agent that reviews API security with OWASP guidelines"

### Update Existing Agent

- **IF:** User says "update", "modify", "change", "fix" and agent name matches existing
- **THEN:** Read existing agent, apply changes, preserve unchanged sections
- **EXAMPLES:** "update my reviewer agent to also check for accessibility", "add memory to my debugger agent"

### Display Only

- **IF:** `--output` flag is set
- **THEN:** Print generated content to chat without writing files
- **EXAMPLES:** "generate an agent for X --output", "show me what a reviewer agent would look like"

## Supporting Files

- `reference.md` - All agent frontmatter fields
- `best-practices.md` - Agent authoring conventions and rules
- `validation-checklist.md` - Pre and post-generation validation
- `examples.md` - Example agent generations for reference
- `templates.md` - Agent structure templates (minimal, standard, full)

## Report

- Show created file structure (tree format)
- Confirm file location
- Summarize which sections were included and why
- Suggest testing: "Try delegating: ask Claude to use the `agent-name` agent to <test task>"

## Key Principles

1. **System Prompt, Not Task Steps**: Agent body defines who the agent is, not what to do
2. **Output Contract Always**: Every agent must define success and failure responses
3. **Context Efficiency**: Every line must be actionable or provide decision-making value
4. **Progressive Loading**: Keep AGENT.md small, reference supporting files for detailed content
5. **One Agent = One Role**: Each agent should specialize in one domain
