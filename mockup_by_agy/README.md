# Stock Advisory — Interactive Mockup Suite (by AGY)

This directory contains the complete, interactive full application mockup suite created for the **Stock Advisory (Fundamental Investment Assistant)** app according to [APP_REQUIREMENTS.md](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/APP_REQUIREMENTS.md), [BACKEND_REQUIREMENTS.md](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/BACKEND_REQUIREMENTS.md), [requirments.md](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/requirments.md), and the complete [BACKEND_ARCHITECTURE_AND_API_SPEC.md](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/BACKEND_ARCHITECTURE_AND_API_SPEC.md).

---

## 1. Quick Start / How to View

You can view the prototypes by opening [mockup_by_agy/index.html](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/mockup_by_agy/index.html) in any web browser.

The master showcase hub (`index.html`) includes:
- **Design Switcher**: Instant switching between all 4 distinct clean designs.
- **Responsive Viewport Controls**: Toggle between Desktop (Full), Laptop (1280px), Tablet (820px), and Mobile (390px) to verify responsive behavior at narrow widths.
- **Standalone Launch**: Open any design in its own dedicated browser tab.

---

## 2. The 4 Distinct Clean Designs

All designs are built strictly on clean design principles (purposeful typography, whitespace, low cognitive load, zero visual clutter, objective investment tone). Each design pursues a distinctly unique visual and interaction architecture:

### 1. Design 1: Swiss Editorial Gazette
- **Location**: [`mockup_by_agy/design-1-swiss-editorial/index.html`](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/mockup_by_agy/design-1-swiss-editorial/index.html)
- **Concept**: Typography-first research journal inspired by elite financial publications (*Financial Times*, *The Economist*, *Bloomberg Opinion*).
- **Aesthetic**: Warm ivory newsprint canvas (`#FAF8F5`), editorial serif typography (`Newsreader`), crisp hairline dividers, pullout margin quotes, and document-style inline evidence drawers.
- **Best For**: Deep, thoughtful investment reading where qualitative context and numerical evidence blend into a clear narrative memorandum.

### 2. Design 2: Nordic Minimalist SaaS
- **Location**: [`mockup_by_agy/design-2-nordic-minimal/index.html`](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/mockup_by_agy/design-2-nordic-minimal/index.html)
- **Concept**: Modern Scandinavian product design (Linear, Notion, Vercel).
- **Aesthetic**: Ultra-clean slate canvas (`#F8FAFC`), crisp white rounded cards (`#FFFFFF`, `rounded-xl`), micro-dot status badges, smooth slide-over drawer for formula trace, and calm, distraction-free whitespace.
- **Best For**: Users who prefer an uncluttered, modern software interface with swift scannability and minimal friction.

### 3. Design 3: Dark Institutional Pro Terminal
- **Location**: [`mockup_by_agy/design-3-dark-institutional/index.html`](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/mockup_by_agy/design-3-dark-institutional/index.html)
- **Concept**: High-density institutional financial cockpit (FactSet, Koyfin, modern Bloomberg Terminal).
- **Aesthetic**: Deep obsidian backdrop (`#070A11`), dark slate elevated panels (`#0E1422`), monospace alignment (`JetBrains Mono`), vibrant cyan/emerald/coral data highlights, keyboard navigation hints (`[F1]`, `[F2]`).
- **Best For**: Quantitative, data-dense workflows and prolonged night-time research sessions with zero eye fatigue.

### 4. Design 4: Bento Modular Analytical Canvas
- **Location**: [`mockup_by_agy/design-4-bento-canvas/index.html`](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/mockup_by_agy/design-4-bento-canvas/index.html)
- **Concept**: Structured Bento-Box modular layout separating cognitive analytical tasks into dedicated container quadrants.
- **Aesthetic**: Warm zinc canvas (`#F4F4F5`), crisp white bento tiles with defined `#E4E4E7` borders, micro-caps labels (`MODULE_01`, `MODULE_02`), pill chips, and clear spatial hierarchy.
- **Best For**: Visual thinkers who evaluate opportunities by compartmentalizing Macro Stress, Quality Health, Valuation Discrepancies, and Actionable Checklists.

---

## 3. Screen-by-Screen Implementation Checklist

Every design implements all 5 required screens from `APP_REQUIREMENTS.md`:

