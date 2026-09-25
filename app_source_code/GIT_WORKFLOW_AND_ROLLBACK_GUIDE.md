# Stock Advisory — Git Checkpoint, PR & Rollback Strategy

**Target Audience:** Flutter Developers, Mobile Engineers, and Agentic AIs  
**Governing Objective:** Ensure all feature development is checkpointed, reviewed via Pull Requests (PRs), and 100% reversible so any specific feature can be rolled back at any time without losing historical track or breaking working modules.

---

## 1. Branching Strategy

All feature work must take place on dedicated, descriptive feature branches branched from `main`:

```
main (Production / Stable Baseline)
  │
  ├── feature/app-01-opportunity-brief      (Screen APP-01 & Benchmark Slider)
  ├── feature/app-02-company-analysis       (Screen APP-02 & 3-Year Statements)
  ├── feature/app-03-watchlist-sqlite       (Screen APP-03 & Local Persistence)
  ├── feature/app-04-explore-screener       (Screen APP-04 & 3-Company Compare)
  ├── feature/app-05-settings-rules         (Screen APP-05 & Rule Versioning)
  └── fix/corporate-action-distortion       (Urgent hotfixes / bug corrections)
```

### Branch Naming Conventions
- `feature/<screen-id>-<short-description>`: e.g. `feature/app-01-brief-toggle`
- `fix/<issue-id>-<description>`: e.g. `fix/pe-unavailable-sort`
- `refactor/<module>`: e.g. `refactor/riverpod-providers`
- `test/<module>`: e.g. `test/rules-precedence`

---

## 2. Atomic Checkpoint Commit Protocol

> [!IMPORTANT]
> **Never commit monolithic, all-in-one commits.**  
> Commits must represent discrete, self-contained checkpoints. If an AI agent or developer implements Screen APP-01, it must be broken down into incremental checkpoint commits.

### Conventional Commit Format
```
<type>(<scope>): <short imperative description>

[Optional detailed body explaining rationale and financial edge cases]
[Optional issue/acceptance criteria reference]
```

### Approved Commit Types
- `feat`: A new user-facing feature or screen component.
- `fix`: A bug fix or formula correction.
- `test`: Adding or updating unit/widget tests.
- `refactor`: Code restructuring without changing behavior.
- `docs`: Documentation updates.
- `chore`: Dependency updates or build configuration changes.

### Example Checkpoint Progression for Screen APP-01
```bash
# Checkpoint 1: Domain models
git commit -m "feat(models): define Company, QualityCheck, and SectorContext entities"

# Checkpoint 2: Mock fixtures
git commit -m "feat(mock): add 5 verified Indian equity candidates in Dart"

# Checkpoint 3: UI Header & Benchmark slider
git commit -m "feat(brief): implement horizontal benchmark stress slider with proxy IT tag"

# Checkpoint 4: Candidate Card Widget
git commit -m "feat(brief): build CandidateCard with decline metrics and worth researching badge"

# Checkpoint 5: Evidence Modal Bottom Sheet
git commit -m "feat(brief): implement slide-up EvidenceBottomSheet with formula audit"

# Checkpoint 6: Unit & Widget Tests
git commit -m "test(brief): add widget tests for daily vs monthly decline discovery toggle"
```

---

## 3. Milestone Checkpoint Tagging

