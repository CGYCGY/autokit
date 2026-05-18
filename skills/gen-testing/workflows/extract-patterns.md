# Test Pattern Extraction Workflow

Extracts testing patterns from existing codebase to document conventions.

## Pattern Categories

1. Test File Organization
2. Test Structure
3. Mocking Patterns
4. Fixture Patterns
5. Assertion Patterns

## Step 1: Detect Language and Framework

### Go
```bash
# Check for go.mod
ls go.mod 2>/dev/null

# Check for test files
find . -name "*_test.go" -type f | head -5
```

**Common frameworks:** `testing`, `testify`, `gomock`, `mockery`

### Python
```bash
# Check for pytest
grep -l "pytest" pyproject.toml requirements.txt 2>/dev/null

# Check for test files
find . -name "test_*.py" -o -name "*_test.py" | head -5
```

**Common frameworks:** `pytest`, `unittest`, `mock`, `factory_boy`

### TypeScript/JavaScript
```bash
# Check for test frameworks in package.json
cat package.json | grep -E "jest|vitest|mocha|jasmine"

# Check for test files
find . -name "*.test.ts" -o -name "*.spec.ts" | head -5
```

**Common frameworks:** `jest`, `vitest`, `mocha`, `testing-library`

### React Native / Expo (extra extractor)

If `mobile: bare | managed | prebuild` was set during environment detection, **also** load `extractors/rn-test-extractors.md` after the TypeScript extractor.

| `mobile` field | Load `rn-test-extractors.md`? |
|----------------|-------------------------------|
| `none` / unset | No — TS extractor only |
| `bare` / `managed` / `prebuild` | Yes, in addition to TS extractor |

The RN extractor covers the e2e layer (Detox, Maestro). Unit and component tests still come from the TypeScript extractor.

## Step 2: Extract Test File Organization

### Directory Structure
```bash
# Find test directories
find . -type d -name "test*" -o -name "__tests__" -o -name "tests" 2>/dev/null
```

**Record:**
- Test location: alongside source (`user_test.go`) or separate (`tests/`)
- Naming convention: `*_test.*`, `test_*.*`, `*.spec.*`, `*.test.*`

### Example Patterns

| Pattern | Example |
|---------|---------|
| Colocated | `src/user.ts` + `src/user.test.ts` |
| Separate | `src/user.ts` + `tests/user.test.ts` |
| `__tests__` folder | `src/user.ts` + `src/__tests__/user.test.ts` |

## Step 3: Extract Test Structure

Read 3-5 test files to identify structure pattern.

### AAA Pattern (Arrange-Act-Assert)
```go
func TestCreateUser(t *testing.T) {
    // Arrange
    user := NewUser("test@example.com")

    // Act
    err := user.Validate()

    // Assert
    assert.NoError(t, err)
}
```

### Table-Driven Tests (Go)
```go
func TestValidate(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        wantErr bool
    }{
        {"valid email", "test@example.com", false},
        {"invalid email", "invalid", true},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            // ...
        })
    }
}
```

### BDD Style (Given-When-Then)
```python
def test_user_creation():
    # Given
    email = "test@example.com"

    # When
    user = create_user(email)

    # Then
    assert user.email == email
```

### Describe/It Blocks (Jest/Vitest)
```typescript
describe('UserService', () => {
  describe('create', () => {
    it('should create a user with valid email', () => {
      // ...
    });
  });
});
```

## Step 4: Extract Mocking Patterns

### Go Mocking

**Interface-based:**
```go
type UserRepository interface {
    FindByID(id string) (*User, error)
}

type mockUserRepo struct {
    mock.Mock
}
```

**Generated mocks:** Look for `//go:generate mockgen` or `mockery`

### Python Mocking

**unittest.mock:**
```python
from unittest.mock import Mock, patch

@patch('module.external_service')
def test_with_mock(mock_service):
    mock_service.return_value = "mocked"
```

**pytest fixtures:**
```python
@pytest.fixture
def mock_db():
    return Mock(spec=Database)
```

### TypeScript Mocking

**Jest mocks:**
```typescript
jest.mock('./database');
const mockDb = Database as jest.Mocked<typeof Database>;
```

**Manual mocks:**
```typescript
const mockUserService: jest.Mocked<UserService> = {
  findById: jest.fn(),
};
```

## Step 5: Extract Fixture Patterns

### Go Test Fixtures
```bash
# Look for testdata directories
find . -name "testdata" -type d

# Look for fixture files
find . -name "*fixture*" -o -name "*testdata*" | head -5
```

### Python Fixtures
```bash
# Look for conftest.py
find . -name "conftest.py"

# Look for fixture definitions
grep -r "@pytest.fixture" . --include="*.py" | head -5
```

### TypeScript Fixtures
```bash
# Look for fixture/factory files
find . -name "*fixture*" -o -name "*factory*" | grep -E "\.(ts|js)$" | head -5

# Look for beforeEach/beforeAll
grep -r "beforeEach\|beforeAll" . --include="*.ts" | head -5
```

## Step 6: Extract Assertion Patterns

| Language | Library | Example |
|----------|---------|---------|
| Go | testify | `assert.Equal(t, expected, actual)` |
| Go | stdlib | `if got != want { t.Errorf(...) }` |
| Python | pytest | `assert result == expected` |
| Python | unittest | `self.assertEqual(result, expected)` |
| TypeScript | Jest | `expect(result).toBe(expected)` |
| TypeScript | Vitest | `expect(result).toEqual(expected)` |

## Output Format

```json
{
  "language": "go",
  "framework": "testify",
  "organization": {
    "location": "colocated",
    "naming": "*_test.go"
  },
  "structure": "table-driven",
  "mocking": {
    "approach": "interface-based",
    "library": "testify/mock"
  },
  "fixtures": {
    "location": "testdata/",
    "pattern": "json-files"
  },
  "assertions": {
    "library": "testify/assert",
    "style": "assert.Equal(t, expected, actual)"
  }
}
```

## Next Step

Proceed to `generate-skill.md` to create the testing skill.
