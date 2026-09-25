/// Standard JSON API Response Envelope matching Section 3 of BACKEND_ARCHITECTURE_AND_API_SPEC.md

class ApiMeta {
  final String snapshotId;
  final String dataTimestamp;
  final String tradingDate;
  final String ruleVersion;
  final String researchHorizon;
  final List<String> warnings;

  const ApiMeta({
    required this.snapshotId,
    required this.dataTimestamp,
    required this.tradingDate,
    required this.ruleVersion,
    required this.researchHorizon,
    this.warnings = const [],
  });

  factory ApiMeta.fromJson(Map<String, dynamic> json) {
    return ApiMeta(
      snapshotId: json['snapshotId'] as String? ?? 'SNP-UNKNOWN',
      dataTimestamp: json['dataTimestamp'] as String? ?? DateTime.now().toIso8601String(),
      tradingDate: json['tradingDate'] as String? ?? '2026-09-24',
      ruleVersion: json['ruleVersion'] as String? ?? 'v1.2',
      researchHorizon: json['researchHorizon'] as String? ?? '1–3 Years',
      warnings: (json['warnings'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'snapshotId': snapshotId,
    'dataTimestamp': dataTimestamp,
    'tradingDate': tradingDate,
    'ruleVersion': ruleVersion,
    'researchHorizon': researchHorizon,
    'warnings': warnings,
  };
}

class ApiError {
  final String code;
  final String message;
  final bool retryable;
  final Map<String, dynamic>? details;

  const ApiError({
    required this.code,
    required this.message,
    this.retryable = false,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] as String? ?? 'INTERNAL_ERROR',
      message: json['message'] as String? ?? 'An unexpected error occurred.',
      retryable: json['retryable'] as bool? ?? false,
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
    'retryable': retryable,
    'details': details,
  };
}

class ApiResponse<T> {
  final String status; // 'success' or 'error'
  final T? data;
  final ApiMeta? meta;
  final ApiError? error;

  const ApiResponse({
    required this.status,
    this.data,
    this.meta,
    this.error,
  });

  bool get isSuccess => status == 'success';
  bool get isError => status == 'error';

  factory ApiResponse.success(T data, {ApiMeta? meta}) {
    return ApiResponse<T>(
      status: 'success',
      data: data,
      meta: meta,
    );
  }

  factory ApiResponse.error(ApiError error) {
    return ApiResponse<T>(
      status: 'error',
      error: error,
    );
  }
}
