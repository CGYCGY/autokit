---
name: codex-cli
description: CLI interface for dispatching tasks to Codex in a tmux pane, sending follow-ups, polling for completion, and reading results. Requires --id for pane isolation.
argument-hint: <task description>
allowed-tools: Bash, Read
user-invocable: false
---

# Codex CLI

CLI interface for Codex in tmux. Handles pane management, prompt delivery, and log-based result retrieval.

## Variables

USER_INPUT: $ARGUMENTS
SCRIPT: ${CLAUDE_SKILL_DIR}/codex-dispatch.sh

## Commands

### dispatch — Start a new Codex task
```bash
bash $SCRIPT dispatch --id "<id>" "<task>"
```
Opens a new tmux pane, launches `codex --full-auto` with the task. Prints log file path to stdout.

### send — Follow-up to existing Codex pane
```bash
bash $SCRIPT send --id "<id>" "<task>"
```
Sends additional instructions to an already-running Codex pane. Creates a new log file. Prints log path to stdout. Errors if no pane exists for this id.

### poll — Check if task is complete
```bash
tail -5 <logfile> | grep -q '<!-- DONE -->'
```
Returns 0 when Codex has written the completion marker.

### kill pane — Close a Codex pane
Read pane ID from state file `${CLAUDE_SKILL_DIR}/.codex-pane-<id>`, then:
```bash
tmux kill-pane -t <pane_id>
```

## Log Format

Logs stored in `${CLAUDE_SKILL_DIR}/logs/`, named `{date}-{id}-{time}.md`:
```
## Task
(one-line description)

## Status
success | partial | failed

## Result
(key findings, output, or answer)

## Files Changed
- path — what changed

## Issues
(problems, or "none")

<!-- DONE -->
```
