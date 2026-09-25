# Stock Advisory — MVP Build Plan

Version: 0.3 draft | Updated: 2026-09-25

## Goal

Deliver a personal advisory research app that explains opportunities during declines. Product vision: `requirments.md`. App scope: `APP_REQUIREMENTS.md`. Calculations, evidence and API behavior: `BACKEND_REQUIREMENTS.md`.

## Delivery assumptions

One developer, one local application, one local database, one data provider, 30–50 nonfinancial stocks and three sectors. A functional MVP is an estimated 7–10 focused development days after credentials and usable data are available. This is a planning estimate, not a delivery guarantee.

No separate mobile app, automated news system, AI service, cloud deployment or trading integration in this milestone.

## Phase 1 — Prove the data (day 1)

- Configure the token locally without sharing it in chat.
- Select five companies from the proposed sectors and verify all required provider fields.
- Verify benchmark candles, dates, reporting basis, ratio definitions and corporate actions.
- Produce a coverage matrix: available, unverified or unsupported.

Exit: enough verified data to calculate at least one end-to-end assessment. If a required field/definition is unavailable, keep the corresponding conclusion insufficient or explicitly revise the requirement; never invent data. A clearly labeled fixture can unblock UI work but does not complete live integration.

## Phase 2 — Data and assessment engine (days 2–3)

- Create database schema, provider adapter and manual refresh job.
- Normalize evidence and implement quality, valuation and freshness rules.
- Implement deterministic conclusions with saved evidence and rule versions.
- Add meaningful calculation and failure-path tests.

Exit: the same input produces the same conclusion, and missing evidence cannot create a positive candidate.

## Phase 3 — First usable advisory flow (days 4–5)

- Build the Opportunity Brief and Company Analysis screens.
- Add source-backed sector/company review forms.
- Show stale, missing, failure and empty states.
- Generate explanations from evidence templates.

Exit: review five companies from home page through evidence and risk explanation. Manually reconcile conclusions with the inputs.

## Phase 4 — Personal workflow and expanded coverage (days 6–7)

- Persist watchlist, thesis and review dates.
- Add the secondary screener and three-company comparison.
- Expand only to companies with understood mappings; report gaps.
- Expose rule settings with versioning and validated inputs.

Exit: personal notes survive restart and the 30–50-company universe loads without hidden data gaps.

## Phase 5 — Reliability and handover (days 8–10 if needed)

- Exercise throttling, expired credentials, partial refresh and restart recovery.
- Verify secret handling, local-only access and mutation protection.
- Check desktop/mobile layout and cached-response performance.
- Write startup, refresh, token replacement and backup/restore instructions.

Exit: complete acceptance criteria in both requirements documents, with limitations recorded.

## Priority if time is tight

Keep: five-company live slice, explained brief, company evidence, manual research notes, watchlist, visible data limitations.

Defer: expanded universe, comparison, advanced filters, editable rule UI and calculated peer-median fallback. Fixed versioned configuration is acceptable for the first slice. Label that delivery an initial slice rather than claiming the full MVP is complete.

## Decisions before coding

| Decision | Proposed default |
|---|---|
| User/access | One user, local computer only |
| Market | Indian listed equities |
| Research horizon | 1–3 years, explicitly displayed |
| Universe | Five companies first; then 30–50 across three nonfinancial sectors |
| Refresh | Manual, completed daily sessions |
| Sector interpretation | User-maintained source-backed research notes |
| Explanations | Deterministic evidence templates |
| Credentials | Read-only Upstox Analytics Token in backend configuration |
| Storage | SQLite; watchlist and notes in the same local database |

Exact sectors, company list and benchmark mapping remain open until the data check. Technology defaults are proposals, not claims that an implementation already exists.

## Success measures

- A qualifying decline produces an understandable research candidate.
- Financial weakness, uncertain evidence and sector concerns change the conclusion visibly.
- No positive candidate relies on missing or unverifiable required inputs.
- Every conclusion can be traced to saved data, research and rule versions.
- The app remains useful with cached data during a provider outage.

This milestone validates usefulness and data reliability. It does not establish investment outperformance; no backtested performance or expected returns are claimed.
