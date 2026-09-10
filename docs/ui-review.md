# UI/UX review — meal-planner (Round 3)

- Reviewer: UI/UX (browser-only; no code fixes)
- Date: 2026-09-09
- Round: **3** (re-verify after UI-review fix round 2)
- App: http://localhost:3001 (port 3000 is still `davidzu.com`; meal-planner answers 200 on 3001)
- Rubric: `docs/02-information-architecture.md`, `docs/04-wireframes.md`, `docs/05-style-guide.md`, `docs/06-components.md`, `docs/07-screen-specs-index.md`, `docs/screens/week-planner.md`
- Viewport pass: 1280 and 375 (plus a 375 archive-index check)
- Seed: 10 real recipes + leftover review artifacts **Ensalada r2 F5**, **Salsa r3 N1**, **Guiso r3 Quitar** (created during R2/R3 walks)

## Verdict

**USABLE**

All three Round-2 failures are fixed with measured evidence. F2 modal assign, recipe create (including extra nested rows), and F4 generate/check-off work at 1280 and 375. No console errors on current page loads. Remaining issues are nits / one minor archive-table overflow that does not block the core flows.

---

## Round-2 findings — re-verify

| ID | Round-2 summary | Status | Evidence |
|----|-----------------|--------|----------|
| **B2** | Picker search does not hide non-matches (`display: flex` beats `[hidden]`) | **Fixed** | Type `Birria` in “Buscar receta…”. 11 `.picker__item`; 10 have `hidden` + computed `display: none` / height 0; only **Birria de res** stays `display: flex` (69.5px). Accessibility tree shows that one row. At 375, `Sopa` leaves 1 of 13 visible. `r3-picker-filter.png`, `r3-picker-375.png` |
| **N1** | Extra ingredient row (Cant. `0.0` / Quitar) blocks Crear receta | **Fixed** | `/recipes/new`: fill name + first row Cant. `2` → Agregar ingrediente → leave extra Cant. `0.0` empty → Crear receta POSTs to `/recipes/24` **Salsa r3 N1** with only `2 pieza de Tomate r3`. Repeat with Quitar checked on the extra row → `/recipes/25` **Guiso r3 Quitar**. `r3-recipe-new-extra-row.png`, `r3-recipe-created.png` |
| **N2** | Picker ✕ is 12×20 | **Fixed** | `.picker__close` is **24×28** (`min-width`/`min-height` 24px) at 1280 and 375. `r3-picker-filter.png`, `r3-picker-375.png` |

---

## Pages walked (Round 3)

| Page | URL | Load | Console | Notes |
|------|-----|------|---------|-------|
| Week planner | `/`, `/weeks/4` | 200 | clean | 7×3, Spanish, modal assign |
| Recipe picker | turbo-frame overlay | 200 | clean | Modal; search **hides** non-matches |
| Recipe library | `/recipes` | 200 | clean | 10 seeds + 3 review leftovers |
| Recipe detail | `/recipes/24` Salsa r3 N1 | 200 | clean | C-06; one ingredient (empty extra row dropped) |
| Recipe new | `/recipes/new` | 200 | clean | Nested add; extra row no longer traps submit |
| Shopping list show | `/shopping_lists/5` | 200 | clean | Grouped; check-off persists |
| Shopping lists index | `/shopping_lists` | 200 | clean | Archive table; **28px overflow at 375** (minor) |
| Settings | `/settings` | 200 | clean | Hogar + miembros |

JS boot: Turbo modal, Stimulus `picker-filter` / `nested-form`, toast. Current-page console: **0 errors** (historical favicon 404 only).

---

## Remaining findings

### Minor

#### N3 (new). Shopping-lists archive table overflows ~28px at 375

- **Page:** `/shopping_lists` (archive index — not the F4 show page)
- **Expected:** Checklist — no horizontal overflow at 375.
- **Actual:** `scrollWidth` 403 vs `clientWidth` 375. `.card.card--flush` / `<table>` (SEMANA / RENGLONES / COMPRADOS / Ver) sticks ~28px past the viewport. Show page `/shopping_lists/5` does **not** overflow.
- **Steps:** Resize to 375 → Recetas nav **Listas**.
- **Screenshot:** `r3-lists-index-375.png`
- **Impact:** Archive is still readable; Ver is reachable. Does not block F4.

#### m8 (residual). Compact cards are still cramped

- 44×44 Quitar + Porc./OK in a 7-column grid. Day names remain **Lunes** / 07. Usable. `r3-week-1280.png`

### Nit

- Review leftovers in the library: Ensalada r2 F5, Salsa r3 N1, Guiso r3 Quitar (this round’s N1 evidence).
- Ingredient `<select>` still lists “Review Carne Mix” / “Review Nested Ing” / “Tortilla extra”.
- `0.06 kg Sal` still ugly (data).
- Shopping-list ✓ is 34×27 (above 24px min; same as R1/R2).
- Favicon 404.
- Port 3000 is another site; meal-planner is 3001.

