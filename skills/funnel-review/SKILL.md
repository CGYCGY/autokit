---
name: funnel-review
description: Audits a landing page's sales funnel for conversion effectiveness. Use when asked to "review funnel", "check CTAs", "audit landing page", "validate conversion path", "funnel audit", or "check page conversion".
argument-hint: <project-directory>
allowed-tools: Read, Grep, Glob, Bash
user-invocable: true
---

# Funnel Review

## Purpose

Analyze a landing page's source files to produce a structured conversion audit covering funnel flow, CTA strategy, mobile elements, content accuracy, and tracking.

## Variables

PROJECT_DIR: $ARGUMENTS
CHECKLIST_DIR: ${CLAUDE_SKILL_DIR}/reference

## Instructions

### Source File Discovery

- Accept any framework: HTML, Astro, React, Vue, or plain files
- Glob for page entry points: `*.html`, `*.astro`, `*.jsx`, `*.tsx`, `*.vue`
- If PROJECT_DIR is empty, use current working directory
- Read the main page file(s) to map section order before analyzing details

### Analysis Scope

Run all five checks regardless of framework:

1. **Funnel Flow** — map section order top-to-bottom; note where CTAs appear relative to content blocks
2. **CTA Strategy** — count CTAs, check text variety and tracking URL variety
3. **Mobile Conversion** — detect sticky bar, floating WhatsApp button, responsive CTA buttons
4. **Content Accuracy** — flag placeholder data and unverified claims
5. **Cross-sell / Exit Capture** — check for links to alternative offerings

### Market Context

- WhatsApp is the primary conversion channel in Malaysian property pages; forms are secondary
- Every section should either build desire or capture the lead — purely decorative sections are a friction risk
- Mobile sticky bar (fixed bottom Call/WhatsApp) is the single highest-impact mobile conversion element

**Read:** `reference/checklist-cta.md`
**Read:** `reference/checklist-mobile.md`
**Read:** `reference/checklist-content.md`

## Workflow

### Phase 1: Discover & Map

1. Glob PROJECT_DIR for page source files
2. Read main entry file(s) to identify all sections in render order
3. Build a Funnel Flow Map: `[Section Name] — [type: content|CTA|social-proof|cross-sell]`

### Phase 2: CTA Analysis

1. Grep for button text, anchor text, and CTA labels across all source files
2. Identify unique CTA texts — flag if >60% share the same wording pattern
3. Grep for tracking URLs (wa.link, bit.ly, UTM params) — flag if all CTAs share one URL
4. Check nav bar for a persistent conversion button (always visible on scroll)

### Phase 3: Mobile & Structural Checks

1. Grep for `fixed`, `sticky`, `position-fixed`, `bottom-0` or equivalent classes — identifies sticky bars
2. Grep for floating WhatsApp button patterns
3. Check that CTA buttons are not inside containers that collapse on mobile

### Phase 4: Content Accuracy

1. Scan for placeholder patterns: `+60123456789`, `example@`, `yourdomain`, `lorem`
2. Scan for unverified stat patterns: `\d+\+?\s*(years|customers|units|reviews)` without a source attribute
3. Flag legal/factual claims (Freehold, GreenBuildingIndex, award names) that lack a citation

### Phase 5: Report

Produce the full audit report following the structure in the Report section below.

## Report

Output a structured markdown report with these sections:

**Funnel Flow Map**
Table of sections in render order with type tag and CTA presence flag.

**CTA Analysis**
- Total CTA count and unique text variants
- Verdict: Good variety / Repetitive (flag if <3 unique texts for >5 CTAs)
- Tracking URL variety: list unique tracked URLs; flag if all CTAs share one destination
- Nav conversion button: Present / Missing

**Mobile Conversion Check**
- Sticky bar: Present / Missing (critical gap if missing)
- Floating WhatsApp: Present / Missing
- Responsive CTA buttons: Pass / Review needed

**Cross-sell / Exit Capture**
- Present / Missing — note linked alternative offering if found

**Content Accuracy Flags**
Bullet list of detected placeholders or unverified claims with file:line references.

**Recommendations (Priority Order)**
Numbered list ordered by estimated conversion impact, highest first. Each item: what to fix and why it matters to conversion.

## Supporting Files

- `reference/checklist-cta.md` — CTA variety and tracking URL audit rules
- `reference/checklist-mobile.md` — Mobile conversion element detection rules
- `reference/checklist-content.md` — Content accuracy and placeholder detection rules
