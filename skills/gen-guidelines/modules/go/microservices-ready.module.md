---
module: microservices-ready
language: go
category: architecture
requires: [modular-monolith]
conflicts: []
---

# Microservices-Ready Module for Go

This module enforces patterns that enable smooth transition from modular monolith to microservices by detecting and preventing coupling issues.

## Detection Criteria

**Required:**
- Modular monolith structure (multiple domain modules)
- User confirms future microservices migration

**Folder structure indicators:**
```
internal/order/
internal/cart/
internal/product/
internal/user/
```

**If found:** Modular monolith detected, microservices-ready patterns applicable

## Purpose

Ensure the monolith can be cleanly split into microservices by:
1. Enforcing module boundaries
2. Preventing cross-module database access
3. Encouraging event-driven communication
4. Identifying coupling violations
5. Creating migration roadmap

## Patterns to Extract & Enforce

### 1. Module Boundary Violations (CRITICAL!)

**Search for:**
```bash
# Find cross-module domain imports
grep -rn "import.*internal/[^/]*/domain" --include="*.go" | \
  grep -v "/domain/" | \
  awk -F: '{print $1}' | \
  while read file; do
    module=$(echo $file | awk -F/ '{print $2}')
    imports=$(grep "import.*internal/[^/]*/domain" "$file" | \
      sed 's/.*internal\/\([^/]*\)\/.*/\1/' | \
      grep -v "^$module$")
    if [ -n "$imports" ]; then
      echo "VIOLATION: $file imports other modules' domains"
    fi
  done
```

**Detect violations:**
```go
// ❌ CRITICAL VIOLATION: Cart module directly imports Order domain
// File: internal/cart/service/cart_service.go
import "github.com/yourproject/internal/order/domain"

func (s *CartService) Checkout() error {
    order := order.NewOrder()  // Direct domain access across modules!
}
```

**Correct pattern:**
```go
// ✅ CORRECT: Use interface dependency
type OrderService interface {
    CreateOrderFromCart(ctx context.Context, cartID uuid.UUID) (*OrderDTO, error)
}

type CartService struct {
    orderService OrderService  // Injected dependency
}

func (s *CartService) Checkout(ctx context.Context) error {
    order, err := s.orderService.CreateOrderFromCart(ctx, s.cart.ID)
    // ...
}
```

**Action:** HIGH PRIORITY WARNING - blocks microservices migration

### 2. Cross-Module Database Access (CRITICAL!)

**Search for:**
```bash
# Find database queries to other modules' tables
grep -rn "db.Table\|db.Model\|db.Where" --include="*.go" | \
  while read line; do
    file=$(echo "$line" | cut -d: -f1)
    module=$(echo "$file" | awk -F/ '{print $2}')
    tables=$(echo "$line" | grep -oP 'Table\("\K[^"]+' | \
      sed 's/s$//' | \
      grep -v "^$module")
    if [ -n "$tables" ]; then
      echo "VIOLATION: $file queries $tables table"
    fi
  done
```

**Detect violations:**
```go
// ❌ CRITICAL VIOLATION: Discount module querying Product table
// File: internal/discount/repository/discount_repo.go
func (r *DiscountRepo) ValidateDiscount(productID uuid.UUID) error {
    var product Product
    r.db.Table("products").Where("id = ?", productID).First(&product)
    // Direct database access to Product module's table!
}
```

**Correct pattern:**
```go
// ✅ CORRECT: Use Product module's service interface
type ProductService interface {
    GetProduct(ctx context.Context, id uuid.UUID) (*ProductDTO, error)
}

type DiscountService struct {
    productService ProductService  // Injected
}

func (s *DiscountService) ValidateDiscount(ctx context.Context, productID uuid.UUID) error {
    product, err := s.productService.GetProduct(ctx, productID)
    // ...
}
```

**Action:** HIGH PRIORITY WARNING - violates database-per-service principle

