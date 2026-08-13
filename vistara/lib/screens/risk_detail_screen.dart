import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/contract_report.dart';

class RiskDetailScreen extends StatelessWidget {
  final ClauseRisk risk;

  const RiskDetailScreen({super.key, required this.risk});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F0), // Pastel peach background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6B4FA0)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Risk Details',
          style: GoogleFonts.poppins(
            color: const Color(0xFF2D2D2D),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Severity Badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _getSeverityColor(risk.severity),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  '${risk.severity.toUpperCase()} SEVERITY',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D2D2D),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Clause Section
            _buildSection(
              icon: Icons.article_outlined,
              title: 'Clause',
              content: risk.clauseText,
              color: const Color(0xFFE8D5FF),
            ),
            const SizedBox(height: 20),
            // Category Section
            _buildSection(
              icon: Icons.category_outlined,
              title: 'Category',
              content: risk.category,
              color: const Color(0xFFD5F3FF),
            ),
            const SizedBox(height: 20),
            // Plain Explanation Section
            _buildSection(
              icon: Icons.info_outlined,
              title: 'Plain Explanation',
              content: risk.plainExplanation,
              color: const Color(0xFFFFF5E5),
            ),
            const SizedBox(height: 20),
            // Worst Case Scenario Section
            _buildSection(
              icon: Icons.warning_amber_outlined,
              title: 'Worst Case Scenario',
              content: risk.worstCaseScenario,
              color: const Color(0xFFFFE5E5),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return const Color(0xFFFFB3B3);
      case 'medium':
        return const Color(0xFFFFD9B3);
      case 'low':
        return const Color(0xFFB3FFB3);
      default:
        return Colors.grey[300]!;
    }
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 24, color: const Color(0xFF6B4FA0)),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 15,
              height: 1.6,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
