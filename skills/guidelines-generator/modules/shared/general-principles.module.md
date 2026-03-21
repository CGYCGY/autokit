---
module: general-principles
language: all
category: universal
requires: []
conflicts: []
priority: highest
---

# General Principles Module

Always included. Provides coding standards enforcement, detection commands, and non-obvious anti-patterns.

## Coding Standards

Always include universal standards. Add others based on project characteristics (architecture, language paradigm, patterns detected).

**Universal (always include):** DRY, KISS, YAGNI, SoC, Boy Scout Rule, Fail-Fast

**Include when relevant (LLM decides based on project):** SOLID, POLA, Law of Demeter, Composition Over Inheritance

> Note: SOLID principles (especially SRP, ISP, DIP) can apply beyond pure OOP — include when the project benefits from them.

### Output

**In SKILL.md `{{CODING_STANDARDS}}`:** Single line listing the selected standards (keywords only).

**In `checklists/review.md`:** Add a "Coding Standards" section with checkbox per selected standard (keyword only, no explanations — agent knows what they mean).

## Detection Commands

```bash
# Magic numbers/strings
grep -rn "[^a-zA-Z][0-9]\{2,\}[^a-zA-Z0-9]" --include="*.{py,go,ts,js}" | grep -v "test\|spec"

# Empty catch blocks
grep -rn "except.*:\s*$\|catch.*{\s*}" --include="*.{py,ts,js}"

# Secrets in code
grep -rn "password\s*=\|api_key\s*=\|secret\s*=" --include="*.{py,go,ts,js}" | grep -v "\.env\|config"

# N+1 query pattern (loops with queries)
grep -B2 -A2 "for.*in.*:\|\.forEach\|\.map" --include="*.{py,ts,js}" | grep -i "query\|find\|select"

# Commented-out code
grep -rn "^[[:space:]]*#.*=\|^[[:space:]]*//.*=\|^[[:space:]]*//.*function" --include="*.{py,ts,js}"

# Functions > 50 lines (review candidates)
# Use language-specific tools: pylint, eslint
```

## Non-Obvious Anti-Patterns

Only patterns where the mistake is subtle:

### Error Handling
```python
# Swallowing exception context
except Exception as e:
    raise CustomError(str(e))  # ❌ Loses stack trace
    raise CustomError(str(e)) from e  # ✅ Preserves chain
```

### Mutability Traps
```python
# Mutable default argument
def add_item(item, items=[]):  # ❌ Shared across calls
def add_item(item, items=None):  # ✅
    items = items or []
```

```javascript
// Shallow copy trap
const newState = { ...state }
newState.nested.value = x  // ❌ Mutates original
const newState = { ...state, nested: { ...state.nested, value: x } }  // ✅
```

### Async/Concurrency
```python
# defer in loop (Go equivalent issues exist in all languages)
for item in items:
    defer_cleanup(item)  # ❌ All execute at function end with last item value

# Closure capture in loops
for i in range(10):
    tasks.append(lambda: print(i))  # ❌ All print 9
    tasks.append(lambda i=i: print(i))  # ✅ Capture current value
```

```javascript
// Promise.all vs sequential (perf trap)
for (const item of items) {
  await process(item)  // ❌ Sequential when parallel is safe
}
await Promise.all(items.map(process))  // ✅ Parallel
```

### Query Patterns
```python
# N+1 hidden in property
class Order:
    @property
    def customer_name(self):
        return self.customer.name  # ❌ Query per access in loops
# Fix: Eager load or batch
```

### Resource Leaks
```python
# File handle leak on exception
f = open(path)
data = f.read()  # ❌ If exception, never closed
f.close()

with open(path) as f:  # ✅ Auto-cleanup
    data = f.read()
```

## Tooling Validation

**CRITICAL:** After implementing code, always run project linters/type-checkers to catch errors.

### Detecting Project Tooling

```bash
# JavaScript/TypeScript
grep -E "\"(lint|typecheck|tsc|eslint)\":" package.json

# Go
ls -la .golangci.yml Makefile | grep -E "golangci|lint"

# Python
grep -E "tool\.(ruff|mypy|pylint|black)" pyproject.toml
cat requirements-dev.txt | grep -E "ruff|mypy|pylint|black"
```

### Language-Specific Commands

See language-specific modules for exact commands:
- **TypeScript/JavaScript**: `typescript-conventions` module
- **Go**: `go-conventions` module
- **Python**: `python-conventions` module

## Validation Checklist

Core items only — agent applies standard principles automatically:

- [ ] No empty catch/except blocks
- [ ] No secrets in code (check grep output)
- [ ] No N+1 query patterns in loops
- [ ] Mutable defaults avoided
- [ ] Resources use context managers/try-finally
- [ ] Error chains preserved (from/cause)
- [ ] Loop closures capture values correctly
- [ ] **Run project linters and fix ALL errors**
- [ ] **Run type checker and fix ALL type errors**

## Progressive Loading

**Core (always load):** This file
**On-demand (load when relevant):**
- `reference/error-handling.md` — when implementing error handling
- `reference/async-patterns.md` — when implementing concurrent code
- `reference/security-checklist.md` — when handling auth/input/secrets
