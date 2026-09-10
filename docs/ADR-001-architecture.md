# ADR-001 — Architecture

- Status: Accepted
- Date: 2026-09-09
- Deciders: Architect (Rails pipeline stage 2)
- Rails: 8.1.3.1 · Ruby as on the machine · PostgreSQL
- Reference apps: Campfire (Hotwire, lean deps), Writebook (small models, no extra auth gem), Fizzy (thin REST controllers, Stimulus)

This ADR is the non-negotiable technical contract. The developer may not change the data model, gem list, auth approach, or Hotwire approach without a new ADR. `docs/spec.md` is the numbered gap list that implements this ADR against the already-partial codebase.

---

## 1. Context

The household meal planner is a Rails 8.1 app: weeks → menu days → recipes → shopping lists. Design is complete (`docs/00`–`docs/07`). Implementation is partial: 12 tables, 8 controllers, views, and routes exist; `test/` does not.

Design language is Spanish (HOGAR, PLATILLO, MENU_DIA). The running schema uses English table/column names. That English schema is the locked contract — not a defect. Spanish remains UI copy only.

Jobs to be done (v1): fill 21 slots (7 × Desayuno/Comida/Cena), generate one merged shopping list, two-user household without login.

---

## 2. Decision

### 2.1 Shape of the app

Server-rendered Hotwire (Campfire/Fizzy), not an SPA. Lean Gemfile (Writebook). English models, Spanish UI, locale `:es`.

v1 is a **single shared household with no authentication**. The `users` table exists for settings and recipe authorship (`planificador` | `cocinero`). Sessions are not enforced. Revisit only when the client portal leaves the parking lot (`docs/02`, `docs/07`).

### 2.2 Existing schema is the data-model contract

`db/schema.rb` (version `2026_09_09_044056`) is the locked data model, with **one required corrective migration** (see §3.13). English names map to the Spanish ERD in `docs/03-data-model.md` as follows and must not be renamed:

| ERD (03) | Table | Notes |
|----------|-------|-------|
| HOGAR | `households` | |
| USUARIO | `users` | |
| SEMANA | `weeks` | `fecha_inicio` → `start_date`; `num_personas` → `people_count` |
| DIA | `days` | `nombre_dia` is derived, not stored |
| MENU_DIA | `menu_days` | `tipo_comida` → `meal_type`; `numero_porciones` → `servings` |
| PLATILLO | `recipes` | `tiempo_preparacion_min` → `prep_time_min`; `porciones_base` → `base_servings`; `id_autor` → `author_id` |
| PLATILLO_INGREDIENTE | `recipe_ingredients` | surrogate `id` PK + unique pair |
| INGREDIENTE | `ingredients` | `unidad_base` → `base_unit`; `precio_unitario` → `unit_price` |
| ETIQUETA | `tags` | |
| PLATILLO_ETIQUETA | `recipe_tags` | surrogate `id` PK + unique pair |
| LISTA_COMPRAS | `shopping_lists` | one per week |
| ITEM_LISTA | `list_items` | `cantidad_total` → `quantity`; `comprado` → `purchased` |

Do **not** add: `difficulty` column (product brief mentions it; ERD does not — filter via tags), `COMPONENTE` / leftovers entity (v2), Active Storage photos (v2), Action Text, composite primary keys.

### 2.3 Open questions — locked for v1

| Question | v1 decision |
|----------|-------------|
| Leftovers as slot type? | No. Leftovers are a recipe like any other. |
| Spanish vs bilingual? | Spanish-only UI. `config.i18n.default_locale = :es`. |
| Batch cooking COMPONENTE? | v2. |
| Show `unit_price` / list cost? | Persist the column; **do not display cost** (nobody maintains prices). |
| Recipe photos? | v2. No Active Storage. |
| `tipo_comida` enum vs table? | Frozen string enum `desayuno \| comida \| cena`. No settings editor. |
| Drag-and-drop swap (F3)? | v1.1. Assign via picker only. Do not block launch. |
| ViewComponent gem? | No. ERB partials named after `docs/06-components.md`. |
| Difficulty filter? | Tags only. Delete the broken `Recipe.by_difficulty` scope (references a non-existent column). |

### 2.4 Authentication / authorization

- No `bcrypt`, no Rails 8 generated auth, no Devise, no session gate.
- `ApplicationController` exposes `current_household` = `Household.first || Household.create!(name: "Mi hogar")`. v1 has exactly one household.
- Roles are data, not permissions. Any visitor can plan, cook-label, and shop.

### 2.5 Hotwire / Turbo / Stimulus

- **Turbo Drive** on (vendored `@hotwired/turbo-rails` via importmap — do not add the `turbo-rails` gem; JS is already in `vendor/javascript/`).
- **Turbo Frames**: recipe picker modal (`turbo-frame#recipe-picker`). Host an empty frame in the layout or week show. `menu_days#new` renders inside that frame (`layout: false` is correct for frame responses).
- **Turbo Streams**: not required in v1. Full-page redirects after assign/remove/generate are acceptable.
- **Stimulus** (vendored `@hotwired/stimulus`): `toast`, `picker-filter`, plus a new `nested-form` controller for ingredient rows. Start Stimulus **once**.
- **Action Cable**: railtie stays (Rails default); no channels in v1.
- No React/Vue/Tailwind. Tokens live as CSS custom properties in `app/assets/stylesheets/application.css`, names identical to `docs/05-style-guide.md`.

### 2.6 Action Text / Active Storage

Both stay **off** (`config/application.rb` already comments them out). Recipe `instructions` and `description` are plain `text`. No photos.

### 2.7 UI components

Implement `docs/06-components.md` as **partials**, not ViewComponent classes. CSS class names already in `application.css` are the contract (`app-shell__*`, `week-grid`, `meal-slot`, `recipe-card-compact`, `picker`, `toast`, `empty-state`, `btn`, tokens). Extract inline markup into the partials listed in `docs/spec.md`. No raw hex in new CSS; no new spacing values outside `4 · 8 · 12 · 16 · 24 · 32 · 48`.

### 2.8 Routes mirror the sitemap (`docs/02`)

```
App
├── Week Planner     root + /weeks/:id
├── Recipes          /recipes
├── Shopping Lists   /shopping_lists
└── Settings         /settings
```

Health check `/up` stays. No extra top-level resources (no `/ingredients`, no `/tags` CRUD in v1). Ingredients are created by name from the recipe form (`find_or_create_by!`).

### 2.9 Shopping-list rules (unchanged from 03, already in `ShoppingList#regenerate!`)

- Scale: `quantity * menu_day.servings / recipe.base_servings`.
- Merge: same `(ingredient_id, unit)` only. `500 g` + `1 kg` → two rows. No unit conversion in v1.
- `weeks.people_count` is the **default servings** when assigning a slot. It does **not** multiply the list a second time (that would double-scale).
- Regenerating a list destroys existing `list_items` (purchased state is lost). Intended.

### 2.10 Testing

Enable `rails/test_unit` (currently commented out). Tester owns `test/` from scratch (stage 4) against the numbered plan in `docs/spec.md`. Developer does not need to write the suite, but must not make it untestable (stable selectors, no auth wall, seeds idempotent).

---

## 3. Final data model (NON-NEGOTIABLE)

Every table, column, type, association, index, validation. Types as in `db/schema.rb`. Do not add/rename/remove columns except the one migration in §3.13.

Conventions for all tables: `id` bigint PK, `created_at`/`updated_at` datetime `null: false`.

### 3.1 `households`

| Column | Type | Constraints |
|--------|------|-------------|
| `name` | string | model: presence. DB currently nullable — leave DB as-is. |

Associations: `has_many :users, dependent: :destroy`; `has_many :weeks, dependent: :destroy`; `has_many :recipes, through: :users`; `has_many :shopping_lists, through: :weeks`.

### 3.2 `users`

| Column | Type | Constraints |
|--------|------|-------------|
| `email` | string | unique index; model: presence, uniqueness, `URI::MailTo::EMAIL_REGEXP` |
| `role` | string | model: inclusion in `planificador`, `cocinero`; `allow_nil: true` |
| `household_id` | bigint | `null: false`, FK → `households`, index |

