---
description: Convert an existing Makefile to a justfile with equivalent functionality
argument-hint: [makefile-path]
allowed-tools: ["Read", "Write", "Glob", "Grep", "Bash", "AskUserQuestion"]
---

# Convert Makefile to Justfile Command

Convert an existing Makefile to an equivalent justfile, leveraging just's first-class parameters, cleaner syntax, and built-in features.

## Instructions

### Step 1: Locate and Read Makefile

1. **Find Makefile**
   - Look for `Makefile`, `makefile`, or `GNUmakefile` in project root
   - If path argument provided, use that instead
   - If not found, report error and exit

2. **Check for existing justfile**
   - If exists, ask user: "justfile already exists. Overwrite or merge with converted Makefile?"

3. **Read and parse Makefile**
   - Extract all variables, targets, and recipes
   - Identify pattern rules, conditionals, and includes

### Step 2: Analyze Makefile Structure

Categorize Makefile contents:

1. **Variables**
   - Simple assignment (`VAR = value`)
   - Immediate assignment (`VAR := value`)
   - Conditional assignment (`VAR ?= value`)
   - Append (`VAR += value`)
   - Shell execution (`VAR := $(shell cmd)`)
   - Exported variables (`export VAR`)

2. **Targets and recipes**
   - `.PHONY` declarations
   - `.DEFAULT_GOAL`
   - Pattern rules (`%-suffix:`, `prefix-%:`)
   - Dependencies between targets
   - Recipe commands (including `@` prefix for silent execution)

3. **Conditionals**
   - `ifeq`/`ifneq`/`ifdef`/`ifndef` blocks
   - OS detection patterns

4. **Includes**
   - `include` or `-include` statements

5. **Automatic variables**
   - `$@` (target name)
   - `$<` (first prerequisite)
   - `$^` (all prerequisites)
   - `$*` (stem from pattern rule)

### Step 3: Conversion Rules Reference

Use this comprehensive translation table:

| Makefile Pattern | Justfile Equivalent | Notes |
|------------------|---------------------|-------|
| **Variables** | | |
| `VAR = value` | `var := "value"` | Simple assignment |
| `VAR := value` | `var := "value"` | Immediate (same in just) |
| `VAR ?= value` | `var := env("VAR", "value")` | Conditional via env |
| `VAR += value` | `var := var + " value"` | Append |
| `export VAR` | `export VAR := "value"` | Export to recipes |
| `$(shell cmd)` | `` `cmd` `` | Command substitution |
| `$(VAR)` | `{{var}}` | Variable interpolation |
| **Targets & Recipes** | | |
| `.PHONY: target` | Remove | All recipes are phony by default |
| `.DEFAULT_GOAL := target` | `default: target` | Special recipe name |
| `target:` | `target:` | Same |
| `target: dep1 dep2` | `target: dep1 dep2` | Same |
| `@command` | `@command` | Same (silence command echo) |
| Tab indentation | Space indentation | Just uses spaces |
| **Pattern Rules** | | |
| `logs-%:` | `logs service:` | Named parameter |
| `$*` in recipe | `{{service}}` | Parameter interpolation |
| `%-suffix:` | `recipe prefix:` | Named parameter |
| `prefix-%:` | `recipe suffix:` | Named parameter |
| `docker-build-%:` | `docker-build service:` | More readable |
| **Argument Passing** | | |
| `make target VAR=value` | `just target value` | Positional args |
| N/A | `recipe *args:` | Variadic args (new!) |
| N/A | `recipe +args:` | Required variadic |
| N/A | `recipe param="default":` | Default values |
| **Automatic Variables** | | |
| `$@` (target name) | Use explicit recipe name | No equivalent needed |
| `$<` (first prereq) | Use explicit parameter | Pass as parameter |
| `$^` (all prereqs) | Use explicit `+params` | Variadic parameter |
| `$*` (pattern stem) | `{{param}}` | Named parameter |
| **Conditionals** | | |
| `ifeq ($(OS),Windows_NT)` | `if os_family() == "windows" { ... }` | Built-in function |
| `ifeq ($(VAR),value)` | `if var == "value" { ... }` | Expression |
| `ifdef VAR` | `if var != "" { ... }` | Check non-empty |
| `ifndef VAR` | `if var == "" { ... }` | Check empty |
| Multi-line conditional | Use shebang recipe | Better for complex logic |
| **Shell Functions** | | |
| `$(wildcard *.go)` | `` `ls *.go 2>/dev/null \| true` `` | Shell glob |
| `$(patsubst %.c,%.o,$^)` | Use shell recipe | No direct equivalent |
| `$(foreach ...)` | Use shebang recipe | Shell loop better |
| `$(dir ...)` | `dirname` in backticks | Shell command |
| `$(notdir ...)` | `basename` in backticks | Shell command |
| **Multi-line Recipes** | | |
| Line continuation `\` | Shebang recipe | Cleaner for scripts |
| `@for x in $(VAR); do \` | `#!/usr/bin/env bash` | Shebang recipe |
| `    echo $$x; \` | `for x in {{var}}; do` | Single `$` in shebang |
| `done` | `    echo $x` | No escaping needed |
| | `done` | |
| **Escaping** | | |
| `$$var` in recipe | `$var` | Single `$` in shebang |
| `$$var` in inline recipe | `$var` | Single `$` always |
| **Includes** | | |
| `include file.mk` | `import "file.just"` | Module system |
| `-include file.mk` | `import? "file.just"` | Optional import |
| **Help Target** | | |
| Custom `help:` target | Remove | Use `just --list` |
| `@grep` based help | Remove | Built-in listing |
| Comments `## help text` | Comments above recipe | `# help text` |

