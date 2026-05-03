# Data Model

Drizzle schema. Tables defined in `db/schema.ts` using `pgTable`. Migrations generated via `drizzle-kit` and checked into the repo.

## Tables Overview

| Table | Purpose |
|---|---|
| | |

## Table Details
<!-- Repeat per table. -->

### Table: [name]

| Column | Type | Constraints | Notes |
|---|---|---|---|
| id | uuid | PK, default `gen_random_uuid()` | |
| | | | |
| created_at | timestamptz | default `now()` | |
| updated_at | timestamptz | default `now()`; updated via trigger or app code | |

#### Indexes

| Index | Columns | Type | Purpose |
|---|---|---|---|
| | | btree / gin / gist | |

#### Validation Rules
<!-- Business rules enforced in app code (Zod) or DB constraints. -->

| Rule | Enforced in | Description |
|---|---|---|
| | | |

## Relationships
<!-- Mermaid ER diagram with cardinality. -->

```mermaid
erDiagram

```

## Data Notes
<!-- Soft-delete pattern, audit fields, retention, partitioning, etc. -->
