import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../services/report_storage_service.dart';
import '../theme/vistara_theme.dart';


import 'saved_pdf_viewer_screen.dart';

class SavedReportsScreen extends StatefulWidget {
  const SavedReportsScreen({
    super.key,
  });

  @override
  State<SavedReportsScreen> createState() =>
      _SavedReportsScreenState();
}

class _SavedReportsScreenState
    extends State<SavedReportsScreen> {
  final ReportStorageService _storageService =
  ReportStorageService();

  List<SavedReport> _reports = <SavedReport>[];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final reports =
    await _storageService.getSavedReports();

    if (!mounted) return;

    setState(() {
      _reports = reports;
      _isLoading = false;
    });
  }

  Future<void> _deleteReport(
      SavedReport report,
      ) async {
    await _storageService.deleteReport(report);

    await _loadReports();
  }

  // ================================================================
  // OPEN ACTUAL SAVED PDF
  // ================================================================

  Future<void> _openSavedPdf(
      SavedReport savedReport,
      ) async {
    final file = File(
      savedReport.pdfPath,
    );

    if (!await file.exists()) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The saved PDF could not be found.',
          ),
        ),
      );

      return;
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SavedPdfViewerScreen(
          pdfPath: savedReport.pdfPath,
          filename: savedReport.filename,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VistaraColors.lilacWhite,

      appBar: AppBar(
        backgroundColor: VistaraColors.lilacWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: VistaraColors.plumCharcoal,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Text(
          'Saved Reports',
          style: GoogleFonts.poppins(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: VistaraColors.plumCharcoal,
          ),
        ),
      ),

      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_reports.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30),

          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,

            children: [
              Container(
                width: 78,
                height: 78,

                decoration: BoxDecoration(
                  color: VistaraColors.ochreAmber
                      .withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.folder_open_outlined,
                  size: 38,
                  color: VistaraColors.ochreAmber,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                'No saved reports yet',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color:
                  VistaraColors.plumCharcoal,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                'Save an analysis report and it '
                    'will appear here.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  height: 1.5,
                  color: VistaraColors.mutedText,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReports,

      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          18,
          12,
          18,
          30,
        ),

        itemCount: _reports.length,

        separatorBuilder: (_, __) =>
        const SizedBox(height: 12),

        itemBuilder: (context, index) {
          return _buildReportCard(
            _reports[index],
          );
        },
      ),
    );
  }

  // ================================================================
  // REPORT CARD
  // ================================================================

  Widget _buildReportCard(
      SavedReport savedReport,
      ) {
    final report = savedReport.report;

    final riskColor =
    _riskColor(report.riskLevel);

    return Dismissible(
      key: ValueKey(savedReport.id),

      direction:
      DismissDirection.endToStart,

      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,

          builder: (context) {
            return AlertDialog(
              title: const Text(
                'Delete report?',
              ),

              content: const Text(
                'This saved report will be '
                    'removed from this device.',
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      false,
                    );
                  },
                  child: const Text(
                    'Cancel',
                  ),
                ),

                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      true,
                    );
                  },
                  child: const Text(
                    'Delete',
                  ),
                ),
              ],
            );
          },
        ) ??
            false;
      },

      onDismissed: (_) {
        _deleteReport(savedReport);
      },

      background: Container(
        alignment: Alignment.centerRight,

        padding:
        const EdgeInsets.only(
          right: 20,
        ),

        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius:
          BorderRadius.circular(18),
        ),

        child: Icon(
          Icons.delete_outline,
          color: Colors.red.shade700,
        ),
      ),

      child: Material(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(18),

        child: InkWell(
          borderRadius:
          BorderRadius.circular(18),

          onTap: () {
            _openSavedPdf(
              savedReport,
            );
          },

          child: Container(
            padding:
            const EdgeInsets.all(16),

            decoration: BoxDecoration(
              borderRadius:
              BorderRadius.circular(18),

              border: Border.all(
                color: riskColor.withValues(
                  alpha: 0.15,
                ),
              ),
            ),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _displayFilename(
                          savedReport.filename,
                        ),

                        maxLines: 1,

                        overflow:
                        TextOverflow.ellipsis,

                        style:
                        GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight:
                          FontWeight.w700,
                          color:
                          VistaraColors
                              .plumCharcoal,
                        ),
                      ),
                    ),

                    Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),

                      decoration:
                      BoxDecoration(
                        color:
                        riskColor.withValues(
                          alpha: 0.10,
                        ),

                        borderRadius:
                        BorderRadius
                            .circular(
                          20,
                        ),
                      ),

                      child: Text(
                        report.riskLevel,

                        style:
                        GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight:
                          FontWeight.w700,
                          color: riskColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Text(
                      'Score ${report.overallScore}/100',

                      style:
                      GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight:
                        FontWeight.w600,
                        color:
                        VistaraColors
                            .mutedText,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Text(
                      '${report.flaggedClauses.length} risks',

                      style:
                      GoogleFonts.poppins(
                        fontSize: 11,
                        color:
                        VistaraColors
                            .mutedText,
                      ),
                    ),

                    const Spacer(),

                    const Icon(
                      Icons
                          .arrow_forward_ios_rounded,
                      size: 13,
                      color:
                      VistaraColors
                          .mutedText,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  _formatDate(
                    savedReport.savedAt,
                  ),

                  style:
                  GoogleFonts.poppins(
                    fontSize: 9,
                    color:
                    VistaraColors
                        .mutedText,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(
                      Icons
                          .picture_as_pdf_outlined,
                      size: 15,
                      color:
                      VistaraColors
                          .ochreAmber,
                    ),

                    const SizedBox(width: 5),

                    Text(
                      'Tap to open PDF',

                      style:
                      GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight:
                        FontWeight.w600,
                        color:
                        VistaraColors
                            .ochreAmber,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // HELPERS
  // ================================================================

  Color _riskColor(
      String level,
      ) {
    switch (level.toLowerCase()) {
      case 'high':
        return VistaraColors.highRisk;

      case 'medium':
        return VistaraColors.mediumRisk;

      case 'low':
        return VistaraColors.lowRisk;

      default:
        return VistaraColors.neutral;
    }
  }

  String _displayFilename(
      String filename,
      ) {
    if (filename.length <= 30) {
      return filename;
    }

    return '${filename.substring(0, 27)}...';
  }

  String _formatDate(
      DateTime date,
      ) {
    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    final year =
    date.year.toString();

    final hour =
    date.hour.toString().padLeft(2, '0');

    final minute =
    date.minute.toString().padLeft(2, '0');

    return 'Saved $day/$month/$year at '
        '$hour:$minute';
  }
}