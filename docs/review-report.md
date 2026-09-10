# Review report — stage 4 gate

- Reviewer: Architect
- Date: 2026-09-09
- Contract: `docs/ADR-001-architecture.md` + `docs/spec.md` §1–§13
- Developer artifact: `docs/implementation-notes.md`
- Scope: working tree vs `main` (uncommitted; no PR). §14 tests are tester-owned and were correctly left unstarted.
- gh PR: none — nothing is committed, so there is no PR to approve. This report is the gate.

## Verdict

**APPROVED**

No contract failures. The developer may group the working tree into conventional commits (see §6); the tester may start §14.

---

## 1. Spec §1–§13 vs implementation

| Section | Result | Notes |
|---------|--------|--------|
| 1.1 Propshaft | PASS | `gem "propshaft"` in default group. `/` emits `/assets/application-*.css`; that URL 200s (`text/css`). |
| 1.2 Test gems | PASS | `capybara`, `selenium-webdriver` in `:test` only. |
| 1.3 Test::Unit | PASS | `require "rails/test_unit/railtie"`; `config.generators.system_tests` is `:test_unit` (not `nil`). |
| 1.4 Locale / TZ | PASS | `default_locale = :es`, `time_zone = America/Mexico_City`. `I18n.l(Date.new(2026,8,24), format: :short)` → `24 ago`. Monday `Day#name` → `Lunes`. |
| 1.5 `current_household` | PASS | Single lookup in `ApplicationController`. Controllers use the helper. No auth. |
| 2.1 list_items index | PASS | See §2 below. |
| 3.1–3.7 Models | PASS | Uniqueness, nested attrs, `find_or_create_named!` idempotent, `clear!` keeps 7 days, ±7 navigation dates, `by_difficulty` gone from `app/`. |
| 4.1–4.3 Stimulus | PASS | One `Application.start()` in `controllers/index.js`. `picker-filter` is on `.picker` wrapping input + list. `nested-form` registered; importmap pin present. |
| 5.1 Routes | PASS | POST copy, POST clear, PATCH menu_day, GET `/settings` as `settings`. GET copy 404. `/households/:id/edit` 404. |
| 6.1–6.8 Controllers | PASS | `#show` honors `:id` on `/weeks/:id`, root uses `params[:date] \|\| Date.current`. Copy is POST + household-scoped. Clear notice `"Semana vaciada."`. Personas PATCH. Assign default servings = `people_count`. F5 return params assign the slot. Nested ingredient names → `find_or_create_named!`. |
| 7.1–7.6 Week planner | PASS | Empty `turbo-frame#recipe-picker` in layout. Prev/next always `root_path(date:)`. Toolbar buttons, empty-state hint **and** 7×3 grid, compact card + servings PATCH + Quitar, picker Asignar / Nueva receta / `_top`. |
| 8.1–8.3 Recipes | PASS | Chip filters + ≤15/30/60, C-06 detail with `recipe-instructions` (`white-space: pre-wrap`), instructions textarea, nested rows, return hidden fields. |
| 9.1–9.2 Shopping lists | PASS | Grouped by `Ingredient::CATEGORIES`, toggle ✓/↺, no `unit_price` / cost, Regenerar is `button_to` POST. Index is weeks-with-lists. |
| 10.1 Settings | PASS | Household name PATCH, members CRUD, read-only “Tipos de comida: Desayuno, Comida, Cena”. |
| 11.1 Partials C-01–C-12 | PASS | All targets exist (C-10 = `.btn` CSS). Extra `_ingredient_fields.html.erb` is a legitimate nested-form extract, not drift. |
| 12.1 Seeds | PASS | 10 recipes kept; current week + 7 days after seed; idempotent `find_or_create`. |
| 13.1–13.3 CSS / nav / CI | PASS | No `style=` in `app/views`. Tokens unchanged. Nav Semana / Recetas / Listas / Ajustes, `lang="es"`. `config/ci.rb` has `bin/rails test` and `bin/rails test:system`. |
| 14 Tests | N/A | Tester stage. `test/` still absent, as specified. |
| 15 Out of scope | PASS | No F3, difficulty column, Active Storage, Action Text, ViewComponent, auth gems, cost UI, meal-type editor, `render.yaml`, RSpec, Turbo Streams. |

HTTP smoke (modern UA, `localhost`): `/`, `/weeks/:id`, `/recipes`, `/recipes/new`, `/shopping_lists`, `/settings`, `/up` → 200. Digested CSS → 200. `/households/1/edit` → 404. GET `/weeks/:id/copy` → 404.

---

## 2. Schema / migration

