---
name: api-testing
description: API testing tools with automatic auth. Triggers on "test api", "curl", or "http request".
user-invocable: true
---

# API Testing

CLI tools for testing REST API endpoints with automatic authentication.

## First Time Setup

Run any command to check if tools are installed:

```bash
uvx api-call --help
```

If "Please edit .claude/api-testing/.env" message appears:
1. The tool created `.claude/api-testing/.env` with a template
2. Ask the user if they want you to help configure it based on their project
3. Edit `.claude/api-testing/.env` with the appropriate settings
4. Run the command again

## Agent Usage Guidelines

**IMPORTANT:** When using these tools as an agent, **ALWAYS include the `-r` flag** with all HTTP request commands. This ensures raw JSON output without truncation.

---

## Quick Reference

### Check Status
```bash
uvx api-call status
```

### JWT Mode (Default)
```bash
uvx api-call login -e user@example.com -p yourpassword
uvx api-call get /users -r
uvx api-call post /users -d '{"name":"John"}' -r
uvx api-call put /users/1 -d '{"name":"Jane"}' -r
uvx api-call delete /users/1 -y -r
```

### API Key / Basic Auth / None Mode
```bash
# No login needed - just make requests
uvx api-call get /users -r
uvx api-call post /users -d '{"name":"John"}' -r
```

---

## Configuration

Configuration is stored in `.claude/api-testing/.env`:

### Base Settings
```env
BASE_URL=http://localhost:3000/api/v1  # Full API base URL (default: http://localhost/api/v1)
AUTH_MODE=jwt                          # jwt | api-key | basic | none (default: jwt)
```

### JWT Mode
```env
AUTH_MODE=jwt
API_TEST_EMAIL=user@example.com        # Default login email
API_TEST_PASSWORD=yourpassword         # Default login password
AUTH_LOGIN_ENDPOINT=/auth/login        # Optional (default: /auth/login)
AUTH_REFRESH_ENDPOINT=/auth/refresh    # Optional (default: /auth/refresh)
```

### API Key Mode
```env
AUTH_MODE=api-key
API_KEY=your-api-key-here
API_KEY_HEADER=X-API-Key               # Optional (default: X-API-Key)
```

### Basic Auth Mode
```env
AUTH_MODE=basic
BASIC_AUTH_USERNAME=admin
BASIC_AUTH_PASSWORD=password
```

### No Auth Mode
```env
AUTH_MODE=none
```

---

## Authentication Modes

| Mode | Login Required | Use Case |
|------|----------------|----------|
| `jwt` | Yes | APIs with access/refresh tokens |
| `api-key` | No | External APIs (Stripe, SendGrid, etc.) |
| `basic` | No | Simple internal APIs |
| `none` | No | Public endpoints |

### JWT Mode (Default)
- Login once with `uvx api-call login`, tokens stored locally
- Access tokens auto-refresh when expired
- Check status: `uvx api-call status`
- Force refresh: `uvx api-call refresh --force`

### API Key Mode
- API key sent in header with every request
- Header name configurable (`X-API-Key`, `Authorization`, etc.)

### Basic Auth Mode
- Username:password encoded and sent with every request
- Standard HTTP Basic Authentication

### None Mode
- No authentication headers added
- Same as using `--no-auth` flag

---

## Available Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `status` | Show config status | `uvx api-call status` |
| `login` | Login (JWT only) | `uvx api-call login -e user@example.com -p pass` |
| `refresh` | Refresh tokens (JWT only) | `uvx api-call refresh --force` |
| `get` | GET requests | `uvx api-call get /users -r` |
| `post` | POST requests | `uvx api-call post /users -d '{...}' -r` |
| `put` | PUT requests | `uvx api-call put /users/1 -d '{...}' -r` |
| `delete` | DELETE requests | `uvx api-call delete /users/1 -y -r` |

## Common Flags

| Flag | Description |
|------|-------------|
| `-r, --raw` | Raw JSON output (recommended for agents) |
| `--no-auth` | Skip authentication for this request |
| `-H, --headers` | Show response headers |
| `-v, --verbose` | Verbose output with request details |
| `-q, --query` | Query params: `-q "page=1&limit=10"` |
| `-d, --data` | JSON data string |
| `-f, --file` | JSON data from file |
| `-y, --yes` | Skip confirmation (delete only) |

---

## Error Handling

- HTTP 4xx/5xx: Shows error details, exits with code 1
- Network errors: Shows connection details
- Token errors: Prompts to login again
- Invalid JSON: Shows parsing error with line number
