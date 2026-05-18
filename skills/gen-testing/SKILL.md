---
name: gen-testing
description: Generates customized testing skills for projects by analyzing test patterns, detecting development environment (Docker, local), and creating executable test guidelines. Use when user asks to "generate testing guidelines", "create test skill", "setup testing", "configure test environment", or mentions "testing conventions", "how to test", "test agent".
context: fork
agent: Plan
---

# Purpose

Analyzes codebase to extract testing patterns, detect development environment, and generate a customized `testing` skill for test agents and developers.

## Variables

### Output Location
SKILL_OUTPUT_DIR: `.claude/skills/testing/`

## Instructions

### Environment Detection Rules
- Detect containerization: `Dockerfile`, `docker-compose.yml`, `.devcontainer/`
- Detect database from docker-compose services or config files
- Find test commands in `Makefile`, `package.json`, `pyproject.toml`, CI files
- **Ask if not detected** - never guess environment

### Database Requirements
- Test database MUST match production architecture
- No SQLite when production uses PostgreSQL/MySQL
- Same DB engine, same schema structure

### Pattern Extraction Rules
- Extract patterns from actual test files, not templates
- Document what exists, don't prescribe what should exist
- Preserve project-specific conventions

## Workflow

### Phase 1: Environment Detection
**Read:** `workflows/detect-environment.md`

1. Search for Docker files (`Dockerfile`, `docker-compose.yml`)
2. Detect mobile platform (React Native / Expo) — sets `mobile: bare|managed|prebuild|none`
3. Identify database services from compose or config
4. Find test commands in build files
5. If unclear, ask user

### Phase 2: Test Pattern Extraction
**Read:** `workflows/extract-patterns.md`
**Read:** `extractors/[language]-test-extractors.md`
**Read (if `mobile != none`):** `extractors/rn-test-extractors.md`

1. Locate test files by language conventions
2. Extract test structure patterns (AAA, BDD, table-driven)
3. Identify mocking approaches
4. Document fixture patterns
5. For mobile projects, additionally extract Detox / Maestro / agent-runner conventions

### Phase 3: User Consultation

Present findings:
```
Detected Environment:
- Containerization: [docker-compose / local / none]
- Database: [PostgreSQL / MySQL / MongoDB / none]
- Test command: [detected command or "not found"]

Questions:
1. Test DB setup - separate container or test schema?
2. Seed data approach - fixtures, factories, or SQL?
```

### Phase 4: Generate Testing Skill
**Read:** `workflows/generate-skill.md`
**Read:** `templates/testing-skill.template.md`

1. Create skill directory structure
2. Generate `SKILL.md` from template
3. Generate `environment.md` with test commands
4. Generate `patterns.md` with extracted conventions
5. Generate `database.md` with setup instructions — **skip if no backend DB detected** (e.g., RN-only project)
6. Generate `seed-data.md` with data management — **skip if step 5 skipped**
7. Generate `mobile-e2e.md` with Detox/Maestro commands and testID conventions — **only if `mobile != none`**
8. Generate `checklists/pre-test.md`

**Output matrix:**

| Project type | DB outputs | Mobile output |
|--------------|------------|---------------|
| Backend (Go/Python/server-side TS) | ✅ database.md, seed-data.md | ❌ |
| RN/Expo only (no backend in repo) | ❌ | ✅ mobile-e2e.md |
| Full-stack monorepo with RN client | ✅ database.md, seed-data.md | ✅ mobile-e2e.md |

## Cookbook

### Docker Environment
- **IF:** `docker-compose.yml` exists with app service
- **THEN:** Use `docker-compose exec <service> <test-command>`
- **EXAMPLES:** "run tests in docker", "test in container"

### Local Environment
- **IF:** No Docker files found, local tooling detected
- **THEN:** Use native test commands (`go test`, `pytest`, `npm test`)
- **EXAMPLES:** "run tests locally", "local testing"

### New Project (No Tests)
- **IF:** No test files found
- **THEN:** Ask user for intended test framework, generate starter patterns
- **EXAMPLES:** "setup testing for new project", "initialize test structure"

### React Native / Expo Mobile
- **IF:** `react-native` or `expo` in `package.json`
- **THEN:** Load `extractors/rn-test-extractors.md` alongside TypeScript extractor; detect Detox (`.detoxrc.*`, `e2e/`) and Maestro (`.maestro/`)
- **EXAMPLES:** "test the RN app", "setup Detox", "setup Maestro flows", "mobile e2e testing"

## Supporting Files

- `workflows/detect-environment.md` - Environment detection logic
- `workflows/extract-patterns.md` - Test pattern extraction
- `workflows/generate-skill.md` - Skill generation process
- `extractors/go-test-extractors.md` - Go test patterns
- `extractors/python-test-extractors.md` - Python test patterns
- `extractors/typescript-test-extractors.md` - TypeScript test patterns
- `extractors/rn-test-extractors.md` - React Native / Expo e2e patterns (Detox, Maestro)
- `templates/testing-skill.template.md` - Generated skill template
