---
description: Migrates a WordPress export to Astro and reviews the funnel. Use when you want to convert a WP site and validate CTA/funnel quality in one step.
argument-hint: <wp-export-path> <target-output-directory>
---

# WP Migrate

## Purpose

Convert a WordPress export to an Astro static site via /wp-to-astro, then run /funnel-review on the output and produce a combined migration + funnel status summary.

## Variables

WP_EXPORT: $ARGUMENTS[0]
TARGET_DIR: $ARGUMENTS[1]

## Instructions

- Both arguments are required. If either is missing, stop and ask the user before proceeding.
- Do not skip the build verification step — only run /funnel-review after `bun run build` passes.
- Report funnel issues exactly as returned by /funnel-review; do not invent or suppress findings.
- If the build fails, stop and report the build errors. Do not run /funnel-review on a broken build.

## Workflow

1. Invoke `/wp-to-astro $ARGUMENTS[0] $ARGUMENTS[1]` — this runs audit, scaffolding, content migration, and build internally.
2. Confirm the Astro build passed (exit 0 from `bun run build` in TARGET_DIR). If it failed, stop here and report errors.
3. Invoke `/funnel-review $ARGUMENTS[1]` on the output directory.
4. Combine results into the final summary (see Output Contract).

## Output Contract

### On Success

Print a two-section summary:

**Migration Status**
- Build: passed
- Pages created, images copied, blog posts migrated (counts from wp-to-astro report)
- Any manual steps remaining (e.g. verify GTM ID, test contact form)

**Funnel Review**
- Overall funnel verdict (pass / issues found)
- Itemized list of funnel issues requiring manual fixing, each with file path and description
- Confirm "No funnel issues found" if /funnel-review returned clean

### On Failure

State which step failed (migration or funnel review), include the error output, and list any partial findings already collected.