Associations: `belongs_to :household`; `has_many :recipes, foreign_key: :author_id, dependent: :nullify, inverse_of: :author`.

### 3.3 `weeks`

| Column | Type | Constraints |
|--------|------|-------------|
| `start_date` | date | `null: false`; always Monday (normalized in model); unique with `household_id` |
| `people_count` | integer | `null: false`, default `2`; model: integer `> 0` |
| `household_id` | bigint | `null: false`, FK → `households`, index |

Indexes: unique `(household_id, start_date)`; index `household_id`.

Associations: `belongs_to :household`; `has_many :days, dependent: :destroy`; `has_one :shopping_list, dependent: :destroy`.

Behaviour that is part of the contract:

- `Week.normalize_start_date` / setter rolls any date back to Monday (`beginning_of_week(:monday)`).
- `Week.for_household_and_date(household, date)` find-or-initialize.
- `build_days!` creates 7 `days` (Mon–Sun) if none exist.
- `copy_from(other)` copies slots by weekday offset, `find_or_create_by(meal_type)` — **does not overwrite** filled slots.
- `label` → `"Semana del #{I18n.l(start_date, format: :short)}"`.
- `filled_slot_count`, `full?` (≥ 21).

### 3.4 `days`

| Column | Type | Constraints |
|--------|------|-------------|
| `date` | date | `null: false`; unique with `week_id` |
| `week_id` | bigint | `null: false`, FK → `weeks`, index |

Indexes: unique `(week_id, date)`; index `week_id`.

Associations: `belongs_to :week`; `has_many :menu_days, dependent: :destroy`.

Derived: `name` / `short_name` from `I18n.l(date)` (Spanish once locale is `:es`). `menu_for(meal_type)`.

### 3.5 `menu_days`

| Column | Type | Constraints |
|--------|------|-------------|
| `meal_type` | string | `null: false`; inclusion `desayuno`, `comida`, `cena` (`Week::MEAL_TYPES`) |
| `servings` | integer | `null: false`, default `1`; model: integer `> 0` |
| `day_id` | bigint | `null: false`, FK → `days`, index |
| `recipe_id` | bigint | `null: false`, FK → `recipes`, index |

Indexes: unique `(day_id, meal_type)` — at most one platillo per meal type per day. Same recipe may appear on the same day in a different meal type.

Associations: `belongs_to :day`; `belongs_to :recipe` (required — empty slot = **no row**).

`scale_factor` = `servings.to_f / recipe.base_servings.to_f`.

**Model bug to fix (not a schema change):** current validation is `validates :recipe_id, uniqueness: {scope: [:day_id, :meal_type]}`. That does not match the unique index. Replace with `validates :meal_type, uniqueness: {scope: :day_id}`.

Deleting a recipe that is planned: `Recipe has_many :menu_days, dependent: :restrict_with_error`. The week-planner “Receta eliminada” branch is defensive only; it cannot occur while `recipe_id` is `null: false`. Do not nullify.

### 3.6 `recipes`

| Column | Type | Constraints |
|--------|------|-------------|
| `name` | string | `null: false`; model: presence |
| `description` | text | optional; short card summary |
| `instructions` | text | optional; plain text steps |
| `prep_time_min` | integer | optional; model: integer `> 0` if present |
| `base_servings` | integer | `null: false`, default `4`; model: integer `> 0` |
| `calories_per_serving` | integer | optional; model: integer `> 0` if present |
| `author_id` | bigint | nullable, FK → `users`, index |

Associations: `belongs_to :author, class_name: "User", optional: true`; `has_many :recipe_ingredients, dependent: :destroy`; `has_many :ingredients, through: :recipe_ingredients`; `has_many :recipe_tags, dependent: :destroy`; `has_many :tags, through: :recipe_tags`; `has_many :menu_days, dependent: :restrict_with_error`.

Must add: `accepts_nested_attributes_for :recipe_ingredients, allow_destroy: true, reject_if: :all_blank`.

Scopes kept: `search(term)` (ILIKE name/description), `by_tag(tag_id)`, `by_max_time(minutes)`. **Delete** `by_difficulty`.

