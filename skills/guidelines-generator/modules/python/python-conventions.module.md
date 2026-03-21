---
module: python-conventions
language: python
category: language
requires: []
conflicts: []
priority: highest
---

# Python Conventions Module

## Detection

```bash
# Look for Python project files
find . -maxdepth 2 -type f \( -name "pyproject.toml" -o -name "requirements.txt" -o -name "setup.py" \)
```

## Tooling Commands

**Detect project linters:**
```bash
# Check pyproject.toml for tool configs
grep -E "\[tool\.(ruff|mypy|pylint|black|isort)\]" pyproject.toml 2>/dev/null

# Check requirements-dev.txt
cat requirements-dev.txt 2>/dev/null | grep -E "ruff|mypy|pylint|black|flake8"

# Check for config files
ls -la .ruff.toml mypy.ini .pylintrc setup.cfg 2>/dev/null
```

**Run after implementation:**
```bash
# Ruff (modern, fast linter + formatter - recommended)
ruff check .                # Linting
ruff format --check .       # Format check
ruff check --fix .          # Auto-fix issues

# mypy (type checker)
mypy .
# or: mypy src/

# pylint (comprehensive linter)
pylint src/
# or: pylint **/*.py

# black (formatter)
black --check .
black .                     # Apply formatting

# flake8 (linter)
flake8 .

# isort (import sorting)
isort --check-only .
isort .                     # Apply sorting
```

**Common pyproject.toml patterns:**
```toml
[tool.ruff]
line-length = 100
target-version = "py311"

[tool.ruff.lint]
select = ["E", "F", "I", "N", "W", "UP"]
ignore = ["E501"]

[tool.mypy]
python_version = "3.11"
strict = true
warn_return_any = true
warn_unused_configs = true

[tool.black]
line-length = 100
target-version = ["py311"]
```

## Pattern Extraction Commands

```bash
# Type annotation coverage
mypy --disallow-untyped-defs --disallow-any-unimported .

# Unused imports
ruff check --select F401 .
# or: pylint --disable=all --enable=unused-import

# Unused variables
ruff check --select F841 .
# or: pylint --disable=all --enable=unused-variable

# Missing docstrings
ruff check --select D .
# or: pylint --disable=all --enable=missing-docstring
```

## Standards

| Pattern | Standard |
|---------|----------|
| Formatting | `black` or `ruff format` |
| Import sorting | `isort` or `ruff` (I rules) |
| Type hints | All functions (enforced by `mypy --strict`) |
| Linting | `ruff` or `pylint` |

## Non-Obvious Anti-Patterns

```python
# Mutable default argument
def add_item(item, items=[]):  # ❌ Shared list across calls
    items.append(item)
    return items
# Fix:
def add_item(item, items=None):  # ✅
    if items is None:
        items = []
    items.append(item)
    return items

# Type narrowing with isinstance not preserved after reassignment
def process(value: str | int) -> str:
    if isinstance(value, str):
        value = value.strip()  # ✅ value is str
        value = None  # ❌ mypy error: incompatible type
    return value

# Missing __future__ annotations for forward references (Python <3.10)
class Node:
    def add_child(self, child: Node):  # ❌ NameError: Node not defined yet
        pass
# Fix:
from __future__ import annotations  # ✅ At top of file

class Node:
    def add_child(self, child: Node):  # ✅
        pass

# Type: ignore hiding real issues
def process(data: dict) -> str:
    return data["key"]  # type: ignore  # ❌ Hides missing key handling
# Fix: Proper error handling
def process(data: dict) -> str:
    if "key" not in data:
        raise ValueError("Missing key")
    return data["key"]  # ✅

# Any leaking through untyped libraries
import untyped_lib  # No stubs

result = untyped_lib.fetch()  # Type: Any (spreads to everything)
value = result.nested.data  # ❌ No type checking
# Fix: Add type stubs or explicit annotations
from typing import cast
from myproject.types import ApiResponse

result = cast(ApiResponse, untyped_lib.fetch())  # ✅
value = result.nested.data  # Type-checked

# Class variable vs instance variable confusion
class Config:
    items = []  # ❌ Class variable - shared across instances

    def add(self, item):
        self.items.append(item)  # Modifies shared list!

# Fix:
class Config:
    def __init__(self):
        self.items = []  # ✅ Instance variable
```

## Validation Checklist

- [ ] **Run `ruff check .` (or `pylint`) and fix ALL errors**
- [ ] **Run `mypy .` and fix ALL type errors**
- [ ] **Run `ruff format --check .` (or `black --check`) and fix formatting**
- [ ] No mutable default arguments
- [ ] All functions have type hints (params + return)
- [ ] No bare `except:` clauses (use specific exceptions)
- [ ] No unused imports or variables
- [ ] `from __future__ import annotations` if Python < 3.10 with forward refs
- [ ] No `# type: ignore` without justification comment

## Progressive Loading

**Core:** This file
**On-demand:**
- `reference/type-hints.md` — when implementing complex types
- `reference/async-patterns.md` — when implementing async/await
- `reference/testing.md` — when writing pytest tests