### 3. Service Interface Pattern

**Search for:**
```bash
# Find application service interfaces
find . -path "*/application/*" -name "*service*.go" -exec grep -l "interface" {} \;
```

**Extract:**
- Public service interfaces (module API contracts)
- Method signatures (will become REST/gRPC later)
- DTO usage (data transfer across module boundaries)

**Check for:**
- Are all cross-module calls through interfaces?
- Do interfaces represent service contracts?
- Can these interfaces be replaced with HTTP/gRPC clients?

**Example:**
```go
// Module's public service interface (becomes microservice API)
// File: internal/cart/application/service.go
type CartApplicationService interface {
    // Commands
    AddItem(ctx context.Context, cmd AddItemCommand) error
    RemoveItem(ctx context.Context, cmd RemoveItemCommand) error
    Checkout(ctx context.Context, cartID uuid.UUID) error

    // Queries
    GetCart(ctx context.Context, query GetCartQuery) (*CartDTO, error)
    ListCarts(ctx context.Context, userID uuid.UUID) ([]*CartDTO, error)
}

// Future microservice implementation:
// - Same interface
// - HTTP/gRPC client implementation
// - No code changes in calling modules
```

### 4. Event-Driven Communication

**Search for:**
```bash
# Find event definitions
grep -rn "Event struct" --include="*.go"

# Find event publishers
grep -rn "Publish\|publish\|Emit\|emit" --include="*.go"

# Find event subscribers
grep -rn "Subscribe\|subscribe\|Handle.*Event" --include="*.go"
```

**Extract:**
- Event naming conventions
- Event structure (what data is shared)
- Event bus/publisher infrastructure
- Subscriber patterns

**Check for:**
- Do modules communicate state changes via events?
- Are events used instead of direct calls for async workflows?
- Is event infrastructure in place?

**Example:**
```go
// Domain event
type OrderCreatedEvent struct {
    OrderID   uuid.UUID
    CartID    uuid.UUID
    UserID    uuid.UUID
    Total     decimal.Decimal
    CreatedAt time.Time
}

// Publisher (Order module)
func (h *CreateOrderHandler) Handle(ctx context.Context, cmd CreateOrderCommand) error {
    order := /* create order */

    // Publish event for other modules
    h.eventBus.Publish(OrderCreatedEvent{
        OrderID: order.ID,
        CartID:  cmd.CartID,
        // ...
    })
}

// Subscriber (Cart module)
func (h *OrderCreatedEventHandler) Handle(event OrderCreatedEvent) error {
    // Mark cart as checked out
    return h.cartService.MarkAsCheckedOut(event.CartID)
}
```

**If missing:** Recommend adding event infrastructure

### 5. Shared Data Patterns

**Search for:**
```bash
# Find foreign keys across module boundaries
grep -rn "foreignKey\|references" --include="*.go"

# Find GORM relationships across modules
grep -rn "has_many\|belongs_to" --include="*.go"
```

**Detect anti-patterns:**
```go
// ❌ BAD: Foreign key to another module's table
type Discount struct {
    ID        uuid.UUID
    ProductID uuid.UUID `gorm:"foreignKey:ProductID;references:products(id)"`
    // Foreign key across module boundary!
}
```

**Recommend patterns:**

**Option A: Reference by ID only**
```go
// ✅ GOOD: Store ID, fetch via service
type Discount struct {
    ID        uuid.UUID
    ProductID uuid.UUID  // No foreign key!
}

// Fetch product details when needed
product, err := productService.GetProduct(ctx, discount.ProductID)
```

**Option B: Duplicate data (eventual consistency)**
```go
// ✅ GOOD: Store denormalized data
type Discount struct {
    ID           uuid.UUID
    ProductID    uuid.UUID
    ProductName  string  // Duplicated from Product module
    ProductPrice decimal.Decimal
}

// Sync via domain events
func (h *ProductUpdatedEventHandler) Handle(event ProductUpdatedEvent) {
    // Update denormalized data in Discount module
}
```

