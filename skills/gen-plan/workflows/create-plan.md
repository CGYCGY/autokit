# Create Plan

1. Analyze Requirements - THINK HARD and parse the `USER_PROMPT` to understand the core problem and desired outcome
2. Explore Codebase - Understand existing patterns, architecture, relevant files, and prior specs to back-reference. Read `AI_DOCS` for AI/agent-facing documentation and `APP_DOCS` for application documentation to ground the plan.
3. Design Solution - Develop technical approach including architecture decisions and implementation strategy
4. Author HTML Plan - Fill the `## Plan Template`, replacing every `{{PLACEHOLDER}}` and repeating `<!-- repeat -->` blocks as needed. Leave the `{{...IMAGE` slots as commented placeholders.
5. Surface Questionables - If `QUESTIONABLE` is true, populate the conditional Questionables section with open decisions/assumptions/risks; otherwise omit the section
6. Generate Filename - Create a descriptive kebab-case filename based on the plan's main topic
7. Save - Write the plan to `PLAN_FILE` (image slots still as commented placeholders — the plan must exist on disk, and its name fixes `IMAGES_OUTPUT_DIR`, before images can be generated)
8. Generate Images - Run the Create sub-workflow in `workflows/image-generation.md` to fill the `{{...IMAGE` slots in the saved file. It drives the pi-image gen-image service on one warm spoke (up → send per slot → down) — keep all slots on the single warm session rather than booting per image.
9. Report - Provide a summary of the plan's key components and the images generated
10. Open in Browser - Open `PLAN_FILE` with the `BROWSER` command resolved per the Variables section
