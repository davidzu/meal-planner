# 06 — Component Inventory

Status: Draft · Contract: one row = one ViewComponent (or partial). Name column = code name, keep identical.

| ID | Component | Variants / states | Used in | Code target | Status |
|----|-----------|-------------------|---------|-------------|--------|
| C-01 | AppShell | desktop / mobile nav | all screens | `AppShellComponent` | ⬜ |
| C-02 | WeekGrid | 7 columns desktop / stacked mobile | week-planner | `WeekGridComponent` | ⬜ |
| C-03 | DayColumn | with date header | week-planner | inside C-02 or own component | ⬜ |
| C-04 | MealSlot | empty / filled / deleted-recipe | week-planner | `MealSlotComponent` | ⬜ |
| C-05 | RecipeCardCompact | default (title + time + servings) | MealSlot | `RecipeCard::CompactComponent` | ⬜ |
| C-06 | RecipeCardFull | + ingredients, instructions, chef's note | recipe detail | `RecipeCard::FullComponent` | ⬜ |
| C-07 | RecipePickerModal | search + recent recipes | F2 assign flow | `RecipePickerComponent` | ⬜ |
| C-08 | SearchBar | with filter chips (tag/time/difficulty) | recipe library, picker | `SearchBarComponent` | ⬜ |
| C-09 | ShoppingListItem | unchecked / checked-off | shopping list | `ShoppingList::ItemComponent` | ⬜ |
| C-10 | PrimaryButton | action / danger | global | plain helper + CSS classes from tokens | ⬜ |
| C-11 | Toast | success / warning (concurrent edit) | global | `ToastComponent` | ⬜ |
| C-12 | EmptyState | icon + hint text + optional CTA | grid, library, lists | `EmptyStateComponent` | ⬜ |

Rules:
1. A component not in this table doesn't get built; add the row first.
2. Every variant/state listed must be visible in a wireframe before code starts.
3. Styling references tokens only (`05-style-guide.md`) — no raw hex/px in components.
