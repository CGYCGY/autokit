---
module: enum-patterns
language: go
category: constants
requires: []
conflicts: []
---

# Enum Patterns Module for Go

Extracts and standardizes enum/constant patterns in Go projects.

## Detection Criteria

Look for:
```bash
grep -rn "^const\|^var.*=.*{" --include="*.go"
grep -rn "^type.*string\|^type.*int" --include="*.go"
```

## Common Patterns

### Pattern A: Type Alias with Const Block
```go
type OrderStatus string

const (
    OrderStatusPending  OrderStatus = "pending"
    OrderStatusPaid     OrderStatus = "paid"
    OrderStatusShipped  OrderStatus = "shipped"
)
```

### Pattern B: Struct-based with Value/Label
```go
type OrderStatus struct {
    Value string
    Label string
}

var (
    OrderStatusPending = OrderStatus{Value: "pending", Label: "Pending"}
    OrderStatusPaid    = OrderStatus{Value: "paid", Label: "Paid"}
)
```

### Pattern C: iota-based
```go
type OrderStatus int

const (
    OrderStatusPending OrderStatus = iota
    OrderStatusPaid
    OrderStatusShipped
)
```

## Extraction Process

1. Find all enum definitions
2. Categorize by pattern
3. Count usage
4. If multiple patterns exist → Ask user to choose standard

## Reference Documentation

### reference/enum-patterns.md

Template based on chosen pattern.

## Checklist Items

- [ ] All enums follow {{CHOSEN_PATTERN}}
- [ ] Enums defined in appropriate layer (usually domain)
- [ ] String enums use consistent casing
