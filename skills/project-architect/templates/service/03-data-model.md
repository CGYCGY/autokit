# Data Model

Only include this doc if the service owns persistent state. Many specialist services are stateless (compute on input, return output, write to caller's DB). If stateless, write "None — service is stateless; results written back to caller via Convex HTTP action / DB" and skip the rest.

## Storage

| Concern | Choice |
|---|---|
| Database (if any) | |
| Reason | |

## Tables / Collections

| Table | Purpose |
|---|---|
| | |

## Table Details
<!-- Repeat per table. Use Drizzle/sqlc/SQLAlchemy schema syntax matching the language picked in 02. -->

### Table: [name]

| Column | Type | Constraints | Notes |
|---|---|---|---|
| | | | |

#### Indexes

| Index | Columns | Purpose |
|---|---|---|
| | | |

## Relationships

```mermaid
erDiagram

```

## Data Notes
<!-- Retention, cleanup jobs, partitioning, etc. -->
