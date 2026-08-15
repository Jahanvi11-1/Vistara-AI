class ClauseRisk {
  final String clauseText;
  final String severity;
  final String category;
  final String plainExplanation;
  final String worstCaseScenario;

  // Evidence information returned by the backend.
  final bool evidenceVerified;
  final double matchConfidence;
  final int? matchedPage;

  ClauseRisk({
    required this.clauseText,
    required this.severity,
    required this.category,
    required this.plainExplanation,
    required this.worstCaseScenario,
    this.evidenceVerified = false,
    this.matchConfidence = 0.0,
    this.matchedPage,
  });

  factory ClauseRisk.fromJson(
      Map<String, dynamic> json,
      ) {
    return ClauseRisk(
      clauseText:
      json['clause_text']?.toString() ?? '',

      severity:
      json['severity']?.toString() ?? 'Low',

      category:
      json['category']?.toString() ?? '',

      plainExplanation:
      json['plain_explanation']?.toString() ?? '',

      worstCaseScenario:
      json['worst_case_scenario']?.toString() ?? '',

      evidenceVerified:
      json['evidence_verified'] == true,

      matchConfidence:
      (json['match_confidence'] as num?)
          ?.toDouble() ??
          0.0,

      matchedPage:
      (json['matched_page'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clause_text': clauseText,
      'severity': severity,
      'category': category,
      'plain_explanation': plainExplanation,
      'worst_case_scenario': worstCaseScenario,
      'evidence_verified': evidenceVerified,
      'match_confidence': matchConfidence,
      'matched_page': matchedPage,
    };
  }
}

class ContractReport {
  final String filename;
  final int overallScore;
  final String riskLevel;
  final int highRiskCount;
  final int mediumRiskCount;
  final int lowRiskCount;
  final List<ClauseRisk> flaggedClauses;

  ContractReport({
    required this.filename,
    required this.overallScore,
    required this.riskLevel,
    required this.highRiskCount,
    required this.mediumRiskCount,
    required this.lowRiskCount,
    required this.flaggedClauses,
  });

  factory ContractReport.fromJson(
      Map<String, dynamic> json,
      ) {
    final rawClauses =
    json['flagged_clauses'];

    return ContractReport(
      filename:
      json['filename']?.toString() ??
          'Unknown Contract',

      overallScore:
      (json['overall_score'] as num?)
          ?.toInt() ??
          0,

      riskLevel:
      json['risk_level']?.toString() ??
          'Low',

      highRiskCount:
      (json['high_risk_count'] as num?)
          ?.toInt() ??
          0,

      mediumRiskCount:
      (json['medium_risk_count'] as num?)
          ?.toInt() ??
          0,

      lowRiskCount:
      (json['low_risk_count'] as num?)
          ?.toInt() ??
          0,

      flaggedClauses:
      rawClauses is List
          ? rawClauses
          .whereType<Map>()
          .map(
            (clause) =>
            ClauseRisk.fromJson(
              Map<String, dynamic>.from(
                clause,
              ),
            ),
      )
          .toList()
          : <ClauseRisk>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filename': filename,
      'overall_score': overallScore,
      'risk_level': riskLevel,
      'high_risk_count': highRiskCount,
      'medium_risk_count': mediumRiskCount,
      'low_risk_count': lowRiskCount,
      'flagged_clauses':
      flaggedClauses
          .map(
            (clause) =>
            clause.toJson(),
      )
          .toList(),
    };
  }
}