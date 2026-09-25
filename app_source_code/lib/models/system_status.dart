/// System Health & Status models matching GET /api/status

class ProviderHealth {
  final String name;
  final bool authenticated;
  final String tokenValidUntil;
  final int quotaRemainingToday;
  final int quotaLimitToday;
  final int lastPingLatencyMs;

  const ProviderHealth({
    required this.name,
    required this.authenticated,
    required this.tokenValidUntil,
    required this.quotaRemainingToday,
    required this.quotaLimitToday,
    required this.lastPingLatencyMs,
  });

  factory ProviderHealth.fromJson(Map<String, dynamic> json) {
    return ProviderHealth(
      name: json['name'] as String? ?? 'Upstox Analytics API',
      authenticated: json['authenticated'] as bool? ?? true,
      tokenValidUntil: json['tokenValidUntil'] as String? ?? '2027-08-14',
      quotaRemainingToday: json['quotaRemainingToday'] as int? ?? 4850,
      quotaLimitToday: json['quotaLimitToday'] as int? ?? 5000,
      lastPingLatencyMs: json['lastPingLatencyMs'] as int? ?? 140,
    );
  }
}

class StorageHealth {
  final String type;
  final int coveredUniverseCount;
  final int totalConfiguredUniverse;
  final String latestCompletedSession;
  final String activeSnapshotId;
  final String activeRuleVersion;

  const StorageHealth({
    required this.type,
    required this.coveredUniverseCount,
    required this.totalConfiguredUniverse,
    required this.latestCompletedSession,
    required this.activeSnapshotId,
    required this.activeRuleVersion,
  });

  factory StorageHealth.fromJson(Map<String, dynamic> json) {
    return StorageHealth(
      type: json['type'] as String? ?? 'PostgreSQL / Supabase (Mock)',
      coveredUniverseCount: json['coveredUniverseCount'] as int? ?? 5,
      totalConfiguredUniverse: json['totalConfiguredUniverse'] as int? ?? 35,
      latestCompletedSession: json['latestCompletedSession'] as String? ?? '2026-09-24',
      activeSnapshotId: json['activeSnapshotId'] as String? ?? 'SNP-20260924-001',
      activeRuleVersion: json['activeRuleVersion'] as String? ?? 'v1.2',
    );
  }
}

class SystemStatusData {
  final String systemHealth; // 'healthy', 'degraded', 'offline'
  final ProviderHealth provider;
  final StorageHealth storage;

  const SystemStatusData({
    required this.systemHealth,
    required this.provider,
    required this.storage,
  });

  bool get isHealthy => systemHealth == 'healthy';

  factory SystemStatusData.fromJson(Map<String, dynamic> json) {
    return SystemStatusData(
      systemHealth: json['systemHealth'] as String? ?? 'healthy',
      provider: ProviderHealth.fromJson(json['provider'] as Map<String, dynamic>? ?? {}),
      storage: StorageHealth.fromJson(json['storage'] as Map<String, dynamic>? ?? {}),
    );
  }
}
