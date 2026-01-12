# Repository Guidelines

## Project Structure & Module Organization

- `Meal Planner/`: main iOS app target (SwiftUI). Organized into:
  - `Core/`: networking, DI, repositories, data sources (`Core/Network`, `Core/DI`, `Core/Repository`).
  - `Features/`: feature screens and components (e.g. `Features/Home`, `Features/Search`, shared UI in `Features/Core/Component`).
  - `Models/`, `Utils/`, and app entry points like `RecipeApp.swift`.
- `Meal PlannerTests/`: unit tests (Swift Testing framework).
- `Meal PlannerUITests/`: UI tests (XCTest).
- `Resources/`: shared assets such as localization (`Resources/en.lproj`) and Lottie files (`Resources/Lottie`).
- `Meal Planner.xcodeproj/`: Xcode project and shared scheme (`Meal Planner`).

## Build, Test, and Development Commands

- Open in Xcode: `open "Meal Planner.xcodeproj"`
- Build (Simulator): `xcodebuild -project "Meal Planner.xcodeproj" -scheme "Meal Planner" -destination 'platform=iOS Simulator,name=iPhone 15' build`
- Run tests (unit + UI): `xcodebuild -project "Meal Planner.xcodeproj" -scheme "Meal Planner" -destination 'platform=iOS Simulator,name=iPhone 15' test`
- Target specific tests (example): `xcodebuild ... test -only-testing:"Meal PlannerUITests"`

## Coding Style & Naming Conventions

- Swift: 4-space indentation, keep functions small, prefer `guard` for early exits.
- SwiftUI: break complex views into subviews/components; place reusable components in `Meal Planner/Features/Core/Component/`.
- Naming: types `UpperCamelCase`, functions/vars `lowerCamelCase`, files match the primary type (e.g. `LoginBottomSheet.swift`).

## Testing Guidelines

- Unit tests use Swift Testing (`import Testing`) with `@Test` and `#expect(...)`.
- UI tests use XCTest (`XCTestCase`) and should start from a clean app state.
- Keep tests deterministic (avoid time/network coupling where possible; mock via repositories/data sources when practical).

## Commit & Pull Request Guidelines

- Commits in history are short, imperative, and often lowercase (e.g. `fix login ui`, `add favourite implement`); follow that pattern and keep messages focused.
- PRs: include a brief “what/why”, link related issues, and add screenshots/GIFs for UI changes. Mention the test command you ran (e.g. `xcodebuild ... test`).

## Security & Configuration Tips

- TheMealDB base URL and an `apiKey` currently live in `Meal Planner/Core/DataSource/Remote/RecipeRemoteDataSourceImpl.swift`. Treat it as a sample/public key; do not commit real secrets. Prefer `.xcconfig` or environment-based configuration for private keys.
