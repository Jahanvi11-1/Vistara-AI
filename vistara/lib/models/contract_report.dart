class ClauseRisk {
  final String clauseText;
  final String severity;
  final String category;
  final String plainExplanation;
  final String worstCaseScenario;

  ClauseRisk({
    required this.clauseText,
    required this.severity,
    required this.category,
    required this.plainExplanation,
    required this.worstCaseScenario,
  });

  factory ClauseRisk.fromJson(Map<String, dynamic> json) {
    return ClauseRisk(
      clauseText: json['clause_text'] as String,
      severity: json['severity'] as String,
      category: json['category'] as String,
      plainExplanation: json['plain_explanation'] as String,
      worstCaseScenario: json['worst_case_scenario'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clause_text': clauseText,
      'severity': severity,
      'category': category,
      'plain_explanation': plainExplanation,
      'worst_case_scenario': worstCaseScenario,
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

  factory ContractReport.fromJson(Map<String, dynamic> json) {
    return ContractReport(
      filename: json['filename'] as String,
      overallScore: json['overall_score'] as int,
      riskLevel: json['risk_level'] as String,
      highRiskCount: json['high_risk_count'] as int,
      mediumRiskCount: json['medium_risk_count'] as int,
      lowRiskCount: json['low_risk_count'] as int,
      flaggedClauses: (json['flagged_clauses'] as List<dynamic>)
          .map((clause) => ClauseRisk.fromJson(clause as Map<String, dynamic>))
          .toList(),
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
      'flagged_clauses': flaggedClauses.map((clause) => clause.toJson()).toList(),
    };
  }
}
