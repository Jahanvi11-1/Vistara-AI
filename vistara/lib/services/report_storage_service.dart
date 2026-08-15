import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/contract_report.dart';

class ReportStorageService {
  static const String _reportsKey =
      'vistara_saved_reports';

  // ===========================================================================
  // SAVE REPORT
  // ===========================================================================

  Future<String> saveReport(
      ContractReport report,
      ) async {
    final directory =
    await getApplicationDocumentsDirectory();

    final reportsDirectory =
    Directory(
      '${directory.path}/vistara_reports',
    );

    if (!await reportsDirectory.exists()) {
      await reportsDirectory.create(
        recursive: true,
      );
    }

    final safeName =
    _safeFilename(report.filename);

    final timestamp =
        DateTime.now()
            .millisecondsSinceEpoch;

    final pdfPath =
        '${reportsDirectory.path}/'
        '${safeName}_$timestamp.pdf';

    final pdfFile =
    File(pdfPath);

    final pdfBytes =
    await _createPdf(report);

    await pdfFile.writeAsBytes(
      pdfBytes,
      flush: true,
    );

    // Store structured report metadata.
    await _saveMetadata(
      report: report,
      pdfPath: pdfPath,
    );

    return pdfPath;
  }

  // ===========================================================================
  // SAVE METADATA
  // ===========================================================================

  Future<void> _saveMetadata({
    required ContractReport report,
    required String pdfPath,
  }) async {
    final prefs =
    await SharedPreferences.getInstance();

    final existing =
        prefs.getStringList(
          _reportsKey,
        ) ??
            <String>[];

    final savedReport = {
      'id': DateTime.now()
          .millisecondsSinceEpoch
          .toString(),

      'filename': report.filename,

      'savedAt': DateTime.now()
          .toIso8601String(),

      'pdfPath': pdfPath,

      'report': report.toJson(),
    };

    existing.insert(
      0,
      jsonEncode(savedReport),
    );

    await prefs.setStringList(
      _reportsKey,
      existing,
    );
  }

  // ===========================================================================
  // GET SAVED REPORTS
  // ===========================================================================

  Future<List<SavedReport>> getSavedReports() async {
    final prefs =
    await SharedPreferences.getInstance();

    final items =
        prefs.getStringList(
          _reportsKey,
        ) ??
            <String>[];

    final List<SavedReport> reports =
    <SavedReport>[];

    for (final item in items) {
      try {
        final decoded =
        jsonDecode(item);

        if (decoded is Map) {
          reports.add(
            SavedReport.fromJson(
              Map<String, dynamic>.from(
                decoded,
              ),
            ),
          );
        }
      } catch (_) {
        // Ignore corrupted individual entries.
      }
    }

    return reports;
  }

  // ===========================================================================
  // DELETE REPORT
  // ===========================================================================

  Future<void> deleteReport(
      SavedReport savedReport,
      ) async {
    final prefs =
    await SharedPreferences.getInstance();

    final items =
        prefs.getStringList(
          _reportsKey,
        ) ??
            <String>[];

    final remaining =
    items.where((item) {
      try {
        final decoded =
        jsonDecode(item);

        return decoded['id'] !=
            savedReport.id;
      } catch (_) {
        return true;
      }
    }).toList();

    await prefs.setStringList(
      _reportsKey,
      remaining,
    );

    // Delete PDF too.
    final file =
    File(savedReport.pdfPath);

    if (await file.exists()) {
      await file.delete();
    }
  }

  // ===========================================================================
  // CREATE PDF
  // ===========================================================================

