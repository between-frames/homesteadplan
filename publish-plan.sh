#!/usr/bin/env bash
# Refresh the plan page's big-picture snapshot from PocketBase and publish (git -> Cloudflare Pages).
# Read-only against the DB. Big-picture counts only — NOT the needs/shopping list.
# Safe to run any time; also fine to schedule nightly like publish-coordination.sh.
set -euo pipefail
PLAN="/Users/kenny/Documents/claude projects/Homesteadplan"
cd "$PLAN"
echo "[$(date '+%Y-%m-%d %H:%M')] -> regenerating plan-data.json from PocketBase"
python3 scripts/export_plan.py
echo "[$(date '+%Y-%m-%d %H:%M')] -> regenerating crop-calendar.html from PocketBase"
# One generator (Homestead-os/scripts/gen_crop_calendar.py) drives both the app
# and this page, so they cannot drift. Read-only against the DB.
python3 "/Users/kenny/Documents/claude projects/Homestead-os/scripts/gen_crop_calendar.py" \
  "/Users/kenny/Documents/claude projects/Pocketbase/pb_data/data.db" \
  "$PLAN/crop-calendar.html" --back=index.html || echo "   (crop-calendar regen skipped)"
echo "[$(date '+%Y-%m-%d %H:%M')] -> git commit + push"
# Was an explicit file list, which silently skipped anything not named here.
# On 2026-08-15 that dropped a scrubbed parcel-map-preview.html: the file was
# edited, the publish ran, git reported "nothing to commit", and the old version
# with the street address stayed live. Stage everything tracked instead, so a
# change to any published file cannot be quietly left behind.
git add -u
git add plan-data.json index.html crop-calendar.html scripts/export_plan.py publish-plan.sh parcel-map-preview.html 2>/dev/null || true
git commit -m "Plan: refresh live DB snapshot ($(date '+%Y-%m-%d %H:%M'))" || echo "   (nothing to commit)"
git push
echo "[$(date '+%Y-%m-%d %H:%M')] done — Cloudflare Pages will rebuild from the push"
