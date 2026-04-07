# Contact Data & CTA Analysis

Extract contact information from plugin configs and inventory CTAs.

## Step 1: Chaty Plugin Config

```bash
grep -o "'cht_social_phone','[^']*'" sqldump.sql
grep -o "'cht_social_whatsapp','[^']*'" sqldump.sql
grep "'chaty'" sqldump.sql | grep -o "'cht_[^']*','[^']*'" | head -20
```

Extract:
- Phone number from cht_social_phone
- WhatsApp number from cht_social_whatsapp
- Any other channel configs (Telegram, email, etc.)

## Step 2: Click-to-Chat (ht-whatsapp) Config

```bash
grep -o "'ht_ctc_chat_options','[^']*'" sqldump.sql
```

The value is a serialized array. Extract:
- `number` — WhatsApp phone number
- `message` — pre-filled message text (copy this verbatim into report)
- `style` — widget style if present

## Step 3: FluentForm Config

```bash
# Find all FluentForm option keys
grep "'fluentform\|'_fluentform\|'ff_" sqldump.sql | grep -o "'[^']*','[^']*'" | head -30

# Get notification email
grep "admin_email\|notification.*email" sqldump.sql | head -10
```

From wp_fluentform_forms table (if present):
```bash
grep "wp_fluentform_forms\|fluentform_forms" sqldump.sql | head -5
```

Extract:
- Notification email address(es)
- Form field labels and types (name, email, phone, message, etc.)
- Any select/radio options listed in form fields

## Step 4: CTA Inventory from Elementor

Using data collected in Phase 4 (Elementor Map):

- Count total button widgets
- List all unique link targets
- Categorize link types:
  - `wa.link/*` — WhatsApp tracking links
  - `tel:` — phone call links
  - `mailto:` — email links
  - Internal page links
  - External URLs (other)
- Count distinct tracking URL patterns (different wa.link slugs = different campaign tracking)

## Step 5: Cross-Reference Phone Numbers

Collect all phone numbers found:
- Chaty phone
- Chaty WhatsApp
- Click-to-Chat number
- Any tel: links from Elementor buttons
- Any phone numbers in form pre-filled messages

Compare and note: do all sources agree on the same number? Flag any discrepancies.

## Output

- Phone number(s) found (source: Chaty / Click-to-Chat / CTA buttons)
- WhatsApp number (confirm consistent across plugins)
- Pre-filled WhatsApp message (verbatim)
- Notification email for forms
- Form fields list
- CTA count and breakdown by type (WhatsApp / phone / email / other)
- Tracking URL list (all unique wa.link or other tracking URLs)
- Phone number cross-reference: consistent or discrepancies noted
