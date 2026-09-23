# FX-002 — View & Reorder Meal Plan

**Project:** MealPlanner-ios (`Meal Planner/`)
**Type:** Feature (FX)
**Author:** BA
**Status:** Draft for review
**Related ticket:** FX-001 — Meal Planning & Procurement (Grocery) Plans

---

## 1. Background & Problem

Users need a more organized way to view a saved meal plan than a single combined view. They should be able to browse planned days in a calendar, inspect that day's meals and ingredients, adjust the order of upcoming meals, and access the plan's ingredient list by category.

## 2. Objective

Redesign the View Meal Plan experience around a calendar and day-level details, while preserving the existing ingredient-selection interaction.

## 3. Primary User Flow

```text
[Main Meal Plan page]
    ├── Calendar: planned dates enabled; dates without meals disabled
    │       └── Select enabled date
    │               └── Day detail: meals and their ingredients
    │                       └── Drag an upcoming meal to a selected plan timeslot
    │                               ├── Empty slot: move meal
    │                               └── Occupied slot: swap meal timeslots
    └── Ingredient widget
            └── Ingredient detail: five category tabs → ingredient list → existing selection flow
```

## 4. Functional Requirements

### 4.1 Main Meal Plan Page

- **FR-1.1** Display a calendar as the primary way to browse a saved meal plan.
- **FR-1.2** Enable dates that contain one or more planned meals.
- **FR-1.3** Disable dates with no planned meals; disabled dates cannot be opened.
- **FR-1.4** Make the full enabled date cell tappable to open that day's detail.
- **FR-1.5** Display the ingredient widget on the main Meal Plan page.
- **FR-1.6** Selecting the ingredient widget opens the ingredient detail page.

### 4.2 Day Meal Detail

- **FR-2.1** Show the selected date and each meal planned for that day.
- **FR-2.2** Show the ingredients associated with each meal.
- **FR-2.3** Allow eligible meals to be dragged to other future timeslots selected when the plan was created, including timeslots on other days.
- **FR-2.4** Dropping a meal into an empty eligible timeslot moves that meal to the destination.
- **FR-2.5** Dropping a meal into an occupied eligible timeslot swaps the two meals' timeslots.
- **FR-2.6** Reordering changes only the meal's timeslot; it does not replace the meal or alter its ingredients.

### 4.3 Ingredient Detail

- **FR-3.1** Display five category tabs, each showing the ingredient list for that category.
- **FR-3.2** Selecting an ingredient follows the existing ingredient interaction behavior.
- **FR-3.3** Show an empty state when the selected category has no ingredients.

## 5. Business Rules

- A meal is eligible to move only before its currently scheduled time has passed, evaluated in the user's local time zone.
- Only timeslots selected for the plan are valid destinations.
- A destination timeslot must be in the future.
- If a destination is occupied, both meals must still be eligible to move for the swap to proceed. Otherwise, block the swap.
- A move or swap preserves each meal and its associated ingredients.
- The five ingredient categories are the same categories used by the saved plan's ingredient list. Their canonical names and definitions are tracked in FX-001, Q2.

## 6. Acceptance Criteria

1. The main Meal Plan page presents a calendar.
2. Dates containing planned meals are enabled and selectable; dates without meals are visibly disabled and cannot be opened.
3. Selecting an enabled date opens a detail page showing that date's meals and the ingredients for each meal.
4. Before its currently scheduled time has passed, a meal can be dragged to any future timeslot selected for the plan, including a timeslot on a different day.
5. Dropping a meal into an empty eligible timeslot moves it there.
6. Dropping a meal into an occupied eligible timeslot swaps the two meals' timeslots, provided both meals can still be moved.
7. A meal whose scheduled time has passed cannot be moved; a swap that would move a past-due meal is blocked.
8. Moving or swapping meals does not change which meals are planned or their ingredients.
9. The ingredient widget is visible on the main Meal Plan page and opens the ingredient detail page when selected.
10. The ingredient detail page has five category tabs, each showing the corresponding ingredients.
11. Selecting an ingredient uses the existing ingredient-selection behavior.

## 7. Edge Cases

| Scenario | Expected behavior |
|---|---|
| Date has no planned meals | Date is disabled and does not navigate. |
| Day has no meals when details load | Show an empty state rather than a blank page. |
| Plan or day details fail to load | Show an error state with a retry option. |
| Meal's scheduled time has passed | Meal remains viewable but cannot be moved. |
| Destination timeslot is not part of the plan | It is not offered as a drop target. |
| Destination timeslot has already passed | It is not offered as a drop target. |
| Occupied destination contains a past-due meal | Block the swap and leave both meals unchanged. |
| Ingredient category contains no items | Show an empty state for that category. |

## 8. Dependencies & Open Questions

- Depends on FX-001 for saved plan dates, selected timeslots, meals, and ingredient data.
- The five category labels and exact category definitions remain open under FX-001, Q2.
- The ingredient-selection flow should reuse the current behavior; confirm implementation details during development if the existing flow differs by entry point.

## 9. Suggested Implementation Breakdown

1. Add calendar-based plan browsing, with enabled/disabled date states and navigation to day detail.
2. Add day-level meal and ingredient details.
3. Implement drag-to-move and drag-to-swap across selected future plan timeslots, enforcing past-time eligibility.
4. Add the main-page ingredient widget and five-tab categorized ingredient detail page, retaining existing ingredient-selection behavior.
5. Add loading, error, and empty states for calendar, day detail, and ingredient categories.
