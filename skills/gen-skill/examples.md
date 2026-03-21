# Skill Generation Examples

## Example 1: Simple User-Invocable Skill

**User request:** "Create a skill that runs my Go tests with coverage"

**Generated output:**

```markdown
---
name: test-runner
description: Runs Go unit tests with coverage reporting. Use when user asks to "run tests", "check coverage", "test my code", or "go test".
argument-hint: [--package ./...] [--coverage]
allowed-tools: Bash, Read
model: sonnet
context: fork
agent: general-purpose
user-invocable: true
disable-model-invocation: true
version: "1.0.0"
---

# Test Runner

## Purpose

Run Go unit tests and report coverage results.

## Variables

- `--package`: Package path to test (default: `./...`)
- `--coverage`: Generate HTML coverage report (default: off)

## Instructions

- Always run tests from the project root
- If `go.mod` not found, ask user for the correct directory
- Parse test output for failures and report summary
- Coverage report goes to `coverage.html` in project root

## Workflow

1. Verify `go.mod` exists in working directory
2. Run `go test <package> -v -count=1`
3. If `--coverage`: run with `-coverprofile=coverage.out` and generate HTML
4. Parse output: total tests, passed, failed, skipped
5. Report summary with any failure details

## Cookbook

### Standard Run
- **IF:** No flags provided
- **THEN:** Run `go test ./... -v -count=1`
- **EXAMPLES:** "run tests", "test my code", "go test"

### With Coverage
- **IF:** `--coverage` flag set
- **THEN:** Run with `-coverprofile`, generate HTML, report percentage
- **EXAMPLES:** "run tests with coverage", "check coverage", "coverage report"

### Specific Package
- **IF:** `--package` flag set to a path
- **THEN:** Run tests only for that package
- **EXAMPLES:** "test the auth package", "run tests for ./internal/api"
```

**Why this works:**
- Single-purpose, focused skill
- Variables map directly to workflow steps
- Cookbook routes have observable IF conditions
- No supporting directories needed (simple skill)

---

## Example 2: Skill with Cookbook Routes

**User request:** "Create a skill that generates database migrations for different ORMs"

**Generated output:**

```markdown
---
name: migration-gen
description: Generates database migration files for detected ORM. Supports GORM, Prisma, and SQLAlchemy. Use when user asks to "create migration", "generate migration", "add migration", "new migration", or "schema change".
argument-hint: <migration description> [--orm gorm|prisma|sqlalchemy]
allowed-tools: Bash, Read, Write, Glob
context: fork
agent: Plan
user-invocable: true
version: "1.0.0"
---

# Migration Generator

## Purpose

Generate database migration files based on detected or specified ORM.

## Variables

- `--orm`: Force a specific ORM (`gorm`, `prisma`, `sqlalchemy`). Auto-detected if omitted.

## Instructions

### ORM Detection Rules
- **GORM**: Look for `gorm.io/gorm` in `go.mod` or `go.sum`
- **Prisma**: Look for `prisma` in `package.json` or `schema.prisma` file
- **SQLAlchemy**: Look for `sqlalchemy` in `requirements.txt`, `pyproject.toml`, or `Pipfile`
- If multiple ORMs detected, ask user which one
- If none detected and `--orm` not set, ask user

### Migration Naming
- Timestamp prefix: `YYYYMMDDHHMMSS`
- Descriptive suffix from user input: `add_users_table`, `alter_orders_add_status`
- Lowercase, underscores for separation

## Workflow

1. Detect ORM from project files (or use `--orm` flag)
2. Parse user's migration description
3. Generate migration file using ORM-specific format
4. Place file in ORM's expected migrations directory
5. Report file path and suggest next steps (review, apply)

## Cookbook

### GORM Migration
- **IF:** GORM detected or `--orm gorm`
- **THEN:** Generate Go migration file with `AutoMigrate` or raw SQL. Place in `migrations/`
- **EXAMPLES:** "create migration to add users table", "gorm migration for orders"

### Prisma Migration
- **IF:** Prisma detected or `--orm prisma`
- **THEN:** Update `schema.prisma`, run `npx prisma migrate dev --name <name>`
- **EXAMPLES:** "prisma migration for new product model", "add field to user schema"

### SQLAlchemy Migration
- **IF:** SQLAlchemy detected or `--orm sqlalchemy`
- **THEN:** Generate Alembic revision with `alembic revision --autogenerate -m "<name>"`
- **EXAMPLES:** "alembic migration for orders table", "sqlalchemy migration add status column"
```

**Why this works:**
- Cookbook routes have testable conditions (file existence, flag values)
- Each route produces a different output format
- Detection logic is in Instructions, execution paths in Cookbook

---

## Example 3: Complex Skill with Supporting Files

**User request:** "Create a skill that generates API documentation from code comments, supporting OpenAPI, GraphQL, and gRPC with multiple output formats"

**Generated output (SKILL.md):**

```markdown
---
name: api-docs
description: Generates API documentation from code annotations. Supports OpenAPI/REST, GraphQL, and gRPC. Outputs Markdown, HTML, or JSON. Use when user asks to "generate api docs", "document api", "create api reference", "export openapi spec".
argument-hint: [--type openapi|graphql|grpc] [--format md|html|json]
allowed-tools: Read, Write, Bash, Glob, Grep
context: fork
agent: Plan
user-invocable: true
version: "1.0.0"
---

# API Documentation Generator

## Purpose

Extract API definitions from source code and generate formatted documentation.

## Variables

- `--type`: API type (`openapi`, `graphql`, `grpc`). Auto-detected if omitted.
- `--format`: Output format (`md`, `html`, `json`). Default: `md`.

## Instructions

### Detection Priority
1. Check for `openapi.yaml` / `swagger.json` -> OpenAPI
2. Check for `*.graphql` / `schema.graphql` -> GraphQL
3. Check for `*.proto` files -> gRPC
4. If multiple found, ask user which to document
5. If none found, scan code comments for annotations

### Output Rules
- Markdown: Write to `docs/api/`
- HTML: Generate via template, write to `docs/api/`
- JSON: Write OpenAPI/AsyncAPI spec to `docs/api/spec.json`

## Workflow

### Phase 1: Detect API Type
**Read:** `workflows/detect-api.md`

1. Scan project for API definition files
2. Identify API type or ask user
3. Load appropriate extractor

### Phase 2: Extract Definitions
**Read:** `workflows/extract-definitions.md`

1. Parse API definitions (routes, types, fields)
2. Extract descriptions from comments/annotations
3. Build internal representation

### Phase 3: Generate Documentation
**Read:** `workflows/generate-docs.md`

1. Apply output format template
2. Generate documentation files
3. Report output location

## Cookbook

### OpenAPI / REST
- **IF:** OpenAPI spec found or `--type openapi`
- **THEN:** Parse spec, generate endpoint documentation
- **EXAMPLES:** "document rest api", "generate openapi docs"

### GraphQL
- **IF:** GraphQL schema found or `--type graphql`
- **THEN:** Parse schema, generate type and query documentation
- **EXAMPLES:** "document graphql api", "generate schema docs"

### gRPC
- **IF:** Proto files found or `--type grpc`
- **THEN:** Parse proto definitions, generate service documentation
- **EXAMPLES:** "document grpc services", "generate proto docs"

## Supporting Files

### Workflows
- `workflows/detect-api.md` - API type detection logic
- `workflows/extract-definitions.md` - Definition extraction procedures
- `workflows/generate-docs.md` - Documentation generation with format templates

### Templates
- `templates/markdown.template.md` - Markdown output template
- `templates/html.template.md` - HTML output template
- `templates/endpoint.template.md` - Per-endpoint template
```

**Why this works:**
- SKILL.md stays concise by referencing workflows for detailed procedures
- Supporting directories (`workflows/`, `templates/`) are justified (3+ files each)
- Each workflow phase has a clear handoff
- Complex logic lives in referenced files, not inline

---

## Example 4: Updating an Existing Skill

**User request:** "Update my test-runner skill to support parallel test execution and add a --timeout flag"

**Process:**

1. Read existing `.claude/skills/test-runner/SKILL.md`
2. Identify changes: new `--timeout` variable, new `--parallel` variable, new cookbook route
3. Preserve existing content, add new sections

**Changes applied:**

```markdown
## Variables (updated)

- `--package`: Package path to test (default: `./...`)
- `--coverage`: Generate HTML coverage report (default: off)
- `--parallel`: Run tests in parallel across packages (default: off)    # ADDED
- `--timeout`: Test timeout duration (default: `30s`)                   # ADDED

## Cookbook (new route added)

### Parallel Execution                                                   # ADDED
- **IF:** `--parallel` flag set
- **THEN:** Run `go test ./... -v -count=1 -parallel <cpu_count> -timeout <timeout>`
- **EXAMPLES:** "run tests in parallel", "parallel test execution"
```

**Update rules followed:**
- Read existing file first
- Only modified/added what was requested
- Preserved all existing cookbook routes
- Added new variables to existing Variables section
- Incremented version if present

---

## Structure Templates

### Minimal Skill (No Optional Sections)

```markdown
---
name: skill-name
description: Does X. Use when user asks to "do X", "run X".
user-invocable: true
---

# Skill Title

## Purpose

One-liner description of what this skill does.
```

### Standard Skill (Common Sections)

```markdown
---
name: skill-name
description: Does X with Y options. Use when user asks to "do X", "run X", "configure Y".
argument-hint: <required-input> [--optional-flag]
allowed-tools: Bash, Read
model: sonnet
context: fork
agent: general-purpose
user-invocable: true
version: "1.0.0"
---

# Skill Title

## Purpose

One-liner description.

## Variables

- `--flag`: Description (default: value)

## Instructions

### Rule Group
- Rule 1
- Rule 2

## Workflow

1. Step one
2. Step two
3. Step three

## Cookbook

### Route Name
- **IF:** condition
- **THEN:** action
- **EXAMPLES:** "trigger phrase 1", "trigger phrase 2"
```

### Full Skill (All Optional Fields + Supporting Files)

```markdown
---
name: skill-name
description: Does X, Y, Z with multiple modes. Use when user asks to "do X", "run Y", "configure Z".
argument-hint: <input> [--mode a|b|c] [--output path]
allowed-tools: Read, Write, Bash, Glob, Grep
model: opus
context: fork
agent: Plan
user-invocable: true
disable-model-invocation: false
version: "1.0.0"
---

# Skill Title

## Purpose

One-liner description.

## Variables

- `--mode`: Execution mode (default: `a`)
- `--output`: Output path (default: current directory)

## Instructions

### Category Rules
- Rule 1
- Rule 2

### Another Category
- Rule 3
- Rule 4

## Workflow

### Phase 1: Name
**Read:** `workflows/phase-1.md`
1. High-level step
2. High-level step

### Phase 2: Name
**Read:** `workflows/phase-2.md`
1. High-level step
2. High-level step

## Cookbook

### Route A
- **IF:** condition A
- **THEN:** action A
- **EXAMPLES:** "phrase 1", "phrase 2"

### Route B
- **IF:** condition B
- **THEN:** action B
- **EXAMPLES:** "phrase 3", "phrase 4"

## Supporting Files

### Workflows
- `workflows/phase-1.md` - Phase 1 detailed procedure
- `workflows/phase-2.md` - Phase 2 detailed procedure

### Templates
- `templates/output.template.md` - Output template

### Tools
- `tools/helper.sh` - Helper script
```

---

## Common Patterns

### Referencing Existing Project Features

When the skill needs to interact with existing project structure:

```markdown
## Instructions

### Project Detection
- Check for `package.json` -> Node.js project
- Check for `go.mod` -> Go project
- Check for `pyproject.toml` -> Python project
- If not detected, ask user
```

### Handling Vague Requests

When user's idea is too vague to generate a quality skill:

**Ask for clarification on:**
1. **Purpose**: "What specific problem does this skill solve?"
2. **Triggers**: "What would you say to invoke this skill?"
3. **Inputs**: "What information does the skill need from you?"
4. **Outputs**: "What should the skill produce? Files, terminal output, both?"
5. **Modes**: "Does it need different modes or just one way to run?"

**Do not generate until at least purpose and triggers are clear.**

### Multi-Skill Composition

When a skill should invoke another skill:

```markdown
## Workflow

### Phase 3: Post-Generation
1. Offer to invoke related skill:
   ```
   Skill generated successfully!
   Would you like to also generate a testing skill for this? (y/n)
   ```
2. If yes: invoke `testing-generator` skill
```
