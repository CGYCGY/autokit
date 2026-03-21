---
description: Update documentation files based on recent implementation or staged changes
argument-hint: @path/to/doc1.md @path/to/doc2.md ...
allowed-tools: ["Read", "Edit", "Bash", "Grep", "Glob"]
---

# Documentation Update Command

You are tasked with updating documentation files to reflect recent code changes or implementations.

## Arguments
The user will provide a list of documentation files to update:
```
$ARGUMENTS
```

## Context Discovery Phase

First, determine what has changed by following these steps:

### Step 1: Check for Chat History
- If this conversation has messages BEFORE this command was invoked, analyze the chat history to understand:
  - What features were implemented
  - What files were created or modified
  - What bugs were fixed
  - What design decisions were made

### Step 2: Check Staged Files (if new session)
- If there's NO prior chat history, or if context is unclear, run:
  ```bash
  git diff --cached --name-status
  ```
- Read the staged files to understand what changed
- For each changed file, use `git diff --cached <file>` to see specific changes

### Step 3: Understand the Changes
Based on the context gathered:
- Identify new features, modified functionality, or architectural changes
- Note which domain/feature areas are affected
- Understand the "why" behind the changes, not just the "what"

## Documentation Update Phase

For each documentation file in the arguments list:

### Rules to Follow:
1. **Single Source of Truth**: These docs are authoritative references, not historical logs
2. **Link, Don't Copy**: Reference code files with paths (e.g., `internal/domain/cart/aggregate.go:42`) instead of pasting code blocks
3. **No History Sections**: Do NOT add sections like:
   - "Recent Changes"
   - "Changelog"
   - "Bug Fixes"
   - "Version History"
   - Update the existing content to reflect current state
4. **Reflect Current State**: Update existing sections to accurately describe how things work NOW
5. **Remove Obsolete Info**: Delete any information that's no longer accurate
6. **Maintain Structure**: Keep the existing document organization unless restructuring improves clarity

### Update Process:
1. Read the documentation file
2. Identify which sections need updates based on the changes
3. Update relevant sections to reflect the current implementation
4. Add new sections only if covering new functionality not yet documented
5. Ensure all code references use file paths with line numbers when specific
6. Verify accuracy against the actual implementation

## Summary Phase

After completing all updates, provide a SHORT summary:

```
Updated documentation:
- docs/path/file1.md: Updated X section to reflect Y change
- docs/path/file2.md: Added Z capability, removed obsolete W section
```

Keep each summary line to ONE line describing the key changes. Be concise.

## Example Summary:
```
Updated documentation:
- docs/domains/cart_domain.md: Updated price calculation logic, added order factory reference
- docs/features/discount_management.md: Reflected new time-based conditions API
```

---

**Important Notes:**
- ALWAYS read the documentation files first before editing
- Focus on WHAT the code does NOW, not what changed
- Be concise in summaries - one line per file maximum
- If a doc file doesn't need updates, mention it briefly but don't update it
