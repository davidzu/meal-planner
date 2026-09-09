# 07 — Screen Specs Index

Status: Draft · Each spec lives in `docs/screens/` and follows `_template.md`.
Contract: a screen is not coded until its spec is written and its wireframe walked through (see `04-wireframes.md`).

| Spec | Screen | Status | Components | Acceptance criteria |
|------|--------|--------|------------|---------------------|
| `week-planner.md` | Week Planner (default) | Draft | C-02, C-03, C-04, C-05, C-07 | 3 scenarios written |
| `recipes.md` | Recipe Library (+ detail, new/edit) | Not started | C-06, C-08 | — |
| `shopping-list.md` | Shopping List | Not started | C-09 | — |
| `settings.md` | Settings — household members | Not started | C-10 | — |

## Auth decision (from 01-product-brief open question)

v1 runs **without login** — single shared household, no authentication. The `users` table
(roles: planificador/cocinero) exists for settings and recipe authorship, but sessions are
not enforced. Revisit when the client portal (parking lot) is designed.

## Definition of done for a screen spec

- [ ] Acceptance criteria written as Given/When/Then (Capybara-ready)
- [ ] Edge cases: empty / error / loading states checked
- [ ] Components referenced exist in `06-components.md`
- [ ] Data dependencies match `03-data-model.md` names