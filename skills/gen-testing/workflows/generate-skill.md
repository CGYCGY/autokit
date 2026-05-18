# Testing Skill Generation Workflow

Generates the testing skill from extracted patterns and environment detection.

## Output Structure

```
.claude/skills/testing/
├── SKILL.md              # Main skill file
├── environment.md        # Test execution environment
├── patterns.md           # Test conventions
├── database.md           # Test DB setup        (skip if HAS_BACKEND_DB=false)
├── seed-data.md          # Test data management (skip if HAS_BACKEND_DB=false)
├── mobile-e2e.md         # Detox/Maestro guide  (only if IS_MOBILE=true)
└── checklists/
    └── pre-test.md       # Pre-test checklist
```

## Step 0: Compute Conditional Flags

Before generating any file, derive these flags from the `detect-environment.md` JSON output:

| Flag | Derivation | Effect |
|------|-----------|--------|
| `IS_MOBILE` | `mobile.platform != "none"` | Gates Step 7 (mobile-e2e.md) and the `mobile-e2e.md` entry in SKILL.md's Supporting Files |
| `HAS_BACKEND_DB` | `database.type != null` | Gates Steps 5–6 (database.md, seed-data.md) and their entries in SKILL.md's Supporting Files |

Apply these flags through every step below — do not generate files for skipped steps, and do not list skipped files in the generated SKILL.md.

## Step 1: Create Directory Structure

```bash
mkdir -p .claude/skills/testing/checklists
```

## Step 2: Generate SKILL.md

Use template from `templates/testing-skill.template.md`.

**Required substitutions:**
- `{{LANGUAGE}}` - Detected language (Go, Python, TypeScript)
- `{{FRAMEWORK}}` - Test framework (pytest, jest, go test)
- `{{TEST_COMMAND}}` - Full test command
- `{{CONTAINER_COMMAND}}` - Docker exec prefix if containerized

## Step 3: Generate environment.md

### Content Structure

```markdown
# Test Environment

## Prerequisites
[List required tools, containers, env vars]

## Running Tests

### Full Test Suite
[Main test command]

### Unit Tests Only
[Unit test command]

### Integration Tests
[Integration test command with DB setup]

### Watch Mode (if available)
[Watch command for TDD]

## Environment Variables
[Required env vars for testing]

## Troubleshooting
[Common issues and solutions]
```

### Docker Environment Example
```markdown
## Running Tests

### Full Test Suite
```bash
docker-compose exec app go test ./...
```

### With Coverage
```bash
docker-compose exec app go test -cover ./...
```

### Specific Package
```bash
docker-compose exec app go test ./internal/user/...
```
```

### Local Environment Example
```markdown
## Running Tests

### Full Test Suite
```bash
pytest
```

### With Coverage
```bash
pytest --cov=app --cov-report=html
```

### Specific Module
```bash
pytest tests/unit/test_user.py
```
```

## Step 4: Generate patterns.md

### Content Structure

```markdown
# Test Patterns

## File Organization
[Where tests live, naming conventions]

## Test Structure
[AAA, BDD, table-driven - with examples from codebase]

## Mocking
[How to mock dependencies - with examples]

## Fixtures
[How to set up test data - with examples]

## Assertions
[Assertion style and library - with examples]
```

### Include Real Examples

Extract 2-3 actual examples from codebase for each pattern:

```markdown
## Test Structure

This project uses table-driven tests. Example from `internal/user/service_test.go:15`:

```go
func TestCreateUser(t *testing.T) {
    tests := []struct {
        name    string
        email   string
        wantErr bool
    }{
        {"valid email", "test@example.com", false},
        {"empty email", "", true},
    }
    // ...
}
```
```

## Step 5: Generate database.md

**Skip this step if `HAS_BACKEND_DB == false`.** Pure RN/Expo projects (or any project with no backend DB) do not need this file.


### Content Structure