### 3.7 `ingredients`

| Column | Type | Constraints |
|--------|------|-------------|
| `name` | string | `null: false`, unique index; model: presence, uniqueness |
| `base_unit` | string | `null: false`, default `"pieza"`; model: presence |
| `unit_price` | decimal(10,2) | optional; model: `>= 0` if present |
| `category` | string | `null: false`, default `"abarrotes"`; inclusion `verduleria`, `carniceria`, `abarrotes`, `otros` |

Associations: `has_many :recipe_ingredients, dependent: :destroy`; `has_many :recipes, through: :recipe_ingredients`; `has_many :list_items, dependent: :destroy`.

No ingredients controller in v1. Create via `Ingredient.find_or_create_by!(name:)` from the recipe form (default `base_unit: "pieza"`, `category: "abarrotes"` unless provided).

### 3.8 `recipe_ingredients`

| Column | Type | Constraints |
|--------|------|-------------|
| `quantity` | decimal(10,2) | `null: false`, default `0`; model: presence, `> 0` |
| `unit` | string | `null: false`; model: presence |
| `prep_note` | string | optional |
| `recipe_id` | bigint | `null: false`, FK, index |
| `ingredient_id` | bigint | `null: false`, FK, index |

Indexes: unique `(recipe_id, ingredient_id)`.

Associations: `belongs_to :recipe`; `belongs_to :ingredient`.

### 3.9 `tags`

| Column | Type | Constraints |
|--------|------|-------------|
| `name` | string | `null: false`, unique index; model: presence, uniqueness |
| `description` | text | optional |

Associations: `has_many :recipe_tags, dependent: :destroy`; `has_many :recipes, through: :recipe_tags`.

Seeded names are the v1 vocabulary. No tags controller.

### 3.10 `recipe_tags`

| Column | Type | Constraints |
|--------|------|-------------|
| `recipe_id` | bigint | `null: false`, FK, index |
| `tag_id` | bigint | `null: false`, FK, index |

Indexes: unique `(recipe_id, tag_id)`.

Associations: `belongs_to :recipe`; `belongs_to :tag`. Validation: `tag_id` uniqueness scoped to `recipe_id`.

### 3.11 `shopping_lists`

| Column | Type | Constraints |
|--------|------|-------------|
| `week_id` | bigint | `null: false`, FK, **unique** index (one list per week) |

Associations: `belongs_to :week`; `has_many :list_items, dependent: :destroy`.

`regenerate!` is the scaling/merge implementation. Keep the `[ingredient_id, unit]` key. Helpers: `total_items`, `purchased_count`, `complete?`.

### 3.12 `list_items`

| Column | Type | Constraints |
|--------|------|-------------|
| `quantity` | decimal(10,2) | `null: false`, default `0`; model: presence, `> 0` |
| `unit` | string | `null: false`; model: presence |
| `purchased` | boolean | `null: false`, default `false` |
| `shopping_list_id` | bigint | `null: false`, FK, index |
| `ingredient_id` | bigint | `null: false`, FK, index |

Associations: `belongs_to :shopping_list`; `belongs_to :ingredient`.

### 3.13 Required migration (the only allowed schema change)

**Defect:** unique index `index_list_items_on_shopping_list_id_and_ingredient_id` on `(shopping_list_id, ingredient_id)` makes the v1 merge rule impossible. `ShoppingList#regenerate!` keys on `[ingredient_id, unit]` and will raise if two recipes use the same ingredient with different units.

**Fix** (new migration, do not edit the old one):

```ruby
class FixListItemsUniqueness < ActiveRecord::Migration[8.1]
  def change
    remove_index :list_items, name: "index_list_items_on_shopping_list_id_and_ingredient_id"
    add_index :list_items,
              [:shopping_list_id, :ingredient_id, :unit],
              unique: true,
              name: "index_list_items_on_list_ingredient_and_unit"
  end
end
```

Model: `validates :ingredient_id, uniqueness: {scope: [:shopping_list_id, :unit]}`.

Any other schema change is a violation.

### 3.14 Foreign keys (already in schema — keep)

