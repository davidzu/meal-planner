# Meal Planner — Multi-Agent Pipeline

A Rails 8.1 household meal planner (weeks → menu days → recipes → shopping
lists), continued by the orchestrator/bots pipeline. Each stage produces an
artifact that is the contract for the next stage. All agents live in
`.opencode/agent/` (project scope).

## Where this project stands (as of 2026-09-09)

- Design: DONE — `docs/00`–`docs/07` (current-state capture, product brief,
  information architecture, data model, wireframes, style guide, components,
  screen specs) are the design artifacts. `docs/design.md` in the pipeline
  contract refers to this doc set.
- Implementation: PARTIAL — 12 tables in `db/schema.rb`, 8 controllers with
  views and routes (weeks, menu_days, recipes, shopping_lists, users,
  households, settings). Migrations dated 2026-09-09.
- Tests: NONE — `test/` does not exist yet. Large chunk of stage 4.
- Git: initialized 2026-09-09, single initial commit.
- Deploy: no `render.yaml` yet; release manager creates it.

## The agents

| # | Agent (opencode) | Model | Produces |
|---|---|---|---|
| 0 | `orchestrator` (primary) | opencode-go/glm-5.3-flash | Dispatches stages, enforces gates, maintains the Status section below |
| 1 | `researcher-designer` | xai/grok-4.20-multi-agent-0309 (Herd) | `docs/design.md` — SKIPPED here; the 00–07 doc set is the design contract |
| 2 | `architect` | xai/grok-4.6 | `docs/ADR-001-*.md` + `docs/spec.md` — gap analysis vs. docs 02–07, locked data model, gem list |
| 3 | `developer` | xai/grok-4.6 | Code completing the spec + `docs/implementation-notes.md` |
| 4 | `tester` | opencode-go/glm-5.3-flash | Test suite from scratch + `docs/test-report.md` |
| 5 | `ui-reviewer` | xai/grok-4.6 + Playwright MCP | `docs/ui-review.md` — browser usability review (USABLE / NEEDS-WORK) |
| 6 | `release-manager` | opencode-go/glm-5.3-flash | Pre-flight, `render.yaml`, git push, Render deploy |

Permissions are structural: the architect can only write `docs/**`, the
developer cannot edit the spec/ADR, the tester can only write `test/**` and
its report, the ui-reviewer only its report, and only the orchestrator may
spawn subagents (`task: deny` on all bots).

## Handoff contract

Each stage reads the previous stage's artifact and writes the next one.
Never skip a stage. Never let a later stage silently change an earlier
decision — changes flow back through the pipeline.

1. **Design** (complete) → `docs/00`–`docs/07`
2. **Architect** → `docs/ADR-001-architecture.md` + `docs/spec.md`
   - Read the existing code AND docs 02–07; the spec is a numbered gap
     list: what remains to build, mapped to files. The existing schema is
     the data-model contract unless a migration is provably wrong.
3. **Developer** → code in `app/`, `config/`, `db/`, `test/`
   - Implements the spec exactly. Deviations only via an updated ADR.
4. **Review gate** (architect) → `docs/review-report.md`
   - Diff vs. ADR, Gemfile sanity, conventional commits. APPROVED required.
5. **Tester** → `docs/test-report.md`
   - Builds the suite from scratch: models, requests, system tests.
     Verdict READY-FOR-RELEASE or NEEDS-FIXES.
6. **UI Reviewer** → `docs/ui-review.md`
   - Walks the running app in a browser against docs 04–07 (wireframes,
     style guide, screen specs). Verdict USABLE or NEEDS-WORK.
7. **Release Manager** → deploy
   - Pre-flight: `db:prepare` on throwaway DB, asset precompile, full suite,
     `bundle audit`, Gemfile.lock sanity. Creates `render.yaml` if missing,
     then push → Render deploy.

## Review gate

Before Tester runs, the **Architect reviews the developer's diff** (via `gh`
PR review): schema matches the ADR, `Gemfile.lock` only changed per spec,
commits are clean and conventional. No merge without architect approval.

## Render

- Blueprint: `render.yaml` (web service + Postgres) — does not exist yet;
  the release manager writes it as part of pre-flight.
- Deploy: push to `main` triggers Render auto-deploy; the release agent
  confirms via the Render API using `RENDER_API_KEY`.
- `RENDER_API_KEY` is stored locally (not committed) — see `.env.local`.

## Status (maintained by the orchestrator)

- Last assessed: not yet assessed by orchestrator
- Next action: assess current stage from docs/ artifacts and code, then
  dispatch stage 2 (architect gap analysis → spec.md)
