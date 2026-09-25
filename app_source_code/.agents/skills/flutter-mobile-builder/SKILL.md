---
name: flutter-mobile-builder
description: Comprehensive workflow skill for building, testing, and maintaining the Stock Advisory Flutter native mobile application
---

# Flutter Mobile Builder Skill

This skill teaches the agent how to build, run, and test the Stock Advisory Flutter mobile application.

## Workflow 1: Implement an App Screen
1. Inspect the visual design in `../mockup_by_agy/mobile/app.html` to understand layout, colors, and typography.
2. Check the API contracts in `../BACKEND_ARCHITECTURE_AND_API_SPEC.md` for JSON response models.
3. Define the immutable entity in `lib/models/`.
4. Create the Riverpod provider in `lib/features/<screen_name>/providers/`.
5. Build the UI widget in `lib/features/<screen_name>/`.
6. Add unit/widget tests in `test/features/<screen_name>/`.

## Workflow 2: Financial Formula Validation
1. Net Profit Check: `PAT > 0`
2. Operating Cash Flow: `OCF > 0`
3. ROCE Check: `ROCE >= 15.0%`
4. Debt/Equity Check: `Total Debt / Equity <= 1.0` with `Equity > 0`
5. Valuation Check: `P/E < Upstox Sector Benchmark`
6. Corporate Action Gate: If corporate action is unadjusted, flag candidate as `Insufficient evidence`.

## Workflow 3: Offline Database Sync
- Sync watchlist items and notes with local SQLite table before falling back to remote.
- Ensure app loads offline using cached snapshots in under 1 second.
