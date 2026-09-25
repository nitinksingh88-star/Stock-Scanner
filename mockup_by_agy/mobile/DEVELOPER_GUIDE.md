# Stock Advisory — Mobile App Developer Handoff Guide

**Target Audience:** Mobile Application Engineers (Flutter / React Native / SwiftUI / Kotlin Jetpack Compose)  
**Specification References:** [APP_REQUIREMENTS.md](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/APP_REQUIREMENTS.md), [BACKEND_REQUIREMENTS.md](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/BACKEND_REQUIREMENTS.md), [BACKEND_ARCHITECTURE_AND_API_SPEC.md](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/BACKEND_ARCHITECTURE_AND_API_SPEC.md)  
**Interactive Simulator:** [mockup_by_agy/mobile/index.html](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/mockup_by_agy/mobile/index.html)  
**Standalone Mobile Preview:** [mockup_by_agy/mobile/app.html](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/mockup_by_agy/mobile/app.html)

---

## 1. Executive Summary & Purpose

The mobile application is a private investment research assistant for Indian equities. Its primary UX answers:
> **“The market or this sector has fallen. Which sound companies deserve attention, how reasonable is their valuation, and what could invalidate the opportunity?”**

### Non-Negotiable Rules for Mobile Engineers
1. **Advisory First, Table Scanner Second**: The primary landing screen is an explained **Opportunity Brief** with narrative context, not a raw scanner table.
2. **Decline is Only a Discovery Trigger**: A price drop alone *never* creates a positive candidate.
3. **No Unexplained "Buy Scores" or Guaranteed Predictions**: Quality, valuation, and risks are kept strictly separate.
4. **Data Integrity & Offline Cache**:
   - Missing data shows **“Unavailable”** (never 0, never a silent pass).
   - Unreviewed context shows **“Not reviewed”** (never “No risks”).
   - Locally constructed sector baskets must be labeled **“Proxy Sector Basket”**.
   - Sector ratios must be labeled **“Upstox sector benchmark”** without misrepresenting them as peer medians.
   - Cached data must remain interactive even when the provider/network is unavailable.

---

## 2. Navigation Architecture & Route Hierarchy

The app uses a persistent bottom navigation bar with 5 primary root tabs:

```
AppRoot
├── Tab 1: /brief (Opportunity Brief - Home)
│   └── BottomSheet: EvidenceSheetModal(/brief/evidence/:isin)
├── Tab 2: /analysis/:isin (Company Dossier Deep-Dive)
│   ├── Horizontal Ticker Selector
│   ├── 3-Year Audited Financials
│   └── Next Checks Task Manager
├── Tab 3: /watchlist (Saved Theses & Checkpoints)
│   └── Inline Thesis & Concerns Editor (Local SQLite)
├── Tab 4: /explore (Screener & 3-Company Compare)
│   ├── Multi-Facet Filter Sheet
│   └── 3-Company Comparison Matrix
└── Tab 5: /settings (Rules Governance & Provider Diagnostics)
    ├── Sourced Sector Notes Manager
    ├── Threshold Recalculation Form (v1.2 → v1.3)
    └── Upstox API Quota Diagnostics
```

---

## 3. Mobile Design Tokens & 4 Archetypes

The mobile app includes 4 switchable clean themes designed for modern mobile devices:

| Theme | Aesthetic Direction | Font Stack | Surface Colors |
|---|---|---|---|
| **1. Minimal iOS / SaaS (Default)** | Clean Scandinavian / Apple Human Interface | `SF Pro Text` / `Inter` | Canvas: `#F8FAFC`, Cards: `#FFFFFF`, Borders: `#E2E8F0` |
| **2. Swiss Editorial** | Formal financial memorandum (*FT* / *Economist*) | `Newsreader` (serif) | Canvas: `#FAF8F5`, Cards: `#FFFFFF`, Borders: `#E4E0D8` |
| **3. Dark Institutional Pro** | Cockpit terminal (*Bloomberg* / *Koyfin*) | `JetBrains Mono` | Canvas: `#090D16`, Cards: `#111827`, Borders: `#1F2937` |
| **4. Bento Grid** | Segmented modular cards | `Plus Jakarta Sans` | Canvas: `#F4F4F5`, Cards: `#FFFFFF`, Borders: `#E4E4E7` |

