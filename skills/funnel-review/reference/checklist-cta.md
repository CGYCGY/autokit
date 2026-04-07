# CTA Audit Checklist

## CTA Count & Placement

- Count total interactive CTAs (buttons, anchor links that trigger conversion actions)
- Map CTA positions relative to content sections
- Ideal pattern: Value section → CTA strip → Value section → CTA strip (AIDA flow)
- Flag: two or more consecutive value sections with no CTA between them
- Flag: page ends with content but no closing CTA above the fold on scroll

## CTA Text Variety

Collect all CTA button labels and anchor texts.

**Grade: Good** — 3+ distinct message types present:
- Value-access CTAs: "Download E-Brochure", "Get Price List", "Request Floor Plan"
- Action-intent CTAs: "WhatsApp Now", "Call Agent", "Book Site Visit"
- Soft-commitment CTAs: "I Want More Info", "Find Out More", "Enquire Now"

**Grade: Repetitive** — flag when:
- >60% of CTAs share the same verb ("WhatsApp Now" repeated on every strip)
- All CTAs use imperative-only phrasing (no value-access variant present)
- No distinction between early-funnel (curious) and late-funnel (ready-to-buy) buyer psychology

**Why variety matters:** Banner blindness sets in when the same CTA text repeats. Different buyers are at different stages — a curious researcher needs a brochure CTA; a ready buyer needs a direct-call CTA.

## Tracking URL Variety

Grep patterns: `wa\.link/`, `bit\.ly/`, `utm_source=`, `utm_campaign=`, `fbclid`, `gclid`

- List every unique tracked URL found across all CTAs
- **Flag:** All CTA sections point to a single tracking URL — attribution is blind; cannot measure which section converts best
- **Ideal:** Each major CTA strip uses a distinct tracking URL so conversion source is attributable
- Note: WhatsApp links using the same phone number but different `wa.link` shortlinks count as distinct (good)

## Nav Conversion Button

- Check `<nav>`, `<header>`, or fixed top-bar elements for a CTA button
- The nav button must be visible on scroll (not hidden behind a hamburger on desktop)
- **Flag:** Nav has only logo + menu links with no conversion action
- **Flag:** Nav CTA exists but uses same URL as all other CTAs (missed attribution opportunity)
