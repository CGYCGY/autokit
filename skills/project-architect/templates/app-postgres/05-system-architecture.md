# System Architecture

## Architecture Diagram

```mermaid
flowchart LR
  Client[Next.js client] --> Server[Next.js server / route handlers]
  Server -- Drizzle --> DB[(PostgreSQL)]
  Server -- WorkOS AuthKit --> Auth[Sessions]
  Server -- enqueue --> Jobs[trigger.dev / BullMQ]
  Jobs -- read/write --> DB
```

## Component Responsibilities

| Component | Responsibility |
|---|---|
| Next.js client | UI, routing, SSR/RSC |
| Next.js server / route handlers | API surface, auth checks, business logic |
| Drizzle | DB access, schema, migrations |
| WorkOS (AuthKit) | Session + identity |
| Jobs runner | Background work (trigger.dev default) |
| Valkey | Cache / queue when BullMQ in use; rate-limit store |

## External Services
<!-- Third-party APIs. Remove if none. -->

| Service | Purpose | Notes |
|---|---|---|
| | | |

## Authentication Flow

WorkOS AuthKit issues sessions/JWTs. Server reads session in route handlers via the WorkOS Node SDK. For non-TS services, validate JWTs against WorkOS's JWKS endpoint (do not call the WorkOS Management API from Go/Python on the hot path).

## Environments

| Environment | Purpose | URL/Notes |
|---|---|---|
| Development | Local | |
| Staging | Pre-prod | |
| Production | Live | |
