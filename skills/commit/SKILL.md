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
2. Parse `--skip` parameter, exclude matching files. Default skip: `__temp/*`
3. Stage relevant files with explicit `git add <path>` (never `git add -A` or `git add .`)
4. Analyze changes: determine type (`feat`, `fix`, `update`, `docs`, `chore`, etc.), scope, and what changed
5. Generate commit message:
   - Title: `type(scope): description`, under 70 characters
   - Body: flat bullets covering why and what changed (1-3 bullets typical)
   - Group bullets under `Section:` headers when changes span multiple areas
   - Do NOT add Co-Authored-By lines
6. Execute: `git commit -m "$(cat <<'EOF'\n...\nEOF\n)"`
7. Confirm with `git log -1 --oneline`

## Cookbook

### Standard
- **IF:** No `--skip` argument provided
- **THEN:** Stage every file shown as modified or untracked in step 1's `git status`, excluding `__temp/*`

### With Exclusions
- **IF:** `--skip pattern1,pattern2` provided
- **THEN:** Stage every file shown as modified or untracked in step 1's `git status`, excluding `__temp/*` and any path matching the supplied patterns

## Report

After commit, output:
- Commit hash (from `git log -1 --oneline`)
- Commit title line
- Number of files staged
- Number of files skipped (with the reason — default exclusion or `--skip` pattern)

## Output Contract

### On Success
Commit hash, commit title, files-staged count, files-skipped count with reasons.

### On Failure
State why the commit was not created (no changes, hook failure, conflict, missing files). Include any partial state (e.g. files staged but commit aborted).
