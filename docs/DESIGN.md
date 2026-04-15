# CalmSurface — Design System

> **Calm surfaces, continuous curves, quiet typography.**
> A portable design system fusing Apple Liquid Glass, Base44, Raycast, and Nothing.

**Version** 0.1 · **Platforms** Flutter, Web (CSS) · **Mode priority** Light first, Dark second

---

## Table of Contents

- [0. Manifesto](#0-manifesto)
- [1. Foundations](#1-foundations)
  - [1.1 Color](#11-color)
  - [1.2 Typography](#12-typography)
  - [1.3 Space](#13-space)
  - [1.4 Radius & Shape](#14-radius--shape)
  - [1.5 Elevation & Depth](#15-elevation--depth)
  - [1.6 Opacity](#16-opacity)
  - [1.7 Motion](#17-motion)
- [2. Signature Patterns](#2-signature-patterns)
- [3. Components](#3-components)
- [4. Iconography](#4-iconography)
- [5. Platform Mapping](#5-platform-mapping)
- [6. Anti-patterns IA](#6-anti-patterns-ia)
- [7. Do / Don't Gallery](#7-do--dont-gallery)
- [8. CalmSurface-Ready Checklist](#8-calmsurface-ready-checklist)

---

## 0. Manifesto

CalmSurface is a reaction against generic AI-product aesthetics: the violet-to-blue gradient on white, the neon glow under every CTA, Inter set in bold, isometric illustrations, sparkle-emoji celebrations.

We borrow from four places. **Apple** teaches us that depth comes from continuous curves (squircle), backdrop blur, and deference to content — a surface should almost disappear. **Base44** teaches us to frame the product with a quiet ambient gradient — a halo instead of a hero video. **Raycast** teaches precision: monospace for numbers, tight density, zero decoration. **Nothing** teaches restraint: monochrome, typography as hierarchy, the dot-matrix as one permitted moment of drama.

The three non-negotiable rules:

1. **Depth by transparency, not shadow.** We stack translucent layers with backdrop blur. Shadows live at or below 6% opacity — they exist but are never felt.
2. **Continuous curvature.** Every surface above 16px uses squircle with `cornerSmoothing ≥ 0.5`. The bigger the surface, the smoother the corner. Standard `border-radius` is forbidden on large surfaces.
3. **Typography carries the hierarchy.** Maximum two font weights per screen. Bold is never the default. Display sizes get negative tracking (-1% to -3%). The difference between a title and a body is size and weight, not colour.

Everything else in this document derives from those three rules.

---

## 1. Foundations

### 1.1 Color

CalmSurface uses a cool-warm neutral scale, a minimal set of semantic colors, four named gradients, and three accent colors. There is no brand blue or brand purple — the "colour" of the system is in the gradients, not in the accents.

#### Neutral scale — Light

Cool-warm greys biased toward cream. 10 steps, from `canvas` (almost white) to `ink` (never pure black — pure black is reserved for primary titles only).

| Token | Hex | Usage |
|-------|-----|-------|
| `neutral.0` canvas | `#FBF8F3` | Root background (under Aurora) |
| `neutral.1` surface | `#F8F4ED` | Surface cream |
| `neutral.2` | `#EFE9E0` | Subtle fill, dividers |
| `neutral.3` | `#E2DBCE` | Border strong, disabled bg |
| `neutral.4` | `#C9C1B3` | Icon muted |
| `neutral.5` | `#9A9286` | Placeholder, metadata |
| `neutral.6` | `#6C645A` | Text secondary |
| `neutral.7` | `#433C33` | Text body alt |
| `neutral.8` | `#1F1A13` | Text body |
| `neutral.9` ink | `#0A0A0A` | Display titles only |

#### Neutral scale — Dark

The dark palette is NOT the light palette inverted. It is a warm dusk — deep browns and slates, never pure black.

| Token | Hex | Usage |
|-------|-----|-------|
| `neutral.0` canvas | `#140C05` | Root background |
| `neutral.1` surface | `#1E1610` | Surface warm dark |
| `neutral.2` | `#261B10` | Subtle fill |
| `neutral.3` | `#2E2318` | Border strong |
| `neutral.4` | `#4A3F33` | Icon muted |
| `neutral.5` | `#7A6D5E` | Placeholder |
| `neutral.6` | `#A69684` | Text secondary |
| `neutral.7` | `#D6BEA0` | Text body alt |
| `neutral.8` | `#F0E3D0` | Text body |
| `neutral.9` | `#FFF3E1` | Display titles |

#### Semantic tokens

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `semantic.success` | `#16A34A` | `#4ADE80` | Confirmation, XP gain |
| `semantic.warning` | `#F59E0B` | `#FBBF24` | Caution, amber states |
| `semantic.danger` | `#DC2626` | `#F87171` | Destructive, errors |
| `semantic.info` | `#6C645A` | `#A69684` | Neutral informational (uses `neutral.6`) |

**Rule:** `info` is never blue. Use the warm neutral. An AI-slop gradient blue pill is the single most recognizable cliché and we refuse it.

#### Glass tints

Surfaces are translucent. Each layer has a prescribed opacity and blur.

| Tint | Light hex | Dark hex | When |
|------|-----------|----------|------|
| `glass.strong` | `#FFFFFF` @ 92% | `#1F170E` @ 94% | Nav bars, sticky headers, modals |
| `glass.medium` | `#FFFFFF` @ 85% | `#261B10` @ 80% | Cards, sheets |
| `glass.soft` | `#FFFFFF` @ 70% | `#2D2014` @ 60% | Secondary surfaces over busy bg |
| `glass.border` | `#FFFFFF` @ 20% | `#FFD9AE` @ 20% | 1px border on glass |
| `glass.border-warm` | `#EA580C` @ 16% | `#EA580C` @ 20% | Warm-bias border on Beedle |

#### Accents

Only three. Reserve them.

| Accent | Hex | Usage |
|--------|-----|-------|
| `accent.mint` | `#DEEFA0` | Primary CTA (web / marketing surfaces). **Pale lime-green — anti-purple.** |
| `accent.ember` | `#FF6B2E` | Brand orange. Beedle primary. Logo moments. |
| `accent.digital` | `#FF6B2E` | Same hex as ember, but used with the Doto font only. |

#### Named gradients

Gradients are first-class tokens. They are named, not described. Consumers reference the token, never the stops.

##### Aurora Cool — the Base44-faithful halo

For portable / web / non-Beedle projects. Vertical, ambient frame around the viewport.

| Stop | Position | Hex |
|------|----------|-----|
| sky | 0% | `#C5E0EE` |
| cream | 50% | `#E8E4DE` |
| peach | 100% | `#FFE0C2` |

##### Aurora Warm — the Beedle variant (no blue)

For Beedle and any project where blue/violet is forbidden. Same halo behaviour, warmer stops.

| Stop | Position | Hex |
|------|----------|-----|
| cream | 0% | `#FFFBF5` |
| peach pale | 40% | `#FFE9D0` |
| peach | 75% | `#FFDBB0` |
| sunset | 100% | `#FFC48A` |

##### Ember — feature-card mesh accent

Radial mesh for highlighted feature cards. Used sparingly — maximum one per screen.

```
radial-gradient at 30% 40%,
  #FF5A1F 0%,
  #FF8C42 40%,
  #FFB067 80%,
  transparent 100%
```

##### Mist — neutral cool gradient

For secondary surfaces that need a subtle lift without warmth.

| Stop | Position | Hex |
|------|----------|-----|
| grey | 0% | `#F0F2F4` |
| soft grey | 100% | `#DDE2E7` |

##### Dusk — dark hero

For dark-mode hero sections, avoids pure black. Vertical.

| Stop | Position | Hex |
|------|----------|-----|
| surface | 0% | `#241810` |
| mid | 50% | `#2E1F11` |
| deep | 100% | `#140C05` |

#### Accessibility

All body text must meet WCAG AA: 4.5:1 for text ≤ 18px / 600, 3:1 for larger. Secondary text on `glass.medium` is checked against the worst-case backdrop. When Ember or Digital accents carry text, the text is `neutral.9` (never white on orange).

---

### 1.2 Typography

Three families. No more.

| Role | Family | License | Why |
|------|--------|---------|-----|
| Body / UI | **Hanken Grotesk** | OFL | Anti-Inter. More organic, rounder terminals, humanist warmth. Free on Google Fonts. |
| Mono / numbers | **Geist Mono** | OFL | Vercel. Sharp, Raycast-adjacent, excellent for data. |
| Display signature | **Doto** | OFL | Official dot-matrix typeface on Google Fonts. Ndot substitute. Single-use per screen. |

**Rule:** Doto never sets body text. It is reserved for one moment per screen — a logo lockup, a digital readout, an empty-state headline. Treat it as a photograph, not a paragraph.

#### Type scale

10 steps. Use `rem` on web (1rem = 16px), raw px in Flutter.

| Token | Size (px / rem) | Weight | Line-height | Tracking | Usage |
|-------|-----------------|--------|-------------|----------|-------|
| `display.xl` | 56 / 3.5 | 700 | 1.05 | -3% | Hero title |
| `display.lg` | 48 / 3.0 | 700 | 1.1 | -2.4% | Section opener |
| `display.md` | 36 / 2.25 | 700 | 1.15 | -1.6% | Feature title |
| `display.sm` | 28 / 1.75 | 700 | 1.2 | -1% | Card title large |
| `headline.lg` | 24 / 1.5 | 600 | 1.25 | -0.5% | Screen title |
| `headline.md` | 20 / 1.25 | 600 | 1.3 | -0.3% | Card title |
| `headline.sm` | 18 / 1.125 | 600 | 1.35 | 0 | List group |
| `title` | 17 / 1.0625 | 600 | 1.4 | 0 | iOS-like title |
| `body.lg` | 16 / 1.0 | 400 | 1.5 | 0 | Paragraph |
| `body.md` | 14 / 0.875 | 400 | 1.5 | 0 | Compact text |
| `body.sm` | 12 / 0.75 | 400 | 1.45 | +1% | Metadata |
| `label.lg` | 14 / 0.875 | 600 | 1.3 | +1% | Button, tag |
| `label.md` | 12 / 0.75 | 600 | 1.3 | +2% | Small button |
| `label.sm` | 11 / 0.6875 | 500 | 1.25 | +3% | All-caps eyebrow |

**Tracking convention.** Display shrinks (negative), body stays neutral, labels stretch (positive). This mimics Apple SF Pro optical sizing.

**Weight convention.** You get two weights per screen. Pick: `400 + 600` (most cases), `400 + 700` (hero screens only). Never `600 + 700` — not enough contrast. Never start a screen in `700`.

**Uppercase convention.** `label.sm` is the only size that may be uppercased (with `+3%` tracking). Never uppercase body text.

---

### 1.3 Space

4pt-based scale. No exceptions.

| Token | Value (px) | Common use |
|-------|-----------|-----------|
| `space.0` | 0 | Reset |
| `space.1` | 2 | Hairline |
| `space.2` | 4 | Icon-label gap |
| `space.3` | 8 | Inline chip gap |
| `space.4` | 12 | Compact padding |
| `space.5` | 16 | Default gap |
| `space.6` | 20 | Card padding |
| `space.7` | 24 | Section gap |
| `space.8` | 32 | Between cards |
| `space.9` | 40 | Large section gap |
| `space.10` | 56 | Hero padding |
| `space.11` | 72 | Page padding top |
| `space.12` | 96 | Rare, hero hero |

#### Density modes

Two density profiles. Pick one per screen.

- **Airy** — card padding 20-24, gap 16-24. Default for marketing, onboarding, empty states, paywalls.
- **Compact** — card padding 12-16, gap 8-12. For dense lists, search results, settings.

Never mix densities within a single vertical flow.

---

### 1.4 Radius & Shape

Squircle is the default. Always use `cornerSmoothing ≥ 0.5` on any surface above 16px. Flutter: `figma_squircle`. Web: SVG clip-path or the [`superellipse`](https://css-tricks.com/super-ellipse-css/) technique when available.

#### Radius scale

| Token | Value | cornerSmoothing | Usage |
|-------|-------|-----------------|-------|
| `radius.xs` | 4 | 0 (standard OK) | Checkbox, tiny chip |
| `radius.sm` | 8 | 0 (standard OK) | Input inner elements |
| `radius.md` | 12 | 0.4 | Small card, dropdown item |
| `radius.lg` | 16 | 0.5 | Standard card |
| `radius.xl` | 20 | 0.55 | Input field |
| `radius.2xl` | 28 | 0.6 | GlassCard default (Beedle) |
| `radius.3xl` | 40 | 0.7 | Bottom sheet, modal |
| `radius.pill` | 999 | n/a | Pills, chips, CTAs |

**Rule "bigger = smoother":** if the surface is large, increase `cornerSmoothing`. A 40px radius with smoothing 0.3 looks AI-slop. With 0.7 it reads as iOS-native.

**Pills cap at 24px tall.** Beyond that, use a squircle card, not a pill.

**liquid_glass_renderer.** For Beedle, use [`liquid_glass_renderer`](https://pub.dev/packages/liquid_glass_renderer) for authentic Apple Liquid Glass rendering — preferred over `BackdropFilter` when the surface has dynamic content behind it.

---

### 1.5 Elevation & Depth

We do not use CSS box-shadow as a primary depth signal. We layer translucent surfaces with different blurs, each sitting on a prescribed layer.

#### Layer model

| Layer | z-order | Blur σ | Opacity | Border | Shadow |
|-------|---------|--------|---------|--------|--------|
| `base` | 0 | 0 | opaque | none | none |
| `surface` | 1 | 8 | 85% | 1px `glass.border` | `shadow.sm` |
| `floating` | 2 | 16 | 85% | 1px `glass.border` | `shadow.md` |
| `overlay` | 3 | 24 | 70% | 1px `glass.border` | `shadow.lg` |
| `modal` | 4 | 40 | 92% | 1px `glass.border` | `shadow.lg` |

#### Shadow tokens (whisper-level)

Use sparingly. Maximum opacity 6%.

| Token | Value |
|-------|-------|
| `shadow.sm` | `0 1px 4px rgba(0,0,0,0.04)` |
| `shadow.md` | `0 8px 24px rgba(0,0,0,0.05)` |
| `shadow.lg` | `0 24px 64px rgba(0,0,0,0.06)` |

**Rule:** if you find yourself reaching for `0 4px 6px rgba(0,0,0,0.1)`, you're in AI-slop territory. Step back, add a 1px border and increase the blur σ instead.

---

### 1.6 Opacity

Seven steps. Nothing in-between.

| Token | Value |
|-------|-------|
| `opacity.4` | 4% |
| `opacity.8` | 8% |
| `opacity.12` | 12% |
| `opacity.24` | 24% |
| `opacity.48` | 48% |
| `opacity.72` | 72% |
| `opacity.92` | 92% |

**Canonical uses.** Hairline borders: 12%. Disabled state: 48%. Glass surface: 72-92%. Scrim under modal: 24% (never 50%).

---

### 1.7 Motion

Motion is atmospheric, not decorative. One expressive moment per screen, the rest quick and quiet.

#### Easings

| Token | cubic-bezier | Flutter Curves | Use |
|-------|-------------|----------------|-----|
| `ease.emphasized` | `(0.3, 0, 0, 1)` | `Curves.easeOutCubic` (approx) | Expressive moments, page transitions |
| `ease.standard` | `(0.2, 0, 0, 1)` | `Curves.easeOutQuart` (approx) | Default state changes |
| `ease.soft` | `(0.4, 0, 0.2, 1)` | `Curves.easeInOutCubic` | Gentle fades, glass ops |
| `ease.spring` | spring | `SpringDescription(mass: 1, stiffness: 180, damping: 20)` | Toggle, bottom sheet |

#### Durations

| Token | Value | Use |
|-------|-------|-----|
| `duration.instant` | 80ms | Hover tint |
| `duration.quick` | 160ms | Button press, chip toggle |
| `duration.standard` | 240ms | Expand/collapse, sheet dismiss |
| `duration.expressive` | 400ms | Page reveal, stagger parent |
| `duration.grand` | 640ms | First-paint hero stagger |

#### Rules

- **One `grand` animation per screen.** Rest is `quick` or `standard`.
- **Stagger 40-60ms between list items** on reveal. Never 100ms+.
- **No pulse / shimmer / bounce** on CTAs at rest. Motion only on interaction or scroll.
- **Reduce-motion respect.** On `prefers-reduced-motion`, all durations collapse to `instant`, no stagger.

---

## 2. Signature Patterns

Five patterns that make a screen read "CalmSurface". Use at least one per major surface.

### 2.1 Aurora Frame

The page has a quiet halo around the content. Gradient is the frame, not the focus.

**Anatomy.** A full-viewport gradient background (Aurora Cool or Aurora Warm), optionally with a subtle 2-4px gradient border visible around the content block. The content sits on `neutral.0` with a small inner margin so the halo breathes.

**Flutter.**

```dart
Stack(
  children: [
    Container(decoration: BoxDecoration(gradient: AppGradients.auroraWarm)),
    SafeArea(child: child),
  ],
);
```

**CSS.**

```css
body {
  background: linear-gradient(180deg, #FFFBF5 0%, #FFE9D0 40%, #FFDBB0 75%, #FFC48A 100%);
  min-height: 100vh;
}
```

### 2.2 Liquid Glass Card

Blur + squircle + 1px border + optional gradient tint. The core surface of the system.

**Default specs (Beedle):** radius 28, cornerSmoothing 0.6, blur σ 20, fill `glass.medium`, border `glass.border`, shadow `shadow.lg` (4% black, 24px offset, 64px blur).

On iOS 26+, swap `BackdropFilter` for `LiquidGlass` from `liquid_glass_renderer`. On older OS and web, fall back to `BackdropFilter` / `backdrop-filter: blur()` with a static opacity bump.

### 2.3 Ember Accent

A single feature card per section gets the Ember radial mesh. Always contains a floating secondary card (glass, white) offset inside it — the mesh is a stage, the glass card is the subject.

**When.** Landing page "what it does" block. Paywall top tier. Onboarding final slide. Never more than one per screen.

### 2.4 Digital Display

A logo lockup, a streak counter, or an empty-state headline rendered in Doto at `display.lg` or `display.xl`, colour `accent.digital` (`#FF6B2E`) on light, with a 4-6% dark backing rectangle optional.

**Sizing.** Minimum 32px for legibility. Doto has low letter distinction — never use for multi-word strings under 24px.

### 2.5 Mint CTA

The primary marketing CTA. Fully rounded pill, `accent.mint` fill, `neutral.9` text, no shadow, no gradient. Hover / press: `neutral.9` fill, `accent.mint` text (colour swap), `duration.quick` with `ease.standard`.

For in-app primary actions in Beedle, the equivalent is a `neutral.9` fill (Black CTA) — see component spec below.

---

## 3. Components

### Button

Five variants. No others.

| Variant | Fill | Text | Border | Use |
|---------|------|------|--------|-----|
| `primary.mint` | `#DEEFA0` | `#0A0A0A` | none | Web / marketing primary |
| `primary.black` | `#0A0A0A` | `#FFFFFF` | none | In-app primary, Beedle default |
| `secondary.outline` | transparent | `#0A0A0A` | 1px `neutral.3` | Secondary actions |
| `ghost` | transparent | `neutral.7` | none | Tertiary, dense contexts |
| `icon` | transparent | `neutral.7` | none | Icon-only, 32-40px square |

**Specs.** Height 40 (default), 32 (compact), 48 (hero). Padding horizontal = `space.6` (20px). Radius = pill (< 48px height). Text: `label.lg`. Press scale: `0.98`, `duration.quick`, `ease.standard`. No ripple, no glow.

**Forbidden.** Gradient fill on primary. Shadow on primary at rest. Icon + text with more than 8px gap. Uppercase text on buttons.

### Input / TextField

Squircle radius 20 (`radius.xl`, smoothing 0.55). Fill `glass.soft` (or `neutral.1` on `base` layer). Border 1px `neutral.3`. Focus border 2px `neutral.8`, no glow, no shadow. Placeholder `neutral.5`. Text `body.lg`. Padding vertical 12, horizontal 16.

**Focus animation.** Border width 1 → 2 over `duration.quick` with `ease.standard`. That is the only change. No colour lift, no inner glow, no outline offset.

### GlassCard

Already implemented at `lib/presentation/widgets/glass_card.dart`. Default specs (radius 28, smoothing 0.6, blur σ 20) are the canonical CalmSurface card. Padding default `EdgeInsets.all(20)` = `space.6`.

When tappable, use an `InkWell` with `customBorder` matching the `SmoothRectangleBorder` to ensure the ripple respects squircle edges.

### Pill / Chip

Height 28 (default) or 24 (compact). Radius `pill`. Padding horizontal 12 / 10. Text `label.md`. Fill `glass.soft` (inactive), `neutral.8` with `neutral.0` text (active), `accent.ember` with `neutral.0` text (branded active). Border `glass.border` on inactive.

**Segmented pills.** A row of pills where only one is active at a time. Inactive pills get `neutral.2` fill, active gets `neutral.9`. No gradient on active. 4px gap between pills.

### Bottom Sheet

Radius top-only 40 (`radius.3xl`, smoothing 0.7). Fill `glass.strong` with backdrop blur σ 24. Grab handle: 36×4 pill, `neutral.4`, 8px from top. Scrim under sheet: `neutral.9` @ 24% (never 50%). Animation: slide-up with `ease.emphasized` `duration.expressive`.

### Modal / Dialog

Used sparingly — prefer bottom sheet on mobile. Centered, radius 28, `glass.strong`, blur σ 40. Max width 420px on web. Scrim `neutral.9` @ 24%. Close button top-right, icon-only, ghost variant.

### AppBar / TopBar

Sticky, `glass.strong`, blur σ 16, border-bottom 1px `glass.border`. Height 52 (+ safe-area). Title centered iOS-style or leading Android-style — pick one per app. Aurora must be visible through the blurred bar.

### TabBar / Navigation (bottom)

Height 56 (+ safe-area). Fill `glass.strong`, blur σ 16, border-top 1px `glass.border`. 3-5 tabs, icon + `label.sm`. Active tab: icon filled + text `neutral.9`. Inactive: icon stroke + text `neutral.5`. No animated indicator bar. No background pill on active.

### List row

Two density modes:
- **Airy.** Height 72, padding vertical 16 / horizontal 20, gap 12. Leading icon/avatar 40×40.
- **Compact.** Height 48, padding 8 / 16, gap 8. Leading icon 24×24.

Title `title` or `body.lg`. Subtitle `body.sm` `neutral.6`. Trailing: chevron `neutral.4` 16px, or a pill. Divider `neutral.2` 1px, inset by leading content width.

### Progress

Two forms:

- **Linear continuous.** 4px height, `neutral.2` track, `neutral.9` fill. No gradient. Animated via width transition.
- **Segmented (Nothing-style).** Row of 8-12 pills, 4×12px each, 2px gap. Active segments `neutral.9`, inactive `neutral.2`. Fills one segment at a time.

### Toggle

Width 48, height 28, radius `pill`. Track `neutral.3` (off) / `neutral.9` (on). Knob 24×24, `neutral.0` fill, shadow `shadow.sm`. No gradient, no colour on "on" state (beyond neutral). Animation: knob translate + track colour, `duration.quick`, `ease.spring`.

### Empty state

Vertical stack, centered. Optional `Doto` headline at `display.md` in `accent.digital`. Body at `body.lg` `neutral.6` max-width 32ch. Single CTA (secondary outline). No illustration.

### Skeleton

`neutral.2` fill, opacity 100%. Shimmer: linear-gradient pass `neutral.2` → `neutral.1` → `neutral.2`, 1.2s cycle, `ease.soft`. Shimmer peak opacity 3%. Never shimmer on shimmer.

### Notification / Toast

Radius 20 (`radius.xl`, smoothing 0.55). Fill `glass.strong` blur σ 24. 1px border `glass.border`. Leading icon (Lucide) 20px in `neutral.8`. Title `label.lg`, body `body.md` `neutral.6`. Max width 360. Slide-in from bottom (mobile) or top-right (web), `ease.emphasized` `duration.standard`. Auto-dismiss 4s.

**Forbidden.** Saturated coloured fills. Red/green/amber backgrounds. The icon carries the semantic, not the surface.

### Badge

Three variants:
- `badge.neutral`: `neutral.2` fill, `neutral.8` text.
- `badge.ember`: `accent.ember` fill, `neutral.0` text.
- `badge.digital`: Doto font, `accent.digital` text, transparent fill, 4% `accent.digital` backing.

Size 20 tall, padding horizontal 6, radius `pill`, text `label.sm`.

---

## 4. Iconography

**Library:** [Lucide](https://lucide.dev). Free, MIT, cohesive stroke, huge coverage, anti-Material-generic.

**Stroke:** 1.5px. Rounded joins, rounded caps.

**Sizes:** 16 / 20 / 24 / 32. Pick one per screen density: 16 compact, 20 default, 24 airy, 32 hero.

**Colour:** inherits text colour. Never gradient. Never multicolor except when the icon is itself illustrative (flag, brand).

#### Emoji policy

- ❌ In navigation, tabs, buttons, page titles.
- ❌ As replacement for an icon ("✨ AI", "🚀 Launch").
- ✅ In user-generated content (notes, cards, chat).
- ✅ In reactions (if reactions are a first-class feature).

---

## 5. Platform Mapping

### 5.1 Flutter

#### pubspec.yaml additions

```yaml
dependencies:
  figma_squircle: ^0.5.3   # already installed on Beedle
  liquid_glass_renderer: ^0.2.0
  google_fonts: ^6.2.1

flutter:
  fonts:
    - family: HankenGrotesk
      fonts:
        - asset: assets/fonts/HankenGrotesk-Regular.ttf
        - asset: assets/fonts/HankenGrotesk-Medium.ttf
          weight: 500
        - asset: assets/fonts/HankenGrotesk-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/HankenGrotesk-Bold.ttf
          weight: 700
    - family: GeistMono
      fonts:
        - asset: assets/fonts/GeistMono-Regular.ttf
        - asset: assets/fonts/GeistMono-Medium.ttf
          weight: 500
    - family: Doto
      fonts:
        - asset: assets/fonts/Doto-Regular.ttf
        - asset: assets/fonts/Doto-Bold.ttf
          weight: 700
```

Self-hosting fonts is preferred over `google_fonts` runtime fetching for offline resilience.

#### Design tokens (Dart)

```dart
// lib/presentation/theme/calm_surface_tokens.dart
import 'package:flutter/material.dart';

abstract final class CalmColors {
  // Neutrals — light
  static const Color canvas = Color(0xFFFBF8F3);
  static const Color surface = Color(0xFFF8F4ED);
  static const Color neutral2 = Color(0xFFEFE9E0);
  static const Color neutral3 = Color(0xFFE2DBCE);
  static const Color neutral4 = Color(0xFFC9C1B3);
  static const Color neutral5 = Color(0xFF9A9286);
  static const Color neutral6 = Color(0xFF6C645A);
  static const Color neutral7 = Color(0xFF433C33);
  static const Color neutral8 = Color(0xFF1F1A13);
  static const Color ink = Color(0xFF0A0A0A);

  // Accents
  static const Color mint = Color(0xFFDEEFA0);
  static const Color ember = Color(0xFFFF6B2E);

  // Glass
  static const Color glassStrong = Color(0xEBFFFFFF);  // 92%
  static const Color glassMedium = Color(0xD9FFFFFF);  // 85%
  static const Color glassSoft = Color(0xB3FFFFFF);    // 70%
  static const Color glassBorder = Color(0x33FFFFFF);  // 20%

  // Semantic
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);
}

abstract final class CalmGradients {
  static const LinearGradient auroraWarm = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: <double>[0.0, 0.4, 0.75, 1.0],
    colors: <Color>[
      Color(0xFFFFFBF5),
      Color(0xFFFFE9D0),
      Color(0xFFFFDBB0),
      Color(0xFFFFC48A),
    ],
  );

  static const LinearGradient auroraCool = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: <double>[0.0, 0.5, 1.0],
    colors: <Color>[Color(0xFFC5E0EE), Color(0xFFE8E4DE), Color(0xFFFFE0C2)],
  );

  static const RadialGradient ember = RadialGradient(
    center: Alignment(-0.4, -0.2),
    radius: 1.2,
    colors: <Color>[Color(0xFFFF5A1F), Color(0xFFFF8C42), Color(0xFFFFB067), Color(0x00FFB067)],
    stops: <double>[0.0, 0.4, 0.8, 1.0],
  );

  static const LinearGradient dusk = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[Color(0xFF241810), Color(0xFF2E1F11), Color(0xFF140C05)],
  );
}

abstract final class CalmRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xl2 = 28;
  static const double xl3 = 40;
  static const double pill = 999;

  // Smoothing paired by radius
  static double smoothingFor(double r) {
    if (r <= 8) return 0;
    if (r <= 16) return 0.5;
    if (r <= 28) return 0.6;
    if (r <= 40) return 0.7;
    return 0.8;
  }
}

abstract final class CalmSpace {
  static const double s0 = 0;
  static const double s1 = 2;
  static const double s2 = 4;
  static const double s3 = 8;
  static const double s4 = 12;
  static const double s5 = 16;
  static const double s6 = 20;
  static const double s7 = 24;
  static const double s8 = 32;
  static const double s9 = 40;
  static const double s10 = 56;
  static const double s11 = 72;
  static const double s12 = 96;
}

abstract final class CalmDuration {
  static const Duration instant = Duration(milliseconds: 80);
  static const Duration quick = Duration(milliseconds: 160);
  static const Duration standard = Duration(milliseconds: 240);
  static const Duration expressive = Duration(milliseconds: 400);
  static const Duration grand = Duration(milliseconds: 640);
}

abstract final class CalmCurves {
  static const Cubic emphasized = Cubic(0.3, 0, 0, 1);
  static const Cubic standard = Cubic(0.2, 0, 0, 1);
  static const Cubic soft = Cubic(0.4, 0, 0.2, 1);
}
```

#### TextTheme snippet

```dart
TextTheme buildCalmTextTheme({required Color primary, required Color secondary}) {
  const String family = 'HankenGrotesk';
  return TextTheme(
    displayLarge: TextStyle(fontFamily: family, fontSize: 56, fontWeight: FontWeight.w700, height: 1.05, letterSpacing: -1.68, color: primary),
    displayMedium: TextStyle(fontFamily: family, fontSize: 48, fontWeight: FontWeight.w700, height: 1.1, letterSpacing: -1.15, color: primary),
    displaySmall: TextStyle(fontFamily: family, fontSize: 36, fontWeight: FontWeight.w700, height: 1.15, letterSpacing: -0.58, color: primary),
    headlineLarge: TextStyle(fontFamily: family, fontSize: 28, fontWeight: FontWeight.w700, height: 1.2, letterSpacing: -0.28, color: primary),
    headlineMedium: TextStyle(fontFamily: family, fontSize: 24, fontWeight: FontWeight.w600, height: 1.25, letterSpacing: -0.12, color: primary),
    headlineSmall: TextStyle(fontFamily: family, fontSize: 20, fontWeight: FontWeight.w600, height: 1.3, color: primary),
    titleLarge: TextStyle(fontFamily: family, fontSize: 17, fontWeight: FontWeight.w600, height: 1.4, color: primary),
    titleMedium: TextStyle(fontFamily: family, fontSize: 15, fontWeight: FontWeight.w600, height: 1.4, color: primary),
    titleSmall: TextStyle(fontFamily: family, fontSize: 13, fontWeight: FontWeight.w600, height: 1.4, color: primary),
    bodyLarge: TextStyle(fontFamily: family, fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, color: primary),
    bodyMedium: TextStyle(fontFamily: family, fontSize: 14, fontWeight: FontWeight.w400, height: 1.5, color: primary),
    bodySmall: TextStyle(fontFamily: family, fontSize: 12, fontWeight: FontWeight.w400, height: 1.45, letterSpacing: 0.12, color: secondary),
    labelLarge: TextStyle(fontFamily: family, fontSize: 14, fontWeight: FontWeight.w600, height: 1.3, letterSpacing: 0.14, color: primary),
    labelMedium: TextStyle(fontFamily: family, fontSize: 12, fontWeight: FontWeight.w600, height: 1.3, letterSpacing: 0.24, color: primary),
    labelSmall: TextStyle(fontFamily: family, fontSize: 11, fontWeight: FontWeight.w500, height: 1.25, letterSpacing: 0.33, color: secondary),
  );
}
```

#### ThemeData snippet

```dart
ThemeData buildCalmLightTheme() {
  const ColorScheme scheme = ColorScheme.light(
    primary: CalmColors.ink,
    onPrimary: CalmColors.canvas,
    secondary: CalmColors.ember,
    onSecondary: CalmColors.canvas,
    surface: CalmColors.surface,
    onSurface: CalmColors.neutral8,
    error: CalmColors.danger,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: CalmColors.canvas,
    textTheme: buildCalmTextTheme(primary: CalmColors.neutral8, secondary: CalmColors.neutral6),
    splashFactory: NoSplash.splashFactory,  // no ripple by default; opt-in per component
  );
}
```

#### Squircle helper

```dart
import 'package:figma_squircle/figma_squircle.dart';

SmoothBorderRadius calmRadius(double r) => SmoothBorderRadius(
  cornerRadius: r,
  cornerSmoothing: CalmRadius.smoothingFor(r),
);
```

#### Aurora Frame widget

```dart
class AuroraFrame extends StatelessWidget {
  const AuroraFrame({required this.child, this.warm = true, super.key});
  final Widget child;
  final bool warm;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: warm ? CalmGradients.auroraWarm : CalmGradients.auroraCool,
      ),
      child: child,
    );
  }
}
```

---

### 5.2 CSS / Web

#### Root tokens

```css
:root {
  /* Neutrals — light */
  --calm-canvas: #FBF8F3;
  --calm-surface: #F8F4ED;
  --calm-neutral-2: #EFE9E0;
  --calm-neutral-3: #E2DBCE;
  --calm-neutral-4: #C9C1B3;
  --calm-neutral-5: #9A9286;
  --calm-neutral-6: #6C645A;
  --calm-neutral-7: #433C33;
  --calm-neutral-8: #1F1A13;
  --calm-ink: #0A0A0A;

  /* Accents */
  --calm-mint: #DEEFA0;
  --calm-ember: #FF6B2E;

  /* Glass */
  --calm-glass-strong: rgba(255, 255, 255, 0.92);
  --calm-glass-medium: rgba(255, 255, 255, 0.85);
  --calm-glass-soft: rgba(255, 255, 255, 0.70);
  --calm-glass-border: rgba(255, 255, 255, 0.20);

  /* Semantic */
  --calm-success: #16A34A;
  --calm-warning: #F59E0B;
  --calm-danger: #DC2626;

  /* Shadows */
  --calm-shadow-sm: 0 1px 4px rgba(0, 0, 0, 0.04);
  --calm-shadow-md: 0 8px 24px rgba(0, 0, 0, 0.05);
  --calm-shadow-lg: 0 24px 64px rgba(0, 0, 0, 0.06);

  /* Radii */
  --calm-radius-xs: 4px;
  --calm-radius-sm: 8px;
  --calm-radius-md: 12px;
  --calm-radius-lg: 16px;
  --calm-radius-xl: 20px;
  --calm-radius-2xl: 28px;
  --calm-radius-3xl: 40px;
  --calm-radius-pill: 999px;

  /* Space */
  --calm-space-1: 2px;
  --calm-space-2: 4px;
  --calm-space-3: 8px;
  --calm-space-4: 12px;
  --calm-space-5: 16px;
  --calm-space-6: 20px;
  --calm-space-7: 24px;
  --calm-space-8: 32px;
  --calm-space-9: 40px;
  --calm-space-10: 56px;
  --calm-space-11: 72px;
  --calm-space-12: 96px;

  /* Motion */
  --calm-ease-emphasized: cubic-bezier(0.3, 0, 0, 1);
  --calm-ease-standard: cubic-bezier(0.2, 0, 0, 1);
  --calm-ease-soft: cubic-bezier(0.4, 0, 0.2, 1);
  --calm-duration-instant: 80ms;
  --calm-duration-quick: 160ms;
  --calm-duration-standard: 240ms;
  --calm-duration-expressive: 400ms;
  --calm-duration-grand: 640ms;

  /* Gradients */
  --calm-aurora-cool: linear-gradient(180deg, #C5E0EE 0%, #E8E4DE 50%, #FFE0C2 100%);
  --calm-aurora-warm: linear-gradient(180deg, #FFFBF5 0%, #FFE9D0 40%, #FFDBB0 75%, #FFC48A 100%);
  --calm-ember: radial-gradient(circle at 30% 40%, #FF5A1F 0%, #FF8C42 40%, #FFB067 80%, transparent 100%);
  --calm-dusk: linear-gradient(180deg, #241810 0%, #2E1F11 50%, #140C05 100%);
  --calm-mist: linear-gradient(180deg, #F0F2F4 0%, #DDE2E7 100%);

  /* Typography */
  --calm-font-body: 'Hanken Grotesk', ui-sans-serif, system-ui, sans-serif;
  --calm-font-mono: 'Geist Mono', ui-monospace, Menlo, monospace;
  --calm-font-digital: 'Doto', ui-monospace, monospace;
}

@media (prefers-color-scheme: dark) {
  :root {
    --calm-canvas: #140C05;
    --calm-surface: #1E1610;
    --calm-neutral-2: #261B10;
    --calm-neutral-3: #2E2318;
    --calm-neutral-4: #4A3F33;
    --calm-neutral-5: #7A6D5E;
    --calm-neutral-6: #A69684;
    --calm-neutral-7: #D6BEA0;
    --calm-neutral-8: #F0E3D0;
    --calm-ink: #FFF3E1;
    --calm-glass-strong: rgba(31, 23, 14, 0.94);
    --calm-glass-medium: rgba(38, 27, 16, 0.80);
    --calm-glass-soft: rgba(45, 32, 20, 0.60);
    --calm-glass-border: rgba(255, 217, 174, 0.20);
  }
}
```

#### Hero with Aurora Frame

```html
<body class="aurora-warm">
  <main class="hero">
    <span class="eyebrow">NEW — Say hello to CalmSurface</span>
    <h1 class="display-xl">Turn your ideas into calm interfaces</h1>
    <p class="lede">A design system for interfaces that don't shout.</p>
    <button class="btn-primary-mint">Get started</button>
  </main>
</body>
```

```css
.aurora-warm { background: var(--calm-aurora-warm); min-height: 100vh; }
.hero { max-width: 720px; margin: 0 auto; padding: var(--calm-space-12) var(--calm-space-7); text-align: center; }
.display-xl { font-family: var(--calm-font-body); font-size: 3.5rem; font-weight: 700; line-height: 1.05; letter-spacing: -0.03em; color: var(--calm-ink); margin: 0 0 var(--calm-space-5); }
.lede { font-family: var(--calm-font-body); font-size: 1.125rem; color: var(--calm-neutral-6); margin: 0 0 var(--calm-space-7); }
.btn-primary-mint { font-family: var(--calm-font-body); font-size: 0.875rem; font-weight: 600; background: var(--calm-mint); color: var(--calm-ink); border: none; padding: var(--calm-space-4) var(--calm-space-7); border-radius: var(--calm-radius-pill); cursor: pointer; transition: all var(--calm-duration-quick) var(--calm-ease-standard); }
.btn-primary-mint:hover { background: var(--calm-ink); color: var(--calm-mint); }
.btn-primary-mint:active { transform: scale(0.98); }
```

#### Glass card

```css
.glass-card {
  background: var(--calm-glass-medium);
  backdrop-filter: blur(20px) saturate(1.1);
  -webkit-backdrop-filter: blur(20px) saturate(1.1);
  border: 1px solid var(--calm-glass-border);
  border-radius: var(--calm-radius-2xl); /* fallback; squircle needs clip-path */
  box-shadow: var(--calm-shadow-lg);
  padding: var(--calm-space-6);
}

/* Squircle approximation via SVG clip-path is preferred when supported */
@supports (clip-path: path('M 0 0')) {
  .glass-card { /* use superellipse polyfill or SVG mask */ }
}
```

#### Tailwind config mapping

```js
// tailwind.config.js (abridged)
export default {
  theme: {
    extend: {
      colors: {
        calm: {
          canvas: '#FBF8F3', surface: '#F8F4ED', ink: '#0A0A0A',
          mint: '#DEEFA0', ember: '#FF6B2E',
          // ... neutral-2..8
        },
      },
      borderRadius: {
        'calm-xl': '20px', 'calm-2xl': '28px', 'calm-3xl': '40px', 'calm-pill': '999px',
      },
      boxShadow: {
        'calm-sm': '0 1px 4px rgba(0,0,0,0.04)',
        'calm-md': '0 8px 24px rgba(0,0,0,0.05)',
        'calm-lg': '0 24px 64px rgba(0,0,0,0.06)',
      },
      fontFamily: {
        body: ['"Hanken Grotesk"', 'ui-sans-serif', 'system-ui'],
        mono: ['"Geist Mono"', 'ui-monospace'],
        digital: ['Doto', 'ui-monospace'],
      },
      transitionTimingFunction: {
        'calm-emphasized': 'cubic-bezier(0.3, 0, 0, 1)',
        'calm-standard': 'cubic-bezier(0.2, 0, 0, 1)',
      },
      backgroundImage: {
        'calm-aurora-warm': 'linear-gradient(180deg, #FFFBF5 0%, #FFE9D0 40%, #FFDBB0 75%, #FFC48A 100%)',
        'calm-aurora-cool': 'linear-gradient(180deg, #C5E0EE 0%, #E8E4DE 50%, #FFE0C2 100%)',
        'calm-ember': 'radial-gradient(circle at 30% 40%, #FF5A1F 0%, #FF8C42 40%, #FFB067 80%, transparent 100%)',
      },
    },
  },
};
```

---

## 6. Anti-patterns IA

Normative rules. For every ❌, a concrete ✅ alternative.

### Color

- ❌ **Violet → blue gradient on white.** The single most recognizable AI-slop signal.
  ✅ Use Aurora Cool (sky→cream→peach) or Aurora Warm (cream→peach). Or nothing — cream canvas with ink typography.

- ❌ **"Info" coloured blue.** Pigeonholes the interface as generic.
  ✅ `neutral.6` warm grey. The icon carries semantic, not the surface.

- ❌ **Dark mode = light mode with inverted colours.** Kills warmth.
  ✅ Distinct palette: warm browns (Beedle) or deep slate (Base44 backend). Pure black (`#000`) is never the background.

- ❌ **Gradient on title text.** Reads as desperate.
  ✅ Pure `#0A0A0A` display. The gradient is in the frame, never the foreground.

- ❌ **Saturated coloured toast backgrounds** (green success, red error, amber warning).
  ✅ `glass.strong` background with a semantic-coloured Lucide icon. Neutral surface, coloured signal.

### Shape & Depth

- ❌ **Uniform `rounded-lg` everywhere.** No hierarchy.
  ✅ Squircle scale: buttons get pill, cards get 28, modals get 40, chips get 999. Bigger surface = larger + smoother radius.

- ❌ **CSS shadow at 10%+ opacity** (`0 4px 6px rgba(0,0,0,0.1)`).
  ✅ Blur σ 20 + 1px `glass.border` + `shadow.lg` (6% max). Depth through layers, not cast shadows.

- ❌ **Glassmorphism 2021** — thick white 40% border, saturated blur, rainbow tint behind.
  ✅ Liquid Glass 2024: subtle 1px border at 20% opacity, higher blur σ, translucent warm fill. On Flutter use `liquid_glass_renderer` when possible.

- ❌ **Neon glow halo behind primary CTAs.**
  ✅ Flat ink (black) or flat mint pill. No shadow at rest. Press scale 0.98.

### Typography

- ❌ **Inter / Roboto / Arial / system default.** You have made zero choice.
  ✅ Hanken Grotesk (body) + Geist Mono (data) + Doto (signature only).

- ❌ **`font-weight: bold` (700) everywhere.**
  ✅ 400 body, 600 title. Reach 700 only for `display.*` sizes, and at most once per screen.

- ❌ **Uppercase body text.**
  ✅ Uppercase reserved for `label.sm` with `+3%` tracking.

- ❌ **Space Grotesk again.** It is the new Inter.
  ✅ Hanken. If you want a second family, earn it — and document why in the project's design doc.

### Iconography & Imagery

- ❌ **Default Material / Heroicons set without editorial choice.**
  ✅ Lucide, stroke 1.5, or a hand-picked set documented per project.

- ❌ **Emojis as feature icons** (✨ AI, 🚀 Launch, 💬 Chat, 🎯 Goal).
  ✅ Lucide icon or text-only label. Emojis only in user-generated content.

- ❌ **Isometric illustrations from undraw.co or Storyset.**
  ✅ Typographic empty states. A short sentence in `body.lg` + `neutral.6`, single CTA. Or a Doto headline.

- ❌ **Gradient-mesh animated hero backgrounds.**
  ✅ Static Aurora Frame. Interaction-triggered motion only.

- ❌ **Autoplaying dashboard video loop as hero.**
  ✅ Static product shot, "Play demo" trigger if needed.

### Layout & Patterns

- ❌ **"Trusted by" logo grid, grey-scale, 6-8 logos.**
  ✅ A single sentence with one quoted number, or nothing. Apple doesn't do it.

- ❌ **Centered modal + 50% black scrim.**
  ✅ Bottom sheet + blur σ 24 + 24% scrim. On web only, a modal with 28px radius and 40 σ blur.

- ❌ **Ghost button with border visible only on hover.**
  ✅ Always visible or never. If ghost, the text colour + slight opacity is the affordance.

- ❌ **Progress bar with multicolour gradient fill.**
  ✅ Single neutral fill. Or segmented (Nothing-style) — 10 pills, fill one at a time.

- ❌ **Toggle switches with saturated "on" colour.**
  ✅ Neutral ink on, neutral grey off. No colour.

- ❌ **Loading spinner centered on a white card.**
  ✅ Skeleton of the actual content shape, 3% shimmer.

- ❌ **Tooltips `?` icon next to every label.**
  ✅ Rewrite the label. If you can't, the feature is mis-scoped.

### Motion

- ❌ **Shimmer / pulse / bounce on CTAs at rest.**
  ✅ Stillness. Motion only on interaction.

- ❌ **Confetti / sparkles on completion.**
  ✅ `duration.expressive` stagger reveal of a success card. One element moves.

- ❌ **Scroll-triggered parallax on every section.**
  ✅ One scroll-triggered moment per page. Usually the hero.

### Brand signals

- ❌ **"Made with AI ✨" badge.**
  ✅ Remove. If disclosure is legally needed, plain text in the footer.

- ❌ **AI-generated avatar placeholders** with distinctive midjourney-face proportions.
  ✅ Initials in a neutral filled circle, or user upload only.

- ❌ **Feature list with three-column icons that are all purple gradient with a white icon inside.**
  ✅ Text-first feature list. If icons, Lucide stroke in `neutral.8`.

---

## 7. Do / Don't Gallery

### Hero section

**✅ Do**

```
┌─────────────────────────────────────────────────┐
│ [sky blue fading to cream fading to peach]      │  ← Aurora Frame
│                                                 │
│    NEW — Say hello to CalmSurface               │  ← eyebrow, label.sm, +3% tracking
│                                                 │
│         Turn your ideas into                    │  ← display.xl, 700, -3% tracking, ink
│              calm interfaces                    │
│                                                 │
│   A design system for interfaces that don't     │  ← body.lg, neutral.6
│              shout.                             │
│                                                 │
│            [  Get started  ]                    │  ← pill, mint fill, ink text
│                                                 │
└─────────────────────────────────────────────────┘
```

**❌ Don't**

```
┌─────────────────────────────────────────────────┐
│ [animated purple→blue mesh gradient]            │
│                                                 │
│ ✨ Introducing AI Calm Surface 🚀               │  ← emojis + AI wording
│                                                 │
│  TURN YOUR IDEAS INTO APPS                      │  ← uppercase body
│  [purple-to-pink gradient on text]              │
│                                                 │
│  [  Get Started Free →  ]                       │  ← purple gradient button
│   └─ neon glow underneath                       │
│                                                 │
│  Trusted by teams at:                           │
│  [Logo] [Logo] [Logo] [Logo] [Logo] [Logo]      │  ← grey logo grid
└─────────────────────────────────────────────────┘
```

### Card

**✅ Do** — Glass card with 28px squircle (smoothing 0.6), blur σ 20, 1px glass.border, shadow.lg at 6%. Title `headline.md` 600 in ink, body `body.md` 400 in neutral.7.

**❌ Don't** — White card, hard 8px radius, `0 4px 6px rgba(0,0,0,0.1)` shadow, bold 700 title, blue link text underneath.

### Empty state

**✅ Do**

```
         ┌─────┐
         │ 000 │       ← Doto, display.lg, accent.digital
         └─────┘

    No cards to show yet.     ← body.lg, neutral.6
    Import your first screenshot.

         [  Import  ]          ← secondary.outline button
```

**❌ Don't**

```
    [isometric cloud+lightbulb illustration]

         Oops! 😅
       Nothing here yet.
    Let's get started! ✨

         [  Get Started  ]   ← purple gradient, glow
```

### Toast

**✅ Do** — Glass.strong, blur σ 24, 20px squircle, 1px glass.border, Lucide CheckCircle icon in `semantic.success` color, text in `neutral.8`, bottom-slide.

**❌ Don't** — Saturated green `#22C55E` background, white text, sharp 6px corners, hard drop shadow, top-right slide.

---

## 8. CalmSurface-Ready Checklist

A 20-item audit. A screen is "CalmSurface-ready" when all 20 pass.

### Foundations (6)

- [ ] **No** unlicensed or AI-default fonts (Inter, Roboto, Arial, system). Hanken Grotesk loaded and active.
- [ ] **No** violet, indigo, or default-blue in the palette. Info tokens use warm neutrals.
- [ ] **No** pure white background. Canvas is `#FBF8F3` or the Aurora gradient.
- [ ] **No** pure black except `#0A0A0A` on display titles.
- [ ] **No** CSS `box-shadow` exceeds 6% opacity.
- [ ] **No** `border-radius` above 16px that isn't squircle (`cornerSmoothing ≥ 0.5`).

### Typography (3)

- [ ] Maximum 2 weights on the screen.
- [ ] Display sizes carry negative tracking (-1% to -3%).
- [ ] Labels at 11px use uppercase + `+3%` tracking; no uppercase elsewhere.

### Components (4)

- [ ] At least one Signature Pattern present (Aurora Frame, Glass Card, Ember Accent, Digital Display, Mint/Black CTA).
- [ ] No emoji in navigation, tabs, or buttons.
- [ ] Icons are Lucide stroke 1.5 (no mixed icon library).
- [ ] Buttons have no gradient fill, no shadow at rest, no glow.

### Depth (2)

- [ ] Glass surfaces use `blur σ ≥ 16` and opacity 70-92%.
- [ ] Glass surfaces have a 1px border at 12-20% opacity.

### Motion (3)

- [ ] At most one `duration.grand` animation per screen.
- [ ] Stagger between list items is 40-60ms.
- [ ] `prefers-reduced-motion` respected — all durations collapse to `instant`.

### Anti-slop sweep (2)

- [ ] No "trusted by" logo grid.
- [ ] No isometric illustration, no "Made with AI ✨" badge, no sparkle emoji in copy.

---

## Appendix A — Related Beedle files

- `lib/presentation/theme/app_typography.dart` — current type scale (to be rewired with Hanken)
- `lib/presentation/theme/app_colors.dart` — current palette (warm-only; compatible with Aurora Warm)
- `lib/presentation/widgets/glass_card.dart` — reference implementation of §2.2 Liquid Glass Card
- `lib/presentation/widgets/gradient_background.dart` — reference implementation of §2.1 Aurora Frame
- `lib/presentation/widgets/blur_surface.dart` — helper for §3 AppBar / Bottom Sheet
- `lib/presentation/widgets/pill_chip.dart` — reference for §3 Pill / Chip
- `pubspec.yaml` — needs `liquid_glass_renderer`, fonts (Hanken, Geist Mono, Doto)

## Appendix B — Font sources

- **Hanken Grotesk** — [Google Fonts](https://fonts.google.com/specimen/Hanken+Grotesk) · OFL
- **Geist Mono** — [Vercel](https://vercel.com/font) or [Google Fonts](https://fonts.google.com/specimen/Geist+Mono) · OFL
- **Doto** — [Google Fonts](https://fonts.google.com/specimen/Doto) · OFL

## Appendix C — Reference sources synthesized

- Apple Liquid Glass (iOS 26 HIG)
- Base44 — [base44.com](https://base44.com) homepage, `/backend`, `/superagents`, `/integrations`
- Raycast — [raycast.com](https://raycast.com)
- Nothing Design Skill — [github.com/dominikmartn/nothing-design-skill](https://github.com/dominikmartn/nothing-design-skill)
- [liquid_glass_renderer](https://pub.dev/packages/liquid_glass_renderer)
- [figma_squircle](https://pub.dev/packages/figma_squircle)
- [Lucide](https://lucide.dev)

---

*CalmSurface v0.1 — Quiet surfaces, continuous curves, deliberate motion.*
