# Stock Advisory — Backend Requirements

Version: 0.3 draft | Updated: 2026-09-25 | Personal-use MVP

## 1. Proposed architecture

Use one application codebase with a browser UI, server-side HTTP handlers, a local SQLite database and an Upstox adapter. A single TypeScript web application is the proposed implementation baseline; final framework/library versions will be selected and checked when implementation begins. Separate frontend/backend deployment, microservices, Redis and cloud infrastructure are unnecessary for this MVP.

Flow: Upstox → validated raw responses → normalized database records → calculation/rule engine → versioned opportunity assessments → app API → browser.

Manual research notes enter the same assessment engine. Explanations use templates and structured evidence; no language model is needed initially.

## 2. Provider integration and validation gate

Use the Upstox Analytics Token stored in local server configuration. Official documentation describes read-only access to fundamentals and market data with one-year token validity; verify access with the user's account before committing to coverage.

Required adapter operations:

- Resolve company ISINs and exchange instrument keys.
- Retrieve company profiles and sector classification.
- Retrieve completed daily candles for companies and selected benchmarks.
- Retrieve key ratios and provider sector benchmarks.
- Retrieve income statements, cash flow and balance sheets, including detailed fields where necessary.
- Retrieve corporate actions covering the price-comparison window.

Validate five companies before implementing broad ingestion. Record actual schemas, available periods, units, statement basis, timestamps, benchmark availability and token access. Confirm P/E earnings basis and price adjustment conventions. Debt and capital-expenditure field mappings require verification; unsupported fields stay unavailable.

## 3. Storage model

| Entity | Minimum fields |
|---|---|
| companies | ISIN, exchange key, ticker, name, sector, industry if known, active flag |
| universe_config | included companies, sector/market benchmarks, membership version |
| price_bars | instrument, session date, OHLC, source, adjustment status, retrieval time |
| fundamental_observations | company, metric, value/unit, period, statement basis, source record, retrieval time, validity status |
| ratio_snapshots | company/sector values, ratio name, definition status, provider as-of if available, retrieval time |
| corporate_actions | company, event type, effective date, factor/details, review status |
| research_notes | company/sector, sources, publication/review/expiry dates, summary, pressure classification, severity, recovery/invalidation conditions |
| watchlist | company, created time |
| personal_notes | company, thesis, concerns, next-review date, modified time |
| refresh_runs | run ID, start/end, per-resource success/error, counts, snapshot ID |
| rule_versions | immutable configuration, version, creation time |
| assessments | company, snapshot/rule/note versions, checks, conclusion, reasons, limitations, calculated time |

Keep provider response evidence locally with each import, excluding authorization headers. Use stable unique keys to prevent duplicate observations. Store restated values as new versions rather than silently replacing evidence used by an old assessment. User notes and watchlists are independent of imported data.

## 4. Normalization and formulas

- Preserve original values, units and provider keys alongside normalized fields.
- Parse numeric strings and percent strings; reject invalid/nonfinite values.
- Normalize percentages as percentage points: 15 means 15%, not 0.15.
- Prefer consolidated statements. A standalone fallback must be labeled and cannot be mixed into a consolidated series.
- Distinguish a metric's financial period, provider as-of date and retrieval time. Retrieval today does not make an old financial result current.
- Nonpositive earnings make earnings-based valuation not meaningful. Nonpositive equity invalidates derived debt/equity and ROE comparisons.
- Derived debt/equity = verified total debt / shareholder equity for the same period and basis.
- Derived free cash flow = operating cash flow − capital expenditure expressed as positive outflow. Never substitute total investing cash flow for capital expenditure.
- Revenue CAGR is optional: three-year CAGR requires four fiscal-year observations, positive starting revenue and consistent periods.

## 5. Price windows and benchmarks

Use the latest completed exchange session T. Daily return = close(T) / close(previous session) − 1. One-month return = close(T) / close(last session on or before T minus one calendar month) − 1. Display the actual endpoints.

