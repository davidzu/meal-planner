# Implementation notes (stage 3)

Developer implemented `docs/spec.md` §1–§13 against `docs/ADR-001-architecture.md`. §14 (test suite) was not started.

Rails 8.1.3.1 · Ruby 4.0.6 · no commit (review gate owns that).

## Sections completed

| Section | Status |
|---------|--------|
| 1 Foundation (Propshaft, test gems, test_unit, locale `:es`, `current_household`) | done |
| 2 Schema (`FixListItemsUniqueness`) | done |
| 3 Models | done |
| 4 Stimulus (single `Application.start()`, picker-filter scope, nested-form) | done |
| 5 Routes (ADR §5.1) | done |
| 6 Controllers | done |
| 7 Week planner views | done |
| 8 Recipe views | done |
| 9 Shopping list views | done |
| 10 Settings views | done |
| 11 Partials C-01–C-12 | done |
| 12 Seeds (idempotent week for today) | done |
| 13 CSS tokens / AppShell / `config/ci.rb` | done |
| 14 Tests | **not done** (tester) |

## Gemfile

Added only what the spec allows:

- `propshaft` (default group)
- `capybara`, `selenium-webdriver` (`:test`)

`json ~> 2.21` pin kept. No `turbo-rails` / `stimulus-rails` gems (JS still vendored).

## Schema

One migration: `db/migrate/20260909120000_fix_list_items_uniqueness.rb` — drops unique `(shopping_list_id, ingredient_id)`, adds unique `(shopping_list_id, ingredient_id, unit)` named `index_list_items_on_list_ingredient_and_unit`. No other schema changes.

## Notes for tester / reviewer

- **No auth.** Any visitor shares `current_household` (`Household.first` or create `"Mi hogar"`).
- **Locale:** `I18n.default_locale = :es`, `Time.zone = America/Mexico_City`. `Week#label` → `Semana del 24 ago`; `Day#name` for a Monday → `Lunes`.
- **Week `#show`:** `/weeks/:id` loads that week; root uses `params[:date] || Date.current` and find-or-creates. Prev/next always link to `root_path(date:)`.
- **Copy is POST** (`source_week_id`); GET copy is no-route. Copy does not overwrite filled slots.
- **Assign servings** default to `week.people_count` (Personas toolbar). Slot servings PATCH scales `regenerate!`.
- **Picker** lives in `turbo-frame#recipe-picker` (empty frame in the layout). `picker-filter` is on `.picker` (wraps input + list). Asignar / Nueva receta / close use `turbo-frame="_top"`. F5 return params: `return_week_id`, `return_day_id`, `return_meal_type`.
- **Recipe form** has instructions + nested ingredient rows (`nested-form` + “Agregar ingrediente”). New ingredients via `ingredient_name` → `Ingredient.find_or_create_named!`.
- **Shopping list** grouped by `Ingredient::CATEGORIES`; no unit_price / cost. Toggle is `PATCH /shopping_lists/:id/toggle_item` with `item_id` param. Mixed units of one ingredient produce two rows.
- **Settings:** household name PATCH, members CRUD, read-only “Tipos de comida: Desayuno, Comida, Cena”. `/households/:id/edit` is no-route.
- **Partials:** C-01 layout AppShell; C-02 `_week_grid`; C-03 `_day_column`; C-04 `_meal_slot`; C-05 `_card_compact`; C-06 `_card_full`; C-07 `_picker`; C-08 `_search_bar`; C-09 `_item`; C-10 `.btn` CSS; C-11 `_toast`; C-12 `_empty_state`.
- **Seeds:** 10 recipes unchanged; after seed, current week + 7 days exist. Safe to run twice.
- **CI:** `config/ci.rb` has `bin/rails test` and `bin/rails test:system` (will fail until §14).
- **Selectors:** Spanish copy as in the views (`Empieza por el lunes`, `Generar lista de compras`, `Vaciar semana`, `Asignar`, `Nueva receta`, …). Stable classes: `week-grid`, `day-column`, `meal-slot`, `picker`, `chip`, `list-item`.

## Deviations

1. **`ShoppingList#regenerate!` saves if `new_record?`.** Spec 6.7 says `shopping_list || build_shopping_list` then `regenerate!`. Creating `list_items` requires a persisted parent, so `save!` runs inside the existing transaction when the list was only `build`ed. Merge key remains `[ingredient_id, unit]`.
2. **`RecipeIngredient#ingredient_name` virtual attribute** so the form field binds; controller 6.6 still maps name → `find_or_create_named!` before save.
3. **Week grid iterates `days.order(:date)`** so columns stay Mon–Sun regardless of load order.

