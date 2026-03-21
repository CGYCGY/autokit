# Guidelines Generation Workflow

This workflow creates the actual guidelines skill from analyzed patterns and user decisions.

## Overview

Transform pattern analysis and decisions into a complete, usable guidelines skill.

## Skill Naming

| Type | SKILL_NAME | SKILL_TITLE | SKILL_SCOPE |
|------|------------|-------------|-------------|
| Frontend | frontend-guidelines | Frontend Development Guidelines | frontend |
| Backend | backend-guidelines | Backend Development Guidelines | backend |
| Full-stack | dev-guidelines | Development Guidelines | full-stack |

## Parallel Execution

**🚀 Use subagents to generate different docs simultaneously:**

```
Launch subagents in parallel:
├── Subagent 1: Generate reference/general-principles.md
├── Subagent 2: Generate reference/architecture.md
├── Subagent 3: Generate reference/framework.md
├── Subagent 4: Generate reference/database.md
├── Subagent 5: Generate checklists/code-review.md
└── Subagent 6: Generate checklists/security.md

Wait for all → Verify all files created
```

**Subagent prompt template:**
```
Generate {{DOC_TYPE}} documentation for a {{LANGUAGE}} project.

Module: {{MODULE_NAME}}
Patterns extracted: {{PATTERN_DATA}}
Decisions made: {{DECISIONS}}

Use this template structure:
{{TEMPLATE}}

Output: Complete markdown file content
```

**Note:** SKILL.md generation is sequential (depends on all data). Reference docs can be parallel.

## Process

### 1. Create Skill Directory Structure

```bash
mkdir -p .claude/skills/{{SKILL_NAME}}/{reference,examples,checklists}
```

Replace `{{SKILL_NAME}}` with the determined skill name (frontend-guidelines, backend-guidelines, or dev-guidelines).

### 2. Generate SKILL.md

Use template from `templates/SKILL.template.md`:

**Context Efficiency Principles:**
- **Remove redundancy**: Don't duplicate frontmatter info in body
- **Actionable only**: Every section must help the agent make decisions
- **PROGRESSIVE LOADING**: Reference external files instead of embedding everything
- **No fluff**: No explanatory text meant for humans, only agent instructions
- **Anti-patterns**: Only include non-obvious ones in supporting files
  - ✅ Keep: Subtle, counterintuitive mistakes (e.g., "defer in loops executes at function end, not iteration")
  - ❌ Remove: Obvious opposites of good patterns (if pattern says "do X", don't add "don't do non-X")

**Populate:**
- Skill name and description (frontmatter only)
- Architecture info (concise, one section)
- Process steps (actionable, from module workflows)
- Quick reference table (lookup data, from module patterns)
- Supporting files list (paths to load when needed)
- **Tooling commands** (from language-specific convention modules)
- **Coding standards** (from `general-principles` module)

**Coding Standards Section:**

Populate `{{CODING_STANDARDS}}` placeholder in the Key Principles section. Select standards relevant to the targeted project:

- **Always include:** DRY, KISS, YAGNI, SoC, Boy Scout Rule, Fail-Fast
- **Include when relevant (based on project architecture, language paradigm, patterns detected):** SOLID, POLA, Law of Demeter, Composition Over Inheritance

List only the keywords — no explanations needed. Example output:

```markdown
- **Coding Standards**: DRY, KISS, YAGNI, SoC, SOLID, POLA, Boy Scout Rule, Fail-Fast
```

**Tooling Commands Section:**

Populate `{{TOOLING_COMMANDS}}` placeholder with language-specific commands from convention modules:

- **TypeScript/JavaScript**: Commands from `typescript-conventions` module
- **Go**: Commands from `go-conventions` module
- **Python**: Commands from `python-conventions` module

**Example for TypeScript project:**
```markdown
# TypeScript type checking
npm run typecheck           # or: npx tsc --noEmit

# ESLint
npm run lint               # or: npx eslint . --ext .ts,.tsx
```

**Example for Go project:**
```markdown
# golangci-lint
golangci-lint run ./...

# Go vet
go vet ./...

# Build check
go build ./...
```

**Example for Python project:**
```markdown
# Ruff
ruff check .

# mypy
mypy .
```

**Example output (for backend project):**
```markdown
---
name: backend-guidelines
description: Enforces {PROJECT_NAME} backend development standards. Reviews code against DDD/CQRS architecture, GORM models, Gin routing patterns, response helpers, and enum constants.
---

# Backend Development Guidelines

## Purpose
Enforces comprehensive backend development standards for the {PROJECT_NAME} project.

## Process

### 1. Identify Task Context
- **Module**: Which module? (order, product, cart, etc.)
- **Layer**: Which layer? (domain, application, repository, controller)
- **Operation Type**: Write operation (command) or read operation (query)?

### 2. Load Relevant References
{LIST_OF_REFERENCE_FILES_FROM_MODULES}

### 3. Check Against Standards
{STANDARDIZATION_RULES_FROM_DECISIONS}

### 4. Validate
Use checklists before committing code:
- checklists/validation.md
- checklists/review.md

### 5. Run Tooling Validation
After implementation, run project linters and type checkers:

```bash
golangci-lint run ./...
go vet ./...
go build ./...
```

**CRITICAL:** Fix ALL linter and type errors before committing.

...
```

### 3. Generate Reference Documentation

For each module, create reference/*.md files:

#### Example: reference/architecture.md

From `ddd-cqrs.module` and `modular-monolith.module`:

```markdown
# Architecture: DDD + CQRS + Modular Monolith

## Overview
This project follows Domain-Driven Design (DDD) principles with CQRS (Command Query Responsibility Segregation) pattern, organized as a modular monolith.

## Module Structure

Each domain module follows this structure:
```
internal/{module}/
├── domain/           # Domain layer (entities, aggregates, value objects)
├── application/      # Application layer (commands, queries, handlers)
├── repository/       # Infrastructure (GORM implementations)
└── controllers/      # API layer (Gin handlers)
```

**Example from codebase:**
- internal/cart/domain/aggregate.go:15
- internal/order/application/command.go:23

## Domain Layer Patterns

{EXTRACTED_PATTERN_FROM_ANALYSIS}

## CQRS Implementation

{EXTRACTED_PATTERN_FROM_ANALYSIS}

...
```

#### Example: reference/enum-patterns.md

From `enum-patterns.module` + user decisions:

```markdown
# Enum Patterns

## Standard (Decision: 2025-11-22)

Use struct-based enums with Value/Label fields:

```go
type OrderStatus struct {
    Value string
    Label string
}

var (
    OrderStatusPending = OrderStatus{Value: "pending", Label: "Pending"}
    OrderStatusPaid    = OrderStatus{Value: "paid", Label: "Paid"}
)
```

**Rationale:** Supports internationalization and provides display labels.

## Usage

{EXTRACTED_EXAMPLES_FROM_CODEBASE}

## Anti-Patterns

❌ **Don't use type alias const blocks:**
```go
type OrderStatus string  // Avoid this pattern
const (
    OrderStatusPending OrderStatus = "pending"
)
```

This pattern was found in 3 files but conflicts with project standard.

**Files to update:**
- internal/product/types.go:12
- internal/discount/enum.go:8
...
```

### 4. Generate Examples

Copy best example files:

```bash
cp internal/domain/cart/aggregate.go examples/cart-aggregate-example.go
cp internal/application/order/command.go examples/order-command-example.go
```

Create examples/*.md with annotations:

```markdown
# Complete Feature Example: Cart Management

This example shows a complete feature following all project patterns.

## Domain Layer

**File:** internal/domain/cart/aggregate.go

```go
// Cart is the aggregate root for shopping cart domain
// Pattern: DDD Aggregate with factory method
type Cart struct {
    ID        uuid.UUID
    UserID    uuid.UUID
    Items     []CartItem
    CreatedAt time.Time
}

// NewCart creates a new cart (Factory Pattern)
func NewCart(userID uuid.UUID) (*Cart, error) {
    if userID == uuid.Nil {
        return nil, ErrInvalidUserID  // Custom domain error
    }
    return &Cart{
        ID:        uuid.UUID.New(),
        UserID:    userID,
        Items:     []CartItem{},
        CreatedAt: time.Now(),
    }, nil
}
```

**Patterns demonstrated:**
✓ Factory method for entity creation
✓ Custom domain error
✓ Validation in constructor
✓ Value object usage (uuid.UUID)

...
```

### 5. Generate Checklists

Merge checklist items from all modules, including tooling validation and seeder data (if ORM detected):

**checklists/validation.md:**
```markdown
# Pre-Commit Validation Checklist

Run through this checklist before committing code.

## Architecture
- [ ] New code is in the correct layer (domain/application/repository/controller)
- [ ] Domain logic is not in controllers or repositories
- [ ] No business logic in infrastructure layer

## Domain Layer
- [ ] Entities use factory methods (NewEntity())
- [ ] Domain errors defined and used
- [ ] No infrastructure dependencies

## Repository Layer
- [ ] All methods use context.Context as first parameter
- [ ] GORM preloading uses PreloadConfig pattern
- [ ] Query filters use FilterObject pattern

## API Layer
- [ ] Controllers use MessageResponse helper
- [ ] DTOs validated with binding tags
- [ ] Errors mapped to appropriate HTTP status

## Enums
- [ ] Use struct-based pattern with Value/Label
- [ ] Defined in domain layer

## Seeder Data (if ORM detected - from seeder-data module)
- [ ] **Seeder file exists for new entity/table**
- [ ] **Minimum viable data covers all required fields**
- [ ] **Relationship data included (foreign keys populated)**
- [ ] **Edge cases represented (enum states, optional fields)**
- [ ] **Seeder runs successfully without errors**
- [ ] **Data realistic enough for manual testing**

## Tooling Validation (CRITICAL)
- [ ] **Run `golangci-lint run ./...` and fix ALL errors**
- [ ] **Run `go vet ./...` and fix ALL warnings**
- [ ] **Run `go build ./...` and ensure compilation succeeds**
- [ ] No unused variables or imports
- [ ] All errors are checked

...
```

**checklists/review.md** must include a **Coding Standards** section with the same standards selected for SKILL.md. Use keyword-only checkboxes — no explanations:

```markdown
## Coding Standards
- [ ] DRY
- [ ] KISS
- [ ] YAGNI
- [ ] SoC
- [ ] Boy Scout Rule
- [ ] Fail-Fast
- [ ] SOLID
- [ ] ...
```

Only list the standards selected as relevant for this project (same set as `{{CODING_STANDARDS}}`).

**Note:**
- Tooling validation items come from the language-specific convention module (`go-conventions`, `typescript-conventions`, or `python-conventions`)
- Seeder data items only added if `seeder-data` module was loaded (ORM detected)

### 6. Create decisions.md

Compile all user decisions from resolution phase:

```markdown
# Standardization Decisions

This file records all coding standard decisions made during guidelines generation.

## Error Handling
**Date:** 2025-11-22
**Decision:** Use custom domain errors for business rules, wrapped errors for infrastructure
**Rationale:** ...
**Files Affected:** ...

## Repository Interfaces
**Date:** 2025-11-22
**Decision:** All repository methods must include context.Context as first parameter
**Rationale:** ...
**Files Affected:** ...

...
```

## Generated Structure

```
.claude/skills/{{SKILL_NAME}}/
├── SKILL.md                          # Main skill file
├── reference/                        # Pattern documentation
│   ├── architecture.md               # DDD/CQRS/Modular patterns
│   ├── gorm-models.md                # GORM patterns
│   ├── enum-patterns.md              # Enum standard
│   ├── response-patterns.md          # API response helpers
│   ├── repository-patterns.md        # Repository interfaces
│   └── ...
├── examples/                         # Real code examples
│   ├── complete-feature.md           # Full feature walkthrough
│   ├── cart-aggregate-example.go     # Annotated examples
│   ├── repository-example.go
│   └── ...
├── checklists/                       # Validation tools
│   ├── validation.md                 # Pre-commit checklist
│   └── review.md                     # Code review checklist
└── decisions.md                      # Standardization log
```

## Output Messages

**Success message:**
```
✓ Guidelines generated successfully!

Created:
  .claude/skills/{{SKILL_NAME}}/
  ├── SKILL.md
  ├── reference/ (6 files)
  ├── examples/ (8 files)
  ├── checklists/ (2 files)
  └── decisions.md

The {{SKILL_NAME}} skill is now active and will:
- Auto-activate when you work on {{SKILL_SCOPE}} code
- Enforce the patterns we identified
- Reference your actual codebase examples
- Check against the standards we agreed on

You can review the generated files and modify as needed.
```

## Next Step

Optionally proceed to remediation phase to fix code violations.
