# API Assumptions

Documents the external API this frontend consumes. Treated as a contract; if it changes, the frontend changes.

## API Source
<!-- e.g., "Owned by our backend team", "Third-party (Stripe)", "Mock for prototype". -->

## Base URL

| Environment | URL |
|---|---|
| Development | |
| Staging | |
| Production | |

## Authentication
<!-- Bearer token, API key, OAuth, session cookie, etc. How the FE obtains and refreshes credentials. -->

## Rate Limits / Quotas
<!-- Document limits the FE must respect. -->

## Endpoints Consumed

| Method | Path | Purpose | Used by |
|---|---|---|---|
| | | | |

## Response Shapes (validated via Zod)
<!-- Repeat per endpoint. -->

### [Endpoint name]

```ts
// Zod schema
const Schema = z.object({
})
```

```json
// Example response
{}
```

## Error Conventions
<!-- How the API signals errors (status code, body shape). What the FE does in each case. -->

| Status | Body shape | FE behavior |
|---|---|---|
| | | |

## Mock Strategy
<!-- MSW handlers checked into repo. List which endpoints are mocked and where the handlers live. -->
