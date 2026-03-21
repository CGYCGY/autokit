# Prompt Generation Examples

## Example 1: Simple Prompt (Display Only)

**User request:** "create a prompt to review my PR before submitting"

**Generated output (displayed in chat, no frontmatter):**

```markdown
# PR Review

## Purpose

Review current branch changes for quality issues before submitting a pull request.

## Instructions

- Check for leftover debug code (console.log, print statements, TODO comments)
- Verify all new functions have appropriate error handling
- Check for hardcoded values that should be environment variables
- Ensure naming conventions are consistent with the existing codebase
- Verify no sensitive data (keys, tokens, passwords) is included

## Workflow

1. Run `git diff main...HEAD` to see all changes
2. Identify modified and new files
3. Review each file for the issues listed in Instructions
4. Check for large files or binaries that shouldn't be committed

## Output Contract

### On Success
List of findings organized by file, with severity (critical, warning, info). Confirm "Ready to submit" if no critical issues found.

### On Failure
State which files could not be reviewed and why. List any partial findings.
```

**Why this works:**
- Display only — no frontmatter
- Has Workflow because PR review is sequential
- Output Contract defines what the user sees on success and failure
- Simple, focused, single purpose

---

## Example 2: Saved Prompt with Arguments

**User request:** "create a prompt that generates a README for a project, save it as gen-readme"

**Generated output (saved to `.claude/commands/gen-readme.md`):**

```markdown
---
description: Generates a README.md for a project with standard sections. Use when starting a new project or updating documentation.
argument-hint: [project-path]
---

# README Generator

## Purpose

Generate a comprehensive README.md for the specified project.

## Variables

PROJECT_PATH: $ARGUMENTS

## Instructions

- Detect project type from config files (package.json, go.mod, pyproject.toml, Cargo.toml)
- Extract project name and description from config
- Detect available scripts/commands
- Identify dependencies and dev dependencies
- Check for existing LICENSE file

## Workflow

1. Read project config file to extract metadata
2. Scan directory structure for key directories (src, tests, docs)
3. Check for existing README.md — if found, ask before overwriting
4. Generate README with sections: Title, Description, Installation, Usage, Development, License
5. Write README.md to project root

## Output Contract

### On Success
README.md written to project root. Show a summary of detected project metadata and sections included.

### On Failure
State what could not be detected (e.g., no config file found, unknown project type). Generate a minimal README with placeholder sections and note what needs manual editing.
```

**Why this works:**
- Saved prompt with frontmatter (`description`, `argument-hint`)
- Uses `$ARGUMENTS` for project path
- Workflow is sequential and clear
- Output Contract handles both success and partial failure

---

## Example 3: Minimal Prompt (No Variables, No Workflow)

**User request:** "make a prompt to check for security issues in my code"

**Generated output (displayed in chat):**

```markdown
# Security Check

## Purpose

Scan the current project for common security vulnerabilities.

## Instructions

- Check for hardcoded secrets (API keys, passwords, tokens)
- Identify SQL injection risks (string concatenation in queries)
- Check for XSS vulnerabilities (unescaped user input in templates)
- Verify authentication checks on sensitive endpoints
- Check file permissions on config and secret files
- Identify outdated dependencies with known CVEs

## Output Contract

### On Success
Security findings organized by severity (critical, high, medium, low) with file paths, line numbers, and remediation steps.

### On Failure
State which areas could not be scanned and why. Include any partial findings from completed checks.
```

**Why this works:**
- No Variables — operates on current project
- No Workflow — instructions are sufficient, no fixed sequence needed
- Concise and focused

---

## Example 4: Updating an Existing Prompt

**User request:** "update my gen-readme prompt to also generate a CONTRIBUTING.md"

**Process:**

1. Read existing `.claude/commands/gen-readme.md`
2. Identify what needs to change based on the request
3. Apply only the requested changes, preserve everything else

**What changes and what doesn't:**

- **Frontmatter `description`**: Update to mention CONTRIBUTING.md
- **Instructions**: Add detection of contribution guidelines (PR templates, issue templates)
- **Workflow**: Add step for generating CONTRIBUTING.md
- **Output Contract**: Update On Success to mention both files
- **Everything else**: Untouched

**Update rules:**
- Always read existing file before modifying
- Only change what the user asked for
- Update frontmatter `description` when scope changes
- If adding `$ARGUMENTS`, add `argument-hint` to frontmatter too