`days.week_id` → `weeks`; `list_items` → `ingredients`, `shopping_lists`; `menu_days` → `days`, `recipes`; `recipe_ingredients` → `ingredients`, `recipes`; `recipe_tags` → `recipes`, `tags`; `recipes.author_id` → `users`; `shopping_lists.week_id` → `weeks`; `users.household_id` → `households`; `weeks.household_id` → `households`.

---

## 4. Gem list (LOCKED)

`Gemfile.lock` may only change as a consequence of this list. Adding any other gem is a review-gate failure.

### 4.1 Keep (already in Gemfile)

| Gem | Constraint | Rationale |
|-----|------------|-----------|
| `rails` | `~> 8.1.3`, `>= 8.1.3.1` | App framework. Do not bump major/minor outside 8.1.x. |
| `pg` | `~> 1.1` | PostgreSQL. |
| `puma` | `>= 5.0` | App server. |
| `importmap-rails` | unpinned | JS via import maps; pins live in `config/importmap.rb` + `vendor/javascript/`. |
| `bootsnap` | unpinned, `require: false` | Boot cache. |
| `thruster` | unpinned, `require: false` | Puma HTTP/2 + asset cache (production). |
| `tzinfo-data` | windows/jruby only | Keep the generator line. |
| `json` | `~> 2.21` | **Required pin** — Rails 8.1 incompatibility with json 3. Do not remove. |
| `debug` | `:development, :test` | Debugger. |
| `bundler-audit` | `:development, :test`, `require: false` | `bin/bundler-audit` / CI. |
| `web-console` | `:development` | Dev console. |

### 4.2 Add

| Gem | Group | Constraint | Rationale |
|-----|-------|------------|-----------|
| `propshaft` | default | unpinned (latest 8.1-compatible) | **Missing asset pipeline.** CSS lives in `app/assets/stylesheets/application.css`; without Propshaft `stylesheet_link_tag` cannot serve it. Rails 8 default; leaner than Sprockets. |
| `capybara` | `:test` | unpinned | System tests (tester). |
| `selenium-webdriver` | `:test` | unpinned | Rails 8 default system-test driver. |

### 4.3 Do not add

`turbo-rails`, `stimulus-rails` (JS already vendored), `view_component`, `bcrypt`, `devise`, `tailwindcss-rails`, `sprockets-rails`, `redis`, `solid_cache`, `solid_queue`, `solid_cable`, `kamal`, `image_processing`, `jsbundling-rails`, `cssbundling-rails`, `rspec-rails` (Minitest/test-unit only).

Unreleased / git gems are forbidden.

---

## 5. Routes, controllers, views

### 5.1 Routes (target)

```ruby
Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "weeks#show"

  resources :weeks, only: [:show, :update] do
    member do
      post :copy          # param: source_week_id
      post :clear
      post :shopping_list, to: "shopping_lists#create"
    end
    resources :days, only: [] do
      resources :menu_days, only: [:new, :create, :update, :destroy]
    end
  end

  resources :recipes do
    collection { get :search }
  end

  resources :shopping_lists, only: [:index, :show] do
    member { patch :toggle_item }  # param: item_id
  end

  get "settings", to: "settings#index", as: :settings
  resources :households, only: [:update]
  resources :users, only: [:new, :create, :edit, :update, :destroy]
end
```

Changes vs current `config/routes.rb`: copy becomes POST (today it is a mutating GET); add `weeks#clear`; add `menu_days#update`; drop `households#show/#edit` (settings owns that UI); keep `settings_path` helper.

`WeeksController#show` **must honor `params[:id]`** when present; only use `params[:date] || Date.today` on `root`. Today it ignores `:id`, so assigning a recipe on a non-current week redirects to `/weeks/:id` and then re-loads **today**. That is a functional defect.

Week prev/next links must work for weeks that do not yet exist: link with `root_path(date: monday)` (or `week_path` after find-or-create). Do not hide the next-week control just because the row is missing.

### 5.2 Controllers (keep thin, RESTful — Fizzy)

Existing: `ApplicationController`, `WeeksController`, `MenuDaysController`, `RecipesController`, `ShoppingListsController`, `SettingsController`, `HouseholdsController`, `UsersController`.

