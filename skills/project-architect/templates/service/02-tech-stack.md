# Tech Stack

Archetype: **Specialist service**. Default language is Go. Python only with a §6 ecosystem trigger.

## Language Decision

| Step | Rule |
|---|---|
| 1 | Does the problem require a Python-only library (Whisper, Scrapy+Playwright, pdfplumber, PaddleOCR, spaCy, sentence-transformers, etc.)? → **Python** |
| 2 | Otherwise → **Go** |
| 3 | If just calling external APIs → **Go** (Python's ecosystem doesn't help; Go's footprint does) |

Record the chosen language and its trigger:

| Language | Trigger |
|---|---|

## Service (Go default)

Use this section if Go was picked. Delete if Python.

| Concern | Choice | Reason |
|---|---|---|
| HTTP | Chi or stdlib `net/http` (Go 1.22+) | §6, §14 — never Gin/Echo/Fiber |
| DB (when needed) | sqlc | §6, §14 — never GORM |
| Migrations | goose or atlas | §6 (sqlc handles queries, not migrations) |
| Logging | stdlib `slog` | §6 |
| Validation | struct tags + `go-playground/validator` | §6 |
| Config | env vars + a typed loader | — |
| Testing | stdlib `testing` + `testify/assert` | — |

## Service (Python — only on §6 trigger)

Use this section if Python was picked. Delete if Go.

| Concern | Choice | Reason |
|---|---|---|
| Package manager | uv | §6 — always |
| Framework | FastAPI | §6 |
| ORM (when DB needed) | SQLAlchemy | §6 |
| Logging | structlog | §6 |
| Validation | Pydantic models (FastAPI native) | — |
| Testing | pytest | — |

## Cross-cutting

| Concern | Choice | Reason |
|---|---|---|
| Wire format | JSON over HTTP | §6 — no gRPC unless concrete reason |
| Auth (internal) | Shared secret OR JWT validated via JWKS / shared secret | §4, §6 |
| Hosting | Self-hosted | §1 |
