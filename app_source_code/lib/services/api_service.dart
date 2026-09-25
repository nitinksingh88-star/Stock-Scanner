import '../models/api_response.dart';
import '../models/benchmark.dart';
import '../models/company.dart';
import '../models/compare_result.dart';
import '../models/opportunity_brief.dart';
import '../models/research_note.dart';
import '../models/rule_settings.dart';
import '../models/system_status.dart';

/// Abstract API Service Contract representing all 16 endpoints in BACKEND_ARCHITECTURE_AND_API_SPEC.md
abstract class ApiService {
  // 1. System Health
  Future<ApiResponse<SystemStatusData>> getSystemStatus();

  // 2. APP-01 Opportunity Brief
  Future<ApiResponse<OpportunityBriefData>> getOpportunityBrief({
    String window = 'day',
    String? sector,
  });

  // 3. APP-02 Company Analysis Dossier
  Future<ApiResponse<Company>> getCompanyDetails(String isin);

  // 4. APP-03 Watchlist & Personal Notes
  Future<ApiResponse<List<Company>>> getWatchlist();
  Future<ApiResponse<bool>> addToWatchlist(String isin);
  Future<ApiResponse<bool>> removeFromWatchlist(String isin);
  Future<ApiResponse<Company>> savePersonalNote(
    String isin, {
    String? thesis,
    String? concerns,
    String? nextReviewDate,
  });

  // 5. APP-04 Universe Screener & Comparison
  Future<ApiResponse<List<Company>>> getScreenerCompanies({
    String? sector,
    String? conclusion,
    String? searchQuery,
    String? sortField,
    bool sortAsc = true,
  });

  Future<ApiResponse<CompanyComparisonData>> compareCompanies(List<String> isins);

  // 6. APP-05 Sector Notes & Rules Engine
  Future<ApiResponse<List<ResearchNoteItem>>> getResearchNotes();
  Future<ApiResponse<ResearchNoteItem>> createResearchNote(ResearchNoteItem note);
  Future<ApiResponse<ResearchNoteItem>> updateResearchNote(String id, ResearchNoteItem note);
  Future<ApiResponse<bool>> deleteResearchNote(String id);

  Future<ApiResponse<RuleSettingsData>> getSettingsRules();
  Future<ApiResponse<RuleSettingsData>> updateSettingsRules(RuleSettingsData rules);

  // 7. Manual Ingestion & Assessment Pipeline
  Future<ApiResponse<String>> triggerDataRefresh();
  Future<ApiResponse<Map<String, dynamic>>> getRefreshStatus(String jobId);
}
