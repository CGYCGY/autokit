---
module: seeder-data
language: all
category: backend
requires: []
conflicts: []
priority: high
---

# Seeder Data Module

Enforces seeder/fixture data creation for all new database entities and features.

## Critical Rule

**Every new database entity, table, or feature MUST have seeder data for testing.**

## Detection Commands

```bash
# Find existing seeder patterns
grep -rn "seed\|fixture\|factory" --include="*.{py,go,ts,js}" | grep -v "test\|spec\|node_modules"

# Common seeder locations
ls -la database/seeds/ seeds/ fixtures/ factories/ prisma/seed.* db/seeds/ internal/*/seeder.go 2>/dev/null

# Migration files (new tables need seeders)
ls -la migrations/ database/migrations/ prisma/migrations/ alembic/versions/ db/migrate/ 2>/dev/null
```

## Validation Checklist

When adding new entities/tables/features:

- [ ] **Seeder file exists** for new entity
- [ ] **Minimum viable data** covers all required fields
- [ ] **Relationship data** included (foreign keys populated)
- [ ] **Edge cases** represented (optional fields, enums, constraints)
- [ ] **Seeder documented** in README or seed command
- [ ] **Seeder runs successfully** without errors
- [ ] **Data realistic** enough for manual testing

## Project-Specific Seeder Commands

Detect and include in generated guidelines:

```bash
# Go
grep -rn "seed\|Seed" --include="*.go" Makefile main.go cmd/

# Python
grep -E "seed|fixtures" manage.py pyproject.toml Makefile

# TypeScript/JavaScript
grep -E "\"seed\"|\"db:seed\"" package.json
cat prisma/schema.prisma | grep -A5 "seed"
```

## Seeder Patterns by Stack

**Go (common patterns):**
```go
// internal/seeder/seeder.go or cmd/seed/main.go
func SeedDatabase(db *gorm.DB) error {
    // Clear existing data (optional, for dev)
    db.Exec("TRUNCATE TABLE users CASCADE")

    // Create entities with relationships
    users := []User{
        {Email: "admin@example.com", Role: "admin"},
        {Email: "user@example.com", Role: "user"},
    }
    if err := db.Create(&users).Error; err != nil {
        return err
    }

    return nil
}
```

**Python FastAPI/Django:**
```python
# seeds.py or management/commands/seed.py
def seed_database():
    # Idempotent seeding
    user, created = User.get_or_create(
        email="admin@example.com",
        defaults={"role": "admin"}
    )

    # Create related data
    Product.objects.create(
        name="Sample Product",
        owner=user
    )
```

**TypeScript Prisma:**
```typescript
// prisma/seed.ts
async function main() {
  // Clear existing (optional, for dev)
  await prisma.product.deleteMany()
  await prisma.user.deleteMany()

  // Create with relationships
  const user = await prisma.user.create({
    data: {
      email: "admin@example.com",
      role: "ADMIN"
    }
  })

  await prisma.product.createMany({
    data: [
      { name: "Product 1", ownerId: user.id },
      { name: "Product 2", ownerId: user.id }
    ]
  })
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect())
```

## Non-Obvious Anti-Patterns

### Missing Relationship Data
```python
# ❌ Incomplete seed - foreign key will fail
Product.create(name="Laptop", category_id=999)  # category doesn't exist

# ✅ Complete seed with relationships
category = Category.create(name="Electronics")
Product.create(name="Laptop", category_id=category.id)
```

### Hardcoded IDs
```typescript
// ❌ Brittle - breaks if DB reset
await prisma.order.create({ data: { userId: 1 } })

// ✅ Reference created entities
const user = await prisma.user.create({ data: {...} })
await prisma.order.create({ data: { userId: user.id } })
```

### Non-Idempotent Seeders
```python
# ❌ Fails on re-run
User.create(email="test@example.com")  # Duplicate key error

# ✅ Idempotent - safe to run multiple times
User.objects.get_or_create(email="test@example.com")
# or: clear tables before seeding (for dev environments)
```

### Insufficient Test Coverage
```go
// ❌ Only happy path
users := []User{{Email: "valid@example.com"}}

// ✅ Edge cases covered
users := []User{
    {Email: "valid@example.com", Role: "admin", IsActive: true},
    {Email: "user@example.com", Role: "user", IsActive: true},
    {Email: "inactive@example.com", Role: "user", IsActive: false},
}
```

### Missing Enum Values
```typescript
// ❌ Only one enum state
await prisma.order.create({ data: { status: "PENDING" } })

// ✅ Cover all enum states for testing
await prisma.order.createMany({
  data: [
    { status: "PENDING", userId: user.id },
    { status: "PAID", userId: user.id },
    { status: "SHIPPED", userId: user.id },
    { status: "CANCELLED", userId: user.id }
  ]
})
```

## Implementation Workflow

When agent adds new feature/entity:

1. **Detect existing seeder location** (use detection commands)
2. **Identify seeder pattern** from existing files
3. **Create/update seeder file** following project conventions
4. **Add minimum viable data** for new entity
5. **Include relationship data** (foreign keys)
6. **Cover edge cases** (enum states, optional fields)
7. **Test seeder runs** successfully before committing
8. **Update seed command** if new file added

## Progressive Loading

**Core (load when entity/feature added):** This file
**On-demand (load for complex scenarios):**
- `reference/seeder-examples.md` — when creating complex seed data with multiple relationships
