/// Benchmark entities for Indian Equities (NIFTY 50 and Sector Baskets)

class MarketBenchmark {
  final String symbol;
  final String name;
  final String type; // e.g. "Official Exchange Index"
  final double latestClose;
  final double dailyChangePercent;
  final double monthlyChangePercent;

  const MarketBenchmark({
    required this.symbol,
    required this.name,
    required this.type,
    required this.latestClose,
    required this.dailyChangePercent,
    required this.monthlyChangePercent,
  });

  factory MarketBenchmark.fromJson(Map<String, dynamic> json) {
    return MarketBenchmark(
      symbol: json['symbol'] as String? ?? 'NIFTY_50',
      name: json['name'] as String? ?? 'NIFTY 50',
      type: json['type'] as String? ?? 'Official Exchange Index',
      latestClose: (json['latestClose'] as num?)?.toDouble() ?? 25000.0,
      dailyChangePercent: (json['dailyChangePercent'] as num?)?.toDouble() ?? 0.0,
      monthlyChangePercent: (json['monthlyChangePercent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SectorBenchmark {
  final String id;
  final String name;
  final bool isProxy;
  final String? proxyDisclosure;
  final double dailyChangePercent;
  final double monthlyChangePercent;

  const SectorBenchmark({
    required this.id,
    required this.name,
    required this.isProxy,
    this.proxyDisclosure,
    required this.dailyChangePercent,
    required this.monthlyChangePercent,
  });

  factory SectorBenchmark.fromJson(Map<String, dynamic> json) {
    return SectorBenchmark(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      isProxy: json['isProxy'] as bool? ?? false,
      proxyDisclosure: json['proxyDisclosure'] as String?,
      dailyChangePercent: (json['dailyChangePercent'] as num?)?.toDouble() ?? 0.0,
      monthlyChangePercent: (json['monthlyChangePercent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class BenchmarkBundle {
  final MarketBenchmark broadMarket;
  final List<SectorBenchmark> sectors;

  const BenchmarkBundle({
    required this.broadMarket,
    required this.sectors,
  });

  factory BenchmarkBundle.fromJson(Map<String, dynamic> json) {
    return BenchmarkBundle(
      broadMarket: MarketBenchmark.fromJson(json['broadMarket'] as Map<String, dynamic>? ?? {}),
      sectors: (json['sectors'] as List<dynamic>?)
              ?.map((e) => SectorBenchmark.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
