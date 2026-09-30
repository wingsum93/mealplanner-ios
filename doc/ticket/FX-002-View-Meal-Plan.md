# FX-002 — View & Reorder Meal Plan

**Project:** MealPlanner-ios (`Meal Planner/`)
**Type:** Feature (FX)
**Author:** BA
**Status:** Ready for development
**Related ticket:** FX-001 — Meal Planning & Procurement (Grocery) Plans

---

## 1. Background & Problem

Users need a more organized way to view a saved meal plan than a single combined view. They should be able to browse planned days in a calendar, inspect that day's meals and ingredients, adjust the order of upcoming meals, and access the plan's ingredient list by category.

## 2. Objective

Redesign the View Meal Plan experience around a calendar and day-level details, while preserving the existing ingredient-selection interaction and reusing the plan data captured in FX-001.

## 3. Actors

- **Primary — The Planner (home cook / shopper):** opens a saved plan, browses days, inspects meals and ingredients, reorders upcoming meals, and works through the categorized ingredient list.
- No new actor is introduced; this is the same actor defined in FX-001 §3.

## 4. User Story

As a planner, I want to browse my saved meal plan on a calendar, inspect each day's meals and ingredients, reorder upcoming meals, and work through a categorized ingredient list, so that I can adjust my week and shop from one place.

## 5. Main Workflow

**Trigger:** User opens a saved Procurement Plan from the Meal Plans area (FX-001).

1. **Main Meal Plan page** loads the plan and displays a month calendar plus the ingredient widget.
2. Calendar shows a month containing the plan's date range.
   - **Decision:** date within plan range **and** has ≥1 planned meal → enabled/tappable. Otherwise → disabled, not tappable.
3. User navigates months when the plan spans more than one month (prev/next clamped to the plan range).
4. User taps an enabled date.
5. **Day Meal Detail** opens showing the date, each planned meal with its timebox and ingredients, and any empty selected timeslots as drop targets.
6. User reorders a meal:
   - **Primary:** drag the meal card onto another timeslot.
   - **Alternate:** tap **Move** on the meal card → destination sheet → pick a valid timeslot.
7. **Decision:** destination timeslot
   - Empty and valid → **move** the meal there.
   - Occupied and valid → **swap** the two meals' timeslots.
   - Invalid (past, source itself, outside plan range, day with no meals) → not offered / rejected.
8. Change is persisted immediately; an **Undo** affordance appears for a short window.
9. User returns to the calendar (Back). Updated day/date states are reflected.
10. User taps the **ingredient widget** on the main page.
11. **Ingredient Detail** opens with five category tabs; selecting a tab lists that category's ingredients.
12. User selects an ingredient → it toggles its checked/unchecked state (existing shopping-list behavior), persisted immediately.
13. **Terminal state:** plan schedule and ingredient checked-state remain saved; user can leave at any time.

## 6. Alternative Flows

- **AF-1 Move without dragging:** user taps **Move**, a destination sheet lists valid future timeslots with "Move here" (empty) or "Swap" (occupied); selecting confirms and dismisses.
- **AF-2 Undo a reorder:** user taps **Undo** in the snackbar before it times out → the previous schedule is restored and re-persisted.
- **AF-3 Occupied swap blocked:** destination is occupied by a past-due meal → the target is disabled/blocked and both meals remain unchanged.
- **AF-4 Legacy plan without ingredient snapshots:** day detail shows "Ingredient details were not saved with this older plan" instead of an empty list; the app best-effort backfills snapshots when meal data is available.
- **AF-5 Empty category:** selecting a category with no planned ingredients shows a category-specific empty state rather than a blank list.
- **AF-6 Day becomes empty after a move:** if a move removes the last meal from a day, that date reverts to disabled on the calendar.

## 7. Functional Requirements

### 7.1 Main Meal Plan Page

- **FR-1.1** Display a calendar as the primary way to browse a saved meal plan.
- **FR-1.2** Enable dates that contain one or more planned meals and fall within the plan's date range.
- **FR-1.3** Disable dates with no planned meals or outside the plan range; disabled dates cannot be opened.
- **FR-1.4** Make the full enabled date cell tappable to open that day's detail.
- **FR-1.5** Display the ingredient widget on the main Meal Plan page, showing total ingredient count and checked count.
- **FR-1.6** Selecting the ingredient widget opens the ingredient detail page.
- **FR-1.7** Provide prev/next month navigation clamped to the plan's start and end months.

### 7.2 Day Meal Detail

- **FR-2.1** Show the selected date and each meal planned for that day.
- **FR-2.2** Show the timebox (Lunch/Dinner), meal name, and the ingredients associated with each meal.
- **FR-2.3** Allow eligible meals to be dragged to other future timeslots selected when the plan was created, including a different day.
- **FR-2.4** Dropping a meal into an empty eligible timeslot moves that meal to the destination.
- **FR-2.5** Dropping a meal into an occupied eligible timeslot swaps the two meals' timeslots.
- **FR-2.6** Reordering changes only the meal's timeslot; it does not replace the meal or alter its ingredients.
- **FR-2.7** Offer a **Move** action as a non-drag alternative that opens a destination picker listing valid timeslots.
- **FR-2.8** Persist every successful move/swap immediately, and surface an **Undo** affordance that reverses the last reorder within its visible window.
- **FR-2.9** Show empty selected timeslots for the day as drop targets.

### 7.3 Ingredient Detail

- **FR-3.1** Display five category tabs — **Meat, Seafood, Vegetable, Herbs, Others** — each showing the ingredient list for that category.
- **FR-3.2** Selecting an ingredient follows the existing ingredient interaction behavior: it toggles the item's checked/unchecked state and persists it.
- **FR-3.3** Show an empty state when the selected category has no ingredients.

## 8. Business Rules

- **Eligibility** — A meal may move only before its currently scheduled time has passed, evaluated in the user's local time zone. Because timeboxes carry no clock time, eligibility is evaluated at **day granularity**: a meal is movable if its scheduled day is **today or later**; a meal on a past day is locked.
- **Valid destinations** — A destination is valid only if all hold:
  1. its timebox is a timebox selected for the plan (e.g. Lunch and/or Dinner), and
  2. its date falls within the plan's start–end range, and
  3. its date is **today or later**, and
  4. its date already contains **at least one planned meal** when the reorder is attempted.
- The source slot itself is never a valid destination.
- **Cross-timebox moves/swaps are allowed** (Lunch ↔ Dinner), subject to the rules above.
- **Swap pre-condition** — If the destination is occupied, both meals must still be eligible to move. Otherwise the swap is blocked and both meals are left unchanged.
- A move or swap preserves each meal, its identity, and its associated ingredients. It changes only timeslot assignment.
- Empty selected timeslots on a valid destination day are offered as move targets.
- The five ingredient categories are the canonical set used by the saved plan's ingredient list: **Meat, Seafood, Vegetable, Herbs, Others** (order as displayed). This resolves FX-001 Q2.
- Ingredient checked-state is persisted per plan.

## 9. Persistence

- Reorders are persisted immediately to the local plan store (offline-first, per FX-001 §7); no explicit Save step.
- A failed persist shows an error message and leaves the on-screen schedule unchanged (no partial state).
- Undo restores the pre-reorder schedule and re-persists it.
- Checked-state toggles persist immediately.

## 10. Edge Cases

| # | Scenario | Expected behavior |
|---|---|---|
| E1 | Date has no planned meals, or is outside the plan range | Date is disabled and does not navigate. |
| E2 | Day has no meals when details load | Show an empty state rather than a blank page. |
| E3 | Plan or day details fail to load | Show an error state with a retry option. |
| E4 | Meal's scheduled day has passed | Meal remains viewable but cannot be moved (locked). |
| E5 | Destination timeslot's timebox not part of the plan | It is not offered as a drop target. |
| E6 | Destination date has already passed | It is not offered as a drop target. |
| E7 | Destination day currently has no planned meals | It is not offered as a valid destination. |
| E8 | Occupied destination contains a past-due meal | Block the swap and leave both meals unchanged. |
| E9 | Move removes the last meal from a day | That date reverts to disabled on the calendar. |
| E10 | Move/swap persist fails | Surface an error; keep the schedule unchanged. |
| E11 | Legacy plan missing ingredient snapshots | Show "ingredient details were not saved" message; best-effort backfill when meal data exists. |
| E12 | Ingredient category contains no items | Show an empty state for that category. |
| E13 | Undo tapped after the snackbar window | No-op; the change stands. |
| E14 | Plan deleted while open in detail | Show "Plan unavailable" (ContentUnavailable) rather than crashing. |
| E15 | Duplicate/racing drag events on the same source | Only the first valid mutation applies; subsequent identical source is ignored. |
| E16 | Timezone/DST change while browsing | Eligibility and "today" use the current local calendar at evaluation time. |

## 11. Acceptance Criteria

1. The main Meal Plan page presents a month calendar with prev/next month controls clamped to the plan's range.
2. Dates within the plan range containing planned meals are enabled and selectable; dates without meals or outside the range are visibly disabled and cannot be opened.
3. Selecting an enabled date opens a detail page showing that date's meals (with timebox, meal name) and the ingredients for each meal.
4. Before its scheduled day has passed, a meal can be moved to any valid future timeslot, including a different day and a different timebox.
5. Dropping a meal into an empty valid timeslot moves it there.
6. Dropping a meal into an occupied valid timeslot swaps the two meals' timeslots, provided both meals can still be moved.
7. A meal whose scheduled day has passed cannot be moved; a swap that would move a past-due meal is blocked.
8. A destination whose timebox is not part of the plan, is outside the plan range, is in the past, or is on a day with no meals is not offered.
9. Cross-timebox moves and swaps (Lunch ↔ Dinner) are permitted and behave as move/swap respectively.
10. Moving or swapping meals does not change which meals are planned or their ingredients.
11. Every successful move/swap is persisted immediately, and an Undo affordance reverses the last reorder within its window.
12. The ingredient widget is visible on the main Meal Plan page, shows item and checked counts, and opens the ingredient detail page when selected.
13. The ingredient detail page has five tabs — Meat, Seafood, Vegetable, Herbs, Others — each listing the corresponding ingredients alphabetically.
14. Selecting an ingredient toggles its checked/unchecked state, and the state persists.
15. A category with no ingredients shows an empty state.
16. A day with no meals, a failed load, or a missing legacy snapshot shows the corresponding empty/error message rather than a blank or crash.

## 12. Assumptions

1. **Calendar granularity:** a single-month grid with prev/next navigation clamped to the plan range (matches current implementation). No week-strip or infinite scroll.
2. **Eligibility is day-level**, since timeboxes have no clock time; "today" slots are still movable.
3. **Empty-day rule:** a destination day must already contain at least one planned meal (per product decision). This is a **change from the current build**, which allows moving to an empty day/timeslot and creating a new slot there.
4. **Undo:** snackbar-style, single-level, auto-dismissing; not a full history. This is **not yet implemented** in the current build.
5. **Ingredient "selection"** means toggling the shopping-list checked state (matches current `PlanIngredientsView` and FX-001 Step 4), not navigating to recipes.
6. Ingredient category tabs are ordered Meat, Seafood, Vegetable, Herbs, Others; each list is sorted alphabetically.
7. Plan/ingredient data is local and offline-first (FX-001 §7); no network is required to view or reorder.
8. Drag-and-drop is not the only reorder path — a **Move** action provides an accessible alternative.
9. Legacy plans without ingredient snapshots are tolerated via a message plus best-effort backfill.

## 13. Open Questions

1. **Record the FX-001 Q2 resolution:** the canonical categories are now Meat, Seafood, Vegetable, Herbs, Others. FX-001 §5.5/§11 Q2 should be updated to match so both tickets agree.
2. **Undo window length:** confirm the snackbar duration (e.g. 5s). Low blast radius; default 5s unless stated.

## 14. Out of Scope

- Creating, editing, duplicating, or deleting a plan (FX-001; FX-002 is view + reorder only).
- Editing meal definitions or recipes, and editing ingredient content within a plan.
- Adding/removing timeboxes for an existing plan.
- Notifications/reminders, nutrition, pricing, grocery integration.
- Cloud sync / multi-household sharing (FX-001 non-goals).

