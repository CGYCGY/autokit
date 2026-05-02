# API Contract

## API Overview

| Concern | Value |
|---------|-------|
| Base URL | `/api/v1` |
| Versioning | URL path |
| Content-Type | `application/json` |

## Common Headers

| Header | Value | Required |
|--------|-------|----------|
| Authorization | Bearer {token} | Yes (except auth endpoints) |
| Content-Type | application/json | Yes (for POST/PUT/PATCH) |

## Status Codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 201 | Created |
| 204 | Deleted (no content) |
| 400 | Validation error |
| 401 | Unauthorized (no/invalid token) |
| 403 | Forbidden (valid token, no permission) |
| 404 | Resource not found |
| 500 | Server error |

## Common Error Response

```json
{
  "error": "error_code",
  "message": "Human readable message",
  "details": {
    "field": "specific field error"
  }
}
```

## Resources

<!-- 
Document each resource with its endpoints.
Repeat the resource section for each entity.
-->

### [Resource Name]

#### [METHOD] /path

<!-- Brief description of what this endpoint does -->

**Request:**

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| | | | |

**Request Example:**

```json
{

}
```

**Response (2xx):**

```json
{

}
```

**Error (4xx):**

```json
{
  "error": "error_code",
  "message": "description"
}
```