### Step 4: Perform Conversion

Follow this systematic approach:

#### 4.1 Justfile Preamble
```just
# ============================================================================
# JUSTFILE (converted from Makefile)
# ============================================================================
# Converted by claude-autokit convert-make-to-just command
# ============================================================================

# Settings
set shell := ["bash", "-cu"]
set dotenv-load
```

If Makefile has `.DEFAULT_GOAL`:
```just
default: <<default-target>>
```

#### 4.2 Convert Variables

**Simple variables:**
```makefile
REGISTRY = docker.io/user
VERSION := $(shell date +%Y%m%d)
TAG ?= latest
```

Becomes:
```just
registry := "docker.io/user"
version := `date +%Y%m%d`
tag := env("TAG", "latest")
```

**Exported variables:**
```makefile
export GO111MODULE = on
```

Becomes:
```just
export GO111MODULE := "on"
```

#### 4.3 Convert Targets to Recipes

**Simple targets:**
```makefile
.PHONY: build
build:
	go build -o bin/app ./cmd/main.go
```

Becomes:
```just
# Build the application
build:
    go build -o bin/app ./cmd/main.go
```

**Targets with dependencies:**
```makefile
deploy: build test
	./deploy.sh
```

Becomes:
```just
# Deploy application
deploy: build test
    ./deploy.sh
```

#### 4.4 Convert Pattern Rules to Parameterized Recipes

**Pattern with `%` stem:**
```makefile
logs-%:
	docker compose logs -f $*

shell-%:
	docker compose exec $* sh

docker-build-%:
	docker build -t $(REGISTRY)/$*:$(VERSION) .
```

Becomes:
```just
# View logs for specific service
logs service:
    docker compose logs -f {{service}}

# Shell into specific container
shell service:
    docker compose exec {{service}} sh

# Build specific service image
docker-build service:
    docker build -t {{registry}}/{{service}}:{{version}} .
```

**Pattern with defaults:**
```just
# Build with optional target (default: release)
build target="release":
    cargo build {{if target == "release" { "--release" } else { "" }}}
```

#### 4.5 Convert Multi-line Recipes with Loops

**Makefile with escaped newlines:**
```makefile
docker-build:
	@for service in $(SERVICES); do \
		echo "Building $$service..."; \
		docker build -t $(REGISTRY)/$$service:$(VERSION) .; \
	done
```

Becomes shebang recipe:
```just
# Build all Docker images
docker-build:
    #!/usr/bin/env bash
    set -euo pipefail
    for service in {{services}}; do
        echo "Building $service..."
        docker build -t {{registry}}/$service:{{version}} .
    done
```

#### 4.6 Convert Conditionals

**OS detection:**
```makefile
ifeq ($(OS),Windows_NT)
    SCRIPT_EXT := .bat
else
    SCRIPT_EXT := .sh
endif

deploy:
	$(SHELL_CMD) script$(SCRIPT_EXT)
```

