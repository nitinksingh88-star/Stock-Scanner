import 'company.dart';

/// Models for Screen APP-04 Side-by-Side 3-Company Comparison matching GET /api/compare

class CompareMetricRow {
  final String label;
  final String category; // 'Core', 'Quality Rules', 'Valuation & Returns', 'Cash Flow'
  final Map<String, String> valuesByIsin;
  final Map<String, bool?> statusByIsin; // true = pass, false = fail, null = neutral/unavailable

  const CompareMetricRow({
    required this.label,
    required this.category,
    required this.valuesByIsin,
    required this.statusByIsin,
  });
}

class CompanyComparisonData {
  final List<Company> companies;
  final String? crossSectorWarning;
  final List<CompareMetricRow> rows;

  const CompanyComparisonData({
    required this.companies,
    this.crossSectorWarning,
    required this.rows,
  });
}