**Option C: API calls (synchronous)**
```go
// ✅ GOOD: Fetch on demand
discount := GetDiscount(id)
product := productService.GetProduct(discount.ProductID)  // API call
```

**Option D: Domain events (asynchronous)**
```go
// ✅ GOOD: Eventually consistent
// Product module publishes ProductCreatedEvent
// Discount module subscribes and caches product data locally
```

**Ask user:** "Found {count} cross-module data dependencies. Which pattern should we use?"

### 6. Module Dependency Graph

**Build dependency graph:**

```go
// Scan all service interface dependencies
type ModuleDependency struct {
    Module    string
    DependsOn []string
}

// Example output:
Cart Module
  ├─ depends on → Product (via ProductService interface)
  ├─ depends on → Discount (via DiscountService interface)
  └─ publishes → CartCheckedOutEvent

Order Module
  ├─ subscribes to → CartCheckedOutEvent
  ├─ depends on → Product (via ProductService interface)
  └─ publishes → OrderCreatedEvent

Product Module
  └─ (no dependencies - can be extracted first!)

Discount Module
  ├─ depends on → Product (via ProductService interface)
  └─ subscribes to → OrderCreatedEvent
```

**Migration order recommendation:**
1. Extract modules with no dependencies first (Product)
2. Then modules that depend only on extracted modules (Discount)
3. Finally modules with most dependencies (Cart, Order)

## Reference Documentation to Generate

### reference/module-boundaries.md

```markdown
# Module Boundaries

## Module Map

{{DETECTED_MODULES}}

## Allowed Dependencies

{{DEPENDENCY_GRAPH}}

## Boundary Rules

1. **No direct domain imports across modules**
2. **All cross-module calls via application service interfaces**
3. **No cross-module database queries**
4. **Use events for state change notifications**

## Current Violations

{{LIST_OF_VIOLATIONS}}
```

### reference/service-interfaces.md

```markdown
# Service Interfaces (Future Microservice APIs)

{{FOR_EACH_MODULE}}

## {{MODULE_NAME}} Service

**Interface:** {{SERVICE_INTERFACE_FILE}}

**Methods:**
{{METHOD_LIST}}

**Future Implementation:**
When extracted as microservice, this interface will be implemented as:
- HTTP REST client (using Gin/Echo/etc.)
- gRPC client
- Message queue consumer

**Current callers:**
{{MODULES_THAT_DEPEND_ON_THIS}}
```

### reference/domain-events.md

```markdown
# Domain Events

## Event Catalog

{{FOR_EACH_EVENT}}

### {{EVENT_NAME}}

**Publisher:** {{MODULE}}
**Subscribers:** {{SUBSCRIBER_MODULES}}
**Data:** {{EVENT_FIELDS}}

**Purpose:** {{INFERRED_PURPOSE}}

**Migration Note:** When modules become services, this event will be published to message queue (RabbitMQ, Kafka, NATS).
```

### reference/migration-roadmap.md

```markdown
# Microservices Migration Roadmap

## Dependency Analysis

{{DEPENDENCY_GRAPH}}

## Recommended Extraction Order

### Phase 1: Extract Leaf Modules (No dependencies)
{{MODULES_WITH_NO_DEPS}}

### Phase 2: Extract Second-Level Modules
{{MODULES_DEPENDING_ON_PHASE1}}

### Phase 3: Extract Core Modules
{{REMAINING_MODULES}}

## Violation Remediation

Before extraction, fix these violations:

{{HIGH_PRIORITY_VIOLATIONS}}

## Infrastructure Requirements

- [ ] Event bus/message queue (RabbitMQ, Kafka, NATS)
- [ ] Service discovery (Consul, etcd)
- [ ] API gateway
- [ ] Distributed tracing (Jaeger, Zipkin)
- [ ] Service mesh (optional: Istio, Linkerd)
```

