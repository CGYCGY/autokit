---
name: frontend-review
description: Audits frontend code quality against a modular checklist. Use when user asks to "review frontend", "audit UI code", "check theme", "check dark mode", "review styling", or "frontend quality check".
allowed-tools: Read, Grep, Glob, Bash
user-invocable: true
---

# Frontend Review

## Purpose

Modular audit of frontend code quality. Each category is a self-contained check file in `checks/`. Run all checks or a specific one.

## Usage

- `/frontend-review` — run all checks
- `/frontend-review theme` — run only the theme check

## Available Checks

| Check | File | What it covers |
|---|---|---|
| theme | `checks/theme.md` | Theme architecture, semantic tokens, dark mode contrast, config alignment |

> New checks will be added as issues are discovered (accessibility, responsive, loading states, forms, performance, etc.)

## Workflow

1. **Determine scope**: if user specified a category, load only that check file. Otherwise load all `checks/*.md` files.
2. **Discover project structure**: find CSS entry point, Tailwind config, component directories, and framework (React, Vue, etc.)
3. **Run each check**: follow the "How to Check" steps in each check file. Use Grep/Glob to find violations.
4. **Generate report**: output findings per category using the format below.

## Report Format

For each check category:

```
### [Category Name] — [PASS / X issues found]

**Critical**
- [issue description + file:line]

**Warning**
- [issue description + file:line]

**Info**
- [issue description]
```

End with:

```
### Summary
- Critical: N
- Warning: N
- Info: N
- Total: N issues across M files
```