No other data-model, gem, or route drift.

## Verification

- `bin/rails db:prepare` — ok (migration applied; schema version `2026_09_09_120000`)
- `bin/rails db:seed` twice — ok; `Recipe.count == 10`, `Household.count == 1`
- `bin/rails routes` — POST copy, POST clear, PATCH menu_day, GET `/settings` as `settings`; no GET copy; no `households#edit`
- Runner: Spanish short date `24 ago`; Monday `Lunes`; `config.generators.system_tests == :test_unit`; mixed-unit regenerate creates two rows
- Server: `/`, `/recipes`, `/shopping_lists`, `/settings` 200; digested `/assets/application-*.css` 200; `/households/1/edit` and GET copy 404

## Out of scope (as specified)

F3 drag-and-drop, difficulty column, Active Storage, Action Text, ViewComponent, auth, ingredients/tags CRUD, list cost, meal-type editor, `render.yaml`, RSpec, Turbo Streams, §14 tests.

## UI-review fix round

Fixes for `docs/ui-review.md` NEEDS-WORK (blockers, majors, cheap minors). No data-model or ADR changes. No new gems.

| Finding | Change |
|---------|--------|
| **B1** | Importmap `to:` paths pointed at missing `vendor/javascript/@hotwired/turbo-rails.js`. Vendored files are `@hotwired--turbo-rails.js` (jspm `--` names). Pins now resolve; `application.js` calls `Turbo.start()` because the vendored ESM build does not auto-start. |
| **B2** | Picker filter works once Stimulus boots (controller was already on `.picker`). |
| **M1** | Recipe form: `minmax(0, 1fr)` on Tiempo/Rinde/Kcal; ingredient rows wrap 2 columns inside the 640px card; inputs `width: 100%; min-width: 0`. |
| **M2** | Cant. `step="any"` `min="0.01"` so whole numbers like `2` are valid. |
| **M3** | Nested-form Stimulus starts with B1. |
| **M4** | `data-turbo-confirm` runs once Turbo boots (Vaciar / Eliminar already had the attributes). |
| **M5** | Spanish AR translations in `config/locales/es.yml` (email taken, restrict_dependent_destroy, attributes). |
| **M6** | Slot “Quitar” is 44×44 with stronger danger contrast. |
| **m1** | Brand is household name (`Mi hogar`), not a second “Semana”; nav stays one wrapping row on mobile. |
| **m2** | Selected chips use `chip--active` + `aria-current`; “Todas” / “Cualquiera” clear filters. |
| **m3** | Slot servings has unique input ids (fixes “Porc. Porc.”) and an OK submit; notice “Platillo actualizado.” |
| **m4** | `db/seeds.rb` deletes leftover `Review Mix%` / `Review Nested%` recipes. |
| **m5** | `Tag#label` maps slugs to Spanish (`desayuno_rapido` → “Desayuno rápido”). |
| **m6** | Failed search CTA is “Limpiar búsqueda”; empty library still offers “Crear la primera receta”. |
| **m7** | Flash is a fixed `.toast-stack` that auto-dismisses via existing `toast` controller (copy unchanged). |
| **m8** | Day headers use `day.name` (“Lunes”); compact-card spacing tightened. |
| **m9** | Form pages use `.page-header` (title left under the back link). |
| **m10** | `native-validation` Stimulus controller sets Spanish HTML5 messages. |

## UI-review fix round 2

Fixes for `docs/ui-review.md` Round 2 NEEDS-WORK. No data-model or ADR changes. No new gems.

| Finding | Change |
|---------|--------|
| **B2** | `.picker__item[hidden] { display: none !important; }` so Stimulus `hidden` wins over `display: flex`. Typing in the picker now visually hides non-matches. |
| **N1** | `nested-form` skips HTML5 constraint validation on rows marked Quitar (`_destroy`) and on fully empty cloned rows (disable fields before submit, restore if validation fails elsewhere). Extra Cant. `0.0` no longer blocks “Crear receta”. |
| **N2** | `.picker__close` is at least 24×24 (`min-width`/`min-height`, inline-flex). |
