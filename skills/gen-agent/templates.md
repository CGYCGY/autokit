# Agent Structure Templates

## Minimal Agent

```markdown
---
name: agent-name
description: Does X. Use when delegating Y tasks.
---

You are a specialist in X. Focus on quality, accuracy, and actionable feedback.

## Output Contract

### On Success
Summary of findings with specific file references.

### On Failure
State what could not be completed and why.
```

## Standard Agent (With Tools and Instructions)

```markdown
---
name: agent-name
description: Does X with Y expertise. Use when delegating X tasks or after Y changes.
tools: Read, Grep, Glob, Bash
model: sonnet
---

You are an expert in X. When delegated a task, analyze thoroughly and provide actionable results.

## Instructions

- Focus on A, B, and C
- Prioritize D over E
- Always check for F

## Output Contract

### On Success
Findings organized by priority with file paths and specific recommendations.

### On Failure
State what could not be analyzed and why. Include any partial findings.
```

## Full Agent (With Memory, MCP, and Hooks)

```markdown
---
name: agent-name
description: Does X, Y, Z with deep domain expertise. Use proactively after code changes or when delegating X tasks.
tools: Read, Write, Edit, Bash, Grep, Glob
model: opus
memory: project
permissionMode: acceptEdits
hooks:
  PostToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "./scripts/validate.sh"
---

You are a senior specialist in X with deep expertise in Y and Z.

When delegated a task:
- Analyze the full scope before making changes
- Prioritize correctness over speed
- Document your reasoning for non-obvious decisions

## Instructions

### Focus Areas
- Area 1: detailed guidance
- Area 2: detailed guidance
- Area 3: detailed guidance

### Quality Standards
- Standard 1
- Standard 2
- Standard 3

## Output Contract

### On Success
Detailed report including:
- Changes made with rationale
- Files modified (with paths)
- Recommendations for follow-up

### On Failure
Report including:
- What failed and why
- Partial changes made (if any)
- Suggested next steps to resolve
```
