import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/contract_report.dart';
import '../theme/vistara_theme.dart';

class RiskDetailScreen extends StatelessWidget {
  final ClauseRisk risk;
  final int? pageNumber;

  const RiskDetailScreen({
    super.key,
    required this.risk,
    this.pageNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VistaraColors.lilacWhite,

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            Expanded(
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  28,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    _buildRiskHeader(),

                    const SizedBox(height: 24),

                    _sectionTitle(
                      'Original Clause',
                    ),

                    const SizedBox(height: 10),

                    _buildOriginalClause(),

                    const SizedBox(height: 26),

                    _sectionTitle(
                      'What does this mean?',
                    ),

                    const SizedBox(height: 9),

                    Text(
                      risk.plainExplanation,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        height: 1.65,
                        color:
                        VistaraColors.bodyText,
                      ),
                    ),

                    const SizedBox(height: 26),

                    _sectionTitle(
                      'Why is it risky?',
                    ),

                    const SizedBox(height: 12),

                    _buildRiskReason(
                      icon:
                      Icons.warning_amber_rounded,
                      title:
                      _riskReasonTitle(),
                      description:
                      _riskReasonDescription(),
                    ),

                    const SizedBox(height: 20),

                    _buildConfidence(),

                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showScenario(context);
                        },
                        icon: const Icon(
                          Icons.auto_awesome_outlined,
                          size: 19,
                        ),
                        label: Text(
                          'See What Could Happen',
                          style:
                          GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          VistaraColors
                              .ochreAmber,
                          foregroundColor:
                          Colors.white,
                          elevation: 0,
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                              14,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      'AI-generated educational analysis — not legal advice.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color:
                        VistaraColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar:
      _buildBottomNavigation(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        18,
        10,
        18,
        10,
      ),
      decoration: BoxDecoration(
        color: VistaraColors.lilacWhite,
        border: Border(
          bottom: BorderSide(
            color: VistaraColors.lavenderGray
                .withValues(alpha: 0.18),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () =>
                Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_rounded,
            ),
          ),

          Expanded(
            child: Text(
              'Clause Review',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color:
                VistaraColors.plumCharcoal,
              ),
            ),
          ),

          Text(
            'VISTARA',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: VistaraColors.ochreAmber,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskHeader() {
    final color = _riskColor();

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: color.withValues(
                  alpha: 0.12,
                ),
                borderRadius:
                BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 14,
                    color: color,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${risk.severity.toUpperCase()} RISK',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight:
                      FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            if (pageNumber != null)
              Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 16,
                    color:
                    VistaraColors.mutedText,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Page $pageNumber',
                    style:
                    GoogleFonts.poppins(
                      fontSize: 11,
                      color:
                      VistaraColors.mutedText,
                    ),
                  ),
                ],
              ),
          ],
        ),

        const SizedBox(height: 14),

        Text(
          risk.category,
          style: GoogleFonts.poppins(
            fontSize: 27,
            fontWeight: FontWeight.w700,
            color:
            VistaraColors.plumCharcoal,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 19,
        fontWeight: FontWeight.w600,
        color: VistaraColors.plumCharcoal,
      ),
    );
  }

  Widget _buildOriginalClause() {
    final color = _riskColor();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        18,
        17,
        18,
        17,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(15),
        border: Border(
          left: BorderSide(
            color: color,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.025,
            ),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        '"${risk.clauseText}"',
        style: GoogleFonts.poppins(
          fontSize: 13,
          height: 1.65,
          fontStyle: FontStyle.italic,
          color: VistaraColors.bodyText,
        ),
      ),
    );
  }

  Widget _buildRiskReason({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(15),
        border: Border.all(
          color: VistaraColors.lavenderGray
              .withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD8D5),
              borderRadius:
              BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFC62828),
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                  GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight:
                    FontWeight.w600,
                    color: VistaraColors
                        .plumCharcoal,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style:
                  GoogleFonts.poppins(
                    fontSize: 12,
                    height: 1.45,
                    color: VistaraColors
                        .mutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidence() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: VistaraColors.softLavender
            .withValues(alpha: 0.55),
        borderRadius:
        BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            Icons.verified_outlined,
            size: 20,
            color: VistaraColors.ochreAmber,
          ),

          const SizedBox(width: 10),

          Text(
            'AI Analysis',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color:
              VistaraColors.plumCharcoal,
            ),
          ),

          const Spacer(),

          Text(
            'High confidence',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color:
              VistaraColors.ochreAmber,
            ),
          ),
        ],
      ),
    );
  }

  void _showScenario(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          constraints:
          const BoxConstraints(
            maxHeight: 620,
          ),
          decoration: BoxDecoration(
            color: VistaraColors.lilacWhite,
            borderRadius:
            const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                22,
                12,
                22,
                24,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: VistaraColors
                            .lavenderGray,
                        borderRadius:
                        BorderRadius.circular(5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'What could happen?',
                          style:
                          GoogleFonts.poppins(
                            fontSize: 25,
                            fontWeight:
                            FontWeight.w700,
                            color: VistaraColors
                                .plumCharcoal,
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: () =>
                            Navigator.pop(context),
                        icon: const Icon(
                          Icons.close_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  _scenarioStep(
                    number: 'STEP 1',
                    icon:
                    Icons.description_outlined,
                    title: 'Contract condition',
                    text:
                    'The agreement contains the flagged term described above.',
                  ),

                  _scenarioArrow(),

                  _scenarioStep(
                    number: 'STEP 2',
                    icon:
                    Icons.notifications_none_rounded,
                    title: 'What you need to notice',
                    text:
                    risk.plainExplanation,
                  ),

                  _scenarioArrow(),

                  _scenarioStep(
                    number: 'OUTCOME',
                    icon:
                    Icons.gavel_outlined,
                    title: 'Possible consequence',
                    text:
                    risk.worstCaseScenario,
                  ),

                  const SizedBox(height: 22),

                  Container(
                    width: double.infinity,
                    padding:
                    const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(13),
                      border: Border.all(
                        color: VistaraColors
                            .lavenderGray
                            .withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color:
                          VistaraColors.mutedText,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            'Illustrative scenario based on the analyzed clause. This is not a prediction or legal conclusion.',
                            style:
                            GoogleFonts.poppins(
                              fontSize: 10,
                              height: 1.45,
                              color: VistaraColors
                                  .mutedText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _scenarioStep({
    required String number,
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.circular(13),
            border: Border.all(
              color: VistaraColors
                  .lavenderGray
                  .withValues(alpha: 0.35),
            ),
          ),
          child: Icon(
            icon,
            color: VistaraColors.ochreAmber,
            size: 21,
          ),
        ),

        const SizedBox(width: 13),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                number,
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                  color:
                  VistaraColors.mutedText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight:
                  FontWeight.w600,
                  color:
                  VistaraColors.plumCharcoal,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  height: 1.5,
                  color:
                  VistaraColors.bodyText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _scenarioArrow() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20,
        top: 8,
        bottom: 8,
      ),
      child: Icon(
        Icons.arrow_downward_rounded,
        size: 20,
        color: VistaraColors.lavenderGray,
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: VistaraColors.lavenderGray
                .withValues(alpha: 0.2),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              _navItem(
                Icons.home_outlined,
                'Home',
              ),
              _navItem(
                Icons.document_scanner_outlined,
                'Analyze',
              ),
              _navItem(
                Icons.history_rounded,
                'Recent',
              ),
              _navItem(
                Icons.bar_chart_outlined,
                'Reports',
              ),
              _navItem(
                Icons.settings_outlined,
                'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
      IconData icon,
      String label,
      ) {
    return Expanded(
      child: InkWell(
        onTap: () {},
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 21,
              color: VistaraColors.mutedText,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: VistaraColors.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _riskColor() {
    switch (risk.severity.toLowerCase()) {
      case 'high':
        return const Color(0xFFC62828);
      case 'medium':
        return const Color(0xFFD99532);
      case 'low':
        return const Color(0xFF817866);
      default:
        return VistaraColors.ochreAmber;
    }
  }

  String _riskReasonTitle() {
    switch (risk.category.toLowerCase()) {
      case 'automatic renewal':
        return 'Automatic obligation';
      case 'liability':
        return 'Potential liability exposure';
      default:
        return risk.category;
    }
  }

  String _riskReasonDescription() {
    switch (risk.category.toLowerCase()) {
      case 'automatic renewal':
        return 'This clause can create an obligation if the required action is missed.';
      case 'liability':
        return 'This term may place responsibilities or costs on you that deserve careful review.';
      default:
        return 'This clause contains terms that may create additional risk or obligations.';
    }
  }
}