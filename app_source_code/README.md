# Stock Advisory — Mobile App Source Code & Flutter Developer Agent

This folder (`app_source_code/`) contains the complete native Flutter application source code and the **AI Developer Agent system** for building the **Stock Advisory (Fundamental Investment Assistant)** mobile app.

---

## 1. How to Use with Any Agentic AI

This directory is pre-configured with agent directives, rules, and skills so that **any AI coding assistant** can immediately step in and continue building:

| Tool / Platform | How it Discovers & Uses the Agent |
|---|---|
| **Antigravity / Gemini CLI** | Automatically discovers and loads `.agents/rules/flutter_rules.md`, `AGENTS.md`, and activates skill `.agents/skills/flutter-mobile-builder/SKILL.md`. |
| **Cursor / Windsurf** | Automatically discovers `.cursor/rules/flutter.mdc` and applies coding standards to all `lib/**/*.dart` files. |
| **Claude Code / Anthropic** | Reads `AGENTS.md` and `FLUTTER_AGENT.md` to adopt the Lead Flutter Mobile Engineer persona. |
| **ChatGPT / OpenAI Operator / Any LLM** | Open [`FLUTTER_AGENT.md`](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/app_source_code/FLUTTER_AGENT.md), copy the launch prompt, and tell the AI: *"You are the Flutter Developer Agent for Stock Advisory. Implement the next task."* |

---

## 2. Agent Instruction Files

- 🤖 **[AGENTS.md](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/app_source_code/AGENTS.md)**: Master role definition, non-negotiable financial rules, directory architecture, and screen-by-screen delivery directives.
- 🚀 **[FLUTTER_AGENT.md](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/app_source_code/FLUTTER_AGENT.md)**: Self-contained drop-in prompt for quick initialization in any conversational or agentic environment.
- 📋 **[.agents/rules/flutter_rules.md](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/app_source_code/.agents/rules/flutter_rules.md)**: Rules for null safety, currency formatting, minimum 44pt touch targets, and corporate action gating.
- 🛠️ **[.agents/skills/flutter-mobile-builder/SKILL.md](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/app_source_code/.agents/skills/flutter-mobile-builder/SKILL.md)**: Procedural workflows for screen creation, offline SQLite persistence, and test verification.

---

## 3. Directory Layout

```
app_source_code/
├── AGENTS.md                        # Master Agent instructions for all Agentic AIs
├── FLUTTER_AGENT.md                 # Universal drop-in launch prompt
├── GIT_WORKFLOW_AND_ROLLBACK_GUIDE.md # Git checkpoints, PRs & rollback runbooks
├── README.md                        # This file
├── pubspec.yaml                     # Dependencies (Riverpod, Dio, Sqflite, Google Fonts)
├── .agents/
│   ├── rules/flutter_rules.md       # Antigravity/Agentic rule set
│   └── skills/flutter-mobile-builder/SKILL.md
├── .cursor/rules/flutter.mdc        # Cursor IDE configuration
├── test/
│   └── mock_api_service_test.dart   # Unit tests verifying financial precedence & endpoints
└── lib/
    ├── main.dart                    # App entry point & 5-tab navigation shell
    ├── core/
    │   ├── constants/app_constants.dart
    │   ├── network/api_endpoints.dart # 16 REST API route definitions
    │   └── theme/app_theme.dart     # Minimal, Editorial, Dark Terminal & Bento themes
    ├── models/
    │   ├── api_response.dart        # Standard Success/Error envelopes & metadata
    │   ├── benchmark.dart           # NIFTY 50 & sector proxy baskets
    │   ├── company.dart             # Domain models (Company, Checks, Statements)
    │   ├── compare_result.dart      # 3-way side-by-side comparison data
    │   ├── opportunity_brief.dart   # APP-01 DTO & discovery window
    │   ├── research_note.dart       # Sourced sector research notes
    │   ├── rule_settings.dart       # Screening heuristic thresholds & versions
    │   └── system_status.dart       # Diagnostics, Upstox provider token & storage
    ├── mock/
    │   └── mock_data.dart           # Offline verification data for 5 Indian equities
    ├── services/
    │   ├── api_service.dart         # Abstract contract for all 16 endpoints
    │   ├── mock_api_service.dart    # Full in-memory mock service with latency & state
    │   ├── http_api_service.dart    # Production Dio HTTP client ready for Fastify backend
    │   └── api_provider.dart        # Riverpod providers & runtime mock toggle
    └── features/
        ├── brief/opportunity_brief_screen.dart       # APP-01 Opportunity Brief
        ├── analysis/company_analysis_screen.dart     # APP-02 Deep Dive Dossier & 3-Yr Financials
        ├── watchlist/watchlist_screen.dart           # APP-03 Watchlist & Personal Notes
        ├── screener/explore_screener_screen.dart     # APP-04 Screener & 3-Way Compare
        └── settings/settings_rules_screen.dart       # APP-05 Diagnostics, Rules v1.2 & Sector Notes
```