Only allowed change: `db/migrate/20260909120000_fix_list_items_uniqueness.rb`.

Class body matches ADR §3.13 verbatim:

- drop `index_list_items_on_shopping_list_id_and_ingredient_id`
- unique `(shopping_list_id, ingredient_id, unit)` named `index_list_items_on_list_ingredient_and_unit`

`db/schema.rb` version `2026_09_09_120000`. Diff vs previous schema is **only** that index (plus version stamp). All other tables/columns/FKs/indexes match the locked model. `ListItem` validation is `uniqueness: {scope: [:shopping_list_id, :unit]}`.

Runner check: mixed units of one ingredient → two rows (`500.0 g | 1.0 kg`); same unit rejected; different unit accepted.

---

## 3. Gemfile / Gemfile.lock

Allowed additions only:

- `propshaft` (1.3.2) + deps
- `capybara` (3.40.0) + deps
- `selenium-webdriver` (4.49.0) + deps

Kept: `rails ~> 8.1.3, >= 8.1.3.1`, `json ~> 2.21`, no version drift on existing gems.

Not added (forbidden): `turbo-rails`, `stimulus-rails`, `view_component`, `bcrypt`, `devise`, `tailwindcss-rails`, `sprockets-rails`, `redis`, `solid_*`, `kamal`, `image_processing`, `jsbundling-rails`, `cssbundling-rails`, `rspec-rails`. No git/unreleased gems.

Lockfile DEPENDENCIES and CHECKSUMS are consistent with `bundle install`.

---

## 4. Flagged bugs — actually fixed

| Flagged defect | Status |
|----------------|--------|
| `WeeksController#show` ignores `:id` | Fixed. `params[:id]` → `current_household.weeks.find`; root-only uses date. |
| Mutating GET copy | Fixed. `post :copy`; GET copy is no-route (404). |
| Recipe nested attributes dead | Fixed. `accepts_nested_attributes_for` + permitted `recipe_ingredients_attributes` + `find_or_create_named!`. |
| `picker-filter` on the `<input>` | Fixed. Controller is on `.picker`; input + `.picker__item` list are in scope. |

No new auth wall. CSRF still on. Writes use strong params. Mutating actions are POST/PATCH/DELETE.

---

## 5. Observations (not failures)

These do **not** block the gate. Tester and a later polish pass should know about them.

1. **N+1 on the week grid.** `weeks#show` does not `includes(days: {menu_days: :recipe})`. `_day_column` calls `day.menu_for` (`find_by`) per meal type → ~21 queries per render. Spec called this minor.
2. **Servings field has no submit control.** Personas has “OK”; slot servings relies on Enter to PATCH. Request tests can PATCH directly; a Capybara `fill_in` without submit will not persist.
3. **Locale `:es` without Active Record translations.** Uniqueness errors surface as `Translation missing: es.activerecord.errors…` (no `rails-i18n` gem — correctly not added). Date copy is fine. Consider a few keys in `es.yml` later, not a gem.
4. **`ShoppingListsController#show` / `#toggle_item` are unscoped** (`ShoppingList.find`). v1 is one household and world-writable, so this matches the ADR; do not treat as an auth hole.
5. **`RecipesController` permits `:author_id`.** `create` overwrites via `assign_author`; `update` could change authorship. Harmless under no-auth v1.
6. **`find_or_create_named!` runs before `recipe.save`.** A failed recipe create can still persist a new `Ingredient`. Acceptable for v1.
7. **Documented implementation details (accepted):** `ShoppingList#regenerate!` `save!` if `new_record?`; virtual `RecipeIngredient#ingredient_name`; `days.order(:date)` in the grid.

---

## 6. Conventional-commit readiness

Working tree is **not committed** (correct — review owns the gate). No secrets (`master.key`, `.env.local`, `RENDER_API_KEY`) in the diff. Developer did not edit the ADR or spec.

History on `main` is already conventional (`chore:`). Suggested grouping when committing (do **not** squash into one blob; keep migration + `ListItem` validation together):

1. `docs: add ADR-001 architecture and spec.md`
2. `chore: add propshaft, capybara, and selenium-webdriver`
3. `fix: unique list_items on shopping_list, ingredient, and unit`
4. `feat: align models, routes, and controllers with spec §3–§6`
5. `feat: week/recipe/list/settings views, partials, locale, and seeds`
6. `docs: add implementation notes`

`PIPELINE.md` status edits are orchestrator-owned; commit separately as `docs: update pipeline status` or leave to the orchestrator.

Policy reminders: no force-push to `main`; no amending published history.

No PR exists, so no `gh` approve/request-changes was possible. This report is the approval artifact.

---

## 7. Developer verification — rechecked