  Future<List<int>> _createPdf(
      ContractReport report,
      ) async {
    final document =
    pw.Document();

    document.addPage(
      pw.MultiPage(
        pageFormat:
        PdfPageFormat.a4,
        margin:
        const pw.EdgeInsets.all(
          36,
        ),
        build: (context) {
          return [
            pw.Text(
              'VISTARA',
              style: pw.TextStyle(
                fontSize: 26,
                fontWeight:
                pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 4),

            pw.Text(
              'Contract Risk Analysis Report',
              style: const pw.TextStyle(
                fontSize: 15,
              ),
            ),

            pw.SizedBox(height: 24),

            pw.Text(
              'Contract',
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight:
                pw.FontWeight.bold,
              ),
            ),

            pw.Text(
              report.filename,
            ),

            pw.SizedBox(height: 18),

            pw.Container(
              padding:
              const pw.EdgeInsets.all(
                14,
              ),
              decoration:
              pw.BoxDecoration(
                border: pw.Border.all(
                  color:
                  PdfColors.grey400,
                ),
                borderRadius:
                pw.BorderRadius.circular(
                  8,
                ),
              ),
              child: pw.Column(
                crossAxisAlignment:
                pw.CrossAxisAlignment
                    .start,
                children: [
                  pw.Text(
                    'Overall Safety Score',
                    style:
                    pw.TextStyle(
                      fontWeight:
                      pw.FontWeight
                          .bold,
                    ),
                  ),

                  pw.SizedBox(height: 6),

                  pw.Text(
                    '${report.overallScore} / 100',
                    style:
                    const pw.TextStyle(
                      fontSize: 24,
                    ),
                  ),

                  pw.SizedBox(height: 8),

                  pw.Text(
                    'Risk Level: ${report.riskLevel}',
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 18),

            pw.Text(
              'Risk Breakdown',
              style: pw.TextStyle(
                fontSize: 15,
                fontWeight:
                pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 8),

            pw.Text(
              'High: ${report.highRiskCount}',
            ),

            pw.Text(
              'Medium: ${report.mediumRiskCount}',
            ),

            pw.Text(
              'Low: ${report.lowRiskCount}',
            ),

            pw.SizedBox(height: 24),

            pw.Text(
              'Identified Risks',
              style: pw.TextStyle(
                fontSize: 15,
                fontWeight:
                pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 10),

            if (report.flaggedClauses.isEmpty)
              pw.Text(
                'No significant risks detected.',
              ),

            ...report.flaggedClauses
                .asMap()
                .entries
                .map(
                  (entry) {
                final index =
                    entry.key + 1;

                final risk =
                    entry.value;

                return pw.Container(
                  margin:
                  const pw.EdgeInsets
                      .only(
                    bottom: 18,
                  ),
                  padding:
                  const pw.EdgeInsets
                      .all(
                    12,
                  ),
                  decoration:
                  pw.BoxDecoration(
                    border:
                    pw.Border.all(
                      color:
                      PdfColors.grey400,
                    ),
                    borderRadius:
                    pw.BorderRadius
                        .circular(
                      7,
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment:
                    pw.CrossAxisAlignment
                        .start,
                    children: [
                      pw.Text(
                        '$index. ${risk.category}',
                        style:
                        pw.TextStyle(
                          fontSize: 13,
                          fontWeight:
                          pw.FontWeight
                              .bold,
                        ),
                      ),

                      pw.SizedBox(
                        height: 5,
                      ),

                      pw.Text(
                        'Severity: ${risk.severity}',
                      ),

                      pw.SizedBox(
                        height: 10,
                      ),

                      pw.Text(
                        'Original Clause',
                        style:
                        pw.TextStyle(
                          fontWeight:
                          pw.FontWeight
                              .bold,
                        ),
                      ),

                      pw.SizedBox(
                        height: 4,
                      ),

                      pw.Text(
                        risk.clauseText,
                      ),

                      pw.SizedBox(
                        height: 10,
                      ),

                      pw.Text(
                        'What this means',
                        style:
                        pw.TextStyle(
                          fontWeight:
                          pw.FontWeight
                              .bold,
                        ),
                      ),

                      pw.SizedBox(
                        height: 4,
                      ),

                      pw.Text(
                        risk.plainExplanation,
                      ),

                      pw.SizedBox(
                        height: 10,
                      ),

                      pw.Text(
                        'Worst-case scenario',
                        style:
                        pw.TextStyle(
                          fontWeight:
                          pw.FontWeight
                              .bold,
                        ),
                      ),

                      pw.SizedBox(
                        height: 4,
                      ),

                      pw.Text(
                        risk.worstCaseScenario,
                      ),
                    ],
                  ),
                );
              },
            ),

            pw.SizedBox(height: 10),

            pw.Text(
              'AI-assisted educational analysis — '
                  'not legal advice.',
              style:
              const pw.TextStyle(
                fontSize: 9,
                color:
                PdfColors.grey600,
              ),
            ),
          ];
        },
      ),
    );

    return document.save();
  }

  // ===========================================================================
  // SAFE FILE NAME
  // ===========================================================================

  String _safeFilename(
      String filename,
      ) {
    final withoutExtension =
    filename.replaceFirst(
      RegExp(
        r'\.[^.]+$',
      ),
      '',
    );

    return withoutExtension
        .replaceAll(
      RegExp(
        r'[^a-zA-Z0-9_-]+',
      ),
      '_',
    )
        .trim();
  }
}

// =============================================================================
// SAVED REPORT MODEL
// =============================================================================

class SavedReport {
  final String id;
  final String filename;
  final DateTime savedAt;
  final String pdfPath;
  final ContractReport report;

  SavedReport({
    required this.id,
    required this.filename,
    required this.savedAt,
    required this.pdfPath,
    required this.report,
  });

  factory SavedReport.fromJson(
      Map<String, dynamic> json,
      ) {
    return SavedReport(
      id:
      json['id']?.toString() ?? '',

      filename:
      json['filename']?.toString() ??
          'Saved Report',

      savedAt:
      DateTime.tryParse(
        json['savedAt']
            ?.toString() ??
            '',
      ) ??
          DateTime.now(),

      pdfPath:
      json['pdfPath']?.toString() ??
          '',

      report:
      ContractReport.fromJson(
        Map<String, dynamic>.from(
          json['report'] as Map,
        ),
      ),
    );
  }
}