/// Domain model entities for Stock Advisory Flutter App

class QualityCheck {
  final String id;
  final String name;
  final String status; // 'pass', 'fail', 'unavailable'
  final String value;
  final String rule;
  final String evidence;
  final String period;

  const QualityCheck({
    required this.id,
    required this.name,
    required this.status,
    required this.value,
    required this.rule,
    required this.evidence,
    required this.period,
  });

  bool get isPass => status == 'pass';
  bool get isFail => status == 'fail';
  bool get isUnavailable => status == 'unavailable';

  factory QualityCheck.fromJson(Map<String, dynamic> json) {
    return QualityCheck(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      status: json['status'] as String? ?? 'unavailable',
      value: json['value'] as String? ?? 'Unavailable',
      rule: json['rule'] as String? ?? '',
      evidence: json['evidence'] as String? ?? '',
      period: json['period'] as String? ?? '',
    );
  }
}

class FinancialStatement {
  final String period;
  final String basis; // 'Consolidated' or 'Standalone'
  final double revenueCr;
  final double netProfitCr;
  final double ocfCr;
  final double capexCr;
  final double fcfCr; // Derived as (ocfCr - capexCr)

  const FinancialStatement({
    required this.period,
    required this.basis,
    required this.revenueCr,
    required this.netProfitCr,
    required this.ocfCr,
    required this.capexCr,
    required this.fcfCr,
  });

