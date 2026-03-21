---
name: {{SKILL_NAME}}
description: Enforces {{PROJECT_NAME}} {{SKILL_SCOPE}} development standards. Reviews code against {{ARCHITECTURE}} architecture, {{ORM}} patterns, {{FRAMEWORK}} routing, response helpers, and coding conventions. Triggers when implementing/reviewing {{SKILL_SCOPE}} code.
---

# {{SKILL_TITLE}}

## Purpose
Enforces comprehensive {{SKILL_SCOPE}} development standards for the {{PROJECT_NAME}} project.

## Architecture

**Pattern:** {{ARCHITECTURE}}
**Language:** {{LANGUAGE}} {{LANGUAGE_VERSION}}
**Framework:** {{FRAMEWORK}}
**ORM:** {{ORM}}

## Process

### 1. Identify Task Context
- **Module/Domain**: Which module? ({{MODULE_LIST}})
- **Layer**: Which layer? ({{LAYER_LIST}})
- **Operation Type**: {{OPERATION_TYPES}}

### 2. Load Relevant References

Based on task, read the reference files you need:

{{REFERENCE_FILE_LIST}}

### 3. Check Against Standards

{{STANDARDIZATION_RULES}}

### 4. Validate

Use checklists before committing code:
- checklists/validation.md
- checklists/review.md

### 5. Run Tooling Validation

After implementation, run project linters and type checkers:

{{TOOLING_COMMANDS}}

**CRITICAL:** Fix ALL linter and type errors before committing.

## Quick Reference

{{QUICK_REFERENCE_TABLE}}

## Supporting Files

- **reference/** - Detailed technical patterns
- **examples/** - Code examples with annotations
- **checklists/** - Validation tools
- **decisions.md** - Standardization decisions log

## Key Principles

- **Coding Standards**: {{CODING_STANDARDS}}
- **Load Only What You Need**: Progressive loading of references
- **Check Decisions First**: Review decisions.md before asking
- **Validate Before Commit**: Use validation checklist
- **Reference Real Code**: Point to actual files, not generic examples
