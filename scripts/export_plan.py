#!/usr/bin/env python3
"""Export a BIG-PICTURE snapshot from PocketBase -> plan-data.json (repo root).
Read-only. Roll-up counts + per-phase progress ONLY — deliberately NO needs/items
list (that's the coordination page's job, not the plan page).
Usage: export_plan.py [db_path] [out_path]
"""
import sqlite3, json, sys, datetime

DB  = sys.argv[1] if len(sys.argv) > 1 else "/Users/kenny/Documents/claude projects/Pocketbase/pb_data/data.db"
OUT = sys.argv[2] if len(sys.argv) > 2 else "/Users/kenny/Documents/claude projects/Homesteadplan/plan-data.json"

db = sqlite3.connect(DB, timeout=15); db.execute("PRAGMA query_only = ON")
db.row_factory = sqlite3.Row; c = db.cursor()

def one(q, *a):
    return c.execute(q, a).fetchone()[0]

today = datetime.date.today().isoformat()

# --- big-picture roll-ups (counts only) ---
roll = {
    "decisions_resolved": one("SELECT count(*) FROM decisions WHERE status='resolved'"),
    "decisions_open":     one("SELECT count(*) FROM decisions WHERE status='open'"),
    "constraints_total":  one("SELECT count(*) FROM constraints"),
    "constraints_handled":one("SELECT count(*) FROM constraints WHERE status IN ('handled','monitoring')"),
    "constraints_open":   one("SELECT count(*) FROM constraints WHERE status IN ('open','needs decision')"),
    "crops_active":       one("SELECT count(*) FROM crops WHERE status='active'"),
    "crops_ruled_out":    one("SELECT count(*) FROM crops WHERE status='ruled_out'"),
    "plantings_total":    one("SELECT count(*) FROM plantings"),
    "plantings_dated":    one("SELECT count(*) FROM plantings WHERE est_seed_date IS NOT NULL AND est_seed_date!=''"),
    "needs_total":        one("SELECT count(*) FROM needs WHERE status!='skip'"),
    "needs_have":         one("SELECT count(*) FROM needs WHERE status='have'"),
    "fields_measured":    one("SELECT count(*) FROM beds WHERE sqft>0"),
    "fields_total":       one("SELECT count(*) FROM beds"),
}

# --- next single hard deadline (one milestone, not a list) ---
nd = c.execute("""SELECT needed_by, item FROM needs
                  WHERE status='need' AND needed_by!='' AND substr(needed_by,1,10) >= ?
                  ORDER BY needed_by LIMIT 1""", (today,)).fetchone()
next_deadline = {"date": nd["needed_by"][:10], "item": (nd["item"] or "")[:80]} if nd else None

# --- per-phase progress: share of that phase's needs already in hand (have/skip) ---
phase_progress = {}
for code in ("P0","P1","P2","P3","P4","P5","P6","P7"):
    tot  = one("SELECT count(*) FROM needs WHERE phase=? AND status!='skip'", code)
    done = one("SELECT count(*) FROM needs WHERE phase=? AND status='have'", code)
    phase_progress[code] = {"done": done, "total": tot, "pct": round(100*done/tot) if tot else None}

data = {
    "generated_at": datetime.datetime.now().astimezone().isoformat(timespec="minutes"),
    "rollups": roll,
    "next_deadline": next_deadline,
    "phase_progress": phase_progress,
    "note": "Big-picture snapshot from PocketBase. Counts only — the item/shopping list lives on the coordination page.",
}
with open(OUT, "w") as f:
    json.dump(data, f, ensure_ascii=False, indent=1)
print(f"wrote {OUT}")
print(json.dumps(data["rollups"], indent=1))
print("next deadline:", next_deadline)