  factory FinancialStatement.fromJson(Map<String, dynamic> json) {
    return FinancialStatement(
      period: json['period'] as String? ?? '',
      basis: json['basis'] as String? ?? 'Consolidated',
      revenueCr: (json['revenueCr'] as num?)?.toDouble() ?? 0.0,
      netProfitCr: (json['netProfitCr'] as num?)?.toDouble() ?? 0.0,
      ocfCr: (json['ocfCr'] as num?)?.toDouble() ?? 0.0,
      capexCr: (json['capexCr'] as num?)?.toDouble() ?? 0.0,
      fcfCr: (json['fcfCr'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SectorContext {
  final String noteTitle;
  final String classification; // 'potentially_temporary', 'potentially_structural', 'mixed'
  final String severity; // 'informational', 'caution', 'material_concern'
  final String sourceUrl;
  final String reviewedDate;
  final String headwind;
  final String recoveryCondition;

  const SectorContext({
    required this.noteTitle,
    required this.classification,
    required this.severity,
    required this.sourceUrl,
    required this.reviewedDate,
    required this.headwind,
    required this.recoveryCondition,
  });

  factory SectorContext.fromJson(Map<String, dynamic> json) {
    return SectorContext(
      noteTitle: json['noteTitle'] as String? ?? '',
      classification: json['classification'] as String? ?? '',
      severity: json['severity'] as String? ?? '',
      sourceUrl: json['sourceUrl'] as String? ?? '',
      reviewedDate: json['reviewedDate'] as String? ?? '',
      headwind: json['headwind'] as String? ?? '',
      recoveryCondition: json['recoveryCondition'] as String? ?? '',
    );
  }
}

class NextCheckTask {
  final String task;
  final String targetDate;
  bool done;

  NextCheckTask({
    required this.task,
    required this.targetDate,
    this.done = false,
  });

  factory NextCheckTask.fromJson(Map<String, dynamic> json) {
    return NextCheckTask(
      task: json['task'] as String? ?? '',
      targetDate: json['targetDate'] as String? ?? '',
      done: json['done'] as bool? ?? false,
    );
  }
}

class Company {
  final String isin;
  final String ticker;
  final String name;
  final String sectorId;
  final String sectorName;
  final String exchange;
  final double currentPrice;
  final String priceDate;
  final double dailyChangePercent;
  final double monthlyChangePercent;
  final double sectorDailyChange;
  final double sectorMonthlyChange;
  final String corporateActionStatus;
  final String conclusion; // 'Worth researching', 'Watch and wait', 'Fundamental concerns', 'Insufficient evidence'
  final String triggerSummary;
  final List<FinancialStatement> financials;
  final List<QualityCheck> checks;
  final SectorContext sectorContext;
  final List<String> companyRisks;
  final List<NextCheckTask> nextChecks;
  bool isSavedInWatchlist;
  String personalThesis;
  String personalConcerns;

  Company({
    required this.isin,
    required this.ticker,
    required this.name,
    required this.sectorId,
    required this.sectorName,
    required this.exchange,
    required this.currentPrice,
    required this.priceDate,
    required this.dailyChangePercent,
    required this.monthlyChangePercent,
    required this.sectorDailyChange,
    required this.sectorMonthlyChange,
    required this.corporateActionStatus,
    required this.conclusion,
    required this.triggerSummary,
    required this.financials,
    required this.checks,
    required this.sectorContext,
    required this.companyRisks,
    required this.nextChecks,
    this.isSavedInWatchlist = false,
    this.personalThesis = '',
    this.personalConcerns = '',
  });

  bool get isWorthResearching => conclusion == 'Worth researching';
  bool get isWatchAndWait => conclusion == 'Watch and wait';
  bool get isFundamentalConcerns => conclusion == 'Fundamental concerns';
  bool get isInsufficientEvidence => conclusion == 'Insufficient evidence';
  bool get hasCorporateActionDistortion =>
      corporateActionStatus.toLowerCase().contains('distortion') ||
      corporateActionStatus.toLowerCase().contains('unverified');

  Company copyWith({
    String? isin,
    String? ticker,
    String? name,
    String? sectorId,
    String? sectorName,
    String? exchange,
    double? currentPrice,
    String? priceDate,
    double? dailyChangePercent,
    double? monthlyChangePercent,
    double? sectorDailyChange,
    double? sectorMonthlyChange,
    String? corporateActionStatus,
    String? conclusion,
    String? triggerSummary,
    List<FinancialStatement>? financials,
    List<QualityCheck>? checks,
    SectorContext? sectorContext,
    List<String>? companyRisks,
    List<NextCheckTask>? nextChecks,
    bool? isSavedInWatchlist,
    String? personalThesis,
    String? personalConcerns,
  }) {
    return Company(
      isin: isin ?? this.isin,
      ticker: ticker ?? this.ticker,
      name: name ?? this.name,
      sectorId: sectorId ?? this.sectorId,
      sectorName: sectorName ?? this.sectorName,
      exchange: exchange ?? this.exchange,
      currentPrice: currentPrice ?? this.currentPrice,
      priceDate: priceDate ?? this.priceDate,
      dailyChangePercent: dailyChangePercent ?? this.dailyChangePercent,
      monthlyChangePercent: monthlyChangePercent ?? this.monthlyChangePercent,
      sectorDailyChange: sectorDailyChange ?? this.sectorDailyChange,
      sectorMonthlyChange: sectorMonthlyChange ?? this.sectorMonthlyChange,
      corporateActionStatus: corporateActionStatus ?? this.corporateActionStatus,
      conclusion: conclusion ?? this.conclusion,
      triggerSummary: triggerSummary ?? this.triggerSummary,
      financials: financials ?? this.financials,
      checks: checks ?? this.checks,
      sectorContext: sectorContext ?? this.sectorContext,
      companyRisks: companyRisks ?? this.companyRisks,
      nextChecks: nextChecks ?? this.nextChecks,
      isSavedInWatchlist: isSavedInWatchlist ?? this.isSavedInWatchlist,
      personalThesis: personalThesis ?? this.personalThesis,
      personalConcerns: personalConcerns ?? this.personalConcerns,
    );
  }

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      isin: json['isin'] as String? ?? '',
      ticker: json['ticker'] as String? ?? '',
      name: json['name'] as String? ?? '',
      sectorId: json['sectorId'] as String? ?? '',
      sectorName: json['sectorName'] as String? ?? '',
      exchange: json['exchange'] as String? ?? 'NSE',
      currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0.0,
      priceDate: json['priceDate'] as String? ?? '2026-09-24',
      dailyChangePercent: (json['dailyChangePercent'] as num?)?.toDouble() ?? (json['windowChangePercent'] as num?)?.toDouble() ?? 0.0,
      monthlyChangePercent: (json['monthlyChangePercent'] as num?)?.toDouble() ?? 0.0,
      sectorDailyChange: (json['sectorDailyChange'] as num?)?.toDouble() ?? (json['sectorChangePercent'] as num?)?.toDouble() ?? 0.0,
      sectorMonthlyChange: (json['sectorMonthlyChange'] as num?)?.toDouble() ?? 0.0,
      corporateActionStatus: json['corporateActionStatus'] as String? ?? 'Verified clean',
      conclusion: json['conclusion'] as String? ?? 'Watch and wait',
      triggerSummary: json['triggerSummary'] as String? ?? json['triggerStatement'] as String? ?? '',
      financials: (json['financials'] as List<dynamic>?)
              ?.map((e) => FinancialStatement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      checks: (json['checks'] as List<dynamic>?)
              ?.map((e) => QualityCheck.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      sectorContext: SectorContext.fromJson(json['sectorContext'] as Map<String, dynamic>? ?? {}),
      companyRisks: (json['companyRisks'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      nextChecks: (json['nextChecks'] as List<dynamic>?)
              ?.map((e) => NextCheckTask.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isSavedInWatchlist: json['inWatchlist'] as bool? ?? json['isSavedInWatchlist'] as bool? ?? false,
      personalThesis: json['personalThesis'] as String? ?? '',
      personalConcerns: json['personalConcerns'] as String? ?? '',
    );
  }
}

