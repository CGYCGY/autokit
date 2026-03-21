# Agent Validation Checklist

## Pre-Creation Checks

- [ ] `best-practices.md` read and understood
- [ ] `reference.md` reviewed for available frontmatter fields
- [ ] `examples.md` reviewed for reference patterns
- [ ] Agent idea is clear enough to proceed (asked user for clarification if vague)
- [ ] Operation type confirmed: create or update
- [ ] Confirmed idea is an agent, not a skill (system prompt vs task instructions)

## Pre-Update Checks (Updates Only)

- [ ] Existing `.claude/agents/<agent-name>/AGENT.md` read in full
- [ ] Changes requested by user are clearly understood
- [ ] Unchanged sections identified and will be preserved
- [ ] Supporting files checked for impact of changes

## YAML Frontmatter Validation

- [ ] Opens with `---` on its own line
- [ ] Closes with `---` on its own line
- [ ] No tabs used (spaces only)
- [ ] Consistent indentation (2 spaces for nested values)
- [ ] `name` field present (required for agents)
- [ ] `description` field present (required for agents)
- [ ] No trailing spaces after values
- [ ] Boolean values are lowercase: `true` / `false`

## Naming Validation

- [ ] All lowercase
- [ ] Hyphens for word separation (no underscores, no spaces, no dots)
- [ ] Maximum 64 characters
- [ ] Descriptive and specific (not `helper`, `agent`, `worker`)
- [ ] No redundant suffix (`-agent`, `-bot`)
- [ ] Name matches directory name in `.claude/agents/`

## Description Validation

- [ ] First sentence describes what the agent does (role-oriented)
- [ ] Second part describes when to delegate to it
- [ ] Under 1024 characters total
- [ ] Includes delegation triggers
- [ ] Specific, not generic
- [ ] Does not simply repeat the agent name

## Optional Fields Validation

### tools / disallowedTools
- [ ] Only specified if restriction is necessary
- [ ] All listed tools are valid Claude Code tool names
- [ ] Not overly restrictive (does not prevent agent from functioning)
- [ ] `Agent(type)` syntax correct if restricting sub-agent spawning

### model
- [ ] Valid value: `sonnet`, `opus`, `haiku`, full model ID, or `inherit`

### effort
- [ ] Valid value: `low`, `medium`, `high`, or `max`
- [ ] `max` only with Opus 4.6

### permissionMode
- [ ] Valid value: `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan`
- [ ] `bypassPermissions` only for trusted, well-tested agents

### maxTurns
- [ ] Reasonable value (not too low to complete tasks, not unnecessarily high)

### skills
- [ ] Referenced skills exist
- [ ] Only skills the agent always needs are preloaded

### mcpServers
- [ ] Server names reference configured servers, or inline definitions are valid
- [ ] Inline definitions use correct schema (stdio, http, sse, ws)

### memory
- [ ] Valid scope: `user`, `project`, or `local`
- [ ] Memory is justified (agent benefits from cross-session learning)

### hooks
- [ ] Hook commands are valid and tested
- [ ] Hook triggers are appropriate (`PreToolUse`, `PostToolUse`, `Stop`)

### background
- [ ] `true` only for agents that should always run concurrently

### isolation
- [ ] `worktree` only when agent needs isolated repo copy

## File Location Validation

- [ ] Agent directory: `.claude/agents/<agent-name>/`
- [ ] Main file: `.claude/agents/<agent-name>/AGENT.md`
- [ ] Directory name matches `name` field in frontmatter
- [ ] For `--simple` mode: single AGENT.md, no subdirectories
- [ ] For `--output` mode: no files written, content displayed in chat

## Content Validation

### System Prompt Body
- [ ] Defines the agent's role and expertise
- [ ] Written in system prompt style ("You are...", "Focus on...")
- [ ] Task-agnostic (works for any delegated task in the domain)
- [ ] Not written as procedural steps (that is a skill pattern)

### Instructions (if present)
- [ ] Each instruction is actionable (a rule, not an explanation)
- [ ] No human-oriented explanatory text
- [ ] Subsection formatting is consistent

### Workflow (if present)
- [ ] Only present when agent always follows a fixed process
- [ ] Steps are task-agnostic (apply regardless of specific delegated task)

### Output Contract (required)
- [ ] Present in every generated agent
- [ ] Has `### On Success` subsection
- [ ] Has `### On Failure` subsection
- [ ] Format fits the agent's domain (JSON, markdown, plain text)
- [ ] On Failure includes what went wrong and any partial results

### Supporting Files
- [ ] All referenced files actually exist
- [ ] No empty directories created
- [ ] No directory with fewer than 3 files (inline instead)
- [ ] File references are one level deep
- [ ] File names are descriptive

## Size Validation

- [ ] AGENT.md is under 500 lines
- [ ] If over 500 lines, content has been moved to supporting files
- [ ] Supporting files are referenced from AGENT.md

## Final Checks

- [ ] Agent created/updated successfully (files written without errors)
- [ ] File location confirmed to user
- [ ] Testing suggestion provided: "Try delegating: ask Claude to use the `agent-name` agent to <test task>"
- [ ] No activation/trigger logic in the body (handled by frontmatter)
- [ ] No duplicate content between description and body
- [ ] No obvious anti-patterns from `best-practices.md`
- [ ] Output Contract is present

## Quick Red Flags

Stop and fix if any of these are true:

- Description is just the agent name restated
- Agent body reads as procedural steps instead of a system prompt
- Output Contract is missing
- AGENT.md exceeds 500 lines with no supporting files
- `name` or `description` field is missing
- Agent covers multiple unrelated domains
- `permissionMode: bypassPermissions` used without justification
- Supporting files referenced but not created
- Empty directories exist in the agent folder
