# Homesteadplan — the public plan page

Static site: `index.html` (the phase/plan visualisation) and
`parcel-map-preview.html`. No build step. Separate from the Homestead OS app —
this one is for showing the plan, not running the farm.

## The rule that outranks everything

**Organic certification governs every decision.** See the `Regulatory` constraints in
the app and `claude/organic-governing-rule.md` in the Homestead project.

## Keep it a view, not a second source of truth

Anything factual here — crop lists, phases, dates, targets — also exists in
PocketBase. When they disagree, **PocketBase wins**. Do not let this page become a
place where numbers get maintained by hand; that is how the vault and the app drifted
apart for months. If a figure matters, it should be read from the data, not retyped.

## Related

- `../Homestead-os` — the working app
- `../Pocketbase` — the records
- `../Homestead Vault` — the reasoning
