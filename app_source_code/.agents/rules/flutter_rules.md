---
trigger: always_on
description: Mandatory rules and guidelines for developing the Stock Advisory Flutter mobile application
---

# Flutter Mobile Developer Rules & Standards

## 1. Code Style & Architecture
- Enforce Clean Architecture: separate `core/`, `models/`, and `features/`.
- Use Riverpod (`ConsumerWidget`, `ConsumerStatefulWidget`) for all state management. Never use raw `setState()` across screen boundaries.
- Ensure all model classes have `fromJson` / `toJson` and immutable copy methods.
- Format all currency in Indian Rupees using `NumberFormat.currency(locale: 'en_IN', symbol: '₹')`. Tabular figures must use monospace fonts for financial decimals.

## 2. Financial Integrity Rules
- Corporate action gating: If `isCorporateActionAdjusted == false`, candidate MUST be flagged with conclusion `Insufficient evidence`.
- Never compress Quality, Valuation, and Risk into a single buy score.
- Unavailable figures must render as `"Unavailable"` (never 0.0 or empty strings).
- Missing research context must render as `"Not reviewed"`.

## 3. UI & Touch Ergonomics
- All touchable widgets (`InkWell`, `ElevatedButton`, `IconButton`) must satisfy a minimum touch target of 44x44 points.
- Use `SafeArea` to handle device notches and home indicator bars.
- Detailed audit records and formula evidence must be presented in modal bottom sheets with a drag handle.
- Bottom navigation bar must persist 5 primary tabs: `Brief`, `Analysis`, `Watchlist`, `Explore`, and `Settings`.

## 4. Git Checkpoint, PR & Rollback Rules
- Commit in discrete, atomic checkpoints using Conventional Commits (`feat(...)`, `fix(...)`, `test(...)`, `refactor(...)`). Never create monolithic multi-feature commits.
- All feature work must be developed on dedicated feature branches (`feature/app-01-brief`, `feature/app-02-analysis`, etc.).
- When requested in user instructions to create a PR, output a structured Pull Request review description with screen mapping, financial test verification, mobile mockup visual parity, and a step-by-step rollback plan.
- Ensure every feature is 100% reversible via `git revert` or feature flags without breaking the main branch or losing track of historical progress. Reference `GIT_WORKFLOW_AND_ROLLBACK_GUIDE.md`.

