---
name: commit
description: Create git commits with proper conventional commit format. Analyze changes, stage files, generate structured commit messages.
argument-hint: [--skip file1,file2]
allowed-tools: Bash, Read
model: sonnet
context: fork
agent: general-purpose
user-invocable: true
disable-model-invocation: true
---

# Commit Skill

## Purpose

Automate git commits with conventional commit format.

## Variables

- `--skip`: Comma-separated exclusion patterns

## Instructions

Execute in sequence:

1. Run `git status`, `git diff HEAD`, `git log --oneline -10`
2. Parse `--skip` parameter, exclude matching files, default skip file:
  - __temp/*
3. Stage relevant files with `git add`
4. Analyze changes: determine type, scope, changes summary
5. Generate commit message with proper scope and some details
6. Remove Co-Authored-By line if exists
7. Execute: `git commit -m "$(cat <<'EOF'\n...\nEOF\n)"`
8. Confirm: `git log -1 --oneline`

## Workflow

1. Analyze repo state
2. Process exclusions
3. Stage files
4. Generate message
5. Commit
6. `Report` result

## Cookbook

### Standard
- **IF:** No args
- **THEN:** Commit all changes

### With Exclusions
- **IF:** `--skip pattern1,pattern2`
- **THEN:** Exclude patterns from staging

## Report

Output commit hash and summary.