## Checklist Items to Generate

Add to `checklists/microservices-ready.md`:

```markdown
# Microservices Readiness Checklist

## Module Boundaries
- [ ] No direct domain imports across modules
- [ ] All cross-module calls use application service interfaces
- [ ] Each module has well-defined public API (service interface)

## Database Independence
- [ ] Each module owns its database tables
- [ ] No foreign keys across module boundaries
- [ ] Cross-module data access via service interfaces or events

## Event-Driven Communication
- [ ] Domain events defined for important state changes
- [ ] Event bus infrastructure exists
- [ ] Modules subscribe to relevant events
- [ ] Async workflows use events, not direct calls

## Service Interfaces
- [ ] Each module exposes clear service interface
- [ ] Interfaces use DTOs, not domain entities
- [ ] Methods are coarse-grained (suitable for network calls)

## Shared Code Strategy
- [ ] Shared code identified (can become library)
- [ ] No shared mutable state across modules
- [ ] Shared constants/enums in separate package

## Migration Readiness
- [ ] Module can run with only its database + dependencies
- [ ] Dependency graph documented
- [ ] Circular dependencies eliminated
```

## Anti-Patterns to Detect

### 1. Tightly Coupled Modules
```go
// ❌ Found in: internal/cart/service/cart_service.go
import "github.com/yourproject/internal/order/domain"

func (s *CartService) Checkout() {
    order := order.NewOrder()  // Direct domain access!
}
```
→ **Action:** Create OrderService interface, inject into CartService

### 2. Shared Database
```go
// ❌ Found in: internal/discount/repository/discount_repo.go
db.Table("products").Where(...)  // Accessing Product module's table!
```
→ **Action:** Call ProductService.GetProduct() instead

### 3. Synchronous Cross-Module Calls Without Interfaces
```go
// ❌ Found in: internal/cart/service/cart_service.go
productService := product.NewProductService(db)  // Direct instantiation!
```
→ **Action:** Inject via interface dependency

### 4. Database-Level Joins Across Modules
```go
// ❌ Found in: internal/order/repository/order_repo.go
db.Table("orders").
    Joins("LEFT JOIN products ON orders.product_id = products.id").
    Where(...)
```
→ **Action:** Fetch from ProductService and join in application layer

## Violation Severity Levels

**CRITICAL (Blocks microservices migration):**
- Direct domain imports across modules
- Cross-module database queries
- Database foreign keys across modules

**HIGH (Makes migration difficult):**
- Missing service interfaces
- Synchronous calls without interfaces
- No event infrastructure

**MEDIUM (Technical debt):**
- Shared mutable state
- Circular dependencies
- Coarse-grained service methods

## Output Format

When violations found:

```
⚠️  MICROSERVICES READINESS VIOLATIONS

CRITICAL (Must fix before migration):
1. Cart → Order (direct domain import)
   • File: internal/cart/service/cart_service.go:45
   • Fix: Create OrderService interface

2. Discount → Product (DB query)
   • File: internal/discount/repository/discount_repo.go:78
   • Fix: Use ProductService.GetProduct()

HIGH (Recommended to fix):
3. Missing CartService interface
   • File: internal/cart/application/
   • Fix: Define CartApplicationService interface

Generate remediation tasks? (y/n)
```

## Keywords for skill-rules.json

```json
{
  "keywords": [
    "microservices", "migration", "boundaries", "coupling",
    "service interface", "event bus", "module", "monolith"
  ],
  "intentPatterns": [
    "migrate.*microservices",
    "prepare.*microservices",
    "split.*service",
    "extract.*service"
  ]
}
```

## Module Configuration

**Priority:** Critical (if microservices migration planned)
**Requires:** modular-monolith
**Works well with:** ddd-cqrs, event-sourcing
**Enforcement:** Warn on violations (they block migration)
