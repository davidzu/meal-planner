# 01 — Product Brief

Status: Draft · Owner: PM/founder · Consumers: all other artifacts

## Vision

A weekly meal planner that turns a trusted recipe library into a filled week — Desayuno, Comida, Cena — and the shopping list that makes it executable. Chef-authored content, not crowdsourced.

## Beachhead user

This household first (founder + spouse). Then existing clients of the meal-prep business, who already trust the recipes and the brand.

## Jobs to be done

1. When the week starts, fill 21 slots fast without decision fatigue.
2. Turn the filled week into one shopping list with merged quantities.
3. Reuse cooking effort (batch items, leftovers) across multiple slots.

## In scope — v1

- Recipe library: CRUD, search, tags, cook time, difficulty, servings
- Week grid: 7 days × 3 meal types, assign/swap/remove recipes
- Shopping list generated from the week, ingredients merged by unit
- Two-user household (planner + cook may differ)

## Out of scope — v1 (explicit)

- Multi-client production scaling (business ops)
- Payments, subscriptions, client-facing portal
- Nutrition/macro tracking
- Mobile native apps (responsive web only)

## Success metric

Time to fully plan one week, measured against baseline in `00-current-state.md`.
Target: baseline ÷ 4 within 8 weeks of dogfooding.

## Open questions

- [ ] Do leftovers need their own slot type, or are they just a recipe?
- [ ] Spanish-only UI, or bilingual from v1?