## 15. Dependencies

- **FX-001** supplies saved plan dates, selected timeslots, meals, and ingredient/snapshot data, plus the Meal Plans entry point.
- **FX-001 Q2** is resolved by this ticket (see §8); propagate the resolution back to FX-001.
- Existing ingredient interaction and the plan repository (`savePlan`, `setIngredientChecked`) are reused.
- Accessibility: the **Move** path must exist so reordering is not drag-only.

## 16. Screens

| # | Screen | Purpose | Workflow step | Key elements | Primary action | States |
|---|---|---|---|---|---|---|
| S1 | Main Meal Plan (Plan Detail) | Browse plan by calendar + entry to shopping list | WF 1–3, 10 | Month grid, prev/next month, day cells (dots for Lunch/Dinner), ingredient widget (`N items · M checked`) | Tap enabled date / tap widget | Loading, loaded, plan-unavailable |
| S2 | Day Meal Detail | Inspect a day's meals + ingredients; reorder | WF 5–9 | Date title, meal cards (timebox, name, ingredients), empty slot drop targets, Move button / drag | Drag meal / tap Move | Populated, empty day, legacy-snapshot message |
| S3 | Move Destination Sheet | Pick a valid destination without dragging | WF 6 (AF-1) | List of future valid days × timeboxes, "Move here"/"Swap"/disabled rows | Select destination | Enabled/disabled rows |
| S4 | Ingredient Detail | Shop from categorized list | WF 11–12 | 5 category tabs, ingredient rows with quantity + ×count, empty state per category | Toggle ingredient checked | Loaded per category, empty category |

## 17. Suggested Tickets

### Ticket FX-002a — Calendar plan browsing
**Scope:** Main Meal Plan page month calendar, enabled/disabled day states, month navigation clamped to plan range, navigation to day detail; plan-unavailable state.
**Acceptance:** AC1, AC2, AC3 (navigation), AC16 (partial).
**Depends on:** FX-001 data layer.

### Ticket FX-002b — Day meal detail
**Scope:** Day detail showing date, meals with timebox + ingredients, empty timebox drop targets, legacy-snapshot message, empty day state.
**Acceptance:** AC3, AC16.
**Depends on:** FX-002a.

### Ticket FX-002c — Reorder (move & swap)
**Scope:** Drag-to-move/swap plus the Move destination sheet; eligibility rules; cross-timebox support; empty-day restriction; enable/disable destination rows; persist immediately; Undo affordance; error handling.
**Acceptance:** AC4–AC11.
**Depends on:** FX-002b. **Includes the empty-day-rule change and Undo (see §12.3–12.4).**

### Ticket FX-002d — Ingredient widget & categorized detail
**Scope:** Main-page ingredient widget; five-tab ingredient detail with alphabetical lists, per-category empty states, and checked-state toggling with persistence.
**Acceptance:** AC12–AC15.
**Depends on:** FX-001 ingredient snapshot data; FX-001 Q2 resolution (§8).

### Ticket FX-002e — States & edge-case polish
**Scope:** Loading/error/empty states across S1/S2/S4, E1–E16 handling, accessibility labels for calendar cells, drag alternative, and Undo timing.
**Acceptance:** AC11, AC16.
**Depends on:** FX-002a–d.

## 18. Current Implementation Notes (for QA)

The feature is largely built. Verify these gaps before sign-off:

- **Empty-day destinations** — current `PlanScheduleMutation.move` and `PlanMoveDestinationSheet` allow moving to any date/timebox in range, including days with no meals. Product rule §8 now forbids this; the destination sheet must exclude no-meal days.
- **Undo** — `moveMeal` saves immediately with no undo. The Undo affordance (FR-2.8 / AC11) is not yet implemented.
- **Eligibility granularity** — code compares start-of-day (`sourceDate >= today`), consistent with the day-level rule in §8; confirm wording in UI ("Move"/lock) matches.
- **Cross-timebox** — already permitted by `PlanScheduleMutation.move`; matches the confirmed decision.
- **Categories** — code already uses Meat, Seafood, Vegetable, Herbs, Others; matches §8.
