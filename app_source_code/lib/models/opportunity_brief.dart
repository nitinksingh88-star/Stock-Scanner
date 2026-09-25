import 'benchmark.dart';
import 'company.dart';

/// Models for Screen APP-01 Opportunity Brief matching GET /api/brief specification

class DiscoveryWindow {
  final String selected; // 'day' or 'month'
  final double threshold; // -2.0 or -8.0
  final String effectiveSession;

  const DiscoveryWindow({
    required this.selected,
    required this.threshold,
    required this.effectiveSession,
  });

  factory DiscoveryWindow.fromJson(Map<String, dynamic> json) {
    return DiscoveryWindow(
      selected: json['selected'] as String? ?? 'day',
      threshold: (json['threshold'] as num?)?.toDouble() ?? -2.0,
      effectiveSession: json['effectiveSession'] as String? ?? '2026-09-24',
    );
  }
}

class ExclusionsSummary {
  final int totalCovered;
  final int declinedQualified;
  final int positiveNoDecline;
  final int disqualifiedFundamental;
  final int disqualifiedCorporateAction;
  final int unreviewedContext;

  const ExclusionsSummary({
    required this.totalCovered,
    required this.declinedQualified,
    required this.positiveNoDecline,
    required this.disqualifiedFundamental,
    required this.disqualifiedCorporateAction,
    required this.unreviewedContext,
  });

  factory ExclusionsSummary.fromJson(Map<String, dynamic> json) {
    return ExclusionsSummary(
      totalCovered: json['totalCovered'] as int? ?? 5,
      declinedQualified: json['declinedQualified'] as int? ?? 3,
      positiveNoDecline: json['positiveNoDecline'] as int? ?? 1,
      disqualifiedFundamental: json['disqualifiedFundamental'] as int? ?? 1,
      disqualifiedCorporateAction: json['disqualifiedCorporateAction'] as int? ?? 1,
      unreviewedContext: json['unreviewedContext'] as int? ?? 0,
    );
  }
}

class OpportunityBriefData {
  final DiscoveryWindow discoveryWindow;
  final BenchmarkBundle benchmarks;
  final List<Company> worthResearching;
  final List<Company> watchAndWait;
  final ExclusionsSummary exclusionsSummary;

  const OpportunityBriefData({
    required this.discoveryWindow,
    required this.benchmarks,
    required this.worthResearching,
    required this.watchAndWait,
    required this.exclusionsSummary,
  });

  factory OpportunityBriefData.fromJson(Map<String, dynamic> json) {
    return OpportunityBriefData(
      discoveryWindow: DiscoveryWindow.fromJson(json['discoveryWindow'] as Map<String, dynamic>? ?? {}),
      benchmarks: BenchmarkBundle.fromJson(json['benchmarks'] as Map<String, dynamic>? ?? {}),
      worthResearching: (json['candidates']?['worthResearching'] as List<dynamic>?)
              ?.map((e) => Company.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      watchAndWait: (json['candidates']?['watchAndWait'] as List<dynamic>?)
              ?.map((e) => Company.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      exclusionsSummary: ExclusionsSummary.fromJson(json['exclusionsSummary'] as Map<String, dynamic>? ?? {}),
    );
  }
}
