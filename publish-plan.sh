#!/usr/bin/env bash
# Refresh the plan page's big-picture snapshot from PocketBase and publish (git -> Cloudflare Pages).
# Read-only against the DB. Big-picture counts only — NOT the needs/shopping list.
# Safe to run any time; also fine to schedule nightly like publish-coordination.sh.
set -euo pipefail
PLAN="/Users/kenny/Documents/claude projects/Homesteadplan"
cd "$PLAN"
echo "[$(date '+%Y-%m-%d %H:%M')] -> regenerating plan-data.json from PocketBase"
python3 scripts/export_plan.py
echo "[$(date '+%Y-%m-%d %H:%M')] -> git commit + push"
git add plan-data.json index.html scripts/export_plan.py publish-plan.sh
git commit -m "Plan: refresh live DB snapshot ($(date '+%Y-%m-%d %H:%M'))" || echo "   (nothing to commit)"
git push
echo "[$(date '+%Y-%m-%d %H:%M')] done — Cloudflare Pages will rebuild from the push"