---

## 4. Key Reference Documents

- 📱 **Interactive Mobile Prototype**: [`../mockup_by_agy/mobile/index.html`](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/mockup_by_agy/mobile/index.html) (Test interactive iPhone frame)
- 📐 **Mobile Developer Handoff Guide**: [`../mockup_by_agy/mobile/DEVELOPER_GUIDE.md`](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/mockup_by_agy/mobile/DEVELOPER_GUIDE.md)
- 🔌 **Backend API Specification & SQLite Schema**: [`../BACKEND_ARCHITECTURE_AND_API_SPEC.md`](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/BACKEND_ARCHITECTURE_AND_API_SPEC.md)
- 📄 **App Functional Requirements**: [`../APP_REQUIREMENTS.md`](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/APP_REQUIREMENTS.md)
- 📊 **Backend Calculation Requirements**: [`../BACKEND_REQUIREMENTS.md`](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/BACKEND_REQUIREMENTS.md)

---

## 5. Running the App

Once Flutter SDK is installed on your development machine:

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run the application (iOS simulator, Android emulator, or Chrome)
flutter run

# 3. Run financial heuristics tests
flutter test
```

---

## 6. Git Workflow, Checkpoint Commits & Rollback Strategy

To ensure zero-loss development and clean rollbacks for any specific feature:
- 📖 **Full Specification**: Read [`GIT_WORKFLOW_AND_ROLLBACK_GUIDE.md`](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/app_source_code/GIT_WORKFLOW_AND_ROLLBACK_GUIDE.md)
- 🌿 **Branching Model**: Develop on isolated feature branches (`feature/app-01-opportunity-brief`, `feature/app-02-company-analysis`).
- 🎯 **Atomic Checkpoint Commits**: Commit incrementally per layer (`feat(models)`, `feat(mock)`, `feat(brief-ui)`, `feat(evidence-modal)`, `test(brief)`).
- 🏷️ **Milestone Checkpoint Tags**: Tag after every major milestone (`checkpoint-phase1-data-verified`, `checkpoint-phase3-brief-analysis`).
- 🔍 **Pull Request (PR) Reviews**: Prepare formal PRs using the template in the guide before merging.
- ⏪ **Rollback Runbooks**: Instant recovery via `git revert <commit-sha>`, `git revert -m 1 <merge-sha>`, tag restore, or `FeatureFlags` toggles without losing track of other work.

---

## 7. API Service Architecture & Mock Placeholders

All 16 REST endpoints from `BACKEND_ARCHITECTURE_AND_API_SPEC.md` are modeled in `lib/services/api_service.dart`.

### How Mock Switching Works
1. **Mock Service (`MockApiService`)**: Active by default. Simulates network delay (150–300ms), returns verified standard success/error envelopes with metadata, and maintains in-memory mutations for watchlists, personal notes, sector notes, and version bumps.
2. **HTTP Service (`HttpApiService`)**: Complete Dio implementation pointing to `AppConstants.defaultBaseUrl`.
3. **Runtime Toggle**:
   - In code: `final useMockApiProvider = StateProvider<bool>((ref) => true);`
   - In UI: Navigate to the **Settings** tab (APP-05) and toggle the **"Using Mock In-Memory API"** switch. Switching to live backend requires zero code changes!

