# Phase 3: Layout & SEO

## Goal

Create the base Layout.astro with full SEO, GTM, and navigation components using real data from wp-audit.

## Steps

### 1. Create src/layouts/Layout.astro

Props interface:
- `title: string`
- `description: string`
- `canonical?: string` (defaults to `Astro.url.href`)
- `robots?: string` (defaults to `"index, follow"`)
- `ogImage?: string` (absolute URL)

Required elements in `<head>`:

**Basic SEO**
```html
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>{title}</title>
<meta name="description" content={description} />
<link rel="canonical" href={canonical ?? Astro.url.href} />
<meta name="robots" content={robots ?? "index, follow"} />
```

**Open Graph** (all URLs must be absolute — use site_domain prefix)
```html
<meta property="og:type" content="website" />
<meta property="og:url" content={canonical ?? Astro.url.href} />
<meta property="og:title" content={title} />
<meta property="og:description" content={description} />
<meta property="og:image" content={ogImage ?? `${SITE_DOMAIN}/og-default.jpg`} />
```

**Twitter Card**
```html
<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:title" content={title} />
<meta name="twitter:description" content={description} />
<meta name="twitter:image" content={ogImage ?? `${SITE_DOMAIN}/og-default.jpg`} />
```

**JSON-LD** (LocalBusiness schema — use real contact data from wp-audit)
```html
<script type="application/ld+json" set:html={JSON.stringify({
  "@context": "https://schema.org",
  "@type": "LocalBusiness",
  "name": SITE_NAME,
  "url": SITE_DOMAIN,
  "telephone": PHONE,
  "email": EMAIL,
})} />
```

**GTM** (use real GTM_ID from wp-audit)
```html
<script>
  // GTM head snippet — replace GTM_ID with real value
</script>
```
Also add GTM noscript iframe at start of `<body>`.

**CSS**
```html
<link rel="stylesheet" href="/src/styles/global.css" />
```
Or import via frontmatter: `import '../styles/global.css'`

**Favicon**
```html
<link rel="icon" type="image/svg+xml" href="/favicon.svg" />
```

### 2. Create src/components/Navbar.astro

- Use real `nav_items` from wp-audit (label + href pairs).
- Include site name/logo in left.
- Mobile-responsive hamburger menu using Tailwind.
- Highlight active route with `Astro.url.pathname` comparison.

### 3. Create src/components/Footer.astro

- Real phone, email, WhatsApp from wp-audit.
- Nav links (same as Navbar).
- Copyright with site name and current year.

### 4. Create src/components/MobileStickyBar.astro

- Fixed bottom bar on mobile only (`md:hidden`).
- Two buttons: Call (tel: link with real phone) and WhatsApp (real wa.link URL).

### 5. Create src/components/FloatingWhatsApp.astro

- Fixed position bottom-right, visible on all screen sizes.
- Links to real `whatsapp_url` from wp-audit.
- WhatsApp icon (SVG or emoji fallback).
