import 'dart:async';
import '../mock/mock_data.dart';
import '../models/api_response.dart';
import '../models/benchmark.dart';
import '../models/company.dart';
import '../models/compare_result.dart';
import '../models/opportunity_brief.dart';
import '../models/research_note.dart';
import '../models/rule_settings.dart';
import '../models/system_status.dart';
import 'api_service.dart';

/// Full In-Memory Mock Implementation of ApiService
/// Provides realistic data, simulated network latency, and mutable session state
class MockApiService implements ApiService {
  // In-memory persistent state for this session
  final List<Company> _universe = List.from(MockStockData.coveredUniverse);

  final List<ResearchNoteItem> _researchNotes = [
    const ResearchNoteItem(
      id: 'rn-001',
      sectorId: 'it',
      sectorName: 'Information Technology',
      title: 'Global Enterprise Discretionary IT Spend Softening',
      sourceUrl: 'https://economictimes.indiatimes.com/tech/ites/gartner-it-spending-forecast',
      sourcePublication: 'Gartner & Economic Times',
      reviewedDate: '2026-09-20',
      classification: 'potentially_temporary',
      severity: 'caution',
      summary: 'Tier-1 Indian IT faces deal conversion delays in North American BFSI and European retail.',
      headwinds: 'Client reprioritization towards rapid GenAI POCs while delaying large legacy migration contracts.',
      recoveryConditions: 'Interest rate easing triggering discretionary IT budget release in H2 FY27.',
    ),
    const ResearchNoteItem(
      id: 'rn-002',
      sectorId: 'fmcg',
      sectorName: 'FMCG & Paints',
      title: 'Intensified Domestic Competition & Raw Material Volatility',
      sourceUrl: 'https://livemint.com/industry/retail/nielsen-fmcg-rural-demand-tracker',
      sourcePublication: 'Livemint & Nielsen',
      reviewedDate: '2026-09-18',
      classification: 'mixed',
      severity: 'material_concern',
      summary: 'Aggressive capacity addition by Birla Opus in decorative paints is forcing price discounting.',
      headwinds: 'Crude derivative price firming alongside dealer margin wars.',
      recoveryConditions: 'Capacity rationalization and stabilization of market share without prolonged margin compression.',
    ),
    const ResearchNoteItem(
      id: 'rn-003',
      sectorId: 'pharma',
      sectorName: 'Pharmaceuticals',
      title: 'API Destocking Cycle Normalization',
      sourceUrl: 'https://business-standard.com/industry/pharma-api-export-trends',
      sourcePublication: 'Business Standard',
      reviewedDate: '2026-09-22',
      classification: 'potentially_temporary',
      severity: 'informational',
      summary: 'Global pharma inventory correction is largely complete; custom synthesis demand remains robust.',
      headwinds: 'Short-term ocean freight rate spikes and localized US FDA inspection scrutiny.',
      recoveryConditions: 'Commercial scale-up of GLP-1 peptide intermediates in Q3/Q4.',
    ),
  ];

  late RuleSettingsData _rules = RuleSettingsData(
    ruleVersion: 'v1.2',
    lastUpdated: '2026-09-24',
    rules: [
      RuleThreshold(
        key: 'daily_decline_trigger',
        name: 'Daily Decline Trigger',
        description: 'Single-session price drop threshold to trigger fundamental review.',
        value: -2.0,
        unit: '%',
        precedenceOrder: 1,
      ),
      RuleThreshold(
        key: 'monthly_decline_trigger',
        name: '1-Month Decline Trigger',
        description: 'Rolling 30-day price drop threshold to trigger fundamental review.',
        value: -8.0,
        unit: '%',
        precedenceOrder: 2,
      ),
      RuleThreshold(
        key: 'min_roce',
        name: 'Minimum ROCE',
        description: 'Minimum required Return on Capital Employed for non-financial companies.',
        value: 15.0,
        unit: '%',
        precedenceOrder: 3,
      ),
      RuleThreshold(
        key: 'max_debt_equity',
        name: 'Max Debt-to-Equity Ratio',
        description: 'Maximum tolerable gross debt to net worth ratio.',
        value: 1.00,
        unit: 'x',
        precedenceOrder: 4,
      ),
    ],
  );

  ApiMeta _createMeta({List<String>? warnings}) {
    return ApiMeta(
      snapshotId: 'SNP-20260924-001',
      dataTimestamp: DateTime.now().toIso8601String(),
      tradingDate: '2026-09-24',
      ruleVersion: _rules.ruleVersion,
      researchHorizon: '1–3 Years',
      warnings: warnings ?? [],
    );
  }

