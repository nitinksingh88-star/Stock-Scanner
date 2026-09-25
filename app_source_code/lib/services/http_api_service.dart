import 'package:dio/dio.dart';
import '../core/constants/app_constants.dart';
import '../core/network/api_endpoints.dart';
import '../models/api_response.dart';
import '../models/company.dart';
import '../models/compare_result.dart';
import '../models/opportunity_brief.dart';
import '../models/research_note.dart';
import '../models/rule_settings.dart';
import '../models/system_status.dart';
import 'api_service.dart';

/// Production HTTP Implementation of ApiService using Dio
/// Connects to Fastify / Node.js backend when running live
class HttpApiService implements ApiService {
  final Dio _dio;

  HttpApiService({String? baseUrl})
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? AppConstants.defaultBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

  @override
  Future<ApiResponse<SystemStatusData>> getSystemStatus() async {
    try {
      final res = await _dio.get(ApiEndpoints.status);
      final json = res.data as Map<String, dynamic>;
      final meta = json['meta'] != null ? ApiMeta.fromJson(json['meta']) : null;
      return ApiResponse.success(SystemStatusData.fromJson(json['data'] ?? {}), meta: meta);
    } on DioException catch (e) {
      return ApiResponse.error(_mapDioError(e));
    }
  }

  @override
  Future<ApiResponse<OpportunityBriefData>> getOpportunityBrief({
    String window = 'day',
    String? sector,
  }) async {
    try {
      final query = <String, dynamic>{'window': window};
      if (sector != null && sector.isNotEmpty) query['sector'] = sector;
      final res = await _dio.get(ApiEndpoints.brief, queryParameters: query);
      final json = res.data as Map<String, dynamic>;
      final meta = json['meta'] != null ? ApiMeta.fromJson(json['meta']) : null;
      return ApiResponse.success(OpportunityBriefData.fromJson(json['data'] ?? {}), meta: meta);
    } on DioException catch (e) {
      return ApiResponse.error(_mapDioError(e));
    }
  }

  @override
  Future<ApiResponse<Company>> getCompanyDetails(String isin) async {
    try {
      final res = await _dio.get(ApiEndpoints.companyDetails(isin));
      final json = res.data as Map<String, dynamic>;
      final meta = json['meta'] != null ? ApiMeta.fromJson(json['meta']) : null;
      return ApiResponse.success(Company.fromJson(json['data'] ?? {}), meta: meta);
    } on DioException catch (e) {
      return ApiResponse.error(_mapDioError(e));
    }
  }

  @override
  Future<ApiResponse<List<Company>>> getWatchlist() async {
    try {
      final res = await _dio.get(ApiEndpoints.watchlist);
      final json = res.data as Map<String, dynamic>;
      final list = (json['data'] as List<dynamic>?)?.map((e) => Company.fromJson(e as Map<String, dynamic>)).toList() ?? [];
      final meta = json['meta'] != null ? ApiMeta.fromJson(json['meta']) : null;
      return ApiResponse.success(list, meta: meta);
    } on DioException catch (e) {
      return ApiResponse.error(_mapDioError(e));
    }
  }

  @override
  Future<ApiResponse<bool>> addToWatchlist(String isin) async {
    try {
      await _dio.put(ApiEndpoints.watchlistIsin(isin));
      return ApiResponse.success(true);
    } on DioException catch (e) {
      return ApiResponse.error(_mapDioError(e));
    }
  }

  @override
  Future<ApiResponse<bool>> removeFromWatchlist(String isin) async {
    try {
      await _dio.delete(ApiEndpoints.watchlistIsin(isin));
      return ApiResponse.success(true);
    } on DioException catch (e) {
      return ApiResponse.error(_mapDioError(e));
    }
  }

  @override
  Future<ApiResponse<Company>> savePersonalNote(
    String isin, {
    String? thesis,
    String? concerns,
    String? nextReviewDate,
  }) async {
    try {
      final res = await _dio.put(
        ApiEndpoints.companyPersonalNote(isin),
        data: {
          'thesis': thesis,
          'concerns': concerns,
          'nextReviewDate': nextReviewDate,
        },
      );
      final json = res.data as Map<String, dynamic>;
      return ApiResponse.success(Company.fromJson(json['data'] ?? {}));
    } on DioException catch (e) {
      return ApiResponse.error(_mapDioError(e));
    }
  }

