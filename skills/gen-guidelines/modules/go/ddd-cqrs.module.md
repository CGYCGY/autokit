---
module: ddd-cqrs
language: go
category: architecture
requires: []
conflicts: [clean-architecture, standard-mvc]
---

# DDD/CQRS Module for Go

This module extracts and enforces Domain-Driven Design (DDD) and Command Query Responsibility Segregation (CQRS) patterns in Go projects.

## Detection Criteria

**Folder structure indicators:**
- `internal/domain/` or `pkg/domain/`
- `internal/application/` or `pkg/application/`
- Module-based organization (e.g., `internal/cart/`, `internal/order/`)

**Code indicators:**
```bash
# Search for DDD keywords
grep -r "aggregate\|Aggregate\|DomainEvent\|ValueObject" --include="*.go"

# Search for CQRS keywords
grep -r "Command\|Query\|Handler" --include="*.go"
```

**If found:** DDD/CQRS architecture detected

## Patterns to Extract

### 1. Domain Entity Structure

**Search for:**
```bash
# Find entity/aggregate definitions
find . -path "*/domain/*" -name "*.go" -exec grep -l "^type.*struct" {} \;
```

**Extract:**
- Constructor patterns (Factory methods)
- Entity naming conventions
- Field organization
- Method signatures (business logic)
- Validation approach

**Inconsistency Check:**
- Multiple constructor patterns → Ask user which is standard
- Mixed pointer/value receivers → Ask user preference
- Different validation approaches → Standardize

**Example patterns to detect:**

```go
// Pattern A: Factory with validation
func NewCart(userID uuid.UUID) (*Cart, error) {
    if userID == uuid.Nil {
        return nil, ErrInvalidUserID
    }
    return &Cart{ID: uuid.New(), UserID: userID}, nil
}

// Pattern B: Simple initialization
cart := &Cart{UserID: userID}

// Pattern C: Builder pattern
cart := NewCartBuilder().WithUserID(userID).Build()
```

### 2. Aggregate Root Identification

**Search for:**
```bash
# Find aggregates (typically in domain/*/aggregate.go)
find . -path "*/domain/*" -name "*aggregate*.go"
```

**Extract:**
- Aggregate naming conventions
- Root entity patterns
- Child entity relationships
- Invariant enforcement

**Example:**
```go
// Aggregate root
type Cart struct {
    ID     uuid.UUID
    Items  []CartItem  // Child entities
    Total  Money       // Value object
}

// Invariant enforcement
func (c *Cart) AddItem(item CartItem) error {
    if c.IsCheckedOut() {
        return ErrCartCheckedOut
    }
    c.Items = append(c.Items, item)
    c.recalculateTotal()
    return nil
}
```

### 3. Value Objects

**Search for:**
```bash
# Find value objects
grep -rn "type.*struct" --include="*.go" | grep -i "value\|vo\|object"
```

**Extract:**
- Value object patterns
- Immutability enforcement
- Equality methods
- Validation in construction

**Example:**
```go
type Money struct {
    Amount   decimal.Decimal
    Currency string
}

func NewMoney(amount decimal.Decimal, currency string) (Money, error) {
    if amount.IsNegative() {
        return Money{}, ErrNegativeAmount
    }
    return Money{Amount: amount, Currency: currency}, nil
}
```

### 4. Domain Events

**Search for:**
```bash
grep -rn "Event\|event" --include="*.go" | grep "type.*struct"
```

**Extract:**
- Event naming conventions (past tense?)
- Event structure
- Event publication patterns
- Event handlers

**Example:**
```go
type CartCheckedOutEvent struct {
    CartID    uuid.UUID
    UserID    uuid.UUID
    TotalAmount Money
    OccurredAt time.Time
}
```

### 5. Repository Interfaces

**Search for:**
```bash
# Find repository interfaces (should be in domain layer)
find . -path "*/domain/*" -name "*repository*.go"
grep -rn "type.*Repository interface" --include="*.go"
```

**Extract:**
- Interface location (domain vs infrastructure)
- Method naming conventions
- Context usage
- Return patterns (entity, error)

**Inconsistency Check:**
- Some interfaces use `ctx context.Context`, others don't → Ask
- Return patterns vary (`*Entity, error` vs `Entity, error`) → Ask
- Method names inconsistent (Get vs Find vs Fetch) → Standardize

**Example:**
```go
// In domain layer: internal/domain/cart/repository.go
type CartRepository interface {
    Save(ctx context.Context, cart *Cart) error
    FindByID(ctx context.Context, id uuid.UUID) (*Cart, error)
    FindByUserID(ctx context.Context, userID uuid.UUID) ([]*Cart, error)
    Delete(ctx context.Context, id uuid.UUID) error
}
```

### 6. CQRS Commands

**Search for:**
```bash
# Find command definitions
find . -path "*/application/*" -name "*command*.go"
grep -rn "Command struct" --include="*.go"
```

**Extract:**
- Command naming (verb-noun pattern?)
- Command structure (data only?)
- Validation in command or handler?

**Example:**
```go
type AddItemToCartCommand struct {
    CartID    uuid.UUID
    ProductID uuid.UUID
    Quantity  int
}
```

### 7. CQRS Queries

**Search for:**
```bash
# Find query definitions
find . -path "*/application/*" -name "*query*.go"
grep -rn "Query struct" --include="*.go"
```

**Extract:**
- Query naming conventions
- Query structure
- DTO return types

**Example:**
```go
type GetCartQuery struct {
    CartID uuid.UUID
}

type CartDTO struct {
    ID     uuid.UUID
    Items  []CartItemDTO
    Total  decimal.Decimal
}
```

### 8. Command/Query Handlers

**Search for:**
```bash
# Find handlers
grep -rn "Handler struct\|Handle(" --include="*.go"
```

**Extract:**
- Handler registration pattern
- Dependencies (repository injection)
- Transaction handling
- Error handling

**Example:**
```go
type AddItemToCartHandler struct {
    cartRepo CartRepository
}

func (h *AddItemToCartHandler) Handle(ctx context.Context, cmd AddItemToCartCommand) error {
    cart, err := h.cartRepo.FindByID(ctx, cmd.CartID)
    if err != nil {
        return fmt.Errorf("finding cart: %w", err)
    }

    if err := cart.AddItem(cmd.ProductID, cmd.Quantity); err != nil {
        return err
    }

    return h.cartRepo.Save(ctx, cart)
}
```

## Reference Documentation to Generate

Create the following files in `reference/`:

### reference/architecture.md

```markdown
# Architecture: DDD + CQRS

## Overview
This project follows Domain-Driven Design (DDD) principles with CQRS pattern.

## Layer Structure

### Domain Layer (`{{DOMAIN_PATH}}`)
Contains business logic, entities, value objects, and repository interfaces.

**Rules:**
- No dependencies on other layers
- Pure business logic
- Repository interfaces defined here

**Extracted Pattern:**
{{DOMAIN_ENTITY_CONSTRUCTOR_PATTERN}}

### Application Layer (`{{APPLICATION_PATH}}`)
Contains commands, queries, and handlers (use cases).

**Rules:**
- Orchestrates domain objects
- No business logic (delegates to domain)
- Depends on domain layer only

**Extracted Pattern:**
{{COMMAND_HANDLER_PATTERN}}

### Infrastructure Layer
Repository implementations, external services.

**Extracted Pattern:**
{{REPOSITORY_IMPLEMENTATION_PATTERN}}
```

### reference/domain-entities.md

```markdown
# Domain Entities

## Entity Construction

**Standard Pattern:**
{{EXTRACTED_CONSTRUCTOR_PATTERN}}

**Example from codebase:**
{{BEST_EXAMPLE_FILE}}:{{LINE_NUMBER}}

## Validation

**Standard:**
{{EXTRACTED_VALIDATION_PATTERN}}

## Business Methods

**Naming Convention:**
{{EXTRACTED_METHOD_NAMING}}
```

### reference/cqrs-patterns.md

```markdown
# CQRS Patterns

## Commands

**Naming:** {{COMMAND_NAMING_PATTERN}}
**Structure:** {{COMMAND_STRUCTURE}}

## Queries

**Naming:** {{QUERY_NAMING_PATTERN}}
**Structure:** {{QUERY_STRUCTURE}}

## Handlers

**Pattern:** {{HANDLER_PATTERN}}
**Dependencies:** {{DEPENDENCY_INJECTION_PATTERN}}
```

## Checklist Items to Generate

Add to `checklists/validation.md`:

```markdown
## DDD/CQRS Validation

### Domain Layer
- [ ] Entities use factory methods (NewEntity pattern)
- [ ] Business logic is in domain entities, not services
- [ ] Repository interfaces are in domain layer
- [ ] No infrastructure dependencies

### Application Layer
- [ ] Commands represent write operations
- [ ] Queries represent read operations
- [ ] Handlers orchestrate, don't contain business logic
- [ ] Transaction boundaries are in handlers

### Layering
- [ ] Domain layer has no external dependencies
- [ ] Application layer depends only on domain
- [ ] Infrastructure implements domain interfaces
```

## Examples to Extract

Find and document best examples:

1. **Complete Aggregate** - Best aggregate root with:
   - Factory method
   - Business methods
   - Invariant enforcement
   - Child entities

2. **Command Handler** - Best handler showing:
   - Repository injection
   - Domain orchestration
   - Error handling
   - Transaction management

3. **Repository Implementation** - Best repo showing:
   - Interface implementation
   - GORM usage (if applicable)
   - Error handling
   - Context usage

## Anti-Patterns to Detect

Check for and warn about:

1. **Anemic Domain Model**
   ```go
   // ❌ Bad: Entity with no behavior
   type Cart struct {
       ID    uuid.UUID
       Items []CartItem
   }
   // All logic in service layer
   ```

2. **Business Logic in Handlers**
   ```go
   // ❌ Bad: Handler contains business logic
   func (h *Handler) Handle(cmd Command) error {
       if cart.Total > 1000 {  // Business rule in handler!
           // ...
       }
   }
   ```

3. **Infrastructure in Domain**
   ```go
   // ❌ Bad: GORM tags in domain entity
   type Cart struct {
       ID uuid.UUID `gorm:"primaryKey"`  // Infrastructure leak!
   }
   ```

## Keywords for skill-rules.json

```json
{
  "keywords": [
    "domain", "entity", "aggregate", "value object",
    "command", "query", "handler", "cqrs",
    "repository", "interface", "ddd"
  ],
  "intentPatterns": [
    "(create|add|implement).*?(entity|aggregate|domain)",
    "(create|add|implement).*?(command|query|handler)",
    "(create|add|implement).*?repository"
  ]
}
```

## Module Configuration

**Priority:** High (fundamental architecture pattern)
**Conflicts with:** clean-architecture, standard-mvc
**Works well with:** modular-monolith, microservices-ready, gorm, gin/echo/fiber
