---
name: gen-sdk-agent
description: Scaffolds a new agent for the SDK Agents workflow engine (AgentConfig in src/agents/). Use when user asks to "create agent", "add agent", "new agent", "scaffold agent", or "generate agent" for the custom workflow system (planner, builder, tester, etc.).
argument-hint: <agent-name> [--description "what it does"]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
user-invocable: true
---

# SDK Agent Generator

## Purpose

Create new workflow engine agents (AgentConfig objects in `src/agents/`) with proper system prompts, tool selection, registration, and tier integration.

## Variables

USER_INPUT: $ARGUMENTS
AGENT_TEMPLATE: ${CLAUDE_SKILL_DIR}/templates/agent-scaffold.ts
TYPES_FILE: src/core/types.ts
AGENTS_INDEX: src/agents/index.ts
TIER_CONSTANTS: src/shared/tier-constants.ts

### Flags
- `--description` or `-d`: One-line description of the agent's role

## Instructions

- Agents are config objects (composition over inheritance), never class hierarchies
- Default to `sonnet` model tier unless role clearly demands `opus` (planning) or `haiku` (simple reporting)
- Always include `{skills}` placeholder in systemPrompt between `</variables>` and `<instructions>`
- `temperature: 0.3` is standard for deterministic agents on `sonnet`/`haiku` — OMIT `temperature` entirely for the `opus` tier (Opus 4.7+ rejects sampling params with a 400)
- Output files go to `.tasks/<slug>/` directory
- `buildInitialPrompt` is optional but recommended — keeps initial message OCP-compliant
- For full AgentConfig interface, ModelTier, tool selection, and TaskContext fields: **Read** `reference/agent-config.md`
- For system prompt XML structure, template variables, skill patterns, and prompt examples: **Read** `reference/system-prompt.md`

## Workflow

### Phase 1: Gather Requirements

1. Parse agent name from arguments (convert to kebab-case)
2. Parse optional `--description` flag; infer from name or ask user if missing
3. Determine model tier, tools, and skill patterns based on role
4. **Read** `reference/agent-config.md` for type definitions and selection guides

### Phase 2: Generate Agent File

1. **Read** `templates/agent-scaffold.ts`
2. **Read** `reference/system-prompt.md` for XML structure and prompt patterns
3. Replace all `qqq` placeholders with agent-specific content
4. Write to `src/agents/<agent-name>.ts`

### Phase 3: Register Agent

1. **Read** `workflows/registration.md` for step-by-step checklist
2. Update `src/agents/index.ts` (import, agents record, re-exports)

### Phase 4: Integrate with Workflow (if applicable)

Only if the agent slots into the main pipeline (user confirms):

1. **Read** `workflows/registration.md` section 4 for tier-constants steps
2. Update `src/shared/tier-constants.ts` (tierAgentFlows, tierAllAgents, agentDisplayNames, hookTimings, agentSkillPatterns)

### Phase 5: Validate

1. Run `bun run build` or typecheck
2. Confirm agent is importable from `src/agents/index.ts`

## Cookbook

### Pipeline Agent (slots into tier flows)

- **IF:** Agent should run as part of the standard planner->builder->tester pipeline
- **THEN:** Generate agent file, register in index.ts, AND update tier-constants.ts
- **EXAMPLES:** "create a reviewer agent that runs after builder", "add a documenter agent to the pipeline"

### Standalone Agent (utility, not in pipeline)

- **IF:** Agent is invoked directly by orchestrator or decomposer, not part of tier flows
- **THEN:** Generate agent file and register in index.ts only. Skip tier-constants.ts
- **EXAMPLES:** "create a triage agent", "add a task-refiner agent"

### Fix Mode Agent (handles failures)

- **IF:** Agent's role involves diagnosing or fixing failures from other agents
- **THEN:** Include `escalationGuidance` and `driftContext` in system prompt, use conditional buildInitialPrompt pattern from `reference/system-prompt.md`
- **EXAMPLES:** "create a fixer agent", "add a diagnostic agent"

## Report

- Show created agent file path and updated files
- Display agent name, model tier, and tool set
- Suggest testing: "Try adding `'<agent-name>'` to a tier flow and running a task"