At the completion of each major build phase (matching [BUILD_PLAN.md](file:///C:/Users/aidev/Documents/app_idea/stock_advisory/BUILD_PLAN.md)), create an annotated Git tag:

```bash
# Phase 1: Verified Data & Fixtures
git tag -a checkpoint-phase1-data-verified -m "Checkpoint: Verified 5 Indian equity test cases and schemas"

# Phase 2: Heuristics & Rules Engine
git tag -a checkpoint-phase2-engine-rules -m "Checkpoint: Precedence rules engine and formulas verified"

# Phase 3: Usable Advisory Flow (APP-01 & APP-02)
git tag -a checkpoint-phase3-brief-analysis -m "Checkpoint: Working Opportunity Brief and Company Analysis"

# Phase 4: Watchlist & Screener (APP-03 & APP-04)
git tag -a checkpoint-phase4-watchlist-explore -m "Checkpoint: Local SQLite persistence and 3-way compare"

# Phase 5: MVP Release Baseline
git tag -a checkpoint-phase5-v0.3-release -m "Checkpoint: Personal-use MVP complete and verified"
```

---

## 4. Pull Request (PR) Creation & Code Review Workflow

When instructed by the user (or during feature completion), the agent or developer must prepare a formal Pull Request for code review.

### Step 1: Pre-PR Health Check
Before opening a PR, ensure:
1. `flutter analyze` passes with zero errors or warnings.
2. `flutter test` passes all financial formula and widget tests.
3. No secrets (`UPSTOX_TOKEN`, API keys) exist in committed files.
4. Clean commit history on the feature branch.

### Step 2: PR Description Template

```markdown
## Summary of Changes
- Implemented Screen APP-01 (Opportunity Brief) with responsive mobile layout.
- Added daily (≤ -2%) and 1-month (≤ -8%) decline discovery toggle.
- Built interactive bottom sheet for formula and evidence trace.

## Screen & Criteria Mapping
- [x] APP-01: Session date (IST), research horizon (1–3Y), and universe coverage (5/35).
- [x] APP-01: Broad-market (Nifty 50) and proxy IT sector basket clearly labeled.
- [x] APP-01: Separated "Worth researching" and "Watch and wait" candidate sections.
- [x] APP-01: Universe exclusions summary banner with exact counts.

## Financial Integrity Verification
- [x] Price decline alone cannot trigger a positive candidate.
- [x] Missing figures show "Unavailable" (never 0).
- [x] Corporate action distortion (Titan 1:1 bonus issue) successfully disqualified.

## Visual Reference & Mobile Parity
- Verified against interactive mobile prototype: `mockup_by_agy/mobile/app.html`
- Verified touch targets ≥ 44x44pt on iOS and Android frames.

## Rollback Plan
If this feature needs to be rolled back:
1. Revert merge commit: `git revert -m 1 <merge-commit-sha>`
2. All previous screens remain intact on `main`.
```

### Step 3: CLI Command to Open PR
Using GitHub CLI (`gh`):
```bash
git push -u origin feature/app-01-opportunity-brief
gh pr create --title "feat(brief): implement Screen APP-01 Opportunity Brief" --body-file PR_DESCRIPTION.md
```

---

## 5. Precision Rollback Runbook (Zero-Loss Recovery)

If a feature, formula, or design change needs to be rolled back, use the appropriate runbook procedure below.

### Scenario A: Roll Back a Specific Atomic Checkpoint Commit
*Use when: A specific commit (e.g. an experimental widget or broken formula) needs to be removed without touching subsequent work.*

```bash
# 1. Identify the commit hash
git log --oneline -n 10

# 2. Revert the specific commit (creates a clean inverse commit)
git revert <commit-sha> --no-edit

# 3. Verify tests pass
flutter test

# 4. Push the revert commit
git push origin <branch-name>
```

---

### Scenario B: Roll Back an Entire Merged Feature PR
*Use when: A completed feature branch was merged into `main`, but needs to be backed out cleanly.*

```bash
# 1. Checkout main and update
git checkout main
git pull origin main

# 2. Find the merge commit SHA
git log --merges -n 5 --oneline

# 3. Revert the merge commit (parent 1 keeps the pre-merge state)
git revert -m 1 <merge-commit-sha> -m "revert: rollback feature/app-01-opportunity-brief"

# 4. Verify main compiles and tests pass
flutter test
git push origin main
```

---

### Scenario C: Restore from a Milestone Tag
*Use when: Multiple regressions occurred and you want to jump back to a known stable milestone.*

```bash
# 1. List available milestone tags
git tag -l "checkpoint-*"

# 2. Create a clean recovery branch from the target tag
git checkout tags/checkpoint-phase3-brief-analysis -b recovery-phase3-baseline

# 3. Confirm clean compile and test state
flutter test
```

---

### Scenario D: Programmatic Feature Flagging (Code-Level Rollback)
In `lib/core/constants/app_constants.dart`, maintain boolean feature toggles so that unstable or experimental screens can be instantly toggled off in production code without Git operations:

```dart
class FeatureFlags {
  static const bool enable3CompanyComparison = true;
  static const bool enableCustomRuleEditing = true;
  static const bool enableExperimentalChart = false; // Toggled off
}
```

---

## 6. Audit Trail Checklist for Any AI Agent Working Here

Before concluding any coding session, the AI agent must:
1. Stage only relevant files: `git add <specific-files>` (never blind `git add .` containing `.env` or build folders).
2. Create an atomic commit with clear conventional commit messaging.
3. If instructed to create a PR, output the structured PR description matching Section 4.
4. Record the latest checkpoint commit hash in the response so the user can roll back with a single command if desired.
