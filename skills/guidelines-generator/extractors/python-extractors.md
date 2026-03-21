# Python Code Extractors

This file defines extraction logic for analyzing Python codebases.

## General Utilities

### Find Python Files
```bash
# Find all Python files
find . -name "*.py" -not -path "*/venv/*" -not -path "*/.venv/*" -not -path "*/node_modules/*" -not -path "*/__pycache__/*"

# Find specific directories
find . -type d -name "app" -o -name "src" -o -name "api"
```

### Parse Requirements
```bash
# Check for requirements.txt
find . -name "requirements.txt" -type f

# Check for pyproject.toml
find . -name "pyproject.toml" -type f

# Get dependencies from pyproject.toml
grep -A100 "\[tool.poetry.dependencies\]" pyproject.toml 2>/dev/null | grep "^[a-zA-Z]" | head -20
```

### Search Imports
```bash
# Find all imports
grep -rn "^import\|^from" --include="*.py" | head -50

# Find specific framework imports
grep -rn "from fastapi import\|import fastapi" --include="*.py"
grep -rn "from django\|import django" --include="*.py"
grep -rn "from flask import\|import flask" --include="*.py"
```

## Pattern Extractors

### Extract Class Definitions
```bash
# Find all class definitions
grep -rn "^class " --include="*.py"

# Find dataclasses
grep -rn "@dataclass" --include="*.py"

# Find Pydantic models
grep -rn "class.*BaseModel" --include="*.py"
```

### Extract Functions
```bash
# Find all function definitions
grep -rn "^def " --include="*.py"

# Find async functions
grep -rn "^async def " --include="*.py"

# Find decorators
grep -rn "^@" --include="*.py"
```

### Extract Type Hints
```bash
# Find type annotations
grep -rn ": .*->" --include="*.py"

# Find Optional usage
grep -rn "Optional\[" --include="*.py"

# Find Union usage
grep -rn "Union\[" --include="*.py"
```

## Framework-Specific Extractors

### FastAPI
```bash
# Find FastAPI routers
grep -rn "@app\\.get\|@app\\.post\|@router\\.get\|@router\\.post" --include="*.py"

# Find Pydantic models
grep -rn "class.*BaseModel" --include="*.py"

# Find dependency injection
grep -rn "Depends(" --include="*.py"
```

### Django
```bash
# Find models
grep -rn "class.*models\\.Model" --include="*.py"

# Find views
grep -rn "def.*request" --include="views.py"

# Find URLs
grep -rn "urlpatterns" --include="urls.py"
```

## Reading Code

Use the Read tool to examine files:

```
Read(file_path)
```

Then extract relevant code sections using line numbers from grep results.

## Pattern Grouping

After extracting, group similar patterns:
1. Read multiple example files
2. Identify common structure
3. Note variations
4. Count usage frequency

## Output Format

Return extracted patterns as:

```json
{
  "patternName": "FastAPI Route Handler",
  "variations": [
    {
      "id": "A",
      "description": "Async route handler with dependency injection",
      "files": ["api/users.py:15", "api/posts.py:23"],
      "count": 12,
      "example": "@router.get('/users')\nasync def get_users(db: Session = Depends(get_db)): ..."
    }
  ]
}
```
