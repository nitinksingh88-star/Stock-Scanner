# Stock Advisory — App Requirements

Version: 0.3 draft | Updated: 2026-09-25 | Personal-use MVP

## 1. Purpose and scope

Build a private investment research assistant for Indian equities. Its primary experience answers: “The market or this sector has fallen. Which sound companies deserve attention, how reasonable is their valuation, and what could invalidate the opportunity?” Screening is secondary.

This document extends the product vision in `requirments.md`. `BACKEND_REQUIREMENTS.md` defines calculations and decision rules; `BUILD_PLAN.md` defines delivery order. These documents refine the implementation without replacing the product vision.

Initial scope: 30–50 nonfinancial companies across three sectors, one user, one computer, latest completed trading sessions, manual refresh, and a provisional 1–3 year research horizon. Universe and sectors are configuration choices to confirm during the first data check. No live intraday advice or return forecasts.

## 2. Main user journey

Open brief → choose daily or one-month decline → read candidates → inspect evidence and risks → save a company → record what to check next.

The first working slice covers five companies and one sector. Expand after the data and conclusions are checked manually.

## 3. Screens and acceptance criteria

### APP-01 — Opportunity Brief (primary home page)

- Show the dataset's trading date, research horizon, covered universe size and last successful refresh.
- Show broad-market and covered-sector changes for the selected daily/monthly window.
- Explain which benchmark is used. A locally constructed sector basket must be labeled as a proxy.
- Show up to five “Worth researching” candidates. Show “Watch and wait” separately; do not use these to pad the main list.
- Each card contains company, sector, price decline, quality checks, valuation comparison, research conclusion, material risk and next check.
- Provide links to company evidence and source-backed sector notes.
- Show “No qualifying opportunities” when appropriate, with exclusion counts and a link to Explore.
- Never use “guaranteed,” predicted profit percentages or an unexplained buy score.

Acceptance: Price decline alone cannot produce a positive conclusion. All displayed changes identify their date range. A stale dataset is visibly stale, including when the provider is unavailable.

### APP-02 — Company Analysis

Display:

1. Why the company appeared in the brief.
2. Company and sector price changes over identical dates.
3. Revenue, profit and operating cash flow for up to three annual periods.
4. Quality and valuation checks: value, rule, pass/fail/unavailable, period and source.
5. Sector context: pressure, potential impact, recovery conditions and contrary evidence.
6. Company-specific concerns and date last reviewed.
7. An evidence-based conclusion and a practical next-review checklist.

Use “Upstox sector benchmark” for the provider's sector ratio. Do not rename it an industry median or present provider P/E as trailing until its basis is verified. A supplied ratio can be displayed with a definition limitation even when it cannot support a positive valuation check.

Acceptance: Clicking a check exposes its evidence. Missing information displays “Unavailable.” Missing research displays “Not reviewed,” never “No risks.” Financial results and recent price dates remain distinct.

### APP-03 — Watchlist and personal notes

- Save/remove companies and persist them locally in the application database.
- Record investment thesis, concerns and next-review date.
- Show the latest available conclusion and data date.
- Allow viewing and editing after restarting the application.

Acceptance: Saves are confirmed only after the backend succeeds. Refreshing market data cannot erase user notes.

### APP-04 — Explore and compare (secondary)

- Search the covered companies; filter by sector, decline window, P/E, ROCE and conclusion.
- Sort by an explicitly selected metric; unavailable values sort last.
- Compare up to three companies across the same checks and financial periods.
- Flag cross-sector comparisons and incompatible statement periods.

Acceptance: Explore includes excluded companies and explains their status. Filters never substitute zero for missing figures.

### APP-05 — Research notes and settings (small utility pages)

- Maintain sector/company research notes with source URL, publication date, review date, summary, pressure classification, severity and next-review date.
- Pressure classification: potentially temporary, potentially structural, mixed or unknown.
- Severity: informational, caution or material concern. Classification and severity are separate.
- Show active screening rules and allow validated changes to supported thresholds.
- Show provider connection status, refresh progress and errors without exposing credentials.
- Editing a note or rule recalculates affected results and records a new assessment version.

Acceptance: A source link is required for a factual sector claim. Unsourced personal opinions remain labeled opinions and cannot clear a material risk flag.

## 4. Required states

| State | Expected behavior |
|---|---|
| No data yet | Explain setup and offer first refresh |
| Refresh running | Show progress; keep the previous snapshot visible |
| Token rejected | Explain that the local credential needs replacement; preserve cached data |
| Partial provider failure | Identify unavailable companies/fields; show coverage and last valid dates |
| Research expired | Downgrade evidence completeness; show which note needs review |
| No opportunities | Explain that no company passed; provide Explore |
| Saving failed | Keep the user's input and show a retry action |

## 5. Design requirements

Responsive browser interface, with opportunity explanations prominent and technical details behind “View evidence.” Support keyboard navigation, labeled controls and text labels alongside status colors. Format money in INR with clearly labeled units. Display local dates in Asia/Kolkata.

Performance target: cached brief and company pages usable within two seconds on the development computer for the configured universe. A page visit must not wait for fresh Upstox requests.

## 6. Exclusions

No brokerage order placement, account balances, personalized allocation, public users, payments, notifications, AI chat, automated news interpretation, price targets or native mobile application. Public hosting and multi-user authentication require a later scope decision.

## 7. App completion checklist

- Home page functions as an explained advisory brief, not a table-first scanner.
- Every conclusion shows supporting evidence and limitations.
- Missing and stale data are visible.
- User notes and watchlists survive restart.
- Five manually verified company examples match backend evidence.
- Core flow works at desktop and narrow mobile widths.
