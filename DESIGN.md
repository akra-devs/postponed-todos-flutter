---
name: Reentry Atlas
description: A calm Korean task re-entry system built from midnight enamel, porcelain tickets, and tactile route markers.
colors:
  midnight: "#101A2D"
  midnight-deep: "#0A1324"
  midnight-raised: "#18243A"
  midnight-soft: "#223048"
  porcelain: "#F3F0E9"
  porcelain-low: "#E4DFD7"
  ink: "#15213A"
  ink-muted: "#6D7182"
  periwinkle: "#8290EA"
  periwinkle-deep: "#6574D8"
  periwinkle-soft: "#D9DEFF"
  mint: "#ADD8CA"
  mint-ink: "#477F76"
  route: "#E8E4DB"
  on-midnight: "#F5F3EE"
  on-midnight-muted: "#BEC7D5"
typography:
  brand-title: { fontSize: "31px", fontWeight: 800, lineHeight: 1.08, letterSpacing: "-0.9px" }
  hero-title: { fontSize: "28px", fontWeight: 700, lineHeight: 1.2, letterSpacing: "-0.4px" }
  section-title: { fontSize: "22px", fontWeight: 700, lineHeight: 1.25, letterSpacing: "-0.2px" }
  card-title: { fontSize: "18px", fontWeight: 700, lineHeight: 1.3 }
  body: { fontSize: "15px", fontWeight: 400, lineHeight: 1.5 }
  supporting: { fontSize: "13px", fontWeight: 400, lineHeight: 1.45 }
  emphasis-label: { fontSize: "14px", fontWeight: 700, lineHeight: 1.2 }
  label: { fontSize: "12px", fontWeight: 600, lineHeight: 1.2 }
rounded:
  sm: "14px"
  md: "16px"
  lg: "20px"
  xl: "24px"
  pill: "999px"
spacing:
  xxs: "4px"
  xs: "8px"
  sm: "12px"
  md: "16px"
  lg: "20px"
  xl: "24px"
components:
  porcelain-ticket: { backgroundColor: "{colors.porcelain}", textColor: "{colors.ink}", rounded: "{rounded.lg}", padding: "20px 22px 18px" }
  button-primary: { backgroundColor: "{colors.periwinkle-deep}", textColor: "{colors.porcelain}", typography: "{typography.emphasis-label}", rounded: "{rounded.pill}", height: "48px" }
  button-add: { backgroundColor: "{colors.periwinkle}", textColor: "{colors.porcelain}", typography: "{typography.card-title}", rounded: "{rounded.pill}", padding: "14px 24px", height: "68px" }
  chip-selected: { backgroundColor: "{colors.periwinkle-soft}", textColor: "{colors.periwinkle-deep}", typography: "{typography.label}", rounded: "{rounded.pill}" }
  navigation-mobile: { backgroundColor: "{colors.midnight-deep}", textColor: "{colors.on-midnight-muted}", typography: "{typography.label}", height: "72px" }
---

# Design System: Reentry Atlas

## Overview

**Creative North Star: “Reentry Atlas / A”**

Reentry Atlas is an operative, low-pressure world for approaching postponed work again. A full-bleed midnight enamel field carries tactile porcelain tickets, softly offset depth, and clay-like route nodes. Expression comes from material and geometry; task behavior and state remain literal.

The shipped experience is dark-only. Periwinkle marks active, postponing, and re-entry actions; mint marks holding and eligible revisit moments. Korean copy is calm, brief, and action-specific.

**Key characteristics:** midnight texture; warm porcelain tickets with side notches; dark navy ink; periwinkle/mint semantic accents; editorial responsive compositions; truthful route geometry; object-led empty states.

## Colors

- **Primary:** Periwinkle is the active/re-entry family. Use deep periwinkle for primary actions, the base tone for active nodes, and the soft tone for selected or tonal surfaces.
- **Secondary:** Mint is reserved for holding and revisit eligibility; mint ink provides readable labels on porcelain.
- **Neutrals:** Midnight variants layer the backdrop, navigation, and wells. Porcelain variants form tickets, rails, and shelf edges. Navy ink belongs on porcelain; on-midnight roles belong on the dark field.

**The Two-State Accent Rule.** Do not use mint as a generic success color or periwinkle as decoration. Each accent communicates its existing task meaning.

## Typography

Use Flutter’s platform-resolved Material sans; no custom font is bundled. Weight, compact tracking, and generous body leading create the voice. Brand headers use `brand-title`; screen sections use `section-title`; list and compact card titles use `card-title`; explanatory copy uses `body` or `supporting`.

At widths below 420 px, recommendation titles use the compact card-title role and the ticket occupies the full content width. Do not create narrow internal title columns or leave a lone Korean syllable on the last line; adjust copy or available width when QA exposes an orphan.

**The Calm Verb Rule.** Labels describe the immediate action—such as “다시 닿기”, “지금은 넘기기”, or “조금 더 쉬고 다시 보기”—without urgency, guilt, or invented promises.

## Layout

