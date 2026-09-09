# 05 — Style Guide / Design Tokens

Status: Draft · Values below are STARTING POINTS — adjust during mockups, then lock.
Contract: token names are the interface between design and code. Rails CSS/Tailwind config must use these exact names.

## Colors

| Token | Value | Use |
|-------|-------|-----|
| surface | #FFFFFF | Page background, cards |
| surface-muted | #F6F4EF | Alternating rows, empty slots |
| ink | #1F2421 | Primary text |
| ink-muted | #6B7280 | Secondary text, timestamps |
| action | #2F6F4F | Primary buttons, filled-slot accents |
| action-hover | #275C42 | Hover state of primary |
| danger | #B3402A | Delete, clear week |

## Type scale (ratio 1.25)

| Token | Size | Weight | Line height | Use |
|-------|------|--------|-------------|-----|
| display | 28px | 600 | 1.2 | Screen titles ("Semana del 24 ago") |
| heading | 20px | 600 | 1.3 | Day headers, section titles |
| body | 16px | 400 | 1.5 | Default text |
| caption | 13px | 500 | 1.4 | Meta: cook time, servings |

Family: system stack (`system-ui`) until brand font chosen. One family only in v1.

## Spacing (base 4)

Allowed values only: `4 · 8 · 12 · 16 · 24 · 32 · 48`

| Token | Value | Typical use |
|-------|-------|-------------|
| space-1 … space-7 | 4…48 | Card padding = 12/16, grid gaps = 8, section gaps = 32 |

## Shape & elevation

| Token | Value | Use |
|-------|-------|-----|
| radius-sm | 6px | Inputs, chips |
| radius-md | 10px | Cards, recipe cards |
| shadow-card | 0 1px 3px rgb(0 0 0 / .08) | Resting cards only |

## Grid

- Desktop: 12 columns, 24px gutter, max content width 1200px
- Mobile: 4 columns, 16px gutter