No new resource controllers. Add actions: `weeks#clear`, `menu_days#update`. Extract `current_household`. Permit nested `recipe_ingredients_attributes` (already permitted — model must accept them). Recipe create may receive `return_week_id`, `return_day_id`, `return_meal_type` for F5 (create recipe while planning → assign into the slot).

### 5.3 Views

Spanish copy throughout. Layout is AppShell (C-01). Screen specs: `docs/screens/week-planner.md` is the only written screen spec; recipes / shopping list / settings follow the same Given/When/Then bar even though their spec files are still “Not started”.

---

## 6. Conventions

### 6.1 Naming

- Models/tables/columns: English, Rails defaults (`MenuDay`, `menu_days`, `meal_type`).
- UI strings: Spanish (`Desayuno`, `Generar lista de compras`, `Quitar`).
- CSS: token names from `docs/05-style-guide.md` (`--action`, `--space-4`, `--radius-md`, …).
- Partials: names from `docs/06-components.md` (see spec).
- Stimulus controllers: kebab-case identifiers (`picker-filter`, `nested-form`, `toast`).

### 6.2 Tests (when tester runs)

- Framework: Minitest via `rails/test_unit` (enable the railtie).
- `test/models/*_test.rb` — validations, `Week` date math, `ShoppingList#regenerate!` (scaling + two-unit merge).
- `test/controllers` — **do not add**. Use **request specs**: `test/integration/*_test.rb` (Rails integration tests) for HTTP + redirects + persistence.
- `test/system/*_test.rb` — Capybara flows F1, F2, F4, F5 and the three week-planner scenarios.
- Fixtures or inline setup; if fixtures, keep them minimal. Prefer `Model.create!` in tests so they document the contract.
- No RSpec.

### 6.3 Version control

- Conventional Commits: `feat:`, `fix:`, `chore:`, `docs:`, `test:`, `refactor:`. Scope optional (`feat(planner): …`).
- One logical change per commit. Migration + matching model validation in the **same** commit.
- No force-push to `main`. No amending published history.
- No secrets in git (`config/master.key`, `.env.local`, `RENDER_API_KEY`).
- No gems from git branches / unreleased versions.
- Developer must not edit `docs/ADR-001-architecture.md` or `docs/spec.md`.

### 6.4 Code style

- No explanatory comments unless the user asked (reference-apps ethos).
- No new dependencies to paper over a missing partial.
- Strong params on every write.
- CSRF stays on. Mutating actions are POST/PATCH/DELETE, never GET (`weeks#copy` is currently GET — fix).

---

## 7. Consequences

**Positive**

- Developer has a frozen schema, a one-line migration, and a closed gem list.
- v1 stays dogfoodable for one household on Sunday without auth or extra JS frameworks.
- Tester can write Capybara scenarios that match `docs/screens/week-planner.md` verbatim.

**Negative / follow-through**

- English schema vs Spanish ERD will confuse readers of `docs/03`. Live with it; do not rename.
- No login means the production URL is world-writable. Acceptable for beachhead; must change before any client portal.
- Merge-by-unit without conversion will show `500 g` and `1 kg` as two lines. Documented; v2 problem.
- ViewComponent inventory in `docs/06` is implemented as partials. Do not “complete” it by adding the gem.

**Review gate (stage 4, architect)**

Before tester runs, architect reviews the developer diff:

1. `git diff` vs base: schema/migrations match §3 (only the list_items index migration).
2. `Gemfile` / `Gemfile.lock`: only §4 additions.
3. Commits: conventional, no secrets, no force-push.
4. `gh` PR review: approve or request-changes.
5. Write `docs/review-report.md` with `APPROVED` or `CHANGES-REQUIRED`.

Any silent drift is a failure.

---

## 8. Out of scope (do not build)

- F3 drag-and-drop swap
- Nutrition / macro tracking (product brief)
- Payments, multi-tenant, client portal
- Native mobile
- Recipe website importer (`docs/00` wish)
- Render `render.yaml` (release manager)
- Screen-spec markdown files for recipes/shopping/settings (nice; not required to ship if the numbered spec is followed)
