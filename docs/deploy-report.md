# Deploy report — stage 7 (release manager)

- Date: 2026-09-09
- Release manager: release-manager bot (Rails pipeline)
- Verdict: **PRE-FLIGHT PASSED — DEPLOY BLOCKED (stopped by decision)**

The app is fully verified and pushed to GitHub, but the Render deploy was
stopped at service creation: the workspace has no payment method on file and
Render rejects API-created services with HTTP 402 even on the free plan.
Per the orchestrator's decision, I stopped there. No Render resources were
created; nothing is half-deployed.

---

## 1. Pre-flight results (all PASS)

| # | Check | Result |
|---|-------|--------|
| 1 | `bin/rails db:prepare` on throwaway DB | PASS — fresh `meal_planner_preflight` on local Postgres (docker unavailable without interactive sudo; local server used instead): migrations clean from scratch, schema version `20260909120000`, all 12 tables, seeds ran (`db:prepare` seeds fresh DBs — good for Render) |
| 2 | `RAILS_ENV=production bin/rails assets:precompile` | PASS — 12 digested assets incl. `@hotwired--turbo-*.js` / `@hotwired--stimulus-*.js` (B1 pins) |
| 3 | `bin/rails test` | PASS — 107 runs, 292 assertions, 0 failures/errors/skips |
| 4 | `bin/rails test:system` | PASS — 12 runs, 45 assertions, 0 failures/errors/skips |
| 5 | `bundle audit check --update` | PASS — 1242 advisories, no vulnerabilities (bundler-audit already in Gemfile) |
| 6 | Gemfile.lock sanity | PASS — diff vs HEAD adds only `propshaft`, `capybara`, `selenium-webdriver` + deps, exactly the ADR-approved list; lock committed |
| 7 | Secrets check | PASS — `config/master.key` untracked + gitignored; no `RENDER_API_KEY` / `SECRET_KEY_BASE` / credentials in app, config, db, or test; `.env.local` not in repo |
| 8 | Gates | PASS — `docs/review-report.md` APPROVED (3 rounds), `docs/test-report.md` READY-FOR-RELEASE, `docs/ui-review.md` round 3 USABLE |

App config notes for Render: `/up` health route exists; `config.hosts` is not
set (no blocked-host risk on `*.onrender.com`); `force_ssl`/`assume_ssl` are
on (correct behind Render TLS); production logs to STDOUT; `DATABASE_URL`
overrides `database.yml` production settings.

## 2. Commits (11, conventional; pushed to `origin/main`)

```
a6af136 docs: add ADR-001 architecture and spec
5fcb8b9 chore: add propshaft, capybara, and selenium-webdriver
8fe5390 fix: unique list_items on shopping_list, ingredient, and unit
0a9b70f feat: align models, routes, and controllers with spec
206d5f3 feat: week planner, recipes, lists, and settings views with Hotwire
742eedf test: add model, request, and system suite per spec 14
1d30b0c docs: add implementation notes and stage reports
b1078ac chore: add Render blueprint and ignore build artifacts
fde3b3b chore: run full and system test suites in CI
49e45e1 chore: document shared free-tier Postgres in Render blueprint
```

- Excluded per reviewer: all UI-review PNGs (root `*.png`), `.playwright-mcp/`
  — both now in `.gitignore`, plus `/public/assets` (build artifact).
- `.ruby-version` normalized `ruby-4.0.6` → `4.0.6` (Render expects the bare
  version; mise accepts both).
- The UI-review fix rounds (rounds 1–2) are folded into the `feat:` view/JS
  and `test:` commits — the tree was never committed between rounds, so the
  reviewer's original 8-commit split could not be reproduced exactly.
- `PIPELINE.md` left uncommitted (orchestrator-owned status section).

## 3. render.yaml

Web service `meal-planner` (ruby runtime, free plan, `main`, autoDeploy,
`/up` health check) + build `bundle install && rails assets:precompile &&
rails db:prepare`, start `rails server`. `RAILS_MASTER_KEY` and
`DATABASE_URL` are `sync: false` — never committed. The `databases:` block is
commented out with rationale: the workspace's single free Postgres slot is
taken (see §4), and the agreed plan is to share `sonic-blog-db`.

## 4. Deploy timeline (stopped)

| Step | Result |
|------|--------|
| GitHub repo | `davidzu/meal-planner` created; `main` pushed (10 commits, later 11). Made **public** with orchestrator approval — Render's GitHub App only covered `sonic-blog` and could not fetch the private repo |
| Postgres | `POST /v1/postgres` for a new free DB → `409 cannot have more than one active free tier database` (slot taken by `sonic-blog-db`). Decision: **share** the existing free instance; `meal_planner_production` will be created by `db:prepare` on first deploy (role owns the instance) |
| Web service | `POST /v1/services` iterated to a valid payload (`type: web_service`, `serviceDetails.runtime: ruby`, `envSpecificDetails` build/start) → **HTTP 402: payment information required**, even for the free plan |
| Decision | Orchestrator chose **Stop**. No service, database, or deploy was created; verified via API that only pre-existing `sonic-blog` resources exist |
| Hygiene | Temp files holding the DB password / master key (`/tmp/opencode/*.json/txt`) shredded |

## 5. Live URL / verification

**Not deployed — no live URL.** Verification steps (root 200, key pages, no
boot errors in logs) could not be run.

## 6. Resume checklist (for whoever ships next)

1. Add a payment card at https://dashboard.render.com/billing (API-created
   services require one even on free plans), **or** create the service
   manually in the dashboard using `render.yaml` values.
2. Create web service: repo `davidzu/meal-planner`, branch `main`, ruby
   runtime, oregon region (must match the DB region for internal
   connectivity), build/start/health per `render.yaml`.
3. Env vars: `DATABASE_URL` =
   internal connection string of `dpg-dagdnj740ujc73ens3dg-a` with database
   `meal_planner_production` (get the base string from the sonic-blog
   service's env vars and swap the path); `RAILS_MASTER_KEY` = value of
   `config/master.key` (local, gitignored); `RAILS_LOG_TO_STDOUT=true`;
   `RAILS_SERVE_STATIC_FILES=true`.
4. Push (or trigger a deploy) → poll `GET /v1/services/{id}/deploys` until
   `live`; first build runs `db:prepare`, which creates + migrates + seeds
   `meal_planner_production`.
5. Verify `https://meal-planner.onrender.com`: `/`, `/recipes`,
   `/shopping_lists`, `/settings` 200, `/up` 200, digested assets 200.
6. Optional: make the repo private again — but only after installing the
   Render GitHub App on it, or auto-deploy breaks.

## 7. Issues / observations

1. **Blocker (deploy):** Render 402 on API service creation without a card.
2. **Free-tier limit:** one free Postgres per account; shared-instance
   decision recorded in `render.yaml`. Caveat: free Render Postgres expires
   after ~30 days (sonic-blog-db created 2026-09-09) — plan for it.
3. **Local libpq quirk:** `psql` 18.6 and the `pg` gem both fail against the
   Render DB external endpoint with "SSL connection has been closed
   unexpectedly" while raw `openssl s_client -starttls postgres` completes a
   TLS 1.3 handshake. Worked around by not needing a manual `CREATE
   DATABASE` (`db:prepare` handles it). Worth knowing if you ever need to
   psql into this instance from this machine.
4. **Repo visibility:** `davidzu/meal-planner` is public (approved). No
   secrets are committed (verified twice).
