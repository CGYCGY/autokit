# Environment Detection Workflow

Detects the development environment to generate correct test execution commands.

## Detection Order

1. Containerization
2. Mobile platform (RN / Expo)
3. Database
4. Test Commands
5. Ask User (if unclear)

## Step 1: Detect Containerization

### Docker Compose (Preferred)
```bash
# Check for docker-compose files
ls docker-compose.yml docker-compose.yaml 2>/dev/null
```

**If found**, extract services:
```bash
# List services
docker-compose config --services
```

**Record:**
- App service name (e.g., `app`, `api`, `backend`, `web`)
- Database service name (e.g., `db`, `postgres`, `mysql`)

### Dockerfile Only
```bash
ls Dockerfile 2>/dev/null
```

**If found without compose**, ask user how they run the container.

### Devcontainer
```bash
ls .devcontainer/devcontainer.json 2>/dev/null
```

**If found**, tests run inside devcontainer - use local commands.

### No Containerization
If none found, environment is local.

## Step 2: Detect Mobile Platform (RN / Expo)

Mobile projects need a different e2e extractor path. Check before continuing.

### React Native CLI (bare)
```bash
grep -E '"react-native":' package.json
ls ios/ android/ 2>/dev/null
ls react-native.config.js 2>/dev/null
```

### Expo
```bash
grep -E '"expo":' package.json
ls app.json app.config.js app.config.ts 2>/dev/null
ls eas.json 2>/dev/null
```

### Decision

| Detected | Action |
|----------|--------|
| `react-native` dep + `ios/` + `android/` | Mark `mobile: bare`, load `extractors/rn-test-extractors.md` in pattern phase |
| `expo` dep + `app.json`, no native dirs | Mark `mobile: managed`, load `extractors/rn-test-extractors.md` |
| `expo` dep + native dirs (prebuild) | Mark `mobile: prebuild`, load `extractors/rn-test-extractors.md` |
| None of the above | Mark `mobile: none`, skip RN extractor |

**Containerization note:** Docker-compose is irrelevant for the mobile e2e layer — Detox/Maestro require a real simulator or device. If `mobile: *` is set, do not wrap mobile e2e commands in `docker-compose exec`. (Unit/component tests via Jest can still run in a container if one exists.)

## Step 3: Detect Database

### From Docker Compose
Search docker-compose for database images:

| Image Pattern | Database Type |
|--------------|---------------|
| `postgres:*` | PostgreSQL |
| `mysql:*` | MySQL |
| `mariadb:*` | MariaDB |
| `mongo:*` | MongoDB |
| `redis:*` | Redis |

### From Config Files

**Go:**
```bash
grep -r "postgres\|mysql\|mongodb" internal/ pkg/ --include="*.go" | head -5
```

**Python:**
```bash
grep -r "postgresql\|mysql\|mongodb" . --include="*.py" --include="*.ini" --include="*.cfg" | head -5
```

**TypeScript:**
```bash
grep -r "postgres\|mysql\|mongodb" . --include="*.ts" --include="*.json" | head -5
```

### From ORM Config

| ORM | Config Location |
|-----|-----------------|
| GORM | Look for `gorm.Open` with driver |
| SQLAlchemy | `DATABASE_URL` or `SQLALCHEMY_DATABASE_URI` |
| Prisma | `prisma/schema.prisma` datasource |
| TypeORM | `ormconfig.json` or `data-source.ts` |

## Step 4: Detect Test Commands

### Makefile
```bash
grep -E "^test:|^test-unit:|^test-integration:" Makefile 2>/dev/null
```

### package.json (Node/TypeScript)
```bash
cat package.json | grep -A5 '"scripts"' | grep -E '"test|"test:'
```

### pyproject.toml (Python)
```bash
grep -A5 '\[tool.pytest' pyproject.toml 2>/dev/null
grep -A5 '\[scripts\]' pyproject.toml 2>/dev/null
```

### CI Files
```bash
# GitHub Actions
cat .github/workflows/*.yml | grep -E "npm test|pytest|go test" 2>/dev/null

# GitLab CI
cat .gitlab-ci.yml | grep -E "npm test|pytest|go test" 2>/dev/null
```

## Step 5: Ask User If Unclear

If any detection fails, present what was found and ask:

```
Development Environment Detection:

Detected:
✓ docker-compose.yml found
✓ Services: app, db
✓ Database: PostgreSQL (from db service image)
✗ Test command: Not found in Makefile or package.json

Questions:
1. How do you run tests?
   a) docker-compose exec app <command>
   b) Local command
   c) Other (please specify)

2. What is the test command?
   a) go test ./...
   b) pytest
   c) npm test
   d) Other (please specify)
```

## Output Format

After detection, record:

```json
{
  "containerization": {
    "type": "docker-compose",
    "appService": "app",
    "dbService": "db"
  },
  "mobile": {
    "platform": "none",
    "e2eFrameworks": []
  },
  "database": {
    "type": "postgresql",
    "host": "db",
    "testStrategy": "separate-schema"
  },
  "testCommand": {
    "raw": "go test ./...",
    "containerized": "docker-compose exec app go test ./..."
  }
}
```

For an RN/Expo project the mobile block would look like:
```json
"mobile": {
  "platform": "managed",
  "e2eFrameworks": ["maestro"]
}
```

`platform` values: `bare | managed | prebuild | none` (must match the decision table in Step 2).

## Next Step

Proceed to `extract-patterns.md` for test pattern extraction.
