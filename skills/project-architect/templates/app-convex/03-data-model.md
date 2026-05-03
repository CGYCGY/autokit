# Data Model

Convex schema. Define tables in `convex/schema.ts` using `defineSchema` + `defineTable` + `v.*` validators.

## Tables Overview

| Table | Purpose |
|---|---|
| | |

## Table Details
<!-- Repeat per table. Use Convex validator types: v.string(), v.number(), v.boolean(), v.id("otherTable"), v.optional(...), v.union(...), v.array(...), v.object({...}). -->

### Table: [name]

| Field | Validator | Notes |
|---|---|---|
| _id | (auto) | Convex document id |
| _creationTime | (auto) | Convex creation timestamp |
| | | |

#### Indexes

| Index name | Fields | Purpose |
|---|---|---|
| | | |

#### Search Indexes
<!-- Only when Convex built-in search is in use for this table. Remove if none. -->

| Index name | Search field | Filter fields | Purpose |
|---|---|---|---|

#### Vector Indexes
<!-- Only if Convex vector search is in use for this table. Remove if none. -->

| Index name | Vector field | Dimensions | Filter fields |
|---|---|---|---|

#### Validation Rules
<!-- Business rules enforced in Convex mutations/actions, not at schema level. -->

| Rule | Enforced in | Description |
|---|---|---|
| | | |

## Relationships
<!-- Convex uses `v.id("table")` for foreign keys. Mermaid ER for clarity. -->

```mermaid
erDiagram

```

## Data Notes
<!-- Soft-delete pattern, denormalization choices, audit fields, retention. -->
