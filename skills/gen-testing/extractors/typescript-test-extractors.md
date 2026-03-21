# TypeScript Test Pattern Extractors

Patterns and commands to extract testing conventions from TypeScript/JavaScript codebases.

## Test File Discovery

```bash
# Find all test files
find . -name "*.test.ts" -o -name "*.spec.ts" -o -name "*.test.tsx" -o -name "*.spec.tsx" | grep -v node_modules

# Find __tests__ directories
find . -name "__tests__" -type d | grep -v node_modules

# Count test files
find . \( -name "*.test.ts" -o -name "*.spec.ts" \) | grep -v node_modules | wc -l
```

## Framework Detection

### Jest
```bash
# Check for jest in dependencies
grep -E '"jest"|"@types/jest"' package.json

# Check for jest config
ls jest.config.js jest.config.ts jest.config.json 2>/dev/null
grep -A5 '"jest"' package.json 2>/dev/null
```

### Vitest
```bash
# Check for vitest in dependencies
grep -E '"vitest"' package.json

# Check for vitest config
ls vitest.config.ts vitest.config.js 2>/dev/null
```

### Mocha
```bash
# Check for mocha
grep -E '"mocha"' package.json

# Check for mocha config
ls .mocharc.js .mocharc.json 2>/dev/null
```

### Testing Library
```bash
# Check for testing-library
grep -E '"@testing-library' package.json
```

## Structure Pattern Detection

### Describe/It Blocks
```bash
# Look for describe blocks
grep -rn "describe(" . --include="*.test.ts" --include="*.spec.ts" | head -5
```

**Example pattern:**
```typescript
describe('UserService', () => {
  describe('create', () => {
    it('should create a user with valid email', () => {
      // Arrange
      const email = 'test@example.com';

      // Act
      const user = userService.create(email);

      // Assert
      expect(user.email).toBe(email);
    });
  });
});
```

### Test Functions
```bash
# Look for test() or it()
grep -rn "^  it(\|^  test(" . --include="*.test.ts" | head -5
```

### Test.each (Parameterized)
```bash
# Look for parameterized tests
grep -r "test\.each\|it\.each\|describe\.each" . --include="*.test.ts" | head -5
```

**Example pattern:**
```typescript
test.each([
  ['valid@example.com', true],
  ['invalid', false],
])('validateEmail(%s) returns %s', (email, expected) => {
  expect(validateEmail(email)).toBe(expected);
});
```

## Mocking Patterns

### Jest Mocks
```bash
# Check for jest.mock
grep -r "jest\.mock\|jest\.spyOn\|jest\.fn()" . --include="*.test.ts" | head -5
```

**Example patterns:**
```typescript
// Module mock
jest.mock('./database');

// Spy
jest.spyOn(userService, 'create');

// Mock function
const mockFn = jest.fn().mockReturnValue('mocked');
```

### Vitest Mocks
```bash
# Check for vi.mock
grep -r "vi\.mock\|vi\.spyOn\|vi\.fn()" . --include="*.test.ts" | head -5
```

### Manual Mocks
```bash
# Check for __mocks__ directory
find . -name "__mocks__" -type d | grep -v node_modules

# Check for manual mock files
ls __mocks__/ src/__mocks__/ 2>/dev/null
```

### Type-Safe Mocks
```bash
# Check for jest.Mocked usage
grep -r "jest\.Mocked\|as jest\.Mock" . --include="*.test.ts" | head -5
```

**Example:**
```typescript
const mockUserService = {
  create: jest.fn(),
  findById: jest.fn(),
} as jest.Mocked<UserService>;
```

## Fixture Patterns

### BeforeEach/AfterEach
```bash
# Find setup/teardown
grep -rn "beforeEach\|afterEach\|beforeAll\|afterAll" . --include="*.test.ts" | head -5
```

**Example pattern:**
```typescript
describe('UserService', () => {
  let userService: UserService;
  let mockDb: MockDatabase;

  beforeEach(() => {
    mockDb = new MockDatabase();
    userService = new UserService(mockDb);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });
});
```

### Factory Functions
```bash
# Check for factory files
find . -name "*factory*" -o -name "*fixture*" | grep -E "\.(ts|js)$" | grep -v node_modules | head -5
```

**Example pattern:**
```typescript
// factories/user.factory.ts
export const createUser = (overrides?: Partial<User>): User => ({
  id: 'user-1',
  email: 'test@example.com',
  ...overrides,
});
```

## Assertion Patterns

### Jest/Vitest Expect
```bash
# Check assertion style
grep -r "expect(" . --include="*.test.ts" | head -5
```

**Common patterns:**
- `expect(result).toBe(expected)`
- `expect(result).toEqual(expected)`
- `expect(result).toMatchObject(expected)`
- `expect(fn).toHaveBeenCalledWith(args)`
- `expect(fn).toThrow(Error)`

### Async Assertions
```bash
# Check for async assertions
grep -r "expect.*resolves\|expect.*rejects\|await expect" . --include="*.test.ts" | head -5
```

**Example:**
```typescript
await expect(asyncFn()).resolves.toBe(expected);
await expect(asyncFn()).rejects.toThrow(Error);
```

## Setup/Teardown Patterns

### Global Setup
```bash
# Check for global setup
ls jest.setup.ts jest.setup.js setupTests.ts 2>/dev/null
grep -r "setupFilesAfterEnv\|globalSetup" jest.config.* 2>/dev/null
```

### Test Utilities
```bash
# Check for test utils
find . -name "*test-utils*" -o -name "*testUtils*" | grep -v node_modules | head -5
```

## Integration Test Patterns

### Supertest (API Testing)
```bash
# Check for supertest
grep -E '"supertest"' package.json
grep -r "import.*supertest\|require.*supertest" . --include="*.test.ts" | head -3
```

**Example:**
```typescript
import request from 'supertest';

describe('POST /users', () => {
  it('creates a user', async () => {
    const response = await request(app)
      .post('/users')
      .send({ email: 'test@example.com' });

    expect(response.status).toBe(201);
  });
});
```

### Testing Library (Component Testing)
```bash
# Check for testing-library usage
grep -r "render\|screen\|fireEvent\|userEvent" . --include="*.test.tsx" | head -5
```

## Coverage Configuration

### Jest Coverage
```bash
grep -A10 "coverageThreshold\|collectCoverageFrom" jest.config.* 2>/dev/null
```

### Common Commands
```bash
# Jest
npm test -- --coverage

# Vitest
npx vitest --coverage
```

## E2E Test Patterns

### Playwright
```bash
grep -E '"@playwright/test"' package.json
ls playwright.config.ts 2>/dev/null
```

### Cypress
```bash
grep -E '"cypress"' package.json
ls cypress.config.ts cypress.config.js 2>/dev/null
```

## Output Template

After extraction, document findings:

```markdown
## TypeScript Test Patterns

### Framework
- Primary: Jest
- Mocking: jest.mock with type-safe mocks
- Component Testing: @testing-library/react

### Structure
- Pattern: Describe/It blocks with AAA
- Parameterized: test.each for data-driven tests

### Example
From `src/__tests__/user.service.test.ts:15`:
```typescript
describe('UserService', () => {
  describe('create', () => {
    it('should create user with valid email', () => {
      const email = 'test@example.com';
      const user = userService.create(email);
      expect(user.email).toBe(email);
    });
  });
});
```
```
