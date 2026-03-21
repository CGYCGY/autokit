# Claude Code Documentation URLs

Fetch these before generating a skill to ensure current spec compliance.

## Skill Documentation

| Doc | URL | Purpose |
|-----|-----|---------|
| Skills | https://code.claude.com/docs/en/skills.md | Core skill spec: frontmatter fields, structure, behavior |
| Skills Best Practices | https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices.md | Authoring guidelines, patterns, anti-patterns |
| Documentation Map | https://code.claude.com/docs/en/claude_code_docs_map.md | Full doc index for cross-referencing |

## Fetch Instructions

1. Attempt to fetch each URL using `WebFetch`
2. If a fetch fails (network error, 404), proceed with local `best-practices.md` only
3. If fetched content differs from local best practices, prefer the fetched version (it is more current)
4. Extract relevant sections: frontmatter fields, structure rules, naming conventions