- The enamel backdrop is edge-to-edge; content stays inside safe areas and always remains vertically scrollable.
- Home content is capped at 640 px. Postponing and Holding use a 1080 px composition canvas inside the expanded shell, with their readable text and ticket widths constrained independently.
- Compact horizontal inset is 20 px. Home grows to 28 px at 560 px content width; list screens grow to 32 px at 600 px.
- At 760 px and above, Postponing becomes a filter-ticket / route-stage split and Holding becomes an editorial-lead / cabinet split. Below 760 px, both collapse into one ordered mobile column without removing controls or actions.
- Below 840 px, use the 72 px bottom navigation and keep add actions in page. At 840 px and above, replace it with `NavigationRail` and its leading add FAB; never stretch tickets to fill the desktop canvas.
- Spotlight tickets compact below 480 px. Their actions stack when available width falls below 310 px or text scale reaches 1.25. Journey labels gain two lines at text scale 1.35.

### QA viewport matrix

| Viewport | Surfaces | Required checks |
| --- | --- | --- |
| 390 × 844 | Home recommendations, revisit, Postponing, Holding | Full-width tickets, intact notches, no clipped actions, no orphaned Korean syllable, in-page add path. |
| 419 / 420 px wide | Home recommendation cards | Compact title role below 420; regular title role at 420; identical full ticket width. |
| 479 / 480 px wide | Home spotlight | Compact padding, icon, title, and height switch cleanly; secondary action remains reachable. |
| 839 / 840 px wide | App shell | Bottom navigation switches to rail without duplicating navigation or add controls. |
| 760 / 761 px wide | Postponing and Holding | Mobile column switches to the two-column editorial composition without clipping filters, shelf edges, or ticket notches. |
| 1280 × 900 | Postponing and Holding | Route stage and cabinet occupy the visual field while text columns stay readable; texture remains full bleed and tickets do not over-expand. |
| 390 × 844 at 1.35× text | Home journey and spotlight | Journey labels may wrap to two lines; actions stack; no overflow or hidden semantics. |

## Elevation & Depth

The backdrop composites the enamel asset at 88% opacity over midnight, then adds a 12% midnight veil. Tickets use black physical shadows with 0.58 alpha and elevations 6 (empty), 7 (list), 9 (default), or 13 (spotlight). Clay nodes use a soft 4–7 px downward offset with 8–12 px blur; only the emphasized periwinkle node adds an 18 px accent glow. The Holding shelf uses a stronger 11 px offset / 20 px blur to read as a containing object.

Motion reinforces placement: shell and section changes fade with a small vertical shift over 360 ms; card reveals use 360–430 ms with a subtle lift and scale. Respect `MediaQuery.disableAnimations` by rendering the final state immediately.

## Shapes

Use the documented radius scale for ordinary containers and pill controls. The signature ticket is not a rounded rectangle: its corner radius interpolates from 20 to 28 px by width, and two 15 px circular side notches are cut at the component’s declared vertical position (normally 0.50 or 0.56). Nodes and state marks are circular with a top-left radial highlight. Holding groups use a 28 px porcelain outer frame around a 24 px midnight well.

## Components

- **Backdrop and headers:** `ReentryAtlasBackdrop` owns the full-bleed material. `ReentryBrandHeader` and `ReentrySectionHeader` place light type directly on it; do not wrap them in generic cards.
- **Tickets:** `ReentryPorcelainTicket` is the reusable porcelain-to-porcelain-low diagonal surface. Recommendation tickets contain a state mark, title, optional note, divider, factual context, and wrapping actions. List tickets keep the same material at a 128 px minimum height; empty tickets use a 168 px minimum.
- **Spotlight:** `ReentryAtlasTicket` is the larger primary re-entry moment, with one dominant periwinkle action and a quiet text alternative. It uses a 220 px compact / 258 px regular minimum height.
- **Routes and nodes:** The home rail is navigation; the Postponing hero route is a section identity and the route inside its stage is an ordered task sequence. Aggregate summary counts are separate from both. Counts may annotate an existing filter or navigation destination, but never become a connected pseudo-lifecycle.
- **Holding cabinet:** A tall, arched porcelain frame and physical ledges contain list tickets in a midnight well. The cabinet silhouette remains visible even when empty so the section keeps its identity. Use mint only when a held item is actually eligible to revisit; ordinary held items remain neutral.
- **Controls and navigation:** Buttons keep a 48 px minimum target and pill shape. The in-page add control is a 68 px periwinkle gradient pill. Navigation always has three labeled destinations; selected icon, label, and indicator use periwinkle.

## Do's and Don'ts

### Do

- **Do** keep new color use inside the documented semantic palette; shared Atlas primitives come from `ReentryAtlasTokens`. Keep the enamel texture decorative and excluded from semantics.
- **Do** let visual state follow domain state and eligibility exactly; keep labels, icons, semantics, and available actions aligned.
- **Do** use route lines only for navigation or a real ordered sequence, and keep aggregate summary counts visually discrete.
- **Do** preserve 48 px minimum controls, safe-area behavior, wrapping actions, and reduced-motion behavior.

### Don't

- **Don't** invent progress, completion, urgency, or lifecycle transitions through color, copy, connected counts, or decorative nodes.
- **Don't** replace porcelain tickets with generic flat cards, remove their side notches, or place dark-field text colors on porcelain.
- **Don't** add a compact-screen FAB, duplicate the add action, or stretch desktop content beyond its caps.
- **Don't** turn calm Korean guidance into deadlines, guilt, or vague promotional language.
