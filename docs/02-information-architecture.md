# 02 — Information Architecture

Status: Draft · Format: this doc = structure of record; Miro = the drawn diagrams
Miro board: _[paste board URL]_

## Sitemap (v1)

```text
App
├── Week Planner            ← default screen after login
│   ├── Day column ×7 (Mon–Sun)
│   │   └── Meal slot: Desayuno | Comida | Cena
│   └── Actions: Generate shopping list · Copy last week · Clear week
├── Recipes
│   ├── Library (search + filter by tag, time, difficulty)
│   ├── Recipe detail
│   └── New / edit recipe
├── Shopping Lists
│   ├── List for current week (auto-generated)
│   └── Archive (past weeks)
└── Settings
    ├── Household members
    └── Meal type labels & schedule
```

Rule: `routes.rb` must mirror this tree 1:1. If a screen has no route or a route has no box here, that's a defect.

## Core user flows

| # | Flow | Trigger | Success ends at | Status |
|---|------|---------|-----------------|--------|
| F1 | Fill next week's plan | Sunday planning session | 21 slots filled < baseline time | ⬜ |
| F2 | Assign recipe to slot | Slot tap/drag on planner | Slot shows recipe card | ⬜ |
| F3 | Swap two slots' meals | Drag between slots | Both slots updated | ⬜ |
| F4 | Generate shopping list from week | Button after filling | Single merged list | ⬜ |
| F5 | Create recipe while planning | "New recipe" from picker | Recipe created + placed in slot | ⬜ |

Flowchart conventions in Miro: rounded rect = start/end · rect = screen/step · diamond = decision · every flow numbered F# matching this table.

## Later (parking lot — do not design yet)

- Client portal (meal-prep customers pick their week)
- Production planning (scale recipes × client servings)
