#!/usr/bin/env bash
# Refresh the plan page's big-picture snapshot from PocketBase and publish (git -> Cloudflare Pages).
# Read-only against the DB. Big-picture counts only — NOT the needs/shopping list.
# Safe to run any time; also fine to schedule nightly like publish-coordination.sh.
set -euo pipefail
PLAN="/Users/kenny/Documents/claude projects/Homesteadplan"
cd "$PLAN"
echo "[$(date '+%Y-%m-%d %H:%M')] -> regenerating plan-data.json from PocketBase"
python3 scripts/export_plan.py
echo "[$(date '+%Y-%m-%d %H:%M')] -> regenerating the Crop Calendar section into index.html"
# One generator (Homestead-os/scripts/gen_crop_calendar.py) drives the app and
# this page, so they cannot drift. Read-only against the DB; injects the calendar
# between the <!--CROPCAL:START/END--> markers in index.html.
python3 "/Users/kenny/Documents/claude projects/Homestead-os/scripts/gen_crop_calendar.py" \
  "/Users/kenny/Documents/claude projects/Pocketbase/pb_data/data.db" \
  --embed="$PLAN/index.html" || echo "   (crop-calendar regen skipped)"
echo "[$(date '+%Y-%m-%d %H:%M')] -> scrub check before anything leaves the machine"
# THIS PAGE IS PUBLIC. On 2026-08-15 a scrubbed parcel-map-preview.html was
# silently left behind and the old version with the street address stayed live.
# The fix then was to stage every tracked file. This is the other half: refuse
# to push at all if the address, the household names, the contact details or the
# parcel identifiers are present in anything about to go out.
#
# Runs BEFORE git add. Any hit aborts with a non-zero exit, so the nightly
# launchd job fails loudly in the log instead of publishing quietly. If a match
# is a false positive, fix the pattern here deliberately - never delete the
# check to get a push through.
SCRUB_FILES=(index.html plan-data.json parcel-map-preview.html)
SCRUB_PATTERNS=(
  "Smiths Winding"      # street
  "573 Smiths"          # street number + street
  "27863"               # ZIP
  "Katherine"           # household
  "Rhodes"              # household
  "@yahoo"              # contact
  "@gmail"              # contact
  "Social Security"
)
scrub_hit=0
for f in "${SCRUB_FILES[@]}"; do
  [ -f "$f" ] || continue
  for p in "${SCRUB_PATTERNS[@]}"; do
    if grep -qi -- "$p" "$f"; then
      echo "   ✗ SCRUB FAIL: '$p' found in $f"
      grep -in -- "$p" "$f" | head -3 | sed 's/^/       /'
      scrub_hit=1
    fi
  done
done
if [ "$scrub_hit" -ne 0 ]; then
  echo ""
  echo "✗ NOTHING WAS PUSHED. The plan page is public and one of the files above"
  echo "  contains personal information. Remove it, then run this again."
  echo "  Do not weaken the pattern list to make this pass."
  exit 1
fi
echo "   clean (${#SCRUB_FILES[@]} files, ${#SCRUB_PATTERNS[@]} patterns)"

echo "[$(date '+%Y-%m-%d %H:%M')] -> git commit + push"
# Was an explicit file list, which silently skipped anything not named here.
# On 2026-08-15 that dropped a scrubbed parcel-map-preview.html: the file was
# edited, the publish ran, git reported "nothing to commit", and the old version
# with the street address stayed live. Stage everything tracked instead, so a
# change to any published file cannot be quietly left behind.
git add -u
git add plan-data.json index.html scripts/export_plan.py publish-plan.sh parcel-map-preview.html 2>/dev/null || true
git commit -m "Plan: refresh live DB snapshot ($(date '+%Y-%m-%d %H:%M'))" || echo "   (nothing to commit)"
git push
echo "[$(date '+%Y-%m-%d %H:%M')] done — Cloudflare Pages will rebuild from the push"
