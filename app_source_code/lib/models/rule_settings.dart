/// Screening Heuristic Rules & Threshold Settings matching GET/PUT /api/settings/rules

class RuleThreshold {
  final String key;
  final String name;
  final String description;
  double value;
  final String unit;
  final int precedenceOrder;

  RuleThreshold({
    required this.key,
    required this.name,
    required this.description,
    required this.value,
    required this.unit,
    required this.precedenceOrder,
  });

  factory RuleThreshold.fromJson(Map<String, dynamic> json) {
    return RuleThreshold(
      key: json['key'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '',
      precedenceOrder: json['precedenceOrder'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'name': name,
    'description': description,
    'value': value,
    'unit': unit,
    'precedenceOrder': precedenceOrder,
  };
}

class RuleSettingsData {
  String ruleVersion;
  String lastUpdated;
  List<RuleThreshold> rules;

  RuleSettingsData({
    required this.ruleVersion,
    required this.lastUpdated,
    required this.rules,
  });

  factory RuleSettingsData.fromJson(Map<String, dynamic> json) {
    return RuleSettingsData(
      ruleVersion: json['ruleVersion'] as String? ?? 'v1.2',
      lastUpdated: json['lastUpdated'] as String? ?? '2026-09-24',
      rules: (json['rules'] as List<dynamic>?)
              ?.map((e) => RuleThreshold.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'ruleVersion': ruleVersion,
    'lastUpdated': lastUpdated,
    'rules': rules.map((e) => e.toJson()).toList(),
  };
}
