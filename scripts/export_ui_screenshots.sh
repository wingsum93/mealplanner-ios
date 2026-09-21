#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_PATH="${PROJECT_PATH:-Meal Planner.xcodeproj}"
SCHEME="${SCHEME:-Meal Planner}"
DESTINATION="${DESTINATION:-platform=iOS Simulator,name=iPhone 17,OS=26.5}"
RESULT_BUNDLE="${RESULT_BUNDLE:-build/SnapshotTest.xcresult}"
RAW_ATTACHMENTS_DIR="${RAW_ATTACHMENTS_DIR:-build/SnapshotTestAttachments}"
SCREENSHOTS_DIR="${SCREENSHOTS_DIR:-screenshots}"

cd "$ROOT_DIR"

rm -rf "$RESULT_BUNDLE" "$RAW_ATTACHMENTS_DIR"
mkdir -p "$SCREENSHOTS_DIR"
find "$SCREENSHOTS_DIR" -maxdepth 1 -type f \( -name '*.png' -o -name 'manifest.json' \) -delete

xcodebuild test \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -destination "$DESTINATION" \
  -parallel-testing-enabled NO \
  -testPlan "SnapshotTest" \
  -resultBundlePath "$RESULT_BUNDLE"

xcrun xcresulttool export attachments \
  --path "$RESULT_BUNDLE" \
  --output-path "$RAW_ATTACHMENTS_DIR" \
  --filter "*.png"

python3 - "$RAW_ATTACHMENTS_DIR" "$SCREENSHOTS_DIR" <<'PY'
from pathlib import Path
import shutil
import sys

raw_dir = Path(sys.argv[1])
out_dir = Path(sys.argv[2])
expected_names = [
    "01-home",
    "02-search-idle",
    "03-search-results",
    "04-area-list",
    "05-category-list",
    "06-ingredient-list",
    "07-ingredient-meals",
    "08-random-pick",
    "09-favourites",
    "10-profile",
    "11-detail-sheet",
]

pngs = sorted(raw_dir.rglob("*.png"))
if not pngs:
    raise SystemExit(f"No PNG attachments were exported from {raw_dir}")

used = set()

for name in expected_names:
    match = next((p for p in pngs if p not in used and name in p.stem), None)
    if match is None:
        remaining = [p for p in pngs if p not in used]
        if not remaining:
            raise SystemExit(f"Missing exported attachment for {name}")
        match = remaining[0]

    used.add(match)
    shutil.copy2(match, out_dir / f"{name}.png")

print(f"Exported {len(expected_names)} screenshots to {out_dir}")
PY