| Claim | Recheck |
|-------|---------|
| `bin/rails db:prepare` | OK; schema version `20260909120000` |
| Locale / Monday / short date | `24 ago`, `Lunes` |
| `system_tests == :test_unit` | true |
| Mixed-unit regenerate → two rows | true |
| Routes: POST copy/clear, no GET copy, no households#edit | true |
| `/`, `/recipes`, `/shopping_lists`, `/settings` 200 | true |
| Digested CSS 200 | true |
| GET copy / households#edit 404 | true |
| `grep by_difficulty app` empty | true |
| `grep Application.start app/javascript` one match | true |
| `grep style= app/views` empty | true |

§14 / `bin/rails test` will fail until the tester creates `test/` — expected.

---

## Verdict (stage 4, original)

APPROVED

---

# Re-review after UI-fix round

- Reviewer: Architect
- Date: 2026-09-09
- Trigger: `docs/ui-review.md` **NEEDS-WORK**; developer applied B1–B2, M1–M6, m1–m10 (see `docs/implementation-notes.md` “UI-review fix round”).
- Scope: working tree on `main` (still uncommitted; no PR). Original §1–§13 approval stands; this pass checks the fix round for ADR/spec drift and that the claimed UI fixes are actually in the tree.
- gh PR: none — still nothing committed.

## Verdict

**APPROVED**

No contract failures. UI-fix round does not change the data model, gem list, auth, or Hotwire/partials approach. Tests re-run green.

---

## 1. Diff vs previously approved state

The whole implementation remains uncommitted on `main` (`388af5e`), so there is no separate fix-round commit. Inspection is of the current working tree vs the original gate notes + `docs/implementation-notes.md` UI-fix table.

Fix-round surface (no schema, no Gemfile additions):

| Area | Files |
|------|--------|
| JS boot (B1) | `config/importmap.rb`, `app/javascript/application.js` |
| Stimulus | `controllers/index.js`, **new** `native_validation_controller.js` (m10); existing `nested_form` / `picker-filter` / `toast` |
| Views / CSS | layout AppShell, picker frame, recipe form, compact card, chips, toast-stack, page-header, 44×44 Quitar |
| Locale | `config/locales/es.yml` AR + HTML5 copy via Stimulus |
| Seeds | delete leftover `Review Mix%` / `Review Nested%` |
| Model (no schema) | `Tag#label` display helper only |

`db/schema.rb` still version `2026_09_09_120000`. Only allowed migration remains `FixListItemsUniqueness`. No new tables/columns/indexes.

---

## 2. ADR / spec contract

| Check | Result |
|-------|--------|
| Data model | PASS — schema unchanged from original approval |
| Gems | PASS — `Gemfile` / lock DEPENDENCIES still only allowed extras: `propshaft`, `capybara`, `selenium-webdriver`. No `turbo-rails` / `stimulus-rails` / `view_component` / auth gems / RSpec |
| No-auth v1 | PASS — `current_household` only; no session gate |
| Hotwire / partials | PASS — vendored importmap Turbo/Stimulus; picker in `turbo-frame#recipe-picker`; ERB partials C-01–C-12; no Turbo Streams; no Action Text / Active Storage |
| Stimulus start-once | PASS — one `Application.start()` in `controllers/index.js` |
| Routes | PASS — ADR §5.1 unchanged |
| `style=` in views | PASS — none |
| `by_difficulty` | PASS — absent from `app/` |
| Developer did not edit ADR/spec | PASS |

`native-validation` is an extra Stimulus controller (not named in spec 4.1). Allowed: no new gem, does not replace the required three, needed for m10.

---

## 3. Spot-check of UI-review findings

| ID | Status | Evidence |
|----|--------|----------|
| **B1** Turbo/Stimulus boot + picker modal | PASS | Importmap JSON: `"@hotwired/turbo-rails" → /assets/@hotwired--turbo-rails-*.js` (jspm `--` filenames). `application.js` imports turbo-rails, `{ start } from "@hotwired/turbo"`, calls `start()`. Layout hosts empty `turbo-frame#recipe-picker`; `menu_days#new` renders that frame (`layout: false`); `+` is `data-turbo-frame="recipe-picker"`; `.picker-overlay` is `position: fixed`. |
| **B2** picker-filter | PASS | `data-controller="picker-filter"` on `.picker` wrapping search input + `.picker__item` list. Works once Stimulus boots. |
| **M1** recipe form overflow | PASS | `.form-grid-3 { minmax(0, 1fr) }`; `.ingredient-fields` 2-col wrap inside card; inputs `width: 100%; min-width: 0`; 1-col under 900px. |
| **M2** whole-number quantity | PASS | `step: "any"`, `min: 0.01`. F5 system test now submits Cant. `2` (was 2.01). |
| **M3** Agregar ingrediente | PASS | `nested-form` registered; template + “Agregar ingrediente” button present. |
| **M4** confirm on destructive | PASS | Vaciar `data-turbo-confirm`; Eliminar / member delete `form: { data: { turbo_confirm: } }`. Requires Turbo (B1). |
| **M5** Spanish AR errors | PASS | `es.yml` `errors.messages.taken`, `restrict_dependent_destroy.has_many`, user email taken, recipe base restrict message. |
| **M6** Quitar 44×44 | PASS | `.recipe-card-compact__remove { min-width/min-height: 44px }` + stronger danger contrast. |
| **m1** brand vs Semana | PASS | Brand = `current_household.name`; nav still Semana / Recetas / Listas / Ajustes. |
| **m2** chip selected + clear | PASS | `chip--active` + `aria-current`; “Todas” / “Cualquiera”. |
| **m3** slot servings OK | PASS | Unique `id` per slot; OK submit; notice `"Platillo actualizado."` |
| **m4** seed cleanup | PASS | `db/seeds.rb` destroys `Review Mix%` / `Review Nested%` / `% UI` leftovers. |
| **m5** tag labels | PASS | `Tag#label` maps slugs (`desayuno_rapido` → “Desayuno rápido”). |
| **m6** empty-search CTA | PASS | Filtered empty → “Limpiar búsqueda”; empty library → “Crear la primera receta”. |
| **m7** toast | PASS | Fixed `.toast-stack`; `toast` controller removes after 4s; copy unchanged. |
| **m8** day headers | PASS | `day.name` (“Lunes”). |
| **m9** form titles | PASS | `.page-header` title under back link. |
| **m10** HTML5 Spanish | PASS | `native-validation` on `<body>` sets Spanish `setCustomValidity` messages. |

---

## 4. Tests (re-run this pass)

| Command | Result |
|---------|--------|
| `bin/rails test` | **107 runs, 292 assertions, 0 failures, 0 errors, 0 skips** |
| `bin/rails test:system` | **9 runs, 37 assertions, 0 failures, 0 errors, 0 skips** |

Matches the developer claim (107 + 9). Delta vs original tester report (106 model/integration) is the added `Tag#label` example — not a contract issue. F5 system test quantity `2` confirms M2.

Importmap resolver check: pins resolve to digested `/assets/@hotwired--*.js` and all four Stimulus controllers.

---

## 5. Conventional-commit readiness

Still **uncommitted** (correct — gate owns the commit). No secrets in the tree (`master.key`, `.env.local`, `RENDER_API_KEY` absent from the diff).

**Do not commit:** repo-root UI-review PNGs (`recipe-picker-fullpage.png`, …), `.playwright-mcp/`.

Suggested extra commit on top of the original grouping:

7. `fix: boot Turbo via importmap and address UI-review findings`

Keep migration + `ListItem` validation together. `PIPELINE.md` remains orchestrator-owned. No force-push; no amending published history. No PR exists, so no `gh` review.

---

## 6. Observations (not failures)

1. Vendored `@hotwired--turbo.js` already calls `start()` at module eval (`lt()`); the explicit `start()` in `application.js` is redundant and idempotent. The real B1 fix is the `--` importmap `to:` paths.
2. Vaciar semana puts `data-turbo-confirm` on the **button** (`data:`), while Eliminar puts it on the **form**. Turbo 8 reads submitter then form — both work.
3. `min-width/min-height: 44px` is outside the spacing token scale; accepted as the UI-review a11y requirement, not a new spacing token.
4. N+1 on the week grid (original observation) is unchanged.

---

## Verdict

APPROVED

---

# Re-review after UI-fix round 2

- Reviewer: Architect
- Date: 2026-09-09
- Trigger: `docs/ui-review.md` Round 2 **NEEDS-WORK** (B2, N1, N2); developer applied the three CSS/JS fixes (see `docs/implementation-notes.md` “UI-review fix round 2”).
- Scope: working tree on `main` (still uncommitted; no PR). Original §1–§13 approval and UI-fix round 1 approval stand. This pass checks only the round-2 delta for ADR/spec drift and that B2 / N1 / N2 are actually in the tree.
- gh PR: none — still nothing committed.

## Verdict

**APPROVED**

No contract failures. Round-2 changes are CSS/Stimulus only. Data model, gem list, no-auth v1, and Hotwire/partials approach are unchanged. Tests re-run green (107 + 12).

---

## 1. Diff vs previously approved state