---

## Flows vs IA / screen spec (regression)

| Flow | Result |
|------|--------|
| F1 Fill week | **Pass.** 21 slots; empty hint not shown this week (slots already filled from R2). Picker is a modal; search now filters (B2). |
| F2 Assign | **Pass.** `+` Lunes Comida → overlay “Asignar receta — Lunes” / Comida → type Birria (only that row) → Asignar → compact card Birria 45 min + Porc. Persists on `/weeks/4`. `r3-week-assigned.png` |
| F3 Swap | Out of scope (v1.1). Not offered. Correct. |
| F4 Generate shopping list | **Pass.** Button enabled. Lands on grouped list (11 renglones). Toast “Lista de compras generada.” ✓ Ajo → “1 comprados”. Show page no overflow at 1280/375. `r3-shopping-list.png`, `r3-shopping-375.png` |
| F5 Create while planning | **Pass** (create path). Extra-row trap gone (N1). Default single-row path unchanged. |
| Settings | **Pass.** Loads; meal types read-only “Desayuno, Comida, Cena”. |
| Recipe CRUD | **Pass.** Create with extra empty row and with Quitar; detail C-06; form no overflow at 1280 or 375. |
| Login / logout | N/A — v1 has no auth. |

---

## Visual vs style guide (`docs/05`)

Measured on week planner, 1280:

| Token | Spec | Rendered |
|-------|------|----------|
| surface | #FFFFFF | `rgb(255, 255, 255)` |
| ink | #1F2421 | `rgb(31, 36, 33)` |
| action | #2F6F4F | `rgb(47, 111, 79)` primary buttons |
| display | 28px / 600 / 1.2 | h1 28px / 600 / 33.6px |
| family | system-ui | `system-ui, -apple-system, sans-serif` |

**Contrast (AA):** ink on white and white on action green pass. `lang="es"`. Slot Quitar still **56×44**.

---

## Responsive

| Width | Week planner | Recipes | Shopping list show | Lists index | Settings | Recipe form | Picker |
|-------|--------------|---------|--------------------|-------------|----------|-------------|--------|
| 1280 | 7 columns, no overflow | 4-card grid, no overflow | Fine | Fine | Fine | No overflow | Modal; filter works; ✕ 24×28 |
| 375 | Stacked days, no overflow (`scrollWidth` 375); nav wraps | 1-col, no overflow | Rows usable, ✓ 34×27, no overflow | **Table overflow 403 vs 375 (N3)** | Single column, no overflow | Fields stack, no overflow | Full-viewport; filter works; ✕ 24×28 |

Tap: Quitar 44×44 (pass). Picker ✕ 24×28 (pass 24px min). `+` empty slots well above 24px.

---

## What works well (do not “fix”)

- Picker filter now **visually** hides non-matches — keep the `[hidden] { display: none !important }` win.
- Nested ingredient rows: empty clones and Quitar/`_destroy` no longer block HTML5 submit — keep.
- Picker close at ≥24×24 — keep.
- JS boot: Turbo modal assign, Stimulus nested-form, toast auto-dismiss, Spanish chrome.
- Spanish labels: Semana del 07 sep, Desayuno / Comida / Cena, Generar lista de compras, Vaciar semana, Recetario, Mi hogar.
- Compact card (name link, cook time, servings + OK) matches C-05 once assigned.
- Shopping list grouped by Verdulería / Carnicería / Abarrotes; purchased count updates.
- Recipe detail C-06: meta, `quantity unit de name`, instructions, Editar / Eliminar.
- Library chips + filters; form titles left under back link.
- Token colors, display type, system-ui, `lang="es"` — don’t restyle the palette.
- Brand “Mi hogar” vs nav “Semana” — keep.

---

## Design gaps (docs silent — do not invent in code)

Unchanged from Round 1/2 (`docs/04` inventory ⬜; recipes / shopping-list / settings specs “Not started”):

1. Product name vs household name in the shell (now “Mi hogar”).
2. Day header format (full weekday + number).
3. C-06 “chef’s note”.
4. C-07 “recent recipes” section — picker is still a flat list.
5. C-08 difficulty chips (out of scope in ADR).
6. Tag editor still a native multi-select (labels are Spanish).
7. Toast auto-dismiss timing.
8. Custom focus ring.
9. Empty shopping-lists archive.
10. F3 drag-and-drop — v1.1.
11. Spanish-only vs bilingual.
12. Meal-type schedule editor (IA lists it; spec 10.1 freezes labels).
13. Archive table layout at 375 (N3) — no wireframe for SCREEN-04 mobile.

---

## USABLE

0 remaining failures from Round 2 (B2, N1, N2 all verified). No new blockers.