  @override
  Future<ApiResponse<List<Company>>> getScreenerCompanies({
    String? sector,
    String? conclusion,
    String? searchQuery,
    String? sortField,
    bool sortAsc = true,
  }) async {
    try {
      final query = <String, dynamic>{
        if (sector != null) 'sector': sector,
        if (conclusion != null) 'conclusion': conclusion,
        if (searchQuery != null) 'q': searchQuery,
        if (sortField != null) 'sort': sortField,
        'order': sortAsc ? 'asc' : 'desc',
      };
      final res = await _dio.get(ApiEndpoints.companies, queryParameters: query);
      final json = res.data as Map<String, dynamic>;
      final list = (json['data'] as List<dynamic>?)?.map((e) => Company.fromJson(e as Map<String, dynamic>)).toList() ?? [];
      return ApiResponse.success(list);
    } on DioException catch (e) {
      return ApiResponse.error(_mapDioError(e));
    }
  }

  @override
  Future<ApiResponse<CompanyComparisonData>> compareCompanies(List<String> isins) async {
    try {
      final res = await _dio.get(ApiEndpoints.compare, queryParameters: {'isins': isins.join(',')});
      final json = res.data as Map<String, dynamic>;
      // For now fallback to mock parsing structure
      return ApiResponse.success(CompanyComparisonData(companies: [], rows: []));
    } on DioException catch (e) {
      return ApiResponse.error(_mapDioError(e));
    }
  }

  @override
  Future<ApiResponse<List<ResearchNoteItem>>> getResearchNotes() async {
    try {
      final res = await _dio.get(ApiEndpoints.researchNotes);
      final json = res.data as Map<String, dynamic>;
      final list = (json['data'] as List<dynamic>?)?.map((e) => ResearchNoteItem.fromJson(e as Map<String, dynamic>)).toList() ?? [];
      return ApiResponse.success(list);
    } on DioException catch (e) {
      return ApiResponse.error(_mapDioError(e));
    }
  }

  @override
  Future<ApiResponse<ResearchNoteItem>> createResearchNote(ResearchNoteItem note) async {
    try {
      final res = await _dio.post(ApiEndpoints.researchNotes, data: note.toJson());
      final json = res.data as Map<String, dynamic>;
      return ApiResponse.success(ResearchNoteItem.fromJson(json['data'] ?? {}));
    } on DioException catch (e) {
      return ApiResponse.error(_mapDioError(e));
    }
  }

  @override
  Future<ApiResponse<ResearchNoteItem>> updateResearchNote(String id, ResearchNoteItem note) async {
    try {
      final res = await _dio.put(ApiEndpoints.researchNoteId(id), data: note.toJson());
      final json = res.data as Map<String, dynamic>;
      return ApiResponse.success(ResearchNoteItem.fromJson(json['data'] ?? {}));
    } on DioException catch (e) {
      return ApiResponse.error(_mapDioError(e));
    }
  }

  @override
  Future<ApiResponse<bool>> deleteResearchNote(String id) async {
    try {
      await _dio.delete(ApiEndpoints.researchNoteId(id));
      return ApiResponse.success(true);
    } on DioException catch (e) {
      return ApiResponse.error(_mapDioError(e));
    }
  }

  @override
  Future<ApiResponse<RuleSettingsData>> getSettingsRules() async {
    try {
      final res = await _dio.get(ApiEndpoints.settingsRules);
      final json = res.data as Map<String, dynamic>;
      return ApiResponse.success(RuleSettingsData.fromJson(json['data'] ?? {}));
    } on DioException catch (e) {
      return ApiResponse.error(_mapDioError(e));
    }
  }

  @override
  Future<ApiResponse<RuleSettingsData>> updateSettingsRules(RuleSettingsData rules) async {
    try {
      final res = await _dio.put(ApiEndpoints.settingsRules, data: rules.toJson());
      final json = res.data as Map<String, dynamic>;
      return ApiResponse.success(RuleSettingsData.fromJson(json['data'] ?? {}));
    } on DioException catch (e) {
      return ApiResponse.error(_mapDioError(e));
    }
  }

  @override
  Future<ApiResponse<String>> triggerDataRefresh() async {
    try {
      final res = await _dio.post(ApiEndpoints.refresh);
      final json = res.data as Map<String, dynamic>;
      return ApiResponse.success(json['data']?['jobId'] as String? ?? 'job-default');
    } on DioException catch (e) {
      return ApiResponse.error(_mapDioError(e));
    }
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getRefreshStatus(String jobId) async {
    try {
      final res = await _dio.get(ApiEndpoints.refreshJob(jobId));
      final json = res.data as Map<String, dynamic>;
      return ApiResponse.success(json['data'] as Map<String, dynamic>? ?? {});
    } on DioException catch (e) {
      return ApiResponse.error(_mapDioError(e));
    }
  }

  ApiError _mapDioError(DioException e) {
    if (e.response != null && e.response?.data is Map<String, dynamic>) {
      final err = (e.response?.data as Map<String, dynamic>)['error'];
      if (err is Map<String, dynamic>) {
        return ApiError.fromJson(err);
      }
    }
    return ApiError(
      code: 'NETWORK_ERROR',
      message: e.message ?? 'Network connection failure to backend server',
      retryable: true,
    );
  }
}
