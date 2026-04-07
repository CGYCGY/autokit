# Phase 4: Pages & Components

## Goal

Recreate WP pages as Astro components preserving exact section order and CTA funnel structure.

## Steps

### 1. Map Elementor Sections → Astro Components

For each page in `pages` from wp-audit:
1. Retrieve the `section_order` list for that page.
2. Create one Astro component per section in `src/components/`.
3. Render sections in the exact order from `section_order` — do not reorder or consolidate.

**Section naming convention:** `<SectionType><Index>.astro` or descriptive name from section heading.

### 2. CTA Section Rules

- NEVER merge adjacent CTA sections or replace multiple CTAs with one.
- Preserve the Value → CTA → Value → CTA alternating funnel pattern exactly.
- Use real `cta_urls` from wp-audit for every CTA link.
- CTA button text should VARY across the page — mix wording:
  - Value-focused: "Get Free Consultation", "See Results", "Learn More"
  - Action-focused: "WhatsApp Us Now", "Call Today", "Start Now"
- Do NOT repeat identical button text on consecutive CTAs.

### 3. Create CtaStrip Component

Create `src/components/CtaStrip.astro` as a reusable CTA banner:

```astro
---
interface Props {
  heading: string;
  subtext?: string;
  primaryHref: string;
  primaryLabel: string;
  secondaryHref?: string;
  secondaryLabel?: string;
}
---
```

- Use tracked CTA URLs (wa.link, tel:, etc.) from wp-audit.
- Accept heading and labels as props so each usage can vary the message.

### 4. Cross-sell Sections

- If wp-audit found `crosssell_sections`, recreate them with links to the other project URLs.
- Do not fabricate testimonials or project details not in the original data.

### 5. Build Index Page

Create `src/pages/index.astro`:
1. Import Layout.astro with page-specific title, description, canonical.
2. Import and render Navbar, all section components in order, Footer.
3. Import and render MobileStickyBar and FloatingWhatsApp.

### 6. Create 404 Page

Create `src/pages/404.astro`:
- Use Layout with title "Page Not Found".
- Simple message + link back to home.
- Include Navbar and Footer.

### 7. ContactForm React Island

If original WP site had a contact form:
- Create `src/components/ContactForm.tsx` as a React component.
- Use `client:visible` directive when embedding in Astro pages.
- Do NOT wrap in an additional `<section>` if the parent Astro component already provides the section wrapper.
