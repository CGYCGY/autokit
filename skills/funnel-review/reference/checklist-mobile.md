# Mobile Conversion Checklist

## Mobile Sticky Bar (Critical Element)

The mobile sticky bar is the single highest-impact conversion element on mobile property pages.

**Detection patterns (grep for any):**
- CSS: `position: fixed`, `position:fixed`, `bottom: 0`, `bottom:0`
- Tailwind: `fixed bottom-0`, `fixed inset-x-0 bottom-0`
- Class names: `sticky-bar`, `mobile-bar`, `bottom-bar`, `cta-bar`
- Astro/React: check component names like `MobileBar`, `StickyFooter`, `BottomCTA`

**What to check:**
- Contains at least one of: phone call link (`tel:`), WhatsApp link (`wa.me` or `wa.link`)
- Applies `md:hidden` or equivalent to hide on desktop (not a desktop element)
- Not obscured by other fixed elements (cookie banner, chat widget z-index conflict)

**Flag:** No mobile sticky bar found — this is a critical conversion gap for mobile-first markets.

## Floating WhatsApp Button

**Detection patterns:**
- `wa.me/`, `wa.link/`, `api.whatsapp.com/send`
- Class names: `whatsapp-float`, `floating-whatsapp`, `fab-whatsapp`
- Inline style: `position: fixed; bottom:`, often paired with a WhatsApp icon SVG or `fab fa-whatsapp`

**What to check:**
- Button is fixed-position (not inline in content)
- Appears on all scroll positions (not conditionally hidden)
- Does not conflict with mobile sticky bar positioning (both can coexist if z-index managed)

**Flag:** Floating WhatsApp absent and no sticky bar — double gap; mobile user has no passive conversion path.

## Responsive CTA Buttons

**Check for:**
- CTA buttons inside flex/grid containers that collapse correctly on small viewports
- Button text is not truncated at mobile widths (check for `overflow: hidden` on button containers)
- Touch target size: buttons should be at least 44px height (check `min-h-[44px]`, `py-3` or equivalent)
- CTA strips using `grid-cols-2` or `flex-wrap` so buttons don't overflow on narrow screens

**Flag:** CTA buttons wrapped in a fixed-width container with no responsive override — renders broken on mobile.

## Form Placement (Secondary Capture)

Even in WhatsApp-first markets, a backup form prevents zero-lead sessions when WhatsApp is unavailable.

**Detection patterns:**
- `<form`, `<Form`, form component names: `ContactForm`, `EnquiryForm`, `LeadForm`
- Input types: `type="tel"`, `type="email"`, `type="text"` inside a form

**Flag:** No form element found anywhere on the page — all-or-nothing on WhatsApp conversion; no fallback capture.
