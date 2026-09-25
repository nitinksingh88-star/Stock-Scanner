/// Sourced Sector Research Note entity matching GET/POST /api/research-notes

class ResearchNoteItem {
  final String id;
  final String sectorId;
  final String sectorName;
  final String title;
  final String sourceUrl;
  final String sourcePublication;
  final String reviewedDate;
  final String classification; // 'potentially_temporary', 'potentially_structural', 'mixed'
  final String severity; // 'informational', 'caution', 'material_concern'
  final String summary;
  final String headwinds;
  final String recoveryConditions;

  const ResearchNoteItem({
    required this.id,
    required this.sectorId,
    required this.sectorName,
    required this.title,
    required this.sourceUrl,
    required this.sourcePublication,
    required this.reviewedDate,
    required this.classification,
    required this.severity,
    required this.summary,
    required this.headwinds,
    required this.recoveryConditions,
  });

  factory ResearchNoteItem.fromJson(Map<String, dynamic> json) {
    return ResearchNoteItem(
      id: json['id'] as String? ?? '',
      sectorId: json['sectorId'] as String? ?? 'it',
      sectorName: json['sectorName'] as String? ?? 'Information Technology',
      title: json['title'] as String? ?? '',
      sourceUrl: json['sourceUrl'] as String? ?? '',
      sourcePublication: json['sourcePublication'] as String? ?? 'Financial Express',
      reviewedDate: json['reviewedDate'] as String? ?? '2026-09-24',
      classification: json['classification'] as String? ?? 'potentially_temporary',
      severity: json['severity'] as String? ?? 'caution',
      summary: json['summary'] as String? ?? '',
      headwinds: json['headwinds'] as String? ?? '',
      recoveryConditions: json['recoveryConditions'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sectorId': sectorId,
    'sectorName': sectorName,
    'title': title,
    'sourceUrl': sourceUrl,
    'sourcePublication': sourcePublication,
    'reviewedDate': reviewedDate,
    'classification': classification,
    'severity': severity,
    'summary': summary,
    'headwinds': headwinds,
    'recoveryConditions': recoveryConditions,
  };
}
