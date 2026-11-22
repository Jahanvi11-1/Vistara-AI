class BoundingBox {
  final int page;
  final double x0;
  final double top;
  final double x1;
  final double bottom;
  final double pageWidth;
  final double pageHeight;

  BoundingBox({
    required this.page,
    required this.x0,
    required this.top,
    required this.x1,
    required this.bottom,
    required this.pageWidth,
    required this.pageHeight,
  });

  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    return BoundingBox(
      page: (json['page'] as num?)?.toInt() ?? 1,
      x0: (json['x0'] as num?)?.toDouble() ?? 0.0,
      top: (json['top'] as num?)?.toDouble() ?? 0.0,
      x1: (json['x1'] as num?)?.toDouble() ?? 0.0,
      bottom: (json['bottom'] as num?)?.toDouble() ?? 0.0,
      pageWidth: (json['page_width'] as num?)?.toDouble() ?? 595.0,
      pageHeight: (json['page_height'] as num?)?.toDouble() ?? 842.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'x0': x0,
      'top': top,
      'x1': x1,
      'bottom': bottom,
      'page_width': pageWidth,
      'page_height': pageHeight,
    };
  }
}

class RedactionSummary {
  final int redactedCount;
  final List<String> redactedTypes;
  final String sanitizedPreview;
  final List<BoundingBox> piiBoxes;

  RedactionSummary({
    this.redactedCount = 0,
    this.redactedTypes = const [],
    this.sanitizedPreview = '',
    this.piiBoxes = const [],
  });

  factory RedactionSummary.fromJson(Map<String, dynamic> json) {
    final rawTypes = json['redacted_types'];
    final rawBoxes = json['pii_boxes'];
    return RedactionSummary(
      redactedCount: (json['redacted_count'] as num?)?.toInt() ?? 0,
      redactedTypes: rawTypes is List
          ? rawTypes.map((e) => e.toString()).toList()
          : const [],
      sanitizedPreview: json['sanitized_preview']?.toString() ?? '',
      piiBoxes: rawBoxes is List
          ? rawBoxes
          .whereType()
          .map(
            (box) => BoundingBox.fromJson(
          Map<String, dynamic>.from(box),
        ),
      )
          .toList()
          : const <BoundingBox>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'redacted_count': redactedCount,
      'redacted_types': redactedTypes,
      'sanitized_preview': sanitizedPreview,
      'pii_boxes': piiBoxes.map((box) => box.toJson()).toList(),
    };
  }
}

class ClauseRisk {
  final String clauseText;
  final String severity;
  final String category;
  final String plainExplanation;
  final String worstCaseScenario;

  // Evidence and spatial grounding returned by Vistara Extract
  final bool evidenceVerified;
  final double matchConfidence;
  final int? matchedPage;
  final List<BoundingBox> boundingBoxes;

  ClauseRisk({
    required this.clauseText,
    required this.severity,
    required this.category,
    required this.plainExplanation,
    required this.worstCaseScenario,
    this.evidenceVerified = false,
    this.matchConfidence = 0.0,
    this.matchedPage,
    this.boundingBoxes = const [],
  });

  factory ClauseRisk.fromJson(
      Map<String, dynamic> json,
      ) {
    final rawBoxes = json['bounding_boxes'];

    return ClauseRisk(
      clauseText: json['clause_text']?.toString() ?? '',
      severity: json['severity']?.toString() ?? 'Low',
      category: json['category']?.toString() ?? '',
      plainExplanation: json['plain_explanation']?.toString() ?? '',
      worstCaseScenario: json['worst_case_scenario']?.toString() ?? '',
      evidenceVerified: json['evidence_verified'] == true,
      matchConfidence: (json['match_confidence'] as num?)?.toDouble() ?? 0.0,
      matchedPage: (json['matched_page'] as num?)?.toInt(),
      boundingBoxes: rawBoxes is List
          ? rawBoxes
          .whereType()
          .map(
            (box) => BoundingBox.fromJson(
          Map<String, dynamic>.from(box),
        ),
      )
          .toList()
          : const <BoundingBox>[],
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
      'bounding_boxes': boundingBoxes.map((box) => box.toJson()).toList(),
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
  final String extractionMethod;
  final RedactionSummary redactionSummary;
  final List<ClauseRisk> flaggedClauses;

  ContractReport({
    required this.filename,
    required this.overallScore,
    required this.riskLevel,
    required this.highRiskCount,
    required this.mediumRiskCount,
    required this.lowRiskCount,
    this.extractionMethod = 'native_pdf',
    RedactionSummary? redactionSummary,
    required this.flaggedClauses,
  }) : redactionSummary = redactionSummary ?? RedactionSummary();

  factory ContractReport.fromJson(
      Map<String, dynamic> json,
      ) {
    final rawClauses = json['flagged_clauses'];
    final rawRedaction = json['redaction_summary'];

    return ContractReport(
      filename: json['filename']?.toString() ?? 'Unknown Contract',
      overallScore: (json['overall_score'] as num?)?.toInt() ?? 0,
      riskLevel: json['risk_level']?.toString() ?? 'Low',
      highRiskCount: (json['high_risk_count'] as num?)?.toInt() ?? 0,
      mediumRiskCount: (json['medium_risk_count'] as num?)?.toInt() ?? 0,
      lowRiskCount: (json['low_risk_count'] as num?)?.toInt() ?? 0,
      extractionMethod: json['extraction_method']?.toString() ?? 'native_pdf',
      redactionSummary: rawRedaction is Map
          ? RedactionSummary.fromJson(
        Map<String, dynamic>.from(rawRedaction),
      )
          : RedactionSummary(),
      flaggedClauses: rawClauses is List
          ? rawClauses
          .whereType()
          .map(
            (clause) => ClauseRisk.fromJson(
          Map<String, dynamic>.from(clause),
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
      'extraction_method': extractionMethod,
      'redaction_summary': redactionSummary.toJson(),
      'flagged_clauses': flaggedClauses
          .map(
            (clause) => clause.toJson(),
      )
          .toList(),
    };
  }
}