import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/contract_report.dart';
import '../services/report_storage_service.dart';
import '../theme/vistara_theme.dart';
import '../widgets/vistara_bottom_nav.dart';

import 'main_navigation.dart';
import 'risk_detail_screen.dart';
import 'saved_reports_screen.dart';

class ReportScreen extends StatefulWidget {
  final ContractReport report;

  const ReportScreen({
    super.key,
    required this.report,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final ReportStorageService _storageService =
  ReportStorageService();

  bool _isSaving = false;

  // ================================================================
  // SAVE REPORT
  // ================================================================

  Future<void> _saveReport() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final pdfPath = await _storageService.saveReport(
        widget.report,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Report saved successfully.',
          ),
          action: SnackBarAction(
            label: 'VIEW',
            onPressed: _openSavedReports,
          ),
        ),
      );

      debugPrint(
        'VISTARA REPORT SAVED: $pdfPath',
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not save report: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ================================================================
  // OPEN SAVED REPORTS
  // ================================================================

  void _openSavedReports() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SavedReportsScreen(),
      ),
    );
  }

  // ================================================================
  // BUILD
  // ================================================================

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

        titleSpacing: 0,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _displayFilename(
                widget.report.filename,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: VistaraColors.plumCharcoal,
              ),
            ),

            Text(
              'Analysis Report',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: VistaraColors.mutedText,
              ),
            ),
          ],
        ),

        actions: [
          // Saved reports
          IconButton(
            tooltip: 'Saved Reports',
            onPressed: _openSavedReports,
            icon: const Icon(
              Icons.folder_copy_outlined,
              color: VistaraColors.plumCharcoal,
            ),
          ),

          // Save current report
          IconButton(
            tooltip: 'Save Report',
            onPressed: _isSaving
                ? null
                : _saveReport,
            icon: _isSaving
                ? const SizedBox(
              width: 19,
              height: 19,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
                : const Icon(
              Icons.download_outlined,
              color: VistaraColors.plumCharcoal,
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          padding: const EdgeInsets.fromLTRB(
            18,
            8,
            18,
            24,
          ),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              // ----------------------------------------------------
              // SCORE
              // ----------------------------------------------------

              _buildScoreCard(),

              const SizedBox(height: 14),

              // ----------------------------------------------------
              // SAVE REPORT
              // ----------------------------------------------------

              _buildSaveReportButton(),

              const SizedBox(height: 20),

              // ----------------------------------------------------
              // RISK BREAKDOWN
              // ----------------------------------------------------

              Text(
                'Risk Breakdown',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: VistaraColors.plumCharcoal,
                ),
              ),

              const SizedBox(height: 10),

              _buildRiskBreakdown(),

              const SizedBox(height: 24),

              // ----------------------------------------------------
              // TOP RISKS
              // ----------------------------------------------------

              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Top Risks Identified',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color:
                        VistaraColors.plumCharcoal,
                      ),
                    ),
                  ),

                  Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),

                    decoration:
                    BoxDecoration(
                      color: VistaraColors
                          .ochreAmber
                          .withValues(
                        alpha: 0.13,
                      ),
                      borderRadius:
                      BorderRadius.circular(
                        20,
                      ),
                    ),

                    child: Text(
                      '${widget.report.flaggedClauses.length}',
                      style:
                      GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight:
                        FontWeight.w700,
                        color:
                        VistaraColors
                            .ochreAmber,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (widget.report.flaggedClauses.isEmpty)
                _buildNoRisks()
              else
                ...widget.report.flaggedClauses
                    .asMap()
                    .entries
                    .map(
                      (entry) {
                    return Padding(
                      padding:
                      const EdgeInsets.only(
                        bottom: 12,
                      ),

                      child: _RiskCard(
                        index: entry.key,
                        risk: entry.value,

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RiskDetailScreen(
                                    risk: entry.value,
                                  ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

              const SizedBox(height: 8),

              // ----------------------------------------------------
              // DISCLAIMER
              // ----------------------------------------------------

              _buildDisclaimer(),
            ],
          ),
        ),
      ),

      // --------------------------------------------------------------
      // BOTTOM NAVIGATION
      // --------------------------------------------------------------

      bottomNavigationBar: VistaraBottomNav(
        currentIndex: 1,
        onDestinationSelected: (index) {
          _goToMainTab(
            context,
            index,
          );
        },
      ),
    );
  }

  // ================================================================
  // SAVE REPORT BUTTON
  // ================================================================

  Widget _buildSaveReportButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,

      child: OutlinedButton.icon(
        onPressed:
        _isSaving ? null : _saveReport,

        icon: _isSaving
            ? const SizedBox(
          width: 18,
          height: 18,
          child:
          CircularProgressIndicator(
            strokeWidth: 2,
          ),
        )
            : const Icon(
          Icons.save_alt_rounded,
        ),

        label: Text(
          _isSaving
              ? 'Saving Report...'
              : 'Save Report',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),

        style:
        OutlinedButton.styleFrom(
          foregroundColor:
          VistaraColors.plumCharcoal,

          side: BorderSide(
            color: VistaraColors
                .plumCharcoal
                .withValues(
              alpha: 0.20,
            ),
          ),

          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
              15,
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // SCORE CARD
  // ================================================================

  Widget _buildScoreCard() {
    final scoreColor =
    _scoreColor(
      widget.report.overallScore,
    );

    return Container(
      width: double.infinity,

      padding:
      const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(24),

        border: Border.all(
          color: VistaraColors
              .lavenderGray
              .withValues(
            alpha: 0.18,
          ),
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Text(
            'Contract Risk Report',
            style: GoogleFonts.poppins(
              fontSize: 19,
              fontWeight:
              FontWeight.w700,
              color:
              VistaraColors
                  .plumCharcoal,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            widget.report.filename,
            maxLines: 2,
            overflow:
            TextOverflow.ellipsis,
            style:
            GoogleFonts.poppins(
              fontSize: 10,
              color:
              VistaraColors
                  .mutedText,
            ),
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              SizedBox(
                width: 112,
                height: 112,

                child: Stack(
                  alignment:
                  Alignment.center,

                  children: [
                    SizedBox(
                      width: 112,
                      height: 112,

                      child:
                      CircularProgressIndicator(
                        value: (
                            widget
                                .report
                                .overallScore
                                .clamp(
                              0,
                              100,
                            ) /
                                100
                        ),

                        strokeWidth: 9,

                        backgroundColor:
                        VistaraColors
                            .lavenderGray
                            .withValues(
                          alpha: 0.18,
                        ),

                        valueColor:
                        AlwaysStoppedAnimation<
                            Color>(
                          scoreColor,
                        ),
                      ),
                    ),

                    Column(
                      mainAxisSize:
                      MainAxisSize.min,

                      children: [
                        Text(
                          '${widget.report.overallScore}',

                          style:
                          GoogleFonts
                              .poppins(
                            fontSize: 29,
                            fontWeight:
                            FontWeight
                                .w700,
                            color:
                            VistaraColors
                                .plumCharcoal,
                          ),
                        ),

                        Text(
                          '/100',

                          style:
                          GoogleFonts
                              .poppins(
                            fontSize: 9,
                            color:
                            VistaraColors
                                .mutedText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 22),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Overall Risk',

                      style:
                      GoogleFonts.poppins(
                        fontSize: 10,
                        color:
                        VistaraColors
                            .mutedText,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      widget.report.riskLevel,

                      style:
                      GoogleFonts.poppins(
                        fontSize: 23,
                        fontWeight:
                        FontWeight.w700,
                        color:
                        _riskLevelColor(
                          widget.report
                              .riskLevel,
                        ),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      _scoreDescription(
                        widget.report
                            .overallScore,
                      ),

                      style:
                      GoogleFonts.poppins(
                        fontSize: 10,
                        height: 1.45,
                        color:
                        VistaraColors
                            .mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // RISK BREAKDOWN
  // ================================================================

  Widget _buildRiskBreakdown() {
    return Row(
      children: [
        Expanded(
          child: _RiskCountCard(
            count:
            widget.report.highRiskCount,
            label: 'High Risk',
            color:
            VistaraColors.highRisk,
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: _RiskCountCard(
            count:
            widget.report.mediumRiskCount,
            label: 'Medium',
            color:
            VistaraColors.mediumRisk,
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: _RiskCountCard(
            count:
            widget.report.lowRiskCount,
            label: 'Low',
            color:
            VistaraColors.lowRisk,
          ),
        ),
      ],
    );
  }

  // ================================================================
  // DISCLAIMER
  // ================================================================

  Widget _buildDisclaimer() {
    return Container(
      width: double.infinity,

      padding:
      const EdgeInsets.all(15),

      decoration:
      BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16),
      ),

      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 17,
            color:
            VistaraColors
                .ochreAmber,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              'Vistara provides AI-powered '
                  'contract risk analysis for '
                  'awareness. It is not legal advice.',

              style:
              GoogleFonts.poppins(
                fontSize: 9,
                height: 1.5,
                color:
                VistaraColors
                    .mutedText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // NO RISKS
  // ================================================================

  Widget _buildNoRisks() {
    return Container(
      width: double.infinity,

      padding:
      const EdgeInsets.all(28),

      decoration:
      BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18),
      ),

      child: Column(
        children: [
          const Icon(
            Icons
                .check_circle_outline_rounded,
            color:
            VistaraColors.lowRisk,
            size: 42,
          ),

          const SizedBox(height: 10),

          Text(
            'No significant risks detected',

            style:
            GoogleFonts.poppins(
              fontSize: 13,
              fontWeight:
              FontWeight.w600,
              color:
              VistaraColors
                  .plumCharcoal,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // NAVIGATION
  // ================================================================

  void _goToMainTab(
      BuildContext context,
      int index,
      ) {
    Navigator.pushAndRemoveUntil(
      context,

      MaterialPageRoute(
        builder: (_) =>
            MainNavigation(
              initialIndex: index,
            ),
      ),

          (route) => false,
    );
  }

  // ================================================================
  // HELPERS
  // ================================================================

  String _displayFilename(
      String filename,
      ) {
    if (filename.length <= 23) {
      return filename;
    }

    return '${filename.substring(0, 20)}...';
  }

  Color _scoreColor(
      int score,
      ) {
    if (score <= 40) {
      return VistaraColors.highRisk;
    }

    if (score <= 70) {
      return VistaraColors.mediumRisk;
    }

    return VistaraColors.lowRisk;
  }

  Color _riskLevelColor(
      String level,
      ) {
    switch (
    level.toLowerCase()) {
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

  String _scoreDescription(
      int score,
      ) {
    if (score <= 40) {
      return 'Requires immediate attention.';
    }

    if (score <= 70) {
      return 'Several clauses deserve review.';
    }

    return 'Generally lower risk based on detected clauses.';
  }
}

// ====================================================================
// RISK COUNT CARD
// ====================================================================

class _RiskCountCard
    extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _RiskCountCard({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        vertical: 13,
        horizontal: 6,
      ),

      decoration:
      BoxDecoration(
        color:
        color.withValues(
          alpha: 0.08,
        ),

        borderRadius:
        BorderRadius.circular(14),

        border: Border.all(
          color:
          color.withValues(
            alpha: 0.14,
          ),
        ),
      ),

      child: Column(
        children: [
          Text(
            '$count',

            style:
            GoogleFonts.poppins(
              fontSize: 21,
              fontWeight:
              FontWeight.w700,
              color: color,
            ),
          ),

          const SizedBox(height: 1),

          Text(
            label,

            textAlign:
            TextAlign.center,

            style:
            GoogleFonts.poppins(
              fontSize: 8,
              fontWeight:
              FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// RISK CARD
// ====================================================================

class _RiskCard
    extends StatelessWidget {
  final int index;
  final ClauseRisk risk;
  final VoidCallback onTap;

  const _RiskCard({
    required this.index,
    required this.risk,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final color =
    VistaraColors.riskColor(
      risk.severity,
    );

    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,

        borderRadius:
        BorderRadius.circular(18),

        child: Container(
          width: double.infinity,

          padding:
          const EdgeInsets.all(16),

          decoration:
          BoxDecoration(
            color: Colors.white,

            borderRadius:
            BorderRadius.circular(
              18,
            ),

            border: Border.all(
              color:
              color.withValues(
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
                      color.withValues(
                        alpha: 0.10,
                      ),

                      borderRadius:
                      BorderRadius.circular(
                        20,
                      ),
                    ),

                    child: Text(
                      risk.severity,

                      style:
                      GoogleFonts.poppins(
                        fontSize: 8,
                        fontWeight:
                        FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),

                  const Spacer(),

                  Text(
                    '${index + 1}',

                    style:
                    GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight:
                      FontWeight.w600,
                      color:
                      VistaraColors
                          .neutral,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Text(
                risk.category,

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

              const SizedBox(height: 6),

              Text(
                risk.plainExplanation,

                maxLines: 3,

                overflow:
                TextOverflow.ellipsis,

                style:
                GoogleFonts.poppins(
                  fontSize: 10.5,
                  height: 1.45,
                  color:
                  VistaraColors
                      .mutedText,
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Text(
                    'View details',

                    style:
                    GoogleFonts.poppins(
                      fontSize: 9.5,
                      fontWeight:
                      FontWeight.w600,
                      color:
                      VistaraColors
                          .ochreAmber,
                    ),
                  ),

                  const SizedBox(width: 4),

                  const Icon(
                    Icons
                        .arrow_forward_rounded,
                    size: 13,
                    color:
                    VistaraColors
                        .ochreAmber,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}