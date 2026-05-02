---
description: Generate a customized scout command for feature exploration
allowed-tools: Read(*), Glob(*), Grep(*), Bash(ls:*), Write(*)
---

# Generate Scout Command

You are generating a customized `/scout` command for this project. The scout command helps explore and gather information before implementing new features.

## Step 1: Analyze Project Structure

First, detect the project structure:

```bash
ls -la
```

Look for:
- `go.mod` → Go project
- `package.json` → Node.js/TypeScript project
- `requirements.txt` / `pyproject.toml` / `setup.py` → Python project
- `Cargo.toml` → Rust project
- `pom.xml` / `build.gradle` → Java project

## Step 2: Detect Architecture Pattern

Search for common directory patterns:

### DDD/Clean Architecture
- `internal/domain/`, `internal/application/`, `internal/infrastructure/`
- `src/domain/`, `src/application/`, `src/infrastructure/`
- `app/domain/`, `app/services/`

### MVC Pattern
- `controllers/`, `models/`, `views/`
- `src/controllers/`, `src/models/`

### Modular/Feature-based
- `modules/`, `features/`
- `src/modules/`, `src/features/`

### Monorepo
- `packages/`, `apps/`, `libs/`

Use Glob to find these patterns:
```
**/domain/**
**/controllers/**
**/services/**
**/models/**
```

## Step 3: Find Documentation Paths

Search for documentation directories:
- `docs/`, `documentation/`, `doc/`
- `.claude/skills/*-guidelines/`
- `README.md`, `ARCHITECTURE.md`, `CONTRIBUTING.md`

Identify:
- **Domain docs**: Technical implementation details
- **Feature docs**: Business requirements
- **Guidelines**: Coding conventions (including `.claude/skills/*-guidelines/`)
- **Examples**: Code samples

## Step 4: Generate Scout Command

Based on your analysis, create a customized `scout.md` file at `.claude/commands/scout.md`.

Use this template and fill in the detected values:

```markdown
---
description: Scout and gather info for new feature planning
argument-hint: [--no-planning|-np] <task-description>
allowed-tools: Read(*), Write(*), Bash(mkdir:*), Bash(ls:*), Glob(*), Grep(*), Task(*)
---

# Feature Scouting Mission

You are conducting a comprehensive scouting mission to gather all necessary information for planning the following task:

**Task:** $ARGUMENTS

## Flag Handling

First, check if $ARGUMENTS starts with `--no-planning` or `-np`:
- If flag is present: Set NO_PLANNING=true and skip generating `05_recommendations.md`
- Parse the remaining arguments as the task description
- If flag is not present: Set NO_PLANNING=false and process all $ARGUMENTS as the task description

## Mission Objectives

Execute the following steps systematically:

### 1. Understand the Task
- Analyze the task description
- Identify key domains/modules involved
- Determine if it's a new feature, enhancement, or refactor
- List preliminary questions and assumptions

### 2. Documentation Discovery

- Read documentation structure file (if exists): `{DETECTED_DOCS_INDEX}`

- Identify relevant documentation categories:
  - **Domain Docs** (`{DETECTED_DOMAIN_DOCS}`) - Technical implementation details
  - **Feature Docs** (`{DETECTED_FEATURE_DOCS}`) - Business requirements and user flows
  - **Guidelines** (`{DETECTED_GUIDELINES}`, `.claude/skills/*-guidelines/`) - Coding patterns and conventions
  - **Examples** (`{DETECTED_EXAMPLES}`) - Code reference snippets
  - **Implementation Plans** (`{DETECTED_PLANS}`) - Related ongoing work

- Read all relevant documentation files

### 3. Codebase Analysis

Search for related code in the following areas:

{ARCHITECTURE_SPECIFIC_PATHS}

**Common areas (all architectures):**
- Analyze existing patterns and conventions
- Identify reusable components and potential integration points
- Note any technical constraints or dependencies
- Check test files for examples of usage

### 4. Generate Feature Name
- Create a kebab-case feature name from the task (e.g., "customer-loyalty-points")
- Ensure it's descriptive and follows project naming conventions

### 5. Create Scout Report Structure

Create the following directory and files:

\`\`\`
{SCOUT_OUTPUT_PATH}/<feature-name>/
└── scout/
    ├── 00_task_overview.md          # Task understanding and scope
    ├── 01_documentation_findings.md  # Summary of relevant docs
    ├── 02_codebase_analysis.md       # Code patterns and integration points
    ├── 03_domain_mapping.md          # Domain boundaries and entities
    ├── 04_technical_requirements.md  # Technical constraints and dependencies
    └── 05_recommendations.md         # Suggested approach (SKIP if --no-planning/-np)
\`\`\`

### 6. Populate Scout Files

[Include detailed instructions for each file based on project architecture]

**Note**: If `--no-planning` or `-np` flag was passed (NO_PLANNING=true), skip generating `05_recommendations.md`. Planning recommendations are handled by the Plan agent in the agentic workflow.

## Execution Notes

- Cover every relevant file under the architecture paths; do not skip a file because it looks unrelated until you confirm it is
- Include file paths and line numbers for every code reference
- Use markdown formatting for readability
- When referencing documentation, link it to the specific code path it describes
- Highlight gaps or missing information explicitly under a "Gaps" subsection at the end of the file
- Follow architecture patterns observed in the codebase

Begin your scouting mission now.
```

## Step 5: Output

1. Create the directory `.claude/commands/` if it doesn't exist
2. Write the customized `scout.md` file
3. Report what was detected and generated

**Example output:**
```
Generated scout command at .claude/commands/scout.md

Detected:
- Project type: Go (DDD/CQRS architecture)
- Domain path: internal/domain/
- Application path: internal/application/
- Documentation: docs/
- Scout output: docs/new_features/
```
