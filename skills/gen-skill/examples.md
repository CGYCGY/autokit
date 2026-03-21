# Skill Generation Examples

## Example 1: Simple Skill (No Variables, No Flags)

**User request:** "Create a skill that formats JSON files"

**Generated output:**

```markdown
---
name: json-formatter
description: Formats JSON files with consistent indentation and sorting. Use when user asks to "format json", "prettify json", "fix json formatting", or "indent json".
allowed-tools: Read, Write, Bash, Glob
user-invocable: true
---

# JSON Formatter

## Purpose

Format JSON files with consistent 2-space indentation and sorted keys.

## Instructions

- Detect JSON files by extension (`.json`, `.jsonc`)
- Preserve comments in `.jsonc` files
- Sort keys alphabetically at all nesting levels
- Use 2-space indentation
- Ensure trailing newline

## Workflow

1. Find JSON files in working directory (or specified path)
2. Read each file
3. Parse, sort keys, re-indent with 2 spaces
4. Write formatted output back to the file
5. Report which files were formatted

## Report

- List files formatted with before/after line counts
- Flag any files that failed to parse
```

**Why this works:**
- No Variables section — skill doesn't need configurable options or user arguments
- No Cookbook — single execution path
- Simple, focused, one capability

---

## Example 2: Skill with Internal Variables (No Flags)

**User request:** "Create a skill that sets up Cloudflare DNS records for a project"

**Generated output:**

```markdown
---
name: dns-setup
description: Creates Cloudflare DNS records for project domains. Use when user asks to "setup dns", "add dns record", "configure cloudflare", or "point domain".
allowed-tools: Bash, Read, Write
user-invocable: true
---

# DNS Setup

## Purpose

Create and manage Cloudflare DNS records for project domains.

## Variables

SKILL_TOOLS: <absolute-path-to-this-skill>/tools
CONFIG_FILE: deploy/.env.deploy

## Instructions

- Always read CONFIG_FILE first to check for existing CLOUDFLARE_ZONE_ID and DOMAIN
- If zone ID is missing, ask user for the Cloudflare zone
- Validate domain format before creating records
- Default record type is CNAME unless user specifies otherwise

## Workflow

1. Read CONFIG_FILE for existing configuration
2. Ask user for subdomain and target if not provided
3. Run `bash ${SKILL_TOOLS}/create-record.sh <type> <subdomain> <target>`
4. Verify record was created
5. Update CONFIG_FILE with new DOMAIN value

## Report

- Show created DNS record details (type, name, target)
- Confirm domain is resolvable
```

**Why this works:**
- Variables section has internal paths the skill references — not user flags
- No `$ARGUMENTS` or flags — skill gathers input conversationally
- Follows the same pattern as `coolify-setup`

---

## Example 3: Complex Skill with Flags and Supporting Files

**User request:** "Create a skill that generates API documentation from code comments, supporting OpenAPI, GraphQL, and gRPC with multiple output formats"

**Generated output (SKILL.md):**

```markdown
---
name: api-docs
description: Generates API documentation from code annotations. Supports OpenAPI/REST, GraphQL, and gRPC. Outputs Markdown, HTML, or JSON. Use when user asks to "generate api docs", "document api", "create api reference", "export openapi spec".
argument-hint: [--type openapi|graphql|grpc] [--format md|html|json]
allowed-tools: Read, Write, Bash, Glob, Grep
context: fork
user-invocable: true
---

# API Documentation Generator

## Purpose

Extract API definitions from source code and generate formatted documentation.

## Variables

USER_INPUT: $ARGUMENTS

### Flags
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

- `workflows/detect-api.md` - API type detection logic
- `workflows/extract-definitions.md` - Definition extraction procedures
- `workflows/generate-docs.md` - Documentation generation with format templates
- `templates/markdown.template.md` - Markdown output template
- `templates/html.template.md` - HTML output template
- `templates/endpoint.template.md` - Per-endpoint template

## Report

- Show generated file structure (tree format)
- Confirm output location
- Summarize endpoints/types documented
```

**Why this works:**
- Flags are justified — multiple output modes the user controls via slash command
- SKILL.md stays concise by referencing workflows for detailed procedures
- Supporting directories (`workflows/`, `templates/`) are justified (3+ files each)
- Complex logic lives in referenced files, not inline

---

## Example 4: Updating an Existing Skill

**User request:** "Update my json-formatter skill to support YAML files too"

**Process:**

1. Read existing `.claude/skills/json-formatter/SKILL.md`
2. Identify changes: description update, instructions update, workflow update
3. Preserve existing content, modify relevant sections

**Changes applied:**

```markdown
## description (updated)
Formats JSON and YAML files with consistent indentation and sorting. Use when user asks to
"format json", "prettify json", "format yaml", "fix formatting", or "indent json".

## Instructions (updated)
- Detect files by extension (`.json`, `.jsonc`, `.yaml`, `.yml`)       # CHANGED
- Preserve comments in `.jsonc` and YAML files                         # CHANGED
- Sort keys alphabetically at all nesting levels
- Use 2-space indentation
- Ensure trailing newline
```

**Update rules followed:**
- Read existing file first
- Only modified/added what was requested
- Preserved all existing structure
- Updated description to include new trigger terms

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
