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
├── README.md                        # This file
├── pubspec.yaml                     # Dependencies (Riverpod, Dio, Sqflite, Google Fonts)
├── .agents/
│   ├── rules/flutter_rules.md       # Antigravity/Agentic rule set
│   └── skills/flutter-mobile-builder/SKILL.md
├── .cursor/rules/flutter.mdc        # Cursor IDE configuration
└── lib/
    ├── main.dart                    # App entry point & bottom navigation shell
    ├── core/
    │   ├── constants/app_constants.dart
    │   └── theme/app_theme.dart     # Minimal, Editorial, Dark Terminal & Bento themes
    ├── models/
    │   └── company.dart             # Domain models (Company, Checks, Statements)
    ├── mock/
    │   └── mock_data.dart           # Offline verification data for Indian equities
    └── features/
        └── brief/
            └── opportunity_brief_screen.dart # APP-01 Opportunity Brief implementation
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

