import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/contract_report.dart';
import 'risk_detail_screen.dart';

class ReportScreen extends StatelessWidget {
  final ContractReport report;

  const ReportScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FFF0), // Pastel mint background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6B4FA0)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Analysis Report',
          style: GoogleFonts.poppins(
            color: const Color(0xFF2D2D2D),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xFF6B4FA0)),
            onPressed: () {
              // Share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Score Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B4FA0), Color(0xFF8B6FCE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B4FA0).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Overall Risk Score',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${report.overallScore}/100',
                    style: GoogleFonts.poppins(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildScoreIndicator(report.riskLevel),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Risk Statistics Section
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'High Risk',
                    report.highRiskCount.toString(),
                    const Color(0xFFFFE5E5),
                    const Color(0xFFD32F2F),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Medium Risk',
                    report.mediumRiskCount.toString(),
                    const Color(0xFFFFF5E5),
                    const Color(0xFFFF9800),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Low Risk',
                    report.lowRiskCount.toString(),
                    const Color(0xFFE5FFE5),
                    const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Risks Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Identified Risks',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE5E5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${report.flaggedClauses.length}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFD32F2F),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...report.flaggedClauses.map((risk) => _buildRiskCard(context, risk)),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreIndicator(String riskLevel) {
    Color color;

    switch (riskLevel.toLowerCase()) {
      case 'low':
        color = Colors.greenAccent;
        break;
      case 'medium':
        color = Colors.orangeAccent;
        break;
      case 'high':
        color = Colors.redAccent;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$riskLevel Risk',
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: textColor.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRiskCard(BuildContext context, ClauseRisk risk) {
    Color severityColor;
    switch (risk.severity.toLowerCase()) {
      case 'high':
        severityColor = const Color(0xFFFFE5E5);
        break;
      case 'medium':
        severityColor = const Color(0xFFFFF5E5);
        break;
      case 'low':
        severityColor = const Color(0xFFE5FFE5);
        break;
      default:
        severityColor = Colors.grey[200]!;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RiskDetailScreen(risk: risk),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: severityColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      risk.clauseText,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D2D2D),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      risk.severity,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D2D2D),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                risk.plainExplanation,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Color(0xFF6B4FA0),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'View details',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF6B4FA0),
                      fontWeight: FontWeight.w500,
                    ),
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