Becomes:
```just
# Deploy using OS-appropriate script
deploy:
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ "{{os_family()}}" == "windows" ]]; then
        cmd /c script.bat
    else
        bash script.sh
    fi
```

Or inline:
```just
script_ext := if os_family() == "windows" { ".bat" } else { ".sh" }

deploy:
    bash script{{script_ext}}
```

#### 4.7 Handle Includes

```makefile
include common.mk
-include local.mk
```

Becomes:
```just
import "common.just"
import? "local.just"
```

Note: Suggest renaming `.mk` files to `.just` files during conversion.

#### 4.8 Remove Help Target

If Makefile has custom help target:
```makefile
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'
```

Remove entirely and note: "Use `just --list` instead of help target"

Convert `## help text` comments to just-style comments:
```makefile
build:  ## Build the application
	go build
```

Becomes:
```just
# Build the application
build:
    go build
```

#### 4.9 Add Variadic Pass-through (Enhancement)

For dev/test commands, add `*args` support (improvement over Makefile):

```makefile
test:
	go test ./...
```

Becomes:
```just
# Run tests with optional arguments
test *args:
    go test {{args}} ./...
```

This allows: `just test -v -run TestFoo` (not possible in Make)

### Step 5: Review and Validate

1. **Check for untranslatable constructs**
   - Complex Make functions (`$(call ...)`, `$(eval ...)`)
   - Recursive Make (`$(MAKE) -C subdir`)
   - Advanced pattern matching

2. **Flag limitations**
   ```
   Note: The following Makefile features have no direct just equivalent:
   - $(call function,args): Convert to shell script or shebang recipe
   - Recursive Make: Use just's import system instead
   - $(eval ...): Use just's conditional expressions or shell scripting
   ```

3. **Verify parameter naming**
   - Ensure pattern rule conversions use descriptive names
   - `logs-%` → `logs service` (not `logs x`)
   - `build-%` → `build target` (not `build item`)

4. **Test variable interpolation**
   - All `$(VAR)` → `{{var}}`
   - All `$$var` in recipes → `$var` in shebang recipes

### Step 6: Finalize

1. Write the justfile to project root (or specified location)
2. Show conversion summary
3. Suggest testing commands

## Output Format

After conversion, display:

```
Makefile successfully converted to justfile!

Conversion summary:
- Variables: X converted (Y with environment defaults)
- Recipes: X converted (Y parameterized, Z with variadic args)
- Pattern rules: X converted to parameterized recipes
- Conditionals: X converted (Y using os_family())
- Includes: X converted to imports

Improvements over Makefile:
- Parameterized recipes (logs service, shell service, etc.)
- Variadic arguments for dev/test commands (just test -v -run TestFoo)
- Built-in --list instead of custom help target
- Cleaner syntax (no tab requirements, no $$ escaping in shebang recipes)

Removed:
- .PHONY declarations (not needed in just)
- Custom help target (use `just --list` instead)

Next steps:
1. Review the generated justfile
2. Test key commands: just --list
3. Rename any included .mk files to .just (if applicable)
4. Consider adding default parameter values where appropriate
```

If any manual intervention needed:
```
⚠ Manual review required:

The following constructs require manual conversion:
- Line X: $(call function,args) - convert to shell function
- Line Y: Recursive $(MAKE) - use just's import system
- Line Z: Complex $(patsubst ...) - implement in shell

See comments in generated justfile for details.
```

## Best Practices for Conversion

1. **Preserve comments**: Keep all meaningful comments from Makefile

2. **Improve names**: Use descriptive parameter names
   - `logs-%` → `logs service:` not `logs s:`
   - `build-%` → `build target:` not `build t:`

3. **Leverage features**: Add enhancements during conversion
   - Add `*args` to test/dev commands
   - Add default values to parameters where sensible
   - Use `os_family()` instead of manual OS detection

4. **Simplify**: Use just's cleaner syntax
   - Replace escaped multi-line with shebang recipes
   - Remove unnecessary `.PHONY` declarations
   - Replace `$$` with `$` in shebang recipes

5. **Group related recipes**: Use comments to organize
   ```just
   # ============================================================================
   # CONTAINER MANAGEMENT
   # ============================================================================
   ```

6. **Keep structure**: Maintain the same logical organization as original Makefile

7. **Add settings preamble**: Always add:
   ```just
   set shell := ["bash", "-cu"]
   set dotenv-load
   ```
