# FX-001 — Meal Planning & Procurement (Grocery) Plans

**Project:** MealPlanner-ios (`Meal Planner/`)
**Type:** Feature (FX)
**Author:** BA
**Status:** Draft for review — 6 open questions in §11
**Target scheme/build:** `Meal Planner` scheme; unit tests via `UnitTest` plan; snapshot via `SnapshotTest` plan.

---

## 1. Background & Problem

Today the app lets the user **browse** meals (Home/Search) and **curate** them (Favorites, Mastered, Recently viewed), but there is no *planning* capability:

- No way to decide "what do I eat on which day."
- No way to turn a set of meals into a **shopping / procurement list**.
- The main page doesn't surface any saved "plan."

**Opportunity:** A lightweight 5-step meal-planning wizard that produces a **schedule** + an **aggregated ingredient list grouped into 5 categories**, saves it as a **Procurement Plan**, and surfaces saved plans on a **reworked main page**.

---

## 2. Objectives & Success Metrics

| Objective | Metric (suggested) |
|---|---|
| Users can go from "pick dates" to "saved plan" in one session | % of started wizards completed |
| Procurement list is actually usable for shopping | weekly active saved-plan opens; low "tap-through-to-manual-list" friction |
| Accurate, de-duplicated ingredient summary | unit/regression coverage of aggregator |
| Feature works fully offline | no network dependency for plan creation/viewing |

**Non-goals (v1):** meal-prep timers, calorie/nutrition, grocery-store/barcode integration, smart pricing, cloud sync, multi-household sharing, breakfast timebox.

---

## 3. Actors

- **Primary — The Planner (home cook):** decides the period, picks meals, reviews schedule, saves and shops from the list.
- **Secondary — The Shopper:** only views/exports an already-saved plan (check off list, open from main page).

---

## 4. High-Level Flow

```
[Home: new main page]
      │  tap "New Meal Plan"
      ▼
[1. Configure ▸]  pick start date + duration (min 1 week ↔ max 1 month),
      │           toggle timeboxes per day: ☑ Lunch ☑ Dinner
      ▼
[2. Pick Meals ▸] tabs: Favorites | Mastered | Recently viewed | Random (10)
      │           multi-select (tick) meals to allocate
      ▼
[3. Schedule ▸]   calendar grid of slots (day × lunch/dinner); shuffle /
      │           swap / tap-to-replace / regenerate ; "Accept" or "Surprise me"
      ▼
[4. Ingredients ▸] aggregated, de-duplicated ingredient list
      │           grouped by 5 categories [see Q2]
      ▼
[5. Save ▸]       auto-name plan → save → return to Home
      ▼
[Home]            "Procurement Plans" section → open plan (schedule + list)
```

---

## 5. Functional Requirements (by screen)

### 5.1 Home — new main page
**FR-1.1** Home displays two areas: existing content (Favorites / Mastered / Recently viewed / Search entry points) **and** a new **"Meal Plans"** area with any saved procurement plans. *(Whether Home is fully reworked vs. extended is **Q6**.)*
**FR-1.2** A prominent primary action **"New Plan" (New Meal Plan)** launches the wizard.
**FR-1.3** Tapping a saved plan opens its detail (schedule + ingredient list). *(Edit/duplicate/delete support → **Q5**.)*

### 5.2 Step 1 — Period & Timeboxes
**FR-2.1** User picks a **start date** (default: today).
**FR-2.2** User picks **duration** between **1 week (7 days) min** and **1 month max**. *(Stepper/slider/date-range? → **Q1**.)*
**FR-2.3** Per-day **meal timeboxes** are toggleable; **Lunch** and **Dinner** are default-on. **Breakfast is out of scope in v1.**
**FR-2.4** A live caption shows total slots, e.g. *"14 slots · 7 days × 2 meals"*.
**FR-2.5** [Inferred] Weekends use the same rules as weekdays in v1 *(confirm in **Q1**).*

### 5.3 Step 2 — Meal Selection
**FR-3.1** Source tabs: **Favorites**, **Mastered**, **Recently viewed**, **Random (10)** — pulled from the existing lists.
**FR-3.2** Multi-select via ticking; selected state persists when switching tabs.
**FR-3.3** **Random (10):** the app proposes a pool of exactly **10** meals (drawn from the user's meals — see **Q4**), regenerable ("Surprise me again").
**FR-3.4** UI shows "N of M slots filled"; a meal may occupy **more than one slot** when slots > selected meals (repeats allowed — **Q3**).
**FR-3.5** [Inferred] User may also proceed with **fewer meals than slots** (repeats fill the gap), and with **more meals than slots** (excess simply unused).
**FR-3.6** [Inferred] Random allocation avoids immediate back-to-back duplication of the same meal within a day where possible (soft constraint only).

### 5.4 Step 3 — Schedule Review & Adjust
**FR-4.1** Calendar/table of all slots: date × (lunch/dinner).
**FR-4.2** Adjustments (minimum viable set):
- **Shuffle all** (re-randomize allocation of chosen meals).
- **Tap a slot → replace** that meal with another from the chosen pool/suggestions.
- **Swap two slots**.
- **Regenerate** (new proposal) / **Clear day**.
**FR-4.3** "Accept schedule" proceeds; a **"Surprise me / Shuffle"** secondary action is also accepted for the impatient user (user's "or just agree it").
**FR-4.4** No slot is left empty unless the week/month has no lunch/dinner toggled (blocked by validation).

### 5.5 Step 4 — Ingredients (Procurement List)
**FR-5.1** All ingredients from all planned meal instances are **aggregated & de-duplicated**: same ingredient appears once with summed quantity where normalizable.
**FR-5.2** Grouped into **5 canonical categories** — Meat, Seafood, Vegetable, Herbs, Others (resolved by FX-002 Q2).
**FR-5.3** [Inferred] Whole categories or individual lines are **checkable/uncheckable** for the final shopping trip.
**FR-5.4** [Open — **Q2b**] Whether quantities can be truly summed depends on per-recipe unit normalization + servings metadata; otherwise fall back to "quantity as listed + total meal count" or name-only grouping.

### 5.6 Step 5 — Save
**FR-6.1** Auto-name e.g. "Plan · Jul 1 – Jul 7" (editable).
**FR-6.2** Saves schedule **and** a **snapshot of the ingredient summary** (so later recipe edits don't corrupt an old list).
**FR-6.3** Confirmation returns to Home, where the plan appears in "Meal Plans."

---

## 6. Data Model (suggested, per existing patterns)

> Ground-truth persistence approach is open (**Q7**); proposal below assumes local, offline-first storage consistent with the app's repository/data-source layering.

- **ProcurementPlan**
  - `id`, `name`, `startDate`, `endDate`, `createdAt`, `source` (auto/random adjustments count)
- **PlanDay / PlanSlot**
  - `planID`, `date`, `timebox` (lunch | dinner), `mealID`, `displayOrder`
- **PlanIngredient** (denormalized snapshot)
  - `planID`, `name`, `quantity`, `unit`, `categoryID` (0–4), `checked`
- **Localizable structs**: timebox labels, category labels → `Resources/en.lproj` per repo convention.

---

## 7. Non-Functional Requirements

- **Offline-first:** plan creation/viewing must not require the network.
- **Deterministic tests:** random allocation should accept an injectable RNG/seeding so unit tests are stable.
- **Performance:** month-scale aggregation computed in O(meals × ingredients); trivial.
- **Follow existing architecture:** new code in `Features/` (reusable UI → `Features/Core/Component/`, e.g. a `MealPickerBottomSheet` mirrors the existing `LoginBottomSheet` pattern); logic in repositories/data sources for testability.

---

## 8. Edge Cases

| # | Scenario | Expected behavior |
|---|---|---|
| E1 | Favorites/Mastered/Recent list is **empty** | Tab shows empty state + CTA back to Home/Search; Random still offered if any meals exist |
| E2 | Selected meals (count) < total slots | Repeats fill available slots; schedule flags repeated days |
| E3 | Selected meals > slots | Excess ignored, no error; UI shows "M slots, N picked" |
| E4 | A meal appears on multiple days | Aggregator sums its ingredients once per instance |
| E5 | Same ingredient spelled/named with different units across recipes (g vs. kg) | Best-effort normalization; unresolved merge listed as separate lines (never silently dropped) |
| E6 | User unchecks a category on Step 4 then saves | Unchecked state persists on the saved plan? (decision: persist checked state) |
| E7 | All categories empty (e.g., meals with no tagged ingredients) | Empty state with copy, allow save/skip |
| E8 | Month lengths / leap year | Duration is day-based (7–31d); date math via `Calendar` |
| E9 | Slot replaced at Step 3 | Save reflects final schedule; ingredient snapshot recomputed from final schedule |
| E10 | App killed mid-wizard | Draft auto-save (or at least confirm-on-exit) so progress isn't lost |

---

## 9. Assumptions (inferred defaults — flagged for confirmation)

1. **Breakfast timebox is out of scope** in v1; only Lunch & Dinner.
2. Repeats of a meal across slots are **allowed** (needed to fill a week from a small pool).
3. Plans are stored **locally only**; no sync in v1.
4. Single-household assumption: no servings/person-count input in v1 → ingredient **quantities are sums as-listed**, names/units may not be perfectly normalizable.
5. Plan name auto-generated; weekday/weekend treated identically.
6. "Random (10)" = a fixed pool of 10 proposed meals (regenerable).

---

## 10. Out of Scope (v1)

- Breakfast planning, macronutrients/nutrition, dietary filters in wizard
- Grocery integration, barcode, price/merchant data
- Multi-household / sharing / cloud sync
- Meal-prep/cooking steps in the plan
- Notifications/reminders

---

## 11. Open Questions (only the ones that change product behavior)

| # | Question | Why it matters | Proposed default if we must proceed |
|---|---|---|---|
| Q1 | **Duration control:** stepper/preset, and do weekends behave differently? | Changes Step-1 UI + slot math | Preset chips (7 / 14 / 21 / 30 days); same rules all days |
| Q2 | **Resolved by FX-002:** canonical order is Meat, Seafood, Vegetable, Herbs, Others. Quantity handling remains best-effort per Q2b. | Defines Step-4 grouping, data model, and recipe ingredient tagging | Use the confirmed five categories. |
| Q3 | **Repeat policy:** when selected meals < slots — allow same meal twice in the same week (and same day)? | Defines schedule fill + aggregation behavior | Allowed; avoid same meal in both slots the same day if possible |
| Q4 | **Random (10) source:** pool of 10 drawn from *which* menu — only favorites, or all of user's meals (incl. recently viewed/mastered)? | Defines Random tab semantics | All user meals, weighted toward favorites |
| Q5 | **Saved-plan management:** edit an existing plan, duplicate, regenerate, delete, max number stored? | Determines Home list + detail scope | v1: open/view, delete, and "copy as new" (regenerate); no in-place edit |
| Q6 | **"New main page":** full Home redesign vs. adding a "Meal Plans" section into the current Home? Anything removed? | Scope of the largest piece of work | Extend current Home with a Plans section; keep existing lists |
| Q7 | **Persistence tech:** existing app uses Core Data / SwiftData / Codable files for favorites & recent? (Ties into matching repo/data-source conventions.) | Determines data-layer ticket shape | Match whatever Favorites/Recent already use |

*Q2, Q3, Q6 have the largest blast radius — answer these first if time-boxed.*

---

## 12. Suggested Dev Tickets (Epic break-down, implementation order)

1. **Data layer:** models + repository/data-source for plans & ingredient snapshots; migration; persistence choice (depends on **Q7**).
2. **Step 1 – Period & Timebox config** (reusable `DatePeriodPicker` + timebox toggles) + unit tests for slot math.
3. **Step 2 – Meal picker** (tabs: Favorites / Mastered / Recent / Random-10; selection state; RNG-injectable).
4. **Step 3 – Schedule review** (slot grid; shuffle / replace / swap / regenerate) + deterministic tests for allocation.
5. **Step 4 – Ingredient aggregation service** (de-dupe, best-effort unit sum, category grouping) — highest-value unit-test target.
6. **Step 5 – Save & Home "Meal Plans" section** (persist, list, open detail, delete).
7. **Home main-page work** (depends on **Q6** scope decision).
8. **Polish & edge cases** (E1–E10): empty states, kill-mid-wizard draft, accessibility of toggles.
9. **Tests:** unit (`UnitTest` plan) — aggregation + random alloc + slot math; **snapshot** (`SnapshotTest` plan writes PNGs directly to `screenshots/`) for new screens; **UITest** happy-path: create plan → save → open from Home.

---

## 13. Next Step Options

Pick one and I'll proceed:
- **(a)** You answer **Q2 / Q3 / Q6** and I finalize this into per-ticket acceptance criteria + data-model tables.
- **(b)** You want me to first **explore the actual code** (open the Xcode workspace / index) to map Favorites–Mastered–Recent implementation and persistence, then ground the data layer section.
- **(c)** You want a **concise 1-page PRD** version of this (leaner, no ticket breakdown).

My recommendation: **(b)**, so the data-layer and Home sections are grounded in the real repository before ticket writing.
