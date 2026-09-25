/// REST API Route Definitions matching BACKEND_ARCHITECTURE_AND_API_SPEC.md
class ApiEndpoints {
  // 1. System Health & Diagnostics
  static const String status = '/status';

  // 2. APP-01 Opportunity Brief
  static const String brief = '/brief';

  // 3. APP-02 Company Analysis Dossier
  static String companyDetails(String isin) => '/companies/$isin';

  // 4. APP-03 Watchlist & Personal Notes
  static const String watchlist = '/watchlist';
  static String watchlistIsin(String isin) => '/watchlist/$isin';
  static String companyPersonalNote(String isin) => '/companies/$isin/personal-note';

  // 5. APP-04 Universe Screener & Comparison
  static const String companies = '/companies';
  static const String compare = '/compare';

  // 6. APP-05 Research Notes & Rules
  static const String researchNotes = '/research-notes';
  static String researchNoteId(String id) => '/research-notes/$id';
  static const String settingsRules = '/settings/rules';

  // 7. Async Data Refresh Pipeline
  static const String refresh = '/refresh';
  static String refreshJob(String jobId) => '/refresh/$jobId';
}
