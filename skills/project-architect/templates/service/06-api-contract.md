# API Contract

JSON over HTTP. Pydantic models (Python) or struct tags (Go) on the service side; Zod on the TS caller side. Schemas should match shape-for-shape.

## API Overview

| Concern | Value |
|---|---|
| Base URL | |
| Versioning | URL path (e.g., `/v1`) |
| Content-Type | `application/json` |

## Common Headers

| Header | Value | Required |
|---|---|---|
| Authorization | Bearer {internal-token} | Yes (except /healthz) |
| Content-Type | application/json | Yes (POST/PUT/PATCH) |

## Status Codes

| Code | Meaning |
|---|---|
| 200 | Success |
| 202 | Accepted (async pattern) |
| 400 | Validation error |
| 401 | Unauthorized |
| 404 | Not found |
| 500 | Server error |

## Common Error Response

```json
{
  "error": "error_code",
  "message": "Human readable message",
  "details": {}
}
```

## Endpoints
<!-- Repeat per endpoint. -->

### [METHOD] /path

<!-- Brief description. -->

**Request:**

| Field | Type | Required | Validation |
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

### GET /healthz

Returns 200 if the service is alive. No auth.
