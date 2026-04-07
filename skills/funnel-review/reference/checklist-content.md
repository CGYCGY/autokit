# Content Accuracy Checklist

## Placeholder Data Detection

Grep for these patterns — any match is a flag:

| Pattern | Meaning |
|---|---|
| `+60123456789` | Placeholder Malaysian phone number |
| `01[2-9]3456789` | Generic placeholder mobile number |
| `example@` | Placeholder email |
| `yourdomain` | Placeholder domain |
| `lorem ipsum` | Unfilled copy placeholder |
| `[INSERT` | Unreplaced template variable |
| `YOUR_` | Unfilled template field |
| `placeholder` (as visible text) | Forgotten HTML placeholder attribute leaking into UI |

Any match: report exact location (file:line) and instruct to replace before launch.

## Unverified Statistics

Grep pattern: `\d+\+?\s*(years|customers|units|projects|reviews|families|homes)`

**Examples that need a source:**
- "15+ years experience" — source? (company founding date)
- "10,000+ happy customers" — source? (CRM data, testimonial platform)
- "500 units sold" — source? (developer press release, NAPIC data)

**Rule:** If the stat cannot be verified from a public source or internal data cited on the page, flag it as fabricated or unverified.

**Exception:** Testimonials attributed to a named person with a photo are self-sourcing — do not flag.

## Unverified Property Claims

Flag these claim types unless accompanied by an in-page citation:

- **Tenure claims**: "Freehold" — must match land title; if not verifiable from source file, flag
- **Green certifications**: "GreenBuildingIndex Certified", "LEED Certified" — check for certification logo or official link
- **Award claims**: "Best Developer 2023", "PropertyGuru Award Winner" — must have award year and issuing body
- **Location proximity**: "5 minutes to KLCC" — flag if no map source or if distance is implausibly short
- **Price claims**: "From RM 4xx,xxx" — flag if no price list or developer price sheet is linked

## Social Proof Audit

Check for social proof elements and assess credibility:

**Present and credible:**
- Named testimonials with photo, unit type, and purchase year
- Star ratings linked to a third-party platform (Google, PropertyGuru)
- Press coverage with publication name and date

**Present but weak (note, do not block):**
- Anonymous testimonials ("Happy Buyer, KL")
- Generic star ratings with no review count
- Logo wall with no attribution or dates

**Missing entirely (flag):**
- No testimonials, ratings, or press mentions on a page targeting purchase decisions
- No social proof between first and last CTA strip

## Cross-sell / Exit Capture

Check for links or sections pointing to alternative projects or property types.

**What to look for:**
- "Explore our other projects" section
- Links to sister development pages
- "Looking for something different?" with category links (landed, commercial, affordable)

**Why it matters:** A buyer who does not convert on this project may convert on a sister project — without a cross-sell, they leave with zero attribution. Cross-sell retains the lead within the developer's ecosystem.

**Flag:** No cross-sell or alternative offering link found anywhere on the page.
