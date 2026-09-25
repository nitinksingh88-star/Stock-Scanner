/// Application-wide constants for Stock Advisory Flutter App
class AppConstants {
  // App Metadata
  static const String appName = 'Stock Advisory';
  static const String appVersion = '0.3.0 MVP';
  static const String researchHorizon = '1–3 Years';
  static const String marketLocale = 'en_IN';
  static const String currencySymbol = '₹';

  // API Config
  static const String defaultBaseUrl = 'http://10.0.2.2:3000/api'; // Android emulator localhost bridge
  static const String defaultIosBaseUrl = 'http://localhost:3000/api';

  // Default Heuristic Thresholds (v1.2)
  static const double defaultDailyDeclineTrigger = -2.0;
  static const double defaultMonthlyDeclineTrigger = -8.0;
  static const double minRocePercent = 15.0;
  static const double maxDebtToEquity = 1.00;

  // Touch Ergonomics
  static const double minTouchTarget = 44.0;
  static const double bottomNavHeight = 60.0;

  // Research Conclusions
  static const String conclusionWorthResearching = 'Worth researching';
  static const String conclusionWatchAndWait = 'Watch and wait';
  static const String conclusionFundamentalConcerns = 'Fundamental concerns';
  static const String conclusionInsufficientEvidence = 'Insufficient evidence';
}
