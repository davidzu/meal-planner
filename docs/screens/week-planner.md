# Screen spec: Week Planner (default screen)

Status: Draft
Wireframe: Miro frame `SCREEN-01` — _[link to board]_
Components used: WeekGrid, DayColumn, MealSlot, RecipeCardCompact, EmptySlot, PrimaryButton, Toolbar
Flows served: F1 (fill week), F2 (assign), F3 (swap)

## Purpose

Fill and adjust the 21 slots of one week (7 days × Desayuno/Comida/Cena) as fast as possible.

## Layout intent

- Toolbar top: week navigation (‹ prev · "Semana del 24 ago" · next ›), actions: Generate shopping list, Copy last week
- Grid: days as columns (desktop) / stacked day cards (mobile); each column = DayColumn with 3 MealSlots labeled Desayuno/Comida/Cena
- Assign interaction v1: tap empty slot → recipe picker modal. Drag-and-drop is a v1.1 candidate — do not block launch on it.

## Acceptance criteria

```gherkin
Scenario: View an empty week
  Given I am a household member on the week planner
  When no plan exists for the displayed week
  Then I see 7 DayColumns each containing Desayuno, Comida, Cena slots in empty state

Scenario: Assign a recipe to a slot
  Given a visible empty Comida slot for Tuesday
  When I tap the slot and pick recipe "Birria" from the picker
  Then the slot shows RecipeCardCompact for Birria with cook time and servings
    And the slot persists after reload

Scenario: Generate shopping list
  Given at least one slot filled this week
  When I press "Generate shopping list"
  Then I am taken to that week's Shopping List page
```

## Edge cases

- [ ] Empty state: all-empty grid shows a one-line hint ("Empieza por el lunes") + Copy last week shortcut
- [ ] Partial week from prior weeks: slots keep their saved recipes
- [ ] Recipe deleted after being planned: slot shows "Receta eliminada" placeholder, not crash
- [ ] Two users editing same week concurrently: last write wins + toast notice (v1 acceptable)

## Data dependencies

`WEEK`, `DAY`, `MENU_DIA` (meal_type: desayuno|comida|cena), `RECIPE`, `SHOPPING_LIST` — see `../03-data-model.md`

## Open questions

- [ ] Show cook time on compact card? (affects speed of filling — test in wireframes)
- [ ] Weekend columns wider than weekday? Probably no — decide at mockup.
