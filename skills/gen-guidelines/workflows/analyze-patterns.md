# Pattern Analysis Workflow

This workflow performs deep code analysis to extract patterns from the codebase.

## Overview

For each selected module, execute its pattern extraction logic using language-specific extractors.

## Parallel Execution

**🚀 Use subagents to scan different layers simultaneously:**

```
Launch subagents in parallel:
├── Subagent 1: Scan domain layer (entities, value objects, aggregates)
├── Subagent 2: Scan application layer (handlers, commands, queries)
├── Subagent 3: Scan infrastructure layer (repositories, external services)
├── Subagent 4: Scan API layer (controllers, middleware, responses)
└── Subagent 5: Scan tests (test patterns, mocks, fixtures)

Wait for all → Merge results into pattern inventory
```

**Subagent prompt template:**
```
You are extracting patterns from the {{LAYER}} layer of a {{LANGUAGE}} project.

Scan files in: {{PATHS}}
Extract patterns for: {{PATTERN_LIST}}

For each pattern found:
1. Pattern name
2. Variations (A, B, C...)
3. File count using each variation
4. Best example file:line — pick the file with the most occurrences of this exact variation; if tied, pick the most recently modified file

Return JSON:
{
  "layer": "{{LAYER}}",
  "patterns": [...]
}
```

## Process

### 1. Load Module Definitions

Read selected modules from `modules/go/` or `modules/python/`:

```markdown
# Example: modules/go/ddd-cqrs.module.md

## Patterns to Extract

### 1. Domain Entity Structure
**Search for:** type * struct in internal/domain/*/
**Extract:** Constructor patterns, validation, methods
**Inconsistency Check:** Multiple constructor patterns → Ask user

### 2. Repository Interfaces
...
```

### 2. Execute Extraction for Each Module

Use language-specific extractor:
- Go: `extractors/go-extractors.md`
- Python: `extractors/python-extractors.md`

### 3. Pattern Storage Format

Store each extracted pattern:

```json
{
  "patternName": "Domain Entity Constructor",
  "module": "ddd-cqrs",
  "category": "structure",
  "priority": "high",
  "variations": [
    {
      "id": "A",
      "description": "Factory function with validation",
      "exampleFiles": [
        "internal/domain/cart/aggregate.go:15",
        "internal/domain/order/aggregate.go:23"
      ],
      "count": 18,
      "codeSnippet": "func NewCart(...) (*Cart, error) { ... }"
    },
    {
      "id": "B",
      "description": "Simple struct initialization",
      "exampleFiles": [
        "internal/domain/product/entity.go:12"
      ],
      "count": 3,
      "codeSnippet": "cart := &Cart{ ... }"
    }
  ],
  "hasInconsistency": true,
  "recommendation": "Use Pattern A (factory with validation) for all domain entities"
}
```

### 4. Collect All Patterns

Build complete pattern inventory across all modules.

## Extraction Techniques

### Search Patterns (Go)

**Find type definitions:**
```bash
grep -rn "^type.*struct" internal/domain/ --include="*.go"
```

**Find interfaces:**
```bash
grep -rn "^type.*interface" internal/ --include="*.go"
```

**Find functions:**
```bash
grep -rn "^func" internal/ --include="*.go"
```

### Search Patterns (Python)

**Find class definitions:**
```bash
grep -rn "^class " app/ --include="*.py"
```

**Find decorators:**
```bash
grep -rn "^@" app/ --include="*.py"
```

**Find function definitions:**
```bash
grep -rn "^def " app/ --include="*.py"
```

### Code Reading

Use `Read` tool to examine files:
- Read example files from search results
- Extract actual code snippets
- Identify pattern variations

### Pattern Grouping

Group similar patterns together:
1. Read multiple files with same pattern
2. Identify common structure
3. Note variations
4. Count usage frequency

## Example: Enum Pattern Extraction (Go)

**Step 1: Search for enums**
```bash
grep -rn "^const" internal/domain/ --include="*.go"
grep -rn "^type.*string" internal/domain/ --include="*.go"
```

**Step 2: Read example files**
```go
// Found in internal/domain/cart/types.go:
type CartStatus string
const (
    CartStatusActive CartStatus = "active"
    CartStatusChecked CartStatus = "checked_out"
)

// Found in internal/domain/order/enum.go:
type OrderStatus struct {
    Value string
    Label string
}
var OrderStatusPending = OrderStatus{Value: "pending", Label: "Pending"}
```

**Step 3: Identify variations**
- Pattern A: Type alias with const block (used in 3 files)
- Pattern B: Struct-based with Value/Label (used in 8 files)

**Step 4: Record pattern**
```json
{
  "patternName": "Enum Definitions",
  "variations": [
    {"id": "A", "description": "Type alias const", "count": 3},
    {"id": "B", "description": "Struct-based", "count": 8}
  ],
  "hasInconsistency": true
}
```

## Output

Pattern inventory with all extracted patterns, ready for inconsistency analysis.

## Next Step

Proceed to `resolve-inconsistencies.md` to analyze conflicts and consult user.
