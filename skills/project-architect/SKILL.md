---
name: project-architect
description: Generate foundational project documentation before development begins. Supports three modes - Fullstack, Frontend Only, and Backend Only. Produces structured docs including project overview, tech stack, data models, feature lists, architecture, API contracts, UI flows, and roadmaps.
allowed-tools: Read, Write, Glob, Bash, AskUserQuestion
model: opus
---

# Project Architect

Generate foundational documents that act as the **north star** for a project. All downstream work (phases → tasks → subtasks → implementation) must align with these docs.

## Modes

| Mode | When to Use |
|------|-------------|
| **Fullstack** | Building both frontend and backend |
| **Frontend Only** | Building UI that consumes existing/external API |
| **Backend Only** | Building API/services with no UI responsibility |

## Discussion Flow

Follow this progressive discussion flow, confirming alignment at each level before going deeper:

```
1. User shares idea
2. Ask: "Fullstack, Frontend Only, or Backend Only?"
3. [Level 1] High-level: Problem, users, goals
4. [Level 2] Mid-level: Core features, constraints, tech preferences
5. [Level 3] Deeper: Data entities, API needs, UI platforms (if multiple frontends)
6. Confirm alignment at each level before proceeding
7. User confirms: "Generate docs"
8. Generate all docs to {project-root}/docs/
```

### Discussion Rules

- Start at high level, go deeper only after alignment confirmed
- Ask about mode (Fullstack/Frontend/Backend) early
- For Fullstack/Frontend: Ask if multiple platforms (web, mobile, desktop)
- Do NOT discuss implementation details - that's for later agents
- Stop at roadmap level - no tasks/subtasks

## Doc Structure by Mode

| Doc | Fullstack | FE Only | BE Only |
|-----|:---------:|:-------:|:-------:|
| 01-project-overview.md | ✅ | ✅ | ✅ |
| 02-tech-stack.md | ✅ Full | ✅ FE | ✅ BE |
| 03-data-model.md | ✅ | ❌ | ✅ |
| 03-api-assumptions.md | ❌ | ✅ | ❌ |
| 04-feature-list.md | ✅ | ✅ | ✅ |
| 05-system-architecture.md | ✅ | ❌ | ✅ |
| 06-api-contract.md | ✅ | ❌ | ✅ |
| 07-component-architecture-{platform}.md | ✅ | ✅ | ❌ |
| 08-ui-flows-{platform}.md | ✅ | ✅ | ❌ |
| 09-roadmap.md | ✅ | ✅ | ✅ |

### Multiple Frontends

When project has multiple frontends (e.g., webapp + mobile):
- Create separate 07 and 08 docs per platform
- Example: `07-component-architecture-webapp.md`, `07-component-architecture-mobile.md`
- 02-tech-stack.md should have sections for each frontend

## Standards (Apply to All Modes)

| Standard | Description |
|----------|-------------|
| **Vertical Slice** | Phases are end-to-end slices, not horizontal layers |
| **Parallel by Default** | Assume phases can run in parallel unless dependency noted |
| **Mermaid Embedded** | Diagrams written in mermaid inside markdown |
| **Feature ≠ Roadmap** | Feature list = flat inventory with priority; Roadmap = sequenced phases |

## Generating Docs

1. Read the appropriate templates from `templates/{mode}/`
2. Fill in each template based on discussion with user
3. Replace guidance comments with actual content
4. For multi-platform projects, duplicate 07 and 08 templates per platform
5. Output all docs to `{project-root}/docs/`

## Templates

Templates are in `templates/` directory organized by mode:
- `templates/fullstack/` - 9 templates
- `templates/frontend-only/` - 7 templates
- `templates/backend-only/` - 7 templates

Each template contains structure with guidance comments. Remove comments when generating final docs.
