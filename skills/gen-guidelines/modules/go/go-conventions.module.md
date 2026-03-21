---
module: go-conventions
language: go
category: language
requires: []
conflicts: []
priority: highest
---

# Go Conventions Module

## Detection

```bash
find . -name "go.mod" -type f
grep "^go " go.mod
```

## Tooling Commands

**Detect project linters:**
```bash
# Check for golangci-lint config
ls -la .golangci.yml .golangci.yaml 2>/dev/null

# Check Makefile for lint targets
grep -E "^lint:|golangci-lint" Makefile 2>/dev/null

# Check for pre-commit hooks
cat .pre-commit-config.yaml 2>/dev/null | grep golangci
```

**Run after implementation:**
```bash
# golangci-lint (recommended - aggregates multiple linters)
golangci-lint run ./...
# or: make lint (if defined in Makefile)

# Go vet (built-in static analyzer)
go vet ./...

# Go build (compile check)
go build ./...

# Go fmt check (formatting)
gofmt -l .
# or: go fmt ./...

# Go staticcheck (popular linter)
staticcheck ./...
```

**Common Makefile patterns:**
```makefile
.PHONY: lint
lint:
	golangci-lint run ./...

.PHONY: test
test:
	go test ./... -v

.PHONY: build
build:
	go build ./...
```

## Pattern Extraction Commands

```bash
# Unused variables (common after refactoring)
golangci-lint run --disable-all --enable unused ./...

# Error handling issues
golangci-lint run --disable-all --enable errcheck ./...

# Ineffective assignments
golangci-lint run --disable-all --enable ineffassign ./...

# Shadowed variables
golangci-lint run --disable-all --enable shadow ./...
```

## Standards

| Pattern | Standard |
|---------|----------|
| Formatting | `gofmt` (enforced) |
| Imports | `goimports` (auto-groups stdlib, external, internal) |
| Error handling | All errors must be checked (`errcheck`) |
| Unused code | No unused variables/imports (`unused`) |

## Non-Obvious Anti-Patterns

```go
// defer in loop (deferred until function exit, not iteration)
for _, file := range files {
    f, _ := os.Open(file)
    defer f.Close()  // ❌ All close at function end, not iteration
}
// Fix: Close immediately or use separate function
for _, file := range files {
    func() {
        f, _ := os.Open(file)
        defer f.Close()  // ✅ Closes at end of anonymous func
        process(f)
    }()
}

// Shadowing err in nested scope
err := doThing()
if err != nil {
    err := handleError(err)  // ❌ Shadows outer err, confusion
    if err != nil {
        return err
    }
}
// Fix: Use different variable name
err := doThing()
if err != nil {
    handleErr := handleError(err)  // ✅
    if handleErr != nil {
        return handleErr
    }
}

// Ineffective assignment before return
func process() error {
    err := validate()
    if err != nil {
        err = fmt.Errorf("validation failed: %w", err)  // ❌ Could wrap directly
        return err
    }
    return nil
}
// Fix: Return directly
func process() error {
    err := validate()
    if err != nil {
        return fmt.Errorf("validation failed: %w", err)  // ✅
    }
    return nil
}

// Copying mutex by value
type Data struct {
    mu sync.Mutex
    value int
}
func process(d Data) {  // ❌ Copies mutex
    d.mu.Lock()
}
// Fix: Use pointer
func process(d *Data) {  // ✅
    d.mu.Lock()
}
```

## Validation Checklist

- [ ] **Run `golangci-lint run ./...` and fix ALL errors**
- [ ] **Run `go vet ./...` and fix ALL warnings**
- [ ] **Run `go build ./...` and ensure compilation succeeds**
- [ ] No unused variables or imports
- [ ] All errors are checked (no `_` for errors without justification)
- [ ] No shadowed variables in error handling
- [ ] No `defer` in loops (unless in closure)
- [ ] Mutex types not copied by value

## Progressive Loading

**Core:** This file
**On-demand:**
- `reference/error-handling.md` — when implementing error handling
- `reference/concurrency.md` — when implementing goroutines/channels
- `reference/testing.md` — when writing tests