  // 1. System Status
  @override
  Future<ApiResponse<SystemStatusData>> getSystemStatus() async {
    await Future.delayed(const Duration(milliseconds: 150));
    final statusData = SystemStatusData(
      systemHealth: 'healthy',
      provider: const ProviderHealth(
        name: 'Upstox Analytics API',
        authenticated: true,
        tokenValidUntil: '2027-08-14',
        quotaRemainingToday: 4850,
        quotaLimitToday: 5000,
        lastPingLatencyMs: 142,
      ),
      storage: StorageHealth(
        type: 'Mock Engine (Fastify / SQLite ready)',
        coveredUniverseCount: _universe.length,
        totalConfiguredUniverse: 35,
        latestCompletedSession: '2026-09-24',
        activeSnapshotId: 'SNP-20260924-001',
        activeRuleVersion: _rules.ruleVersion,
      ),
    );
    return ApiResponse.success(statusData, meta: _createMeta());
  }

  // 2. APP-01 Opportunity Brief
  @override
  Future<ApiResponse<OpportunityBriefData>> getOpportunityBrief({
    String window = 'day',
    String? sector,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final isDay = window == 'day';
    final threshold = isDay ? -2.0 : -8.0;

    // Filter universe by sector if provided
    var candidatePool = _universe;
    if (sector != null && sector.isNotEmpty && sector != 'all') {
      candidatePool = candidatePool.where((c) => c.sectorId == sector).toList();
    }

    // Filter by trigger condition
    final declined = candidatePool.where((c) {
      final change = isDay ? c.dailyChangePercent : c.monthlyChangePercent;
      return change <= threshold;
    }).toList();

    final worthResearching = declined.where((c) => c.isWorthResearching).toList();
    final watchAndWait = declined.where((c) => !c.isWorthResearching).toList();

    final briefData = OpportunityBriefData(
      discoveryWindow: DiscoveryWindow(
        selected: window,
        threshold: threshold,
        effectiveSession: '2026-09-24',
      ),
      benchmarks: const BenchmarkBundle(
        broadMarket: MarketBenchmark(
          symbol: 'NIFTY_50',
          name: 'NIFTY 50',
          type: 'Official Exchange Index',
          latestClose: 25120.40,
          dailyChangePercent: -1.35,
          monthlyChangePercent: -3.40,
        ),
        sectors: [
          SectorBenchmark(
            id: 'it',
            name: 'Nifty IT Proxy',
            isProxy: true,
            proxyDisclosure: 'Locally constructed equal-weight basket of 5 liquid IT stocks used as proxy.',
            dailyChangePercent: -2.40,
            monthlyChangePercent: -7.10,
          ),
          SectorBenchmark(
            id: 'fmcg',
            name: 'Nifty FMCG',
            isProxy: false,
            dailyChangePercent: -1.10,
            monthlyChangePercent: -2.80,
          ),
          SectorBenchmark(
            id: 'pharma',
            name: 'Nifty Healthcare',
            isProxy: false,
            dailyChangePercent: -0.75,
            monthlyChangePercent: -1.65,
          ),
        ],
      ),
      worthResearching: worthResearching,
      watchAndWait: watchAndWait,
      exclusionsSummary: ExclusionsSummary(
        totalCovered: _universe.length,
        declinedQualified: worthResearching.length,
        positiveNoDecline: _universe.where((c) => (isDay ? c.dailyChangePercent : c.monthlyChangePercent) > threshold).length,
        disqualifiedFundamental: _universe.where((c) => c.isFundamentalConcerns).length,
        disqualifiedCorporateAction: _universe.where((c) => c.hasCorporateActionDistortion).length,
        unreviewedContext: 0,
      ),
    );

    return ApiResponse.success(briefData, meta: _createMeta());
  }

  // 3. APP-02 Company Analysis Dossier
  @override
  Future<ApiResponse<Company>> getCompanyDetails(String isin) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      final company = _universe.firstWhere((c) => c.isin == isin);
      return ApiResponse.success(company, meta: _createMeta());
    } catch (_) {
      return ApiResponse.error(
        ApiError(
          code: 'COMPANY_NOT_FOUND',
          message: 'No company found with ISIN: $isin in the covered universe.',
        ),
      );
    }
  }

  // 4. APP-03 Watchlist & Personal Notes
  @override
  Future<ApiResponse<List<Company>>> getWatchlist() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final saved = _universe.where((c) => c.isSavedInWatchlist).toList();
    return ApiResponse.success(saved, meta: _createMeta());
  }

  @override
  Future<ApiResponse<bool>> addToWatchlist(String isin) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final idx = _universe.indexWhere((c) => c.isin == isin);
    if (idx != -1) {
      _universe[idx] = _universe[idx].copyWith(isSavedInWatchlist: true);
      return ApiResponse.success(true, meta: _createMeta());
    }
    return ApiResponse.error(
      const ApiError(code: 'NOT_FOUND', message: 'Company not found'),
    );
  }

  @override
  Future<ApiResponse<bool>> removeFromWatchlist(String isin) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final idx = _universe.indexWhere((c) => c.isin == isin);
    if (idx != -1) {
      _universe[idx] = _universe[idx].copyWith(isSavedInWatchlist: false);
      return ApiResponse.success(true, meta: _createMeta());
    }
    return ApiResponse.error(
      const ApiError(code: 'NOT_FOUND', message: 'Company not found'),
    );
  }

  @override
  Future<ApiResponse<Company>> savePersonalNote(
    String isin, {
    String? thesis,
    String? concerns,
    String? nextReviewDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _universe.indexWhere((c) => c.isin == isin);
    if (idx != -1) {
      final updated = _universe[idx].copyWith(
        personalThesis: thesis ?? _universe[idx].personalThesis,
        personalConcerns: concerns ?? _universe[idx].personalConcerns,
      );
      _universe[idx] = updated;
      return ApiResponse.success(updated, meta: _createMeta());
    }
    return ApiResponse.error(
      const ApiError(code: 'NOT_FOUND', message: 'Company not found'),
    );
  }

  // 5. APP-04 Universe Screener & Comparison
  @override
  Future<ApiResponse<List<Company>>> getScreenerCompanies({
    String? sector,
    String? conclusion,
    String? searchQuery,
    String? sortField,
    bool sortAsc = true,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    var results = List<Company>.from(_universe);

    if (sector != null && sector.isNotEmpty && sector != 'all') {
      results = results.where((c) => c.sectorId == sector).toList();
    }

    if (conclusion != null && conclusion.isNotEmpty && conclusion != 'all') {
      results = results.where((c) => c.conclusion.toLowerCase() == conclusion.toLowerCase()).toList();
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      results = results.where((c) {
        return c.ticker.toLowerCase().contains(query) ||
            c.name.toLowerCase().contains(query) ||
            c.isin.toLowerCase().contains(query);
      }).toList();
    }

    // Sort with nulls / unavailables pushed to bottom
    if (sortField != null) {
      results.sort((a, b) {
        if (sortField == 'ticker') {
          return sortAsc ? a.ticker.compareTo(b.ticker) : b.ticker.compareTo(a.ticker);
        } else if (sortField == 'change') {
          return sortAsc
              ? a.dailyChangePercent.compareTo(b.dailyChangePercent)
              : b.dailyChangePercent.compareTo(a.dailyChangePercent);
        } else if (sortField == 'roce') {
          final aRoceCheck = a.checks.firstWhere((chk) => chk.id == 'roce', orElse: () => const QualityCheck(id: '', name: '', status: 'unavailable', value: 'Unavailable', rule: '', evidence: '', period: ''));
          final bRoceCheck = b.checks.firstWhere((chk) => chk.id == 'roce', orElse: () => const QualityCheck(id: '', name: '', status: 'unavailable', value: 'Unavailable', rule: '', evidence: '', period: ''));
          if (aRoceCheck.isUnavailable && bRoceCheck.isUnavailable) return 0;
          if (aRoceCheck.isUnavailable) return 1; // nulls last
          if (bRoceCheck.isUnavailable) return -1;
          final aVal = double.tryParse(aRoceCheck.value.replaceAll('%', '').trim()) ?? 0.0;
          final bVal = double.tryParse(bRoceCheck.value.replaceAll('%', '').trim()) ?? 0.0;
          return sortAsc ? aVal.compareTo(bVal) : bVal.compareTo(aVal);
        }
        return 0;
      });
    }

    return ApiResponse.success(results, meta: _createMeta());
  }

  @override
  Future<ApiResponse<CompanyComparisonData>> compareCompanies(List<String> isins) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final selectedCompanies = _universe.where((c) => isins.contains(c.isin)).toList();

    // Check for cross-sector warning
    final distinctSectors = selectedCompanies.map((c) => c.sectorName).toSet();
    String? warning;
    if (distinctSectors.length > 1) {
      warning = 'Cross-sector comparison (${distinctSectors.join(" vs ")}): Valuation multiples, capital intensity, and margins reflect fundamentally different business models.';
    }

    final rows = <CompareMetricRow>[
      CompareMetricRow(
        label: 'Research Conclusion',
        category: 'Core',
        valuesByIsin: {for (var c in selectedCompanies) c.isin: c.conclusion},
        statusByIsin: {for (var c in selectedCompanies) c.isin: c.isWorthResearching ? true : (c.isFundamentalConcerns ? false : null)},
      ),
      CompareMetricRow(
        label: 'Current Price (₹)',
        category: 'Core',
        valuesByIsin: {for (var c in selectedCompanies) c.isin: '₹${c.currentPrice.toStringAsFixed(2)}'},
        statusByIsin: {for (var c in selectedCompanies) c.isin: null},
      ),
      CompareMetricRow(
        label: 'Daily Decline',
        category: 'Core',
        valuesByIsin: {for (var c in selectedCompanies) c.isin: '${c.dailyChangePercent.toStringAsFixed(2)}%'},
        statusByIsin: {for (var c in selectedCompanies) c.isin: c.dailyChangePercent <= -2.0 ? true : null},
      ),
      CompareMetricRow(
        label: '1-Month Decline',
        category: 'Core',
        valuesByIsin: {for (var c in selectedCompanies) c.isin: '${c.monthlyChangePercent.toStringAsFixed(2)}%'},
        statusByIsin: {for (var c in selectedCompanies) c.isin: c.monthlyChangePercent <= -8.0 ? true : null},
      ),
      CompareMetricRow(
        label: 'Annual Net Profit (FY25)',
        category: 'Quality Rules',
        valuesByIsin: {
          for (var c in selectedCompanies)
            c.isin: c.checks.firstWhere((chk) => chk.id == 'net_profit', orElse: () => const QualityCheck(id: '', name: '', status: 'unavailable', value: 'Unavailable', rule: '', evidence: '', period: '')).value
        },
        statusByIsin: {
          for (var c in selectedCompanies)
            c.isin: c.checks.firstWhere((chk) => chk.id == 'net_profit', orElse: () => const QualityCheck(id: '', name: '', status: 'unavailable', value: 'Unavailable', rule: '', evidence: '', period: '')).isPass
        },
      ),
      CompareMetricRow(
        label: 'Operating Cash Flow (FY25)',
        category: 'Quality Rules',
        valuesByIsin: {
          for (var c in selectedCompanies)
            c.isin: c.checks.firstWhere((chk) => chk.id == 'operating_cashflow', orElse: () => const QualityCheck(id: '', name: '', status: 'unavailable', value: 'Unavailable', rule: '', evidence: '', period: '')).value
        },
        statusByIsin: {
          for (var c in selectedCompanies)
            c.isin: c.checks.firstWhere((chk) => chk.id == 'operating_cashflow', orElse: () => const QualityCheck(id: '', name: '', status: 'unavailable', value: 'Unavailable', rule: '', evidence: '', period: '')).isPass
        },
      ),
      CompareMetricRow(
        label: 'ROCE (≥ 15.0%)',
        category: 'Quality Rules',
        valuesByIsin: {
          for (var c in selectedCompanies)
            c.isin: c.checks.firstWhere((chk) => chk.id == 'roce', orElse: () => const QualityCheck(id: '', name: '', status: 'unavailable', value: 'Unavailable', rule: '', evidence: '', period: '')).value
        },
        statusByIsin: {
          for (var c in selectedCompanies)
            c.isin: c.checks.firstWhere((chk) => chk.id == 'roce', orElse: () => const QualityCheck(id: '', name: '', status: 'unavailable', value: 'Unavailable', rule: '', evidence: '', period: '')).isPass
        },
      ),
      CompareMetricRow(
        label: 'Debt / Equity (≤ 1.00x)',
        category: 'Quality Rules',
        valuesByIsin: {
          for (var c in selectedCompanies)
            c.isin: c.checks.firstWhere((chk) => chk.id == 'debt_equity', orElse: () => const QualityCheck(id: '', name: '', status: 'unavailable', value: 'Unavailable', rule: '', evidence: '', period: '')).value
        },
        statusByIsin: {
          for (var c in selectedCompanies)
            c.isin: c.checks.firstWhere((chk) => chk.id == 'debt_equity', orElse: () => const QualityCheck(id: '', name: '', status: 'unavailable', value: 'Unavailable', rule: '', evidence: '', period: '')).isPass
        },
      ),
      CompareMetricRow(
        label: 'Valuation vs Benchmark',
        category: 'Valuation & Returns',
        valuesByIsin: {
          for (var c in selectedCompanies)
            c.isin: c.checks.firstWhere((chk) => chk.id == 'valuation_pe', orElse: () => const QualityCheck(id: '', name: '', status: 'unavailable', value: 'Unavailable', rule: '', evidence: '', period: '')).value
        },
        statusByIsin: {
          for (var c in selectedCompanies)
            c.isin: c.checks.firstWhere((chk) => chk.id == 'valuation_pe', orElse: () => const QualityCheck(id: '', name: '', status: 'unavailable', value: 'Unavailable', rule: '', evidence: '', period: '')).isPass
        },
      ),
    ];

    return ApiResponse.success(
      CompanyComparisonData(
        companies: selectedCompanies,
        crossSectorWarning: warning,
        rows: rows,
      ),
      meta: _createMeta(),
    );
  }

  // 6. APP-05 Research Notes & Rules
  @override
  Future<ApiResponse<List<ResearchNoteItem>>> getResearchNotes() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return ApiResponse.success(List.from(_researchNotes), meta: _createMeta());
  }

  @override
  Future<ApiResponse<ResearchNoteItem>> createResearchNote(ResearchNoteItem note) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final newNote = ResearchNoteItem(
      id: 'rn-${DateTime.now().millisecondsSinceEpoch}',
      sectorId: note.sectorId,
      sectorName: note.sectorName,
      title: note.title,
      sourceUrl: note.sourceUrl,
      sourcePublication: note.sourcePublication,
      reviewedDate: DateTime.now().toString().split(' ').first,
      classification: note.classification,
      severity: note.severity,
      summary: note.summary,
      headwinds: note.headwinds,
      recoveryConditions: note.recoveryConditions,
    );
    _researchNotes.insert(0, newNote);
    return ApiResponse.success(newNote, meta: _createMeta(warnings: ['Active assessment cache invalidated.']));
  }

  @override
  Future<ApiResponse<ResearchNoteItem>> updateResearchNote(String id, ResearchNoteItem note) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _researchNotes.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _researchNotes[idx] = note;
      return ApiResponse.success(note, meta: _createMeta(warnings: ['Universe assessment recalculation triggered.']));
    }
    return ApiResponse.error(const ApiError(code: 'NOT_FOUND', message: 'Note not found'));
  }

  @override
  Future<ApiResponse<bool>> deleteResearchNote(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _researchNotes.removeWhere((n) => n.id == id);
    return ApiResponse.success(true, meta: _createMeta(warnings: ['Sector context removed. Invalidation complete.']));
  }

  @override
  Future<ApiResponse<RuleSettingsData>> getSettingsRules() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return ApiResponse.success(_rules, meta: _createMeta());
  }

  @override
  Future<ApiResponse<RuleSettingsData>> updateSettingsRules(RuleSettingsData rules) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final currentVerNum = double.tryParse(_rules.ruleVersion.replaceAll('v', '')) ?? 1.2;
    final bumpedVersion = 'v${(currentVerNum + 0.1).toStringAsFixed(1)}';

    _rules = RuleSettingsData(
      ruleVersion: bumpedVersion,
      lastUpdated: DateTime.now().toString().split(' ').first,
      rules: rules.rules,
    );
    return ApiResponse.success(
      _rules,
      meta: _createMeta(warnings: ['Rule version bumped to $bumpedVersion. Assessment recalculated across 5 stocks.']),
    );
  }

  // 7. Manual Refresh Pipeline
  @override
  Future<ApiResponse<String>> triggerDataRefresh() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final jobId = 'job-${DateTime.now().millisecondsSinceEpoch}';
    return ApiResponse.success(jobId, meta: _createMeta());
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getRefreshStatus(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return ApiResponse.success({
      'jobId': jobId,
      'status': 'completed',
      'progressPercent': 100,
      'durationMs': 1840,
      'assessedCount': _universe.length,
      'disqualifiedCount': 2,
      'qualifiedCount': 2,
    }, meta: _createMeta());
  }
}
