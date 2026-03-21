# Go Code Extractors

This file defines extraction logic for analyzing Go codebases.

## General Utilities

### Find Go Files
```bash
find . -name "*.go" -not -path "*/vendor/*" -not -path "*/node_modules/*"
```

### Parse go.mod
```bash
# Get module name
grep "^module" go.mod | awk '{print $2}'

# Get dependencies
grep -v "^module\|^go\|^require\|^replace\|^exclude\|^retract\|^//" go.mod | grep -v "^$"
```

### Search Imports
```bash
# Find all imports
find . -name "*.go" -exec grep -h "^\s*\"" {} \; | sort -u

# Find specific package imports
grep -rn "import.*github.com/gin-gonic/gin" --include="*.go"
```

## Pattern Extractors

### Extract Type Definitions
```bash
# Find all struct types
grep -rn "^type.*struct" --include="*.go"

# Find all interface types
grep -rn "^type.*interface" --include="*.go"

# Find all type aliases
grep -rn "^type.*=" --include="*.go"
```

### Extract Functions
```bash
# Find all function definitions
grep -rn "^func " --include="*.go"

# Find methods (functions with receivers)
grep -rn "^func ([^)]*)" --include="*.go"
```

### Extract Constants and Variables
```bash
# Find const blocks
grep -rn "^const\|^const (" --include="*.go"

# Find var declarations
grep -rn "^var\|^var (" --include="*.go"
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
  "patternName": "Domain Entity Constructor",
  "variations": [
    {
      "id": "A",
      "description": "Factory function returning pointer and error",
      "files": ["file1.go:15", "file2.go:23"],
      "count": 12,
      "example": "func NewCart(...) (*Cart, error) { ... }"
    }
  ]
}
```
