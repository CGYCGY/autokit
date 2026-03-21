---
module: pydantic
language: python
category: library
requires: []
conflicts: []
---

# Pydantic Module for Python

Extracts Pydantic-specific patterns: schema design, validation, field constraints, etc.

## Detection Criteria

```bash
grep -r "from pydantic import\|import pydantic" --include="*.py"
```

## Patterns to Extract

### 1. Three-Tier Schema Pattern
```python
# 1. Base: Shared attributes
class ResourceBase(BaseModel):
    name: str = Field(..., min_length=1)

# 2. Create: Input for POST
class ResourceCreate(ResourceBase):
    extra_field: Optional[str] = None

# 3. Response: Output with metadata
class ResourceResponse(ResourceBase):
    id: UUID
    created_at: datetime

    class Config:
        from_attributes = True

# 4. Update: Partial updates (optional fields)
class ResourceUpdate(BaseModel):
    name: Optional[str] = None
```

### 2. Field Validation
```python
from pydantic import Field, field_validator

# Numeric constraints
amount: Decimal = Field(..., gt=0)
page: int = Field(default=1, ge=1, le=100)

# String constraints
name: str = Field(..., min_length=2, max_length=100)
color: str = Field(default="#6B7280", pattern=r"^#[0-9A-Fa-f]{6}$")

# Field validators
@field_validator('currency')
@classmethod
def validate_currency(cls, v):
    if not v.isupper():
        raise ValueError('Currency must be uppercase')
    return v
```

### 3. Model Validators (Cross-field)
```python
from pydantic import model_validator

@model_validator(mode='after')
def validate_date_range(self):
    if self.end_date and self.start_date:
        if self.end_date < self.start_date:
            raise ValueError('end_date must be after start_date')
    return self
```

### 4. Config Class Usage
```python
# Response models only
class ResourceResponse(ResourceBase):
    id: UUID

    class Config:
        from_attributes = True  # Enable ORM serialization
```

### 5. Decimal Handling (Money)
```python
from decimal import Decimal

# Always use Decimal for money, never float
amount: Decimal = Field(..., gt=0)
ai_confidence: Optional[Decimal] = None
```

### 6. Optional Field Patterns
```python
# Simple optional
merchant: Optional[str] = None

# Optional with constraint
merchant: Optional[str] = Field(None, max_length=255)

# Optional with default factory
preferences: Optional[Dict[str, Any]] = Field(default_factory=dict)
```

### 7. String Enum Pattern
```python
from enum import Enum

class StatusType(str, Enum):
    PENDING = "pending"
    COMPLETED = "completed"
    CANCELLED = "cancelled"
```

### 8. Nested/Recursive Models
```python
class CategoryWithChildren(CategoryResponse):
    children: List['CategoryWithChildren'] = []

# Required for forward references
CategoryWithChildren.model_rebuild()
```

## Reference Documentation

### reference/pydantic-patterns.md

Document schema patterns, validation strategies, field constraints, and naming conventions found in codebase.

## Checklist Items

- [ ] Schemas follow three-tier pattern (Base, Create, Response)
- [ ] Update schemas use Optional fields
- [ ] Response schemas have `from_attributes = True` config
- [ ] Decimal used for money/currency (not float)
- [ ] Field constraints use Field() with gt/ge/lt/le/min_length/max_length
- [ ] Cross-field validation uses model_validator
- [ ] Naming follows {Resource}Base/Create/Update/Response convention
- [ ] Enums inherit from (str, Enum) for JSON serialization
