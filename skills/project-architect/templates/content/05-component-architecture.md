# Component Architecture

Astro pages + layouts. React only inside islands (`client:*` directives). Default to no JS — add islands only where interaction is required.

## Pages

| Path | Source | Purpose |
|---|---|---|
| / | `src/pages/index.astro` | |
| | | |

## Layouts

| Layout | Used by | Purpose |
|---|---|---|
| | | |

## Astro Components (no JS shipped)

| Component | Purpose |
|---|---|
| | |

## React Islands

| Island | Hydration | Purpose |
|---|---|---|
| | client:load / client:idle / client:visible / client:media | |

## Shared UI (shadcn/ui in islands)

| Component | Used by |
|---|---|
| | |

## Form Submissions
<!-- Forms post to a sibling repo. List endpoints. -->

| Form | Posts to | Validation |
|---|---|---|
| | | Zod (in island) + server-side in sibling repo |
