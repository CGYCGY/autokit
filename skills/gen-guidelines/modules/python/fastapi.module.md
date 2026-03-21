---
module: fastapi
language: python
category: framework
requires: []
conflicts: [django, flask]
---

# FastAPI Module for Python

Extracts FastAPI-specific patterns: routing, dependencies, Pydantic models, etc.

## Detection Criteria

```bash
grep -r "from fastapi import\|import fastapi" --include="*.py"
```

## Patterns to Extract

### 1. Router Definition
```python
# Pattern A: APIRouter
from fastapi import APIRouter
router = APIRouter(prefix="/api/v1")

# Pattern B: FastAPI app directly
from fastapi import FastAPI
app = FastAPI()
```

### 2. Dependency Injection
```python
# Using Depends()
from fastapi import Depends

def get_db():
    # ...

@router.get("/items")
def get_items(db: Session = Depends(get_db)):
    # ...
```

### 3. Request/Response Models
```python
# Pydantic schemas
from pydantic import BaseModel

class ItemCreate(BaseModel):
    name: str
    price: float

class ItemResponse(BaseModel):
    id: int
    name: str
    price: float

    class Config:
        from_attributes = True
```

## Reference Documentation

### reference/fastapi-patterns.md

Document routing, dependency injection, middleware, exception handling patterns found in codebase.

## Checklist Items

- [ ] Routes use APIRouter with consistent prefixes
- [ ] Dependencies injected via Depends()
- [ ] Request/response models use Pydantic
- [ ] Validation errors handled consistently