| Screen ID | Screen Name | Acceptance Criteria Implemented in Mockups |
|---|---|---|
| **APP-01** | **Opportunity Brief** | • Top Context bar: Trading date (IST), research horizon (1–3 yrs), coverage size (5 of 35), refresh status.<br>• Daily (-2%) vs 1-Month (-8%) decline window selector.<br>• Nifty 50 & Sector changes with proxy disclosures.<br>• Up to 5 “Worth researching” candidate cards.<br>• Separate “Watch and wait” section (never padded into main list).<br>• Exclusion counts and link to Explore.<br>• Evidence drawer trigger & Watchlist quick-save. |
| **APP-02** | **Company Analysis** | • Exact trigger reason (“Why this stock appeared”).<br>• Price vs Sector change over identical dates.<br>• 3-Year Annual Financials (Revenue, Profit, OCF, Capex, Free Cash Flow) with consolidated tags.<br>• 4-Pillar Quality Checks + Valuation Check with expandable evidence drawers.<br>• Sector context (pressure, impact, recovery conditions, source URLs).<br>• Company-specific concerns and audit timestamps.<br>• Actionable next-review checklist. |
| **APP-03** | **Watchlist & Personal Notes** | • Saved companies table with thesis, concerns, next-review date.<br>• Live inline note editor with persistence simulation.<br>• Freshness and conclusion indicators surviving refresh. |
| **APP-04** | **Explore & Compare** | • Multi-facet screener (Sector, Decline Window, P/E, ROCE, Conclusion).<br>• Explicit sorting where unavailable values sort last.<br>• Side-by-side **3-Company Comparison Matrix**.<br>• Cross-sector mismatch warnings and incompatible statement period tags. |
| **APP-05** | **Research Notes & Settings** | • Sourced Sector Research Note manager (URL, publication date, review date, pressure classification, severity).<br>• Rule threshold editor (ROCE, D/E, Decline %) with rule versioning history (v1.2 → v1.3).<br>• Upstox token health, rate limits, and manual refresh controls. |

---

## 4. Edge-State Simulator Matrix (Section 4 Requirements)

Every mockup includes an interactive **State Simulation Bar** at the top of the page. You can switch between:

1. **Normal Operation**: Active snapshot with 5 verified candidates (TCS, INFY, ASIANPAINT, DIVISLAB, TITAN).
2. **State 1: No Data Yet**: Initial onboarding state explaining setup and prompting first refresh.
3. **State 2: Refresh Running**: Background job progress bar showing resource counters while keeping the previous snapshot visible.
4. **State 3: Token Rejected / Expired**: Warning banner explaining credential replacement with cached data intact.
5. **State 4: Partial Provider Failure**: Specific company/field gaps highlighted with coverage %.
6. **State 5: Research Expired**: Note older than 30 days downgrades evidence completeness.
7. **State 6: No Qualifying Opportunities**: Educational empty state showing detailed exclusion breakdown.

---

## 5. Mobile Native App Suite & Developer Handoff

In addition to the Web Application prototypes, a dedicated **Native Mobile Application Suite** has been developed for mobile developers (Flutter, React Native, SwiftUI, Kotlin Jetpack Compose):

- **Interactive Mobile Device Simulator**: [`mockup_by_agy/mobile/index.html`](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/mockup_by_agy/mobile/index.html)
  - Features an authentic interactive **iPhone 16 Pro / Android Pixel** frame with Dynamic Island, status bar, and home indicator.
  - Side-by-side **Developer Handoff Reference Panel** containing route navigation stacks, touch targets (&ge;44pt), design tokens, and local SQLite schemas.
- **Standalone Mobile Application (Phone Viewport)**: [`mockup_by_agy/mobile/app.html`](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/mockup_by_agy/mobile/app.html)
  - Full-screen native touch interface: Bottom tab bar (Brief, Analysis, Watchlist, Explore, Settings), slide-up bottom sheets for evidence audit, and 4 switchable clean themes (Minimal iOS, Swiss Editorial, Dark Pro Terminal, Bento).
- **Mobile Engineer Handoff Guide**: [`mockup_by_agy/mobile/DEVELOPER_GUIDE.md`](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/mockup_by_agy/mobile/DEVELOPER_GUIDE.md)
  - Technical blueprint detailing architecture, state models, database schemas, and API integration rules.

---

## 6. Directory Structure

```
mockup_by_agy/
├── index.html                       # Master Interactive Web Showcase & Switcher
├── README.md                        # Documentation & Criteria Mapping
├── shared/
│   ├── mock-data.js                 # 5 verified companies, financials, sector notes, rules
│   └── shared-styles.css            # Common CSS reset, font imports & utilities
├── mobile/                          # Dedicated Native Mobile Application Suite
│   ├── index.html                   # Device Frame Simulator & Developer Reference Hub
│   ├── app.html                     # Standalone Touch Mobile App (Phone Viewport)
│   ├── style.css                    # Mobile Design System Stylesheet
│   ├── app.js                       # Mobile Navigation & Bottom Sheet Controller
│   └── DEVELOPER_GUIDE.md           # Technical Handoff Guide for Mobile Engineers
├── design-1-swiss-editorial/        # Web Design 1: Swiss Editorial Gazette
│   ├── index.html
│   ├── style.css
│   └── app.js
├── design-2-nordic-minimal/         # Web Design 2: Nordic Minimalist SaaS
│   ├── index.html
│   ├── style.css
│   └── app.js
├── design-3-dark-institutional/     # Web Design 3: Dark Institutional Pro Terminal
│   ├── index.html
│   ├── style.css
│   └── app.js
└── design-4-bento-canvas/           # Web Design 4: Bento Modular Analytical Canvas
    ├── index.html
    ├── style.css
    └── app.js
```

