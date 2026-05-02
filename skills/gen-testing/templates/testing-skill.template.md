# Testing Skill Template

Template for generating the testing skill. Replace `{{PLACEHOLDER}}` with extracted values.

## SKILL.md Template

```markdown
---
name: testing
description: Executes tests for this {{LANGUAGE}} project using {{FRAMEWORK}}. Use when user asks to "run tests", "test this", "check if tests pass", or mentions "testing", "test coverage", "unit tests", "integration tests".
---

# Purpose

Runs and manages tests for this project. Provides test execution commands, patterns, and database setup specific to this codebase.

## Variables

### Test Commands
- FULL_SUITE: `{{TEST_COMMAND}}`
- UNIT_ONLY: `{{UNIT_TEST_COMMAND}}`
- INTEGRATION: `{{INTEGRATION_TEST_COMMAND}}`
- COVERAGE: `{{COVERAGE_COMMAND}}`

### Environment
- CONTAINER: `{{CONTAINER_SERVICE}}` (if Docker)
- TEST_DB: `{{TEST_DATABASE}}`

## Instructions

### Before Running Tests
- Read `checklists/pre-test.md` for prerequisites
- Ensure environment is ready (containers running, DB available)

### Test Execution Rules
- Always run from project root
- Use containerized commands if Docker environment
- Run unit tests first, then integration tests
- Check coverage after significant changes

### Database Rules
- Test database must match production architecture
- Never run tests against production database
- Clean up test data after integration tests

## Workflow

### Running Full Test Suite
1. Verify prerequisites (read `checklists/pre-test.md`)
2. Execute: `{{FULL_TEST_COMMAND}}`
3. Report results

### Running Specific Tests
1. Identify test file or pattern
2. Execute: `{{SPECIFIC_TEST_COMMAND}} <pattern>`
3. Report results

### Running with Coverage
1. Execute: `{{COVERAGE_COMMAND}}`
2. Report coverage percentage
3. Identify uncovered areas if below threshold

## Cookbook

### Unit Tests Only
- **IF:** Request matches "unit tests", "quick test", or "test without db"
- **THEN:** Execute `{{UNIT_TEST_COMMAND}}`
- **EXAMPLES:** "run unit tests", "quick test", "test without db"

### Integration Tests
- **IF:** Request matches "integration tests", "db tests", or "full tests"
- **THEN:** Verify DB is ready, then execute `{{INTEGRATION_TEST_COMMAND}}`
- **EXAMPLES:** "run integration tests", "test with database", "full tests"

### Single Test File
- **IF:** Request includes a file path or function name (e.g. `tests/auth_test.go`, `TestLogin`)
- **THEN:** Execute `{{SPECIFIC_TEST_COMMAND}} <file>`
- **EXAMPLES:** "test user service", "run tests for auth"

### Coverage Report
- **IF:** Request matches "coverage" or "coverage report"
- **THEN:** Execute `{{COVERAGE_COMMAND}}`, report percentage
- **EXAMPLES:** "check coverage", "coverage report", "how much is tested"

## Supporting Files

- `environment.md` - Test execution environment details
- `patterns.md` - Test conventions and examples
- `database.md` - Test database setup
- `seed-data.md` - Test data management
- `checklists/pre-test.md` - Prerequisites checklist
```

## environment.md Template

```markdown
# Test Environment

## Development Environment

**Type:** {{ENVIRONMENT_TYPE}}
{{#if DOCKER}}
**Container Service:** {{CONTAINER_SERVICE}}
**Compose File:** docker-compose.yml
{{/if}}

## Prerequisites

{{#if DOCKER}}
- Docker and docker-compose installed
- Containers running: `docker-compose up -d`
{{else}}
- {{LANGUAGE}} installed (version {{VERSION}})
- Dependencies installed: `{{INSTALL_COMMAND}}`
{{/if}}
- Test database created
- Environment variables set

## Running Tests

### Full Test Suite
```bash
{{FULL_TEST_COMMAND}}
```

### Unit Tests Only
```bash
{{UNIT_TEST_COMMAND}}
```

### Integration Tests
```bash
{{INTEGRATION_TEST_COMMAND}}
```

### Specific File/Pattern
```bash
{{SPECIFIC_TEST_COMMAND}} <pattern>
```

### With Coverage
```bash
{{COVERAGE_COMMAND}}
```

### Watch Mode
```bash
{{WATCH_COMMAND}}
```

## Environment Variables

| Variable | Description | Test Value |
|----------|-------------|------------|
{{#each ENV_VARS}}
| {{name}} | {{description}} | {{testValue}} |
{{/each}}

## Troubleshooting

### Container Not Running
```bash
docker-compose up -d
docker-compose ps  # Verify status
```

### Database Connection Failed
- Check container is running: `docker-compose ps db`
- Verify test database exists
- Check DATABASE_URL environment variable

### Tests Hanging
- Check for missing mocks (external services)
- Verify no actual network calls in unit tests
- Check for deadlocks in concurrent tests
```

## patterns.md Template

```markdown
# Test Patterns

## File Organization

**Location:** {{TEST_LOCATION}}
**Naming:** {{TEST_NAMING}}

Example:
```
{{FILE_STRUCTURE_EXAMPLE}}
```

## Test Structure

**Pattern:** {{STRUCTURE_PATTERN}}

### Example
From `{{EXAMPLE_FILE}}`:
```{{LANGUAGE}}
{{STRUCTURE_EXAMPLE}}
```

## Mocking

**Approach:** {{MOCK_APPROACH}}
**Library:** {{MOCK_LIBRARY}}

### Example
```{{LANGUAGE}}
{{MOCK_EXAMPLE}}
```

## Fixtures

**Location:** {{FIXTURE_LOCATION}}
**Pattern:** {{FIXTURE_PATTERN}}

### Example
```{{LANGUAGE}}
{{FIXTURE_EXAMPLE}}
```

## Assertions

**Library:** {{ASSERTION_LIBRARY}}
**Style:** {{ASSERTION_STYLE}}

### Common Assertions
```{{LANGUAGE}}
{{ASSERTION_EXAMPLES}}
```
```

## database.md Template

```markdown
# Test Database

## Architecture

- **Type:** {{DB_TYPE}}
- **Host:** {{DB_HOST}}
- **Test Database:** {{TEST_DB_NAME}}

## Setup

### Create Test Database
```bash
{{CREATE_DB_COMMAND}}
```

### Run Migrations
```bash
{{MIGRATE_COMMAND}}
```

## Connection

### Environment Variable
```
{{DB_URL_VAR}}={{TEST_DB_URL}}
```

### Code Configuration
```{{LANGUAGE}}
{{DB_CONFIG_EXAMPLE}}
```

## Isolation Strategy

{{ISOLATION_STRATEGY}}

### Transaction Rollback (Recommended)
```{{LANGUAGE}}
{{TRANSACTION_EXAMPLE}}
```

### Truncate Tables
```{{LANGUAGE}}
{{TRUNCATE_EXAMPLE}}
```

## Cleanup

### Reset Database
```bash
{{RESET_DB_COMMAND}}
```

### Between Test Runs
{{CLEANUP_STRATEGY}}
```

## seed-data.md Template

```markdown
# Test Data Management

## Approach

**Primary:** {{SEED_APPROACH}}
**Location:** {{SEED_LOCATION}}

## Creating Test Data

### {{SEED_METHOD_1}}
```{{LANGUAGE}}
{{SEED_EXAMPLE_1}}
```

### {{SEED_METHOD_2}}
```{{LANGUAGE}}
{{SEED_EXAMPLE_2}}
```

## Common Test Entities

### User
```{{LANGUAGE}}
{{USER_FIXTURE}}
```

### {{ENTITY_2}}
```{{LANGUAGE}}
{{ENTITY_2_FIXTURE}}
```

## Loading Seed Data

### For Integration Tests
```{{LANGUAGE}}
{{LOAD_SEED_EXAMPLE}}
```

### For Specific Test
```{{LANGUAGE}}
{{SPECIFIC_SEED_EXAMPLE}}
```

## Cleanup

### After Each Test
{{CLEANUP_EACH}}

### After Test Suite
{{CLEANUP_SUITE}}
```

## checklists/pre-test.md Template

```markdown
# Pre-Test Checklist

Run through this checklist before executing tests.

## Environment

{{#if DOCKER}}
- [ ] Docker is running
- [ ] Containers are up: `docker-compose ps`
- [ ] All services healthy
{{else}}
- [ ] {{LANGUAGE}} installed and in PATH
- [ ] Dependencies installed: `{{INSTALL_COMMAND}}`
{{/if}}

## Database

- [ ] Test database exists: `{{CHECK_DB_COMMAND}}`
- [ ] Migrations are current: `{{CHECK_MIGRATION_COMMAND}}`
- [ ] No stale test data

## Configuration

- [ ] Environment variables set
- [ ] Test configuration loaded
- [ ] No production credentials in test env

## Quick Verification

```bash
# Run a single fast test to verify setup
{{QUICK_TEST_COMMAND}}
```

## Common Issues

### {{ISSUE_1}}
{{SOLUTION_1}}

### {{ISSUE_2}}
{{SOLUTION_2}}

### {{ISSUE_3}}
{{SOLUTION_3}}
```

## Placeholder Reference

| Placeholder | Source | Example |
|-------------|--------|---------|
| `{{LANGUAGE}}` | detect-environment | `Go`, `Python`, `TypeScript` |
| `{{FRAMEWORK}}` | extract-patterns | `pytest`, `jest`, `go test` |
| `{{TEST_COMMAND}}` | detect-environment | `docker-compose exec app go test ./...` |
| `{{CONTAINER_SERVICE}}` | detect-environment | `app` |
| `{{DB_TYPE}}` | detect-environment | `PostgreSQL` |
| `{{STRUCTURE_PATTERN}}` | extract-patterns | `Table-driven tests` |
| `{{MOCK_APPROACH}}` | extract-patterns | `Interface-based mocks` |
| `{{FIXTURE_PATTERN}}` | extract-patterns | `JSON files in testdata/` |
