import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/company.dart';
import '../models/compare_result.dart';
import '../models/opportunity_brief.dart';
import '../models/research_note.dart';
import '../models/rule_settings.dart';
import '../models/system_status.dart';
import 'api_service.dart';
import 'http_api_service.dart';
import 'mock_api_service.dart';

// Single shared in-memory mock instance across the app lifecycle
final _mockInstance = MockApiService();

/// Toggle between Mock API and Live HTTP backend
final useMockApiProvider = StateProvider<bool>((ref) => true);

/// Master ApiService Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  final useMock = ref.watch(useMockApiProvider);
  if (useMock) {
    return _mockInstance;
  }
  return HttpApiService();
});

// -------------------------------------------------------------
// System Status
// -------------------------------------------------------------
final systemStatusProvider = FutureProvider<SystemStatusData>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final res = await api.getSystemStatus();
  if (res.isSuccess && res.data != null) return res.data!;
  throw Exception(res.error?.message ?? 'Failed to load system status');
});

// -------------------------------------------------------------
// APP-01 Opportunity Brief Providers
// -------------------------------------------------------------
final briefWindowProvider = StateProvider<String>((ref) => 'day');
final briefSectorFilterProvider = StateProvider<String?>((ref) => null);

final briefDataProvider = FutureProvider<OpportunityBriefData>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final window = ref.watch(briefWindowProvider);
  final sector = ref.watch(briefSectorFilterProvider);

  final res = await api.getOpportunityBrief(window: window, sector: sector);
  if (res.isSuccess && res.data != null) {
    return res.data!;
  }
  throw Exception(res.error?.message ?? 'Failed to load Opportunity Brief');
});

// -------------------------------------------------------------
// APP-02 Company Dossier Provider
// -------------------------------------------------------------
final companyDetailProvider = FutureProvider.family<Company, String>((ref, isin) async {
  final api = ref.watch(apiServiceProvider);
  final res = await api.getCompanyDetails(isin);
  if (res.isSuccess && res.data != null) return res.data!;
  throw Exception(res.error?.message ?? 'Company not found');
});

// -------------------------------------------------------------
// APP-03 Watchlist State Notifier
// -------------------------------------------------------------
class WatchlistNotifier extends StateNotifier<AsyncValue<List<Company>>> {
  final ApiService _api;

  WatchlistNotifier(this._api) : super(const AsyncValue.loading()) {
    loadWatchlist();
  }

  Future<void> loadWatchlist() async {
    state = const AsyncValue.loading();
    try {
      final res = await _api.getWatchlist();
      if (res.isSuccess && res.data != null) {
        state = AsyncValue.data(res.data!);
      } else {
        state = AsyncValue.error(res.error?.message ?? 'Failed to load watchlist', StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleWatchlist(Company company) async {
    try {
      if (company.isSavedInWatchlist) {
        await _api.removeFromWatchlist(company.isin);
      } else {
        await _api.addToWatchlist(company.isin);
      }
      await loadWatchlist();
    } catch (_) {}
  }

  Future<void> savePersonalNote(String isin, {String? thesis, String? concerns}) async {
    try {
      await _api.savePersonalNote(isin, thesis: thesis, concerns: concerns);
      await loadWatchlist();
    } catch (_) {}
  }
}

final watchlistProvider = StateNotifierProvider<WatchlistNotifier, AsyncValue<List<Company>>>((ref) {
  final api = ref.watch(apiServiceProvider);
  return WatchlistNotifier(api);
});

// -------------------------------------------------------------
// APP-04 Screener Providers
// -------------------------------------------------------------
final screenerSearchQueryProvider = StateProvider<String>((ref) => '');
final screenerSectorFilterProvider = StateProvider<String?>((ref) => null);
final screenerConclusionFilterProvider = StateProvider<String?>((ref) => null);
final screenerSortFieldProvider = StateProvider<String?>((ref) => null);
final screenerSortAscProvider = StateProvider<bool>((ref) => true);

final screenerCompaniesProvider = FutureProvider<List<Company>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final search = ref.watch(screenerSearchQueryProvider);
  final sector = ref.watch(screenerSectorFilterProvider);
  final conclusion = ref.watch(screenerConclusionFilterProvider);
  final sortField = ref.watch(screenerSortFieldProvider);
  final sortAsc = ref.watch(screenerSortAscProvider);

  final res = await api.getScreenerCompanies(
    searchQuery: search,
    sector: sector,
    conclusion: conclusion,
    sortField: sortField,
    sortAsc: sortAsc,
  );
  if (res.isSuccess && res.data != null) return res.data!;
  throw Exception(res.error?.message ?? 'Failed to load screener list');
});

// Screener multi-select for compare
final compareSelectedIsinsProvider = StateProvider<List<String>>((ref) => []);

final comparisonResultProvider = FutureProvider<CompanyComparisonData>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final isins = ref.watch(compareSelectedIsinsProvider);
  if (isins.isEmpty) {
    return const CompanyComparisonData(companies: [], rows: []);
  }
  final res = await api.compareCompanies(isins);
  if (res.isSuccess && res.data != null) return res.data!;
  throw Exception(res.error?.message ?? 'Failed to compare companies');
});

// -------------------------------------------------------------
// APP-05 Research Notes & Rules Providers
// -------------------------------------------------------------
final researchNotesProvider = FutureProvider<List<ResearchNoteItem>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final res = await api.getResearchNotes();
  if (res.isSuccess && res.data != null) return res.data!;
  throw Exception(res.error?.message ?? 'Failed to load research notes');
});

final rulesSettingsProvider = FutureProvider<RuleSettingsData>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final res = await api.getSettingsRules();
  if (res.isSuccess && res.data != null) return res.data!;
  throw Exception(res.error?.message ?? 'Failed to load rule settings');
});
