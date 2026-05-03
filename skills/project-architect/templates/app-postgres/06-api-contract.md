# API Contract

HTTP API exposed by Next.js route handlers. Consumed by the Next.js client and any sibling services.

## API Overview

| Concern | Value |
|---|---|
| Base URL | `/api/v1` |
| Versioning | URL path |
| Content-Type | `application/json` |

## Common Headers

| Header | Value | Required |
|---|---|---|
| Authorization | Bearer {token} | Yes (except auth endpoints) |
| Content-Type | application/json | Yes (POST/PUT/PATCH) |

## Status Codes

| Code | Meaning |
|---|---|
| 200 | Success |
| 201 | Created |
| 204 | Deleted (no content) |
| 400 | Validation error |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not found |
| 500 | Server error |

## Common Error Response

```json
{
  "error": "error_code",
  "message": "Human readable message",
  "details": { "field": "specific field error" }
}
```

## Resources
<!-- Repeat the resource section per entity. -->

### [Resource]

#### [METHOD] /path

<!-- Brief description -->

**Request:**

| Field | Type | Required | Validation (Zod) |
|---|---|---|---|
| | | | |

**Request example:**

```json
{}
```

**Response (2xx):**

```json
{}
```

**Error (4xx):**

```json
{ "error": "error_code", "message": "..." }
```