Use identical endpoints for company and benchmark. Do not silently select a different day for one instrument when its bar is missing. Validate completed sessions using available market-calendar information; if the calendar cannot be established, display the last available date without claiming it is current.

Use split/bonus-adjusted comparable prices when adjustment is verified; avoid double adjustment. For unsupported or unresolved corporate actions within the window, mark the return unverified and prevent it from generating a positive candidate. Label the calculation a price return, not a dividend-inclusive total return. Flag material ex-dividend moves for review.

Prefer a verified sector index. If unavailable, use a labeled fixed-membership equal-weight return basket of at least five covered companies with complete endpoint data; report membership and count. If insufficient, leave the sector return unavailable. Never label a proxy as an official index.

## 6. Initial assessment rules

These are configurable research heuristics for the initial nonfinancial universe, not validated predictors of returns. No score represents a probability of profit. Financial businesses remain excluded.

### 6.1 Discovery trigger

Default stock-decline thresholds: daily return ≤ -2% OR one-month return ≤ -8%. The UI's selected window determines which applies. Broad-market/sector returns provide context; selecting a sector scopes the candidate universe. A company can also qualify during a company-specific decline. All dates and thresholds are visible.

### 6.2 Quality checks

Required starter checks: latest annual net profit > 0; annual operating cash flow > 0; ROCE ≥ 15%; debt/equity ≤ 1 with positive equity. All required checks must pass for “Worth researching.” Use verified definitions and consistent periods. Do not silently substitute ROE for ROCE; a changed definition requires a new rule version.

Free cash flow and revenue/profit trends add context if available. They are not mandatory in the first five-company slice. Any additional hard exclusion must be explicitly configured and explained.

### 6.3 Valuation check

Require meaningful positive company P/E below a meaningful positive comparable benchmark. Provider benchmark label: “Upstox sector benchmark”; its methodology and earnings basis must be compatible or the check is unavailable. Do not call it an industry median.

Alternative: calculate a labeled median of at least five comparable covered peers excluding the company, using consistently defined P/E values. Record membership and coverage. This fallback is optional, not required to ship the first slice.

A passed check means “below selected benchmark,” not “intrinsically undervalued.” Unverified ratio basis allows display only, not a passed check. Cyclical peak earnings and unusual profits are review prompts.

### 6.4 Evidence freshness (initial configurable defaults)

- Prices: expected latest completed session.
- Provider ratios: retrieved within seven days, with source-as-of limitations visible.
- Annual statements: latest obtainable period; flag if period end is older than 18 months or the provider is known to lack a newer published filing.
- Sector and company reviews: reviewed within 30 days and not beyond an earlier user-set review date.

Fresh annual data alone does not establish current business health. Company review should consider the latest available quarterly results and disclosed events. Unknown provider update lag remains a limitation.

### 6.5 Conclusion precedence

Evaluate in this order and retain every reason, including secondary missing-data warnings:

1. **Fundamental concerns:** a verified material concern or failed required quality check exists.
2. **Insufficient evidence:** a required price/fundamental/valuation input is missing, invalid or stale, or the sector/company context has not been reviewed. An unverified cause of decline remains insufficient under the product draft.
3. **Watch and wait:** quality evidence is sufficient, but valuation fails or reviewed context remains mixed/uncertain or contains caution flags.
4. **Worth researching:** decline trigger, all quality checks and valuation pass; required reviews are current; no material/caution issue remains unresolved.

Companies outside the decline threshold stay available in Explore but are not brief candidates; return an explicit `triggered=false` rather than implying a negative investment conclusion.

List up to five qualifying candidates. Use deterministic research-priority ordering: more available optional evidence, then lower positive P/E-to-benchmark ratio, then ISIN as tie-breaker. State that this is shortlist ordering, not expected-return ranking.

## 7. App-facing API contract (proposed internal routes)

