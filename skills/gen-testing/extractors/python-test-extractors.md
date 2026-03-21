# Python Test Pattern Extractors

Patterns and commands to extract testing conventions from Python codebases.

## Test File Discovery

```bash
# Find all test files
find . -name "test_*.py" -o -name "*_test.py" | grep -v __pycache__ | grep -v venv

# Count test files
find . -name "test_*.py" -o -name "*_test.py" | grep -v __pycache__ | wc -l
```

## Framework Detection

### Pytest
```bash
# Check for pytest in dependencies
grep -i "pytest" pyproject.toml requirements.txt setup.py 2>/dev/null

# Check for pytest.ini or pyproject.toml config
ls pytest.ini 2>/dev/null
grep -A10 "\[tool.pytest" pyproject.toml 2>/dev/null
```

### Unittest
```bash
# Check for unittest usage
grep -r "import unittest\|from unittest" . --include="*.py" | head -3
```

## Structure Pattern Detection

### Function-Based (Pytest Style)
```bash
# Look for test functions
grep -rn "^def test_" . --include="test_*.py" | head -5
```

**Example pattern:**
```python
def test_create_user():
    # Arrange
    email = "test@example.com"

    # Act
    user = create_user(email)

    # Assert
    assert user.email == email
```

### Class-Based (Unittest Style)
```bash
# Look for test classes
grep -rn "class Test.*:" . --include="*.py" | head -5
```

### Parametrized Tests
```bash
# Look for pytest.mark.parametrize
grep -r "@pytest.mark.parametrize" . --include="*.py" | head -5
```

**Example pattern:**
```python
@pytest.mark.parametrize("email,expected", [
    ("valid@example.com", True),
    ("invalid", False),
])
def test_validate_email(email, expected):
    assert validate_email(email) == expected
```

## Fixture Patterns

### Conftest.py
```bash
# Find conftest files
find . -name "conftest.py"

# List fixtures in conftest
grep -n "@pytest.fixture" */conftest.py 2>/dev/null
```

### Fixture Definitions
```bash
# Find all fixtures
grep -rn "@pytest.fixture" . --include="*.py" | head -10
```

**Example patterns:**
```python
# Function-scoped (default)
@pytest.fixture
def user():
    return User(email="test@example.com")

# Module-scoped
@pytest.fixture(scope="module")
def db_connection():
    conn = create_connection()
    yield conn
    conn.close()

# Session-scoped
@pytest.fixture(scope="session")
def app():
    return create_app(testing=True)
```

### Factory Fixtures
```bash
# Check for factory pattern
grep -r "factory_boy\|Factory\|@pytest.fixture.*factory" . --include="*.py" | head -5
```

## Mocking Patterns

### unittest.mock
```bash
# Check for mock usage
grep -r "from unittest.mock import\|from unittest import mock\|@patch\|@mock" . --include="*.py" | head -5
```

**Example patterns:**
```python
# Decorator style
@patch('module.external_service')
def test_with_mock(mock_service):
    mock_service.return_value = "mocked"

# Context manager style
def test_with_context_mock():
    with patch('module.external_service') as mock:
        mock.return_value = "mocked"
```

### pytest-mock
```bash
# Check for mocker fixture
grep -r "mocker\." . --include="*.py" | head -5
```

**Example pattern:**
```python
def test_with_mocker(mocker):
    mock = mocker.patch('module.external_service')
    mock.return_value = "mocked"
```

## Assertion Patterns

### Pytest Assertions
```bash
# Check assertion style
grep -r "^    assert " . --include="test_*.py" | head -5
```

**Common patterns:**
- `assert result == expected`
- `assert result is not None`
- `assert "error" in str(exc.value)`

### Pytest Raises
```bash
# Check for exception testing
grep -r "pytest.raises" . --include="*.py" | head -3
```

**Example:**
```python
def test_invalid_raises():
    with pytest.raises(ValueError):
        validate("")
```

## Setup/Teardown Patterns

### Module Level
```bash
# Check for setup_module/teardown_module
grep -rn "def setup_module\|def teardown_module" . --include="*.py" | head -3
```

### Class Level
```bash
# Check for setup_class/teardown_class
grep -rn "def setup_class\|def teardown_class\|@classmethod" . --include="test_*.py" | head -3
```

### Function Level
```bash
# Check for setup_function/teardown_function
grep -rn "def setup_function\|def teardown_function\|def setup\|def teardown" . --include="*.py" | head -3
```

## Integration Test Patterns

### Markers
```bash
# Check for custom markers
grep -r "@pytest.mark\." . --include="*.py" | head -5
```

**Common markers:**
- `@pytest.mark.integration`
- `@pytest.mark.slow`
- `@pytest.mark.skip`

### Database Tests
```bash
# Check for database test patterns
grep -r "test_db\|TestDatabase\|@pytest.fixture.*db" . --include="*.py" | head -5
```

## Coverage Configuration

### pyproject.toml
```bash
grep -A10 "\[tool.coverage" pyproject.toml 2>/dev/null
```

### Common Commands
```bash
# With pytest-cov
pytest --cov=app --cov-report=html

# With coverage.py
coverage run -m pytest
coverage html
```

## Async Test Patterns

### pytest-asyncio
```bash
# Check for async tests
grep -r "@pytest.mark.asyncio\|async def test_" . --include="*.py" | head -5
```

**Example:**
```python
@pytest.mark.asyncio
async def test_async_operation():
    result = await fetch_data()
    assert result is not None
```

## Output Template

After extraction, document findings:

```markdown
## Python Test Patterns

### Framework
- Primary: pytest
- Mocking: unittest.mock with @patch
- Fixtures: conftest.py with function-scoped fixtures

### Structure
- Pattern: Function-based tests with AAA
- Parametrized: Yes, using @pytest.mark.parametrize

### Example
From `tests/test_user.py:15`:
```python
@pytest.mark.parametrize("email,valid", [
    ("test@example.com", True),
    ("invalid", False),
])
def test_validate_email(email, valid):
    result = validate_email(email)
    assert result == valid
```
```
