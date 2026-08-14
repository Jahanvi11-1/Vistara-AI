import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/vistara_theme.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VistaraColors.lilacWhite,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  Text(
                    'VISTARA',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: VistaraColors.ochreAmber,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Text(
                'Reports',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: VistaraColors.plumCharcoal,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Review your contract risk analysis.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: VistaraColors.mutedText,
                ),
              ),

              const SizedBox(height: 20),

              // SUMMARY CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: VistaraColors.lavenderGray
                        .withValues(alpha: .22),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _summaryItem(
                        'Documents',
                        '1',
                      ),
                    ),
                    Expanded(
                      child: _summaryItem(
                        'High Risk',
                        '1',
                      ),
                    ),
                    Expanded(
                      child: _summaryItem(
                        'Reviewed',
                        '1',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Recent Reports',
                style: GoogleFonts.poppins(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: VistaraColors.plumCharcoal,
                ),
              ),

              const SizedBox(height: 12),

              _reportCard(
                context,
                filename: 'contract1.pdf',
                score: 5,
                risk: 'High',
                high: 10,
                medium: 2,
                low: 1,
              ),

              const SizedBox(height: 12),

              _emptyHint(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryItem(
      String title,
      String value,
      ) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: VistaraColors.plumCharcoal,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: VistaraColors.mutedText,
          ),
        ),
      ],
    );
  }

  Widget _reportCard(
      BuildContext context, {
        required String filename,
        required int score,
        required String risk,
        required int high,
        required int medium,
        required int low,
      }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          // Individual report navigation will be connected
          // to the saved ContractReport.
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: VistaraColors.ochreAmber
                          .withValues(alpha: .12),
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: VistaraColors.ochreAmber,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          filename,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight:
                            FontWeight.w600,
                            color: VistaraColors
                                .plumCharcoal,
                          ),
                        ),
                        Text(
                          'Analysis Report',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color:
                            VistaraColors.neutral,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    '$score/100',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color:
                      VistaraColors.riskColor(risk),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  _riskCount(
                    high,
                    'High',
                    VistaraColors.highRisk,
                  ),
                  const SizedBox(width: 10),
                  _riskCount(
                    medium,
                    'Medium',
                    VistaraColors.mediumRisk,
                  ),
                  const SizedBox(width: 10),
                  _riskCount(
                    low,
                    'Low',
                    VistaraColors.lowRisk,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _riskCount(
      int count,
      String label,
      Color color,
      ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyHint() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: VistaraColors.lavenderGray
            .withValues(alpha: .10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 18,
            color: VistaraColors.neutral,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Reports are generated after a contract is analyzed. '
                  'Your analyzed documents can be opened to review '
                  'individual flagged clauses.',
              style: GoogleFonts.poppins(
                fontSize: 11,
                height: 1.5,
                color: VistaraColors.mutedText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}