# Inconsistency Resolution Workflow

This workflow presents pattern inconsistencies to the user in batch mode and records standardization decisions.

## Overview

After pattern extraction, analyze conflicts and consult user to determine project standards.

## Parallel Execution

**🚀 Use subagents to analyze different categories simultaneously:**

```
Launch subagents in parallel:
├── Subagent 1: Analyze error handling patterns
├── Subagent 2: Analyze auth/security patterns
├── Subagent 3: Analyze repository/data access patterns
├── Subagent 4: Analyze API response patterns
└── Subagent 5: Analyze naming/style conventions

Wait for all → Merge and rank by priority
```

**Subagent prompt template:**
```
Analyze {{CATEGORY}} patterns from this inventory:
{{PATTERN_DATA}}

Identify inconsistencies where multiple patterns exist for the same concern.

For each inconsistency:
1. Category name
2. Patterns found (with file counts)
3. Industry standard recommendation — 2-4 sentences covering: (a) which pattern is the recommended default, (b) the rationale, (c) when each variation is appropriate if multiple should coexist
4. Impact level (high/medium/low)

Return JSON:
{
  "category": "{{CATEGORY}}",
  "inconsistencies": [...]
}
```

## Process

### 1. Filter for Inconsistencies

From pattern inventory, select patterns where `hasInconsistency === true`:

```json
{
  "patternName": "Error Handling",
  "variations": [
    {"id": "A", "count": 18},
    {"id": "B", "count": 7}
  ],
  "hasInconsistency": true
}
```

### 2. Rank by Priority

Organize inconsistencies by impact:

**HIGH PRIORITY:**
- Security/auth patterns
- Error handling
- Database transactions
- Cross-module dependencies (if microservices-ready)

**MEDIUM PRIORITY:**
- Repository interfaces
- Response formats
- Validation approaches
- Enum definitions

**LOW PRIORITY:**
- Variable naming
- Import ordering
- Code formatting

### 3. Create Batch Summary

Present complete list:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
INCONSISTENCY ANALYSIS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Found 12 inconsistencies across your codebase:

HIGH PRIORITY (Security/Correctness):
1. Error Handling (2 patterns)
2. Auth Middleware (3 patterns)
3. Database Transactions (2 patterns)

MEDIUM PRIORITY (Structure):
4. Repository Interfaces (2 patterns)
5. Response Format (2 patterns)
6. Enum Definitions (3 patterns)
7. Validation Approach (2 patterns)

LOW PRIORITY (Style):
8. Variable Naming (2 conventions)
9. Import Ordering (inconsistent)
10. Function Naming (2 conventions)
11. Comment Style (2 styles)
12. File Organization (2 approaches)

What would you like to do?
A) Review all 12 now
B) Review only HIGH priority (3 items)
C) Review HIGH + MEDIUM (7 items)
D) Skip and use most common patterns for all

>
```

### 4. Interactive Resolution

For each inconsistency selected, present detailed comparison:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
INCONSISTENCY #1 of 12
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Category: Error Handling (HIGH PRIORITY)
Module: ddd-cqrs

Pattern A: Custom Domain Errors
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
• Usage: 18 files
• Locations:
  - internal/domain/cart/errors.go:12
  - internal/domain/order/errors.go:8
  - internal/domain/product/errors.go:15

• Example Code:
  ```go
  // Define custom errors
  var (
      ErrInvalidItem = errors.New("invalid cart item")
      ErrCartNotFound = errors.New("cart not found")
  )

  // Use in code
  if !isValid(item) {
      return ErrInvalidItem
  }
  ```

Pattern B: Wrapped Errors
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
• Usage: 7 files
• Locations:
  - internal/service/order.go:45
  - internal/service/cart.go:78
  - internal/repository/gorm/product.go:123

• Example Code:
  ```go
  // Wrap errors with context
  if err != nil {
      return fmt.Errorf("failed to create order: %w", err)
  }

  if err := repo.Save(cart); err != nil {
      return fmt.Errorf("cart save failed: %w", err)
  }
  ```

Industry Standard / Recommendation:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Use BOTH patterns in appropriate contexts:

• Pattern A (Custom Domain Errors):
  - Domain layer business rule violations
  - Well-known error conditions
  - Errors that need to be handled specifically

• Pattern B (Wrapped Errors):
  - Infrastructure layer failures
  - Adding context to external errors
  - Debugging information

Example combined approach:
  ```go
  // Domain layer
  if cart.IsEmpty() {
      return ErrEmptyCart  // Custom error
  }

  // Infrastructure layer
  if err := db.Save(cart); err != nil {
      return fmt.Errorf("saving cart: %w", err)  // Wrapped
  }
  ```

Your Decision:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. ⭐ Accept recommendation (use both in appropriate contexts)
2. Standardize on Pattern A only (custom errors everywhere)
3. Standardize on Pattern B only (wrapped errors everywhere)
4. Keep both patterns without documentation
5. Show me more code examples

Enter choice (1-5):

>
```

### 5. Record Decision

After user chooses, record in `decisions.md`:

```markdown
## Error Handling

**Decision Date:** 2025-11-22

**Standard:** Use custom domain errors for business rules, wrapped errors for infrastructure

**Rationale:**
- Custom errors (Pattern A) clearly communicate business rule violations
- Wrapped errors (Pattern B) preserve error chains and add context
- Combining both provides best of both worlds

**Pattern A Usage:** Domain layer only
- Files: internal/domain/*/errors.go
- Count: 18 files (keep as is)

**Pattern B Usage:** Application & infrastructure layers
- Files: internal/service/*, internal/repository/*
- Count: 7 files (keep as is)

**Action Required:**
None - both patterns are appropriate in their current contexts.
If new violations found, enforce this standard.

**Examples:**
See reference/error-handling.md for detailed examples.

---
```

### 6. Track Remediation Needs

Build remediation list:

```json
{
  "inconsistency": "Repository Interfaces",
  "decision": "All repos must use context.Context as first parameter",
  "affectedFiles": [
    "internal/repository/gorm/cart.go",
    "internal/repository/gorm/product.go"
  ],
  "remediationType": "manual",
  "effort": "moderate",
  "codeChanges": [
    {
      "file": "internal/repository/gorm/cart.go",
      "line": 23,
      "current": "func (r *CartRepo) Save(cart *domain.Cart) error",
      "proposed": "func (r *CartRepo) Save(ctx context.Context, cart *domain.Cart) error"
    }
  ]
}
```

### 7. Repeat for All Selected Inconsistencies

Continue until all inconsistencies resolved or user opts to skip.

## Decision Recording Format

### Template

```markdown
## {PATTERN_NAME}

**Decision Date:** {DATE}

**Standard:** {CHOSEN_STANDARD}

**Rationale:**
{WHY_THIS_DECISION}

**Usage Guidelines:**
{WHEN_TO_USE_WHAT}

**Affected Files:**
{FILE_LIST_BY_PATTERN}

**Action Required:**
{REMEDIATION_NEEDED_OR_NONE}

**Examples:**
{REFERENCE_TO_EXAMPLES}

---
```

## Output

1. **decisions.md** - Complete log of all standardization decisions
2. **Remediation list** - Files that need updates (if any)
3. **Pattern selections** - Which patterns become the standard

## Next Step

Proceed to `generate-guidelines.md` to create the actual guidelines skill.