### Touch Ergonomics
- **Minimum Tap Targets**: 44x44 pt for all icons, buttons, and segmented pills.
- **Safe Area Insets**: Top safe area (`44pt` for notch/island) and bottom safe area (`34pt` for home indicator).
- **Pull-to-Refresh**: Native swipe-down gesture on `/brief` and `/analysis` to trigger manual refresh.

---

## 4. Local SQLite Database Schema

All user theses, watchlists, notes, and rule versions must persist locally on the device (offline first):

```sql
-- Watchlist Table
CREATE TABLE IF NOT EXISTS watchlist (
  isin TEXT PRIMARY KEY,
  ticker TEXT NOT NULL,
  company_name TEXT NOT NULL,
  sector_id TEXT NOT NULL,
  added_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Personal Theses and Review Checkpoints
CREATE TABLE IF NOT EXISTS personal_notes (
  isin TEXT PRIMARY KEY,
  thesis TEXT,
  concerns TEXT,
  next_review_date DATE,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (isin) REFERENCES watchlist(isin) ON DELETE CASCADE
);

-- Sourced Sector Research Notes
CREATE TABLE IF NOT EXISTS sector_research_notes (
  sector_id TEXT PRIMARY KEY,
  sector_name TEXT NOT NULL,
  title TEXT NOT NULL,
  source_url TEXT NOT NULL,
  published_date DATE NOT NULL,
  reviewed_date DATE NOT NULL,
  next_review_date DATE NOT NULL,
  pressure_classification TEXT CHECK(pressure_classification IN ('potentially_temporary', 'potentially_structural', 'mixed', 'unknown')),
  severity TEXT CHECK(severity IN ('informational', 'caution', 'material_concern')),
  summary TEXT NOT NULL,
  potential_impact TEXT,
  recovery_conditions TEXT,
  invalidation_criteria TEXT
);

-- Local Rule Versioning
CREATE TABLE IF NOT EXISTS rule_versions (
  version_tag TEXT PRIMARY KEY,
  min_roce REAL DEFAULT 15.0,
  max_debt_equity REAL DEFAULT 1.0,
  daily_decline_trigger REAL DEFAULT -2.0,
  monthly_decline_trigger REAL DEFAULT -8.0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

---

## 5. Decision Rules & Assessment Precedence (Engine Logic)

When evaluating universe candidates on the completed trading session $T$:

1. **Discovery Trigger**:
   - Daily Window: $\text{Daily Return} \le -2.0\%$
   - 1-Month Window: $\text{1-Month Return} \le -8.0\%$
2. **Quality Checks**:
   - Latest Annual Net Profit $> 0$ (Consolidated)
   - Latest Annual Operating Cash Flow $> 0$
   - ROCE $\ge 15.0\%$
   - Total Debt / Equity $\le 1.00x$ (with positive shareholder equity)
3. **Valuation Check**:
   - Meaningful positive company P/E strictly below verified **Upstox sector benchmark**
4. **Corporate Action Protection**:
   - Splits, bonuses, or restructuring events must be verified. If unadjusted, disqualify candidate as `Insufficient evidence`.
5. **Precedence Hierarchy**:
   1. `Fundamental concerns`: Quality check failed or material concern verified.
   2. `Insufficient evidence`: Missing data, unverified corporate action, or unreviewed sector.
   3. `Watch and wait`: Quality passes, but valuation fails or caution flag active.
   4. `Worth researching`: All quality checks pass, valuation $<$ benchmark, context verified.

---

## 6. How to Review the Mockup

1. Open [`mockup_by_agy/mobile/index.html`](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/mockup_by_agy/mobile/index.html) to view the interactive mobile app inside the simulated iPhone 16 Pro / Android device shell alongside these technical specs.
2. Open [`mockup_by_agy/mobile/app.html`](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/mockup_by_agy/mobile/app.html) directly to test responsive full-screen mobile behavior on an actual phone or browser devtools.