| Method and route | Purpose |
|---|---|
| GET /api/brief?window=day&sector=... | benchmark context, candidates, exclusions, coverage; window accepts day or month |
| GET /api/companies | covered universe, validated filters and sort |
| GET /api/companies/:isin | profile, prices, metrics, assessment and evidence |
| GET /api/compare?isins=... | same evidence for up to three companies |
| GET /api/watchlist | saved companies |
| PUT /api/watchlist/:isin | idempotent save |
| DELETE /api/watchlist/:isin | remove |
| PUT /api/companies/:isin/personal-note | save thesis and next-review date |
| GET/POST /api/research-notes | list/create research notes |
| PUT/DELETE /api/research-notes/:id | update/remove note; invalidate affected assessments |
| GET/PUT /api/settings/rules | view/update validated rules with versioning |
| POST /api/refresh | start one refresh job; return 202 and job ID |
| GET /api/refresh/:id | progress and per-resource errors |
| GET /api/status | credential configured flag, last refresh, health |

Responses include snapshot ID, data-as-of, generated-at, coverage and warnings. Each check includes ID, actual value, rule, pass/fail/unavailable, evidence references and reason. Error envelope: code, safe message, retryable flag. Use 400 for invalid input, 404 for unknown resources, 409 for conflicting active refresh, and 503 when no usable data exists. Cached valid responses may return 200 with explicit stale/provider warnings.

## 8. Refresh and failure handling

- Page requests read cached data; only explicit refresh makes provider calls.
- One durable job at a time. On restart mark interrupted jobs incomplete and permit retry.
- Bound concurrency and honor current documented per-user/API quotas and retry guidance.
- Retry transient network/5xx/429 failures with bounded exponential backoff and jitter; do not repeatedly retry invalid credentials.
- Validate imports before publishing a new snapshot. Commit each company's dependent dataset atomically; record per-company dates and completeness when the overall run is partial.
- Retain last good data on failure, visibly stale where applicable. Never combine a new price with old inputs silently.
- Recalculate after valid data, research-note or rule changes. Preserve historical assessment evidence.

## 9. Local security and operation

Bind to loopback only for this personal version. Browser accesses the local backend; only the backend sends the token to Upstox. Keep tokens outside source control, browser bundles, URLs, logs, exports and database evidence. No order-placement integration.

Check Origin/Host and protect mutation routes against cross-site requests; do not enable wildcard cross-origin access. Validate inputs and render notes as plain text or sanitized content. Provide a local database backup/restore procedure that excludes credentials. Remote deployment requires authentication and a fresh security review.

## 10. Required verification

Unit checks: return dates around weekends/holidays, numeric parsing, missing versus zero, nonpositive earnings/equity, statement-basis mismatch, corporate actions, quality/valuation boundaries, review expiry and conclusion precedence.

Integration checks: invalid token, provider throttling, partial import, interrupted refresh, repeat imports without duplicates, assessment invalidation, watchlist persistence and secret redaction.

Manual financial QA: reconcile five companies against source evidence; review at least one healthy declining company, a cheap but weak company, unknown sector context, a corporate-action case and an insufficient-data case. Fixtures may cover scenarios absent from live samples and must be labeled synthetic.

## 11. Official references and remaining uncertainty

Reviewed 2026-09-25. Documentation verification is not an account-access test.

- [Company Fundamentals](https://upstox.com/developer/api-documentation/announcements/company-fundamentals-api/)
- [Key Ratios](https://upstox.com/developer/api-documentation/get-key-ratios/)
- [Analytics Token](https://upstox.com/developer/api-documentation/analytics-token/)
- [Rate Limits](https://upstox.com/developer/api-documentation/rate-limiting/)

Still to verify: actual account access, selected-company coverage, historical depth, precise ratio basis, sector benchmark methodology, usable debt/capex fields and price adjustment conventions. Record findings before relaxing any eligibility rule.