The whole implementation remains uncommitted on `main` (`388af5e`), so there is no isolated round-2 commit. Inspection is of the three claimed files plus schema/gems/routes.

Round-2 surface (no schema, no Gemfile, no routes, no controllers, no partials added/removed):

| Finding | File | Change |
|---------|------|--------|
| **B2** | `app/assets/stylesheets/application.css` | `.picker__item[hidden] { display: none !important; }` |
| **N1** | `app/javascript/controllers/nested_form_controller.js` | Skip HTML5 on `_destroy` rows and fully empty cloned rows (disable fields on submit; restore on `invalid`) |
| **N2** | `app/assets/stylesheets/application.css` | `.picker__close` `min-width`/`min-height` 24px, `inline-flex` |

Also present (tester-owned, not drift): three system tests covering the three findings.

`db/schema.rb` still version `2026_09_09_120000`. Only allowed migration remains `FixListItemsUniqueness`. `Gemfile` / lock DEPENDENCIES unchanged from round-1 approval.

---

## 2. ADR / spec contract

| Check | Result |
|-------|--------|
| Data model | PASS — schema unchanged |
| Gems | PASS — only allowed extras: `propshaft`, `capybara`, `selenium-webdriver`. No `turbo-rails` / `stimulus-rails` / `view_component` / auth gems / RSpec |
| No-auth v1 | PASS — `current_household` only; no session gate |
| Hotwire / partials | PASS — picker still `turbo-frame#recipe-picker`; ERB C-01–C-12; no Turbo Streams; no Action Text / Active Storage |
| Stimulus start-once | PASS — one `Application.start()` in `controllers/index.js` |
| Routes | PASS — ADR §5.1 unchanged this round |
| `style=` in views | PASS — none |
| Developer did not edit ADR/spec | PASS |

---

## 3. Spot-check of remaining UI-review findings

| ID | Status | Evidence |
|----|--------|----------|
| **B2** picker search hides non-matches | PASS | `.picker__item` is still `display: flex`; new rule `.picker__item[hidden] { display: none !important; }` so Stimulus `item.hidden` wins. `picker-filter` still sets `hidden` from `data-name`. System test `picker search hides non-matching recipes` asserts `assert_no_selector ".picker__item", text: "Arroz rojo"` after typing “Birria”. |
| **N1** extra nested row does not block create | PASS | `nested-form` `shouldSkip`: `_destroy` checked **or** fully empty (qty blank/0, no ingredient/name/unit/note). `skipInvalidRows` disables those fields on submit (keeps `_destroy` and `id`); `invalid` restores if another field fails. System tests: Quitar-checked extra row, and empty extra row, both create successfully. |
| **N2** picker ✕ ≥24×24 | PASS | `.picker__close { display: inline-flex; min-width: 24px; min-height: 24px; padding: var(--space-1); }`. Markup still `link_to "✕"` with `turbo-frame="_top"`. |

Minimal: no new gems, no new Stimulus controllers, no schema, no view-structure change.

---

## 4. Tests (re-run this pass)

| Command | Result |
|---------|--------|
| `bin/rails test` | **107 runs, 292 assertions, 0 failures, 0 errors, 0 skips** |
| `bin/rails test:system` | **12 runs, 45 assertions, 0 failures, 0 errors, 0 skips** |

Matches the developer claim (107 + 12). Delta vs UI-fix round 1 (9 system tests) is the three coverage tests for B2 / N1 — not a contract issue.

---

## 5. Conventional-commit readiness

Still **uncommitted** (correct — gate owns the commit). No secrets in the tree (`master.key`, `.env.local`, `RENDER_API_KEY` absent from the diff).

**Do not commit:** repo-root UI-review PNGs (`r2-*.png`, `recipe-picker-fullpage.png`, …), `.playwright-mcp/`.

Suggested extra commit on top of the original grouping + round-1 fix commit:

8. `fix: hide picker non-matches and skip empty nested ingredient rows`

Keep migration + `ListItem` validation together. `PIPELINE.md` remains orchestrator-owned. No force-push; no amending published history. No PR exists, so no `gh` review.

---

## 6. Observations (not failures)

1. `!important` on `[hidden]` is the prescribed override of author `display: flex`; do not restyle `.picker__item` to `display: none` by default.
2. Nested-form disables skipped fields rather than removing them, so a failed HTML5 check elsewhere re-enables the extra row (`onInvalid`). Acceptable.
3. Compact-card cramped layout (m8 residual) and leftover Review ingredients in the `<select>` remain nits from UI-review round 2 — not this gate.
4. N+1 on the week grid (original observation) is unchanged.

---

## Verdict

APPROVED