```markdown
# Test Database

## Architecture
[Database type, connection details]

## Setup

### Option A: Separate Test Database
[How to create/connect to test DB]

### Option B: Test Schema
[How to use test schema in same DB]

## Migrations
[How to run migrations for tests]

## Cleanup
[How to reset database between tests]

## Isolation
[How tests are isolated from each other]
```

### Docker Database Example
```markdown
## Architecture

- **Type:** PostgreSQL 15
- **Container:** `db` service in docker-compose
- **Test Database:** `app_test` (separate from `app`)

## Setup

### Create Test Database
```bash
docker-compose exec db createdb -U postgres app_test
```

### Run Migrations
```bash
docker-compose exec app go run cmd/migrate/main.go -db=test
```

## Cleanup

Tests use transactions that rollback after each test.
For full reset:
```bash
docker-compose exec db dropdb -U postgres app_test
docker-compose exec db createdb -U postgres app_test
```
```

## Step 6: Generate seed-data.md

**Skip this step if `HAS_BACKEND_DB == false`** (must skip whenever Step 5 was skipped).


### Content Structure

```markdown
# Test Data Management

## Approach
[Fixtures, factories, or SQL scripts]

## Creating Test Data

### Using Fixtures
[How to use fixture files]

### Using Factories
[How to use factory functions]

## Common Test Data
[Frequently used test entities]

## Cleanup
[How to clean up after tests]
```

### Fixtures Example
```markdown
## Approach

This project uses JSON fixtures in `testdata/` directories.

## Creating Test Data

### Loading Fixtures
```go
func loadFixture(t *testing.T, name string) []byte {
    data, err := os.ReadFile(filepath.Join("testdata", name))
    require.NoError(t, err)
    return data
}
```

### Fixture Location
Place fixtures alongside test files:
```
internal/user/
├── service.go
├── service_test.go
└── testdata/
    ├── valid_user.json
    └── invalid_user.json
```
```

## Step 7: Generate mobile-e2e.md

**Skip this step if `IS_MOBILE == false`.** Use the `## mobile-e2e.md Template` block in `templates/testing-skill.template.md`.

### Content Structure

```markdown
# Mobile E2E Tests

## Project
[Workflow, platforms, bundle IDs]

## testID Convention
[Style + shape, with rationale]

## Detox             (only if Detox detected)
[Configurations, build, run, matcher style, example]

## Maestro           (only if Maestro detected)
[Flow location, run, selector style, example]

## Simulator / Emulator Boot
[iOS + Android commands]

## Mocking Strategy
[Approach, optional setup example]

## CI Integration
[Binary build, runner, device farm]

## Troubleshooting
[Per-framework fixes]
```

### Conditional Rules

| Block | Include when |
|-------|--------------|
| `{{#if DETOX}}` | `detox` in `package.json` or `.detoxrc.*` found |
| `{{#if MAESTRO}}` | `.maestro/` found or `maestro test` referenced in CI |
| `{{#if MOBILE_MOCK_APPROACH}}` | a mocking approach was extracted |

### Empty-Framework Fallback

If `IS_MOBILE == true` but neither Detox nor Maestro was detected, emit only the Project + testID Convention sections, plus a note: `> No e2e framework detected — recommend adding Detox or Maestro.`

## Step 8: Generate checklists/pre-test.md

```markdown
# Pre-Test Checklist

## Before Running Tests

- [ ] Docker containers running (`docker-compose up -d`)
- [ ] Test database exists and migrated
- [ ] Environment variables set
- [ ] Dependencies installed

## Quick Verification

```bash
# Check containers
docker-compose ps

# Check DB connection
docker-compose exec db pg_isready

# Run single test to verify setup
docker-compose exec app go test ./internal/health/...
```

## Common Issues

### Database Connection Failed
- Ensure `db` container is running
- Check `DATABASE_URL` env var
- Verify test database exists

### Tests Hanging
- Check for missing mocks
- Verify no real external calls
- Check for deadlocks in concurrent tests
```

## Final Validation

After generation, verify:
1. All files created successfully
2. Commands are accurate for detected environment
3. Examples match actual codebase patterns
4. No placeholder text remains
