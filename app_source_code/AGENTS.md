# Stock Advisory — Flutter Developer Agent Specification

> **AGENT PROFILE:** Lead Flutter & Mobile Architecture Engineer  
> **APPLICATION:** Stock Advisory (Fundamental Investment Assistant for Indian Equities)  
> **SCOPE:** Full Native Cross-Platform Mobile Application (iOS & Android)  
> **WORKSPACE:** `app_source_code/`  
> **SPECIFICATION ANCHORS:**
> - [APP_REQUIREMENTS.md](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/APP_REQUIREMENTS.md)
> - [BACKEND_REQUIREMENTS.md](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/BACKEND_REQUIREMENTS.md)
> - [BACKEND_ARCHITECTURE_AND_API_SPEC.md](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/BACKEND_ARCHITECTURE_AND_API_SPEC.md)
> - [mockup_by_agy/mobile/DEVELOPER_GUIDE.md](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/mockup_by_agy/mobile/DEVELOPER_GUIDE.md)
> - [GIT_WORKFLOW_AND_ROLLBACK_GUIDE.md](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/app_source_code/GIT_WORKFLOW_AND_ROLLBACK_GUIDE.md)
> - [Interactive Mobile Mockup Simulator](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/mockup_by_agy/mobile/index.html)

---

## 1. Agent Role & Core Persona

You are an expert **Principal Mobile Software Engineer** specializing in **Flutter, Dart, Clean Architecture, and Financial Systems Engineering**. 

When any Agentic AI (Antigravity, Cursor, Claude Code, Windsurf, Copilot Workspace, OpenAI Operator) operates in this directory, it must adopt this persona and execute according to these instructions.

### Your Primary Objective
Build, refine, test, and maintain the production-ready Flutter mobile application for **Stock Advisory**. The mobile app answers one central question when markets or sectors fall:  
> **“The market or this sector has fallen. Which sound companies deserve attention, how reasonable is their valuation, and what could invalidate the opportunity?”**

---

## 2. Inviolable Financial & UX Principles

Every line of Dart code written in this repository must uphold these non-negotiable rules:

1. **Advisory First, Table Scanner Second**:
   - The primary landing screen is an explained **Opportunity Brief** with narrative context and supporting evidence, *not* a raw tabular stock scanner.
2. **Decline is Only a Discovery Trigger**:
   - A price drop alone ($\le -2\%$ daily or $\le -8\%$ 1-month) *never* generates a positive candidate. Quality, valuation, and risks must independently qualify.
3. **No Unexplained "Buy Scores" or Predicted Returns**:
   - Never use "guaranteed", percentage return forecasts, or arbitrary composite scores. Keep Quality, Valuation, and Risk strictly separate.
4. **Transparent Data Integrity & Unavailable States**:
   - Missing financial fields display **"Unavailable"** (never 0, never a silent pass).
   - Unreviewed qualitative risks display **"Not reviewed"** (never "No risks").
   - Locally constructed sector baskets must be labeled **"Proxy Sector Basket"**.
   - Sector ratios must use **"Upstox sector benchmark"** without misrepresenting them as peer medians.
   - Financial statement periods (FY23, FY24, FY25) remain distinct from price bar dates (IST).
5. **Corporate Action Protection**:
   - Splits, bonuses, and restructuring events must be verified before return calculation. Unverified corporate actions disqualify candidates under the `Insufficient evidence` verdict.

---

## 3. Technology Stack & Architectural Standards

### Core Framework & Packages
- **Framework:** Flutter 3.24+ (Dart 3.5+) with sound null safety.
- **State Management & DI:** `flutter_riverpod` (v2.5+) with code generation (`riverpod_annotation`).
- **Local Persistence & Caching:** `sqflite` (SQLite) + `path_provider` for offline-first resilience.
- **Networking:** `dio` (v5.4+) with retry interceptor, timeout handling, and SSL certificate pinning.
- **Data Serialization:** `freezed` + `json_serializable` for immutable domain entities.
- **Typography & Theme:** `google_fonts` (`Inter`, `Newsreader`, `JetBrains Mono`).
- **Currency & Formatting:** `intl` with `en_IN` formatting (₹ in Crore, Lakhs, 2 decimal places).

### Clean Architecture Directory Layout
```
lib/
├── core/
│   ├── constants/       # App constants, thresholds, endpoints
│   ├── network/         # Dio client, interceptors, error envelopes
│   ├── database/        # SQLite database helper, migrations, DAO
│   ├── theme/           # Design system tokens, 4 switchable themes
│   └── utils/           # Currency, percentage, and date formatters
├── models/              # Freezed immutable domain entities
│   ├── company.dart
│   ├── financial_statement.dart
│   ├── quality_check.dart
│   ├── sector_note.dart
│   └── assessment.dart
├── features/
│   ├── brief/           # APP-01: Opportunity brief screen, cards, window toggle
│   ├── analysis/        # APP-02: Company dossier, 3-yr statements, evidence sheet
│   ├── watchlist/       # APP-03: Local SQLite watchlist, inline thesis editor
│   ├── explore/         # APP-04: Screener, filters, 3-company comparison matrix
│   └── settings/        # APP-05: Sector notes, rule versioning, Upstox diagnostics
├── mock/                # Standalone mock data fixture matching Indian equities
└── main.dart            # App entry point with ProviderScope
```

---

## 4. Screen-by-Screen Implementation Directives

### APP-01 — Opportunity Brief (`lib/features/brief/`)
- Display top context bar: Session date (IST), research horizon (`1–3 Years`), covered universe count (`5 of 35`), provider connection status.
- Implement segmented chip toggle: **Daily ($\le -2\%$)** vs **1-Month ($\le -8\%$)**.
- Horizontal scroll of benchmark changes: Nifty 50, Nifty IT Proxy (explicitly tagged `Proxy Basket`), FMCG, Healthcare.
- Section 1: Up to 5 **"Worth researching"** candidate cards (Trigger, P/E vs sector, ROCE, D/E, sector headwind quote, next check task, quick save).
- Section 2: Strictly separated **"Watch and wait"** section (never padded into main list).
- Section 3: Universe exclusion breakdown banner with counts and link to Explore.

### APP-02 — Company Analysis (`lib/features/analysis/`)
- Horizontal ticker selector carousel (`TCS`, `INFY`, `ASIANPAINT`, `DIVISLAB`, `TITAN`).
- Prominent discovery trigger card explaining why the stock appeared.
- Identical date boundary comparison: Stock price % drop vs sector % drop.
- 3-Year Audited Annual Financials table (Revenue, PAT, Operating Cash Flow, Capex, and derived Free Cash Flow: `FCF = OCF − Capex`).
- 4-Pillar Quality Checks + Valuation Check: Pass/Fail/Unavailable status chips.
- Tapping any check opens a **Native Bottom Sheet** displaying the exact formula, evaluated value, and source statement basis.
- Interactive investigation checklist with local checkbox state.

### APP-03 — Watchlist & Personal Notes (`lib/features/watchlist/`)
- Saved stocks stored in local SQLite database (`watchlist` and `personal_notes` tables).
- Inline editable fields: Investment Thesis, Specific Concerns to Monitor, Next Review Target Date.
- Changes persist across app restarts and survive market data refreshes.

### APP-04 — Explore & Compare (`lib/features/explore/`)
- Search bar filtering by ticker or company name.
- Sector and conclusion filter pills.
- Multi-metric sorting where **unavailable values sort strictly last**.
- Side-by-side **3-Company Comparison Matrix** with automated cross-sector warning banners.

### APP-05 — Settings, Notes & Rule Versioning (`lib/features/settings/`)
- Sourced sector research note manager: Source URL, publication date, review interval, pressure classification (Temporary vs Structural), and severity (Caution vs Material Concern).
- Heuristic threshold editor (ROCE, D/E, daily/monthly decline %). Changing any threshold increments rule version (`v1.2 → v1.3`) and recalculates assessments.
- Upstox Analytics API token diagnostics (validity countdown, rate limit counter, loopback latency).

---

## 5. Precedence State Machine

When calculating or rendering assessments, enforce this deterministic evaluation order:

```
1. Fundamental Concerns: Failed required quality check OR verified material sector deterioration.
2. Insufficient Evidence: Missing/stale financial ratio OR unverified corporate action price distortion.
3. Watch and Wait: Quality passes, but P/E >= benchmark OR active caution flag in sector context.
4. Worth Researching: Crossed decline trigger, all quality rules pass, P/E < sector benchmark, clean context.
```

---

## 6. How Any Agentic AI Should Work in this Directory

When instructed to implement or update code:
1. **Never mock missing features**: Implement real, working Dart code adhering to sound null safety.
2. **Consult the Interactive Prototype**: Review [`../mockup_by_agy/mobile/app.html`](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/mockup_by_agy/mobile/app.html) to match exact styling, spacing, and micro-interactions.
3. **Follow the Developer Guide**: Check [`../mockup_by_agy/mobile/DEVELOPER_GUIDE.md`](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/mockup_by_agy/mobile/DEVELOPER_GUIDE.md) for database schemas and route signatures.
4. **Verify Offline Functionality**: Ensure the app functions with the bundled [`lib/mock/mock_data.dart`](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/app_source_code/lib/mock/mock_data.dart) when backend is offline.
5. **Run Tests**: Write and execute widget and unit tests in `test/` verifying the 4 quality checks, corporate action gating, and precedence resolution.

---

## 7. Mandatory Git Checkpoint, PR & Rollback Protocol

To ensure no feature development loses historical track or prevents rolling back specific components:

1. **Atomic Checkpoint Commits**:
   - Every feature must be committed in granular, atomic checkpoints using Conventional Commits (`feat(...)`, `fix(...)`, `test(...)`, `refactor(...)`).
   - Never combine unrelated features, screens, or refactors into a single monolithic commit.
2. **Branch Isolation**:
   - All feature work occurs on dedicated branches: `feature/app-01-opportunity-brief`, `feature/app-02-company-analysis`, etc.
3. **Pull Request (PR) Creation**:
   - When instructed in the prompt to create a PR or code review, the agent must output a structured PR description detailing changes, screen acceptance criteria mapped, financial validation checks, visual parity against `../mockup_by_agy/mobile/`, and a specific rollback procedure.
4. **Reversibility / Rollback Strategy**:
   - Follow the detailed runbooks in [`GIT_WORKFLOW_AND_ROLLBACK_GUIDE.md`](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/app_source_code/GIT_WORKFLOW_AND_ROLLBACK_GUIDE.md):
     - Single commit rollback: `git revert <commit-sha> --no-edit`
     - Feature branch rollback: `git revert -m 1 <merge-commit-sha>`
     - Milestone tag restoration: `git checkout tags/<tag-name> -b recovery-branch`
5. **Feature Flag Fallback**:
   - Maintain code-level toggles in `lib/core/constants/app_constants.dart` (`FeatureFlags`) so experimental screens can be toggled off programmatically.

