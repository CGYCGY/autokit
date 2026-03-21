# Go Test Pattern Extractors

Patterns and commands to extract testing conventions from Go codebases.

## Test File Discovery

```bash
# Find all test files
find . -name "*_test.go" -type f | grep -v vendor

# Count test files
find . -name "*_test.go" -type f | grep -v vendor | wc -l
```

## Framework Detection

### Standard Library
```bash
# Check for testing package usage
grep -r "testing.T" . --include="*_test.go" | head -3
```

### Testify
```bash
# Check for testify imports
grep -r "github.com/stretchr/testify" . --include="*_test.go" | head -3
```

### Gomock
```bash
# Check for gomock
grep -r "go:generate mockgen\|gomock" . --include="*.go" | head -3
```

### Mockery
```bash
# Check for mockery
grep -r "go:generate mockery" . --include="*.go" | head -3
ls mocks/ 2>/dev/null
```

## Structure Pattern Detection

### Table-Driven Tests
```bash
# Look for test table pattern
grep -r "tests := \[\]struct\|testCases := \[\]struct" . --include="*_test.go" | head -3
```

**Example pattern:**
```go
tests := []struct {
    name    string
    input   Type
    want    Type
    wantErr bool
}{
    // test cases
}
for _, tt := range tests {
    t.Run(tt.name, func(t *testing.T) {
        // ...
    })
}
```

### Subtests
```bash
# Look for t.Run usage
grep -r "t\.Run(" . --include="*_test.go" | head -3
```

### Parallel Tests
```bash
# Look for t.Parallel()
grep -r "t\.Parallel()" . --include="*_test.go" | head -3
```

## Mocking Patterns

### Interface-Based Mocks
```bash
# Find mock implementations
grep -rn "type mock.*struct\|type Mock.*struct" . --include="*_test.go" | head -5
```

### Generated Mocks Location
```bash
# Common mock directories
ls mocks/ internal/mocks/ pkg/mocks/ 2>/dev/null
```

### Mock Usage Pattern
```bash
# How mocks are used
grep -A5 "mock\." . --include="*_test.go" | head -20
```

## Fixture Patterns

### Testdata Directory
```bash
# Find testdata directories
find . -name "testdata" -type d
```

### Fixture Loading
```bash
# How fixtures are loaded
grep -r "testdata\|ReadFile.*test\|LoadFixture" . --include="*_test.go" | head -5
```

### Golden Files
```bash
# Check for golden file pattern
grep -r "golden\|\.golden" . --include="*_test.go" | head -3
```

## Assertion Patterns

### Testify Assert
```bash
# Check assertion style
grep -r "assert\.\|require\." . --include="*_test.go" | head -5
```

**Common patterns:**
- `assert.Equal(t, expected, actual)`
- `assert.NoError(t, err)`
- `require.NotNil(t, obj)`

### Standard Library
```bash
# Check for if-based assertions
grep -r "if.*!= want\|t\.Errorf\|t\.Fatalf" . --include="*_test.go" | head -5
```

## Setup/Teardown Patterns

### TestMain
```bash
# Check for TestMain
grep -rn "func TestMain" . --include="*_test.go"
```

### Setup Functions
```bash
# Check for setup helpers
grep -rn "func setup\|func Setup\|func newTest" . --include="*_test.go" | head -5
```

### Cleanup
```bash
# Check for t.Cleanup usage
grep -r "t\.Cleanup(" . --include="*_test.go" | head -3
```

## Integration Test Patterns

### Build Tags
```bash
# Check for integration build tags
grep -r "//go:build integration\|// +build integration" . --include="*_test.go" | head -3
```

### Database Tests
```bash
# Check for database test patterns
grep -r "testdb\|TestDB\|setupDB\|NewTestDatabase" . --include="*_test.go" | head -5
```

## Coverage Configuration

### Makefile Targets
```bash
grep -E "cover|coverage" Makefile 2>/dev/null
```

### Common Commands
```bash
# Standard coverage
go test -cover ./...

# With HTML report
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

## Output Template

After extraction, document findings:

```markdown
## Go Test Patterns

### Framework
- Primary: testify (assert + require)
- Mocking: mockery (generated mocks in `mocks/`)

### Structure
- Pattern: Table-driven tests with t.Run
- Parallel: Yes, using t.Parallel()

### Example
From `internal/user/service_test.go:25`:
```go
func TestUserService_Create(t *testing.T) {
    tests := []struct {
        name    string
        email   string
        wantErr bool
    }{
        {"valid", "test@example.com", false},
        {"invalid", "", true},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            // ...
        })
    }
}
```
```
