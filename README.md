# Meal Planner — Product Design Workspace & Rails App

Design artifact pipeline for a weekly meal planner (Desayuno/Comida/Cena) built on Ruby on Rails.
This repo is the source of truth; Miro holds throwaway visuals only.

## Artifact chain

```text
00 current-state ──► 01 brief ──► 02 IA ──► 04 wireframes ──► 07 screen specs ──► code
                        │                     ▲                    │
                        └──► 03 data model ◄──┴── 05 tokens · 06 components
```

Rule of sequence: an artifact can only lock when its upstream dependency is locked.
Iterations loop back through the same files — update in place, never fork versions by date.

## Progress tracker

| # | Artifact | File | Status | Locked means |
|---|----------|------|--------|--------------|
| 00 | Current-state capture | `docs/00-current-state.md` | Draft | One real week observed & filled in |
| 01 | Product brief | `docs/01-product-brief.md` | Draft | Scope in/out agreed by both stakeholders (you + wife) |
| 02 | Information architecture | `docs/02-information-architecture.md` | Draft | Sitemap stable + flows F1–F5 drawn in Miro |
| 03 | Data model | `docs/03-data-model.md` | Draft | ERD matches planned migrations, open questions resolved |
| 04 | Wireframes | `docs/04-wireframes.md` + Miro | Not started | Round-1 frames walked through with second user |
| 05 | Style guide / tokens | `docs/05-style-guide.md` | Draft | Values survive one mockup round unchanged |
| 06 | Component inventory | `docs/06-components.md` | Draft | Every wireframe element maps to a row |
| 07 | Screen specs | `docs/screens/*.md` | 1 example | Acceptance criteria written per screen before its code |
| — | Rails app (v1 scaffold) | `app/`, `db/`, `config/` | Built | ERD ↔ schema, sitemap ↔ routes, specs ↔ tests |

Status vocabulary: **Not started → Draft → In review → Locked**.
Only Locked artifacts constrain code. Everything else is negotiable — that's what keeps iteration cheap.

## Standing conventions

1. **Miro owns pictures; repo owns values.** Exact hexes, sizes, names live here, never in Miro notes.
2. **Token names are contracts**: style guide ↔ CSS ↔ component markup use identical names.
3. **Routes mirror the sitemap; schema mirrors the ERD; tests mirror acceptance criteria.** Divergence = defect, fix same day.
4. **One friction fixed per weekly cycle**, chosen from `docs/friction-journal.md` after each Sunday planning session.

## The Rails app

Rails 8.1 · Ruby 4.0 · PostgreSQL. Server-rendered Hotwire-style (Turbo + Stimulus via importmap), no SPA tooling.

### Models (English names, Spanish UI)

`Household` → `User` · `Week` → `Day` → `MenuDay` → `Recipe` and `Ingredient` (via `RecipeIngredient`) · `Tag` (via `RecipeTag`) · `ShoppingList` → `ListItem`

### Quick start

```bash
bundle install
bin/rails db:create db:migrate db:seed
bin/rails server   # http://localhost:3000
```

Seeds load a real recipe library (Birria de res, Pollo guisado, Frijoles de olla…) plus a two-member household.

### Key flows

- **Week grid** (`/`): 7 days × Desayuno/Comida/Cena. Tap an empty slot → recipe picker modal. Copy previous week, navigate weeks.
- **Shopping list** (`POST /weeks/:id/shopping_list`): regenerates by summing ingredient quantities across filled slots, scaled by `servings / base_servings`. Merge rule v1: same unit only (500 g + 1 kg → two rows).
- **Recipes** (`/recipes`): CRUD with nested ingredients, tags, search + filters.
- **Settings** (`/settings`): household name + members (planificador/cocinero roles).

### Design-token contract

`app/assets/stylesheets/application.css` defines CSS variables whose names match `docs/05-style-guide.md` exactly (`--surface`, `--action`, `--space-*`, `--radius-*`, …). Keep them in sync.

## Next actions

- [ ] Fill `00-current-state.md` during next real planning session (baseline metrics!)
- [ ] Review `01-product-brief.md` with wife, resolve open questions
- [ ] Draw flows F1–F4 in Miro, paste board link into `02`
- [ ] Walk the scaffolded app through one real Sunday planning session, log frictions
- [ ] Write Capybara system tests from `docs/screens/*.md` acceptance criteria