import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/contract_report.dart';
import '../services/storage_service.dart';
import '../theme/vistara_theme.dart';
import 'report_screen.dart';

class RecentDocumentsScreen extends StatefulWidget {
  const RecentDocumentsScreen({super.key});

  @override
  State<RecentDocumentsScreen> createState() =>
      _RecentDocumentsScreenState();
}

class _RecentDocumentsScreenState
    extends State<RecentDocumentsScreen> {
  final StorageService _storageService = StorageService();

  final TextEditingController _searchController =
  TextEditingController();

  String selectedFilter = 'All';

  List<RecentDocument> _documents = [];
  bool _isLoading = true;
  bool _usingMockData = false;

  // ===========================================================================
  // MOCK FALLBACK
  // ===========================================================================

  final List<RecentDocument> _mockDocuments = [
    RecentDocument(
      documentName: 'Apartment Lease',
      timestamp: DateTime.now(),
      report: ContractReport(
        filename: 'Apartment Lease.pdf',
        overallScore: 78,
        riskLevel: 'High',
        highRiskCount: 3,
        mediumRiskCount: 2,
        lowRiskCount: 1,
        flaggedClauses: [],
      ),
    ),
    RecentDocument(
      documentName: 'Freelance Agreement',
      timestamp: DateTime.now().subtract(
        const Duration(days: 1),
      ),
      report: ContractReport(
        filename: 'Freelance Agreement.pdf',
        overallScore: 62,
        riskLevel: 'Medium',
        highRiskCount: 1,
        mediumRiskCount: 3,
        lowRiskCount: 2,
        flaggedClauses: [],
      ),
    ),
    RecentDocument(
      documentName: 'Student Loan Agreement',
      timestamp: DateTime.now().subtract(
        const Duration(days: 4),
      ),
      report: ContractReport(
        filename: 'Student Loan Agreement.pdf',
        overallScore: 71,
        riskLevel: 'High',
        highRiskCount: 2,
        mediumRiskCount: 1,
        lowRiskCount: 1,
        flaggedClauses: [],
      ),
    ),
  ];

  // ===========================================================================
  // INIT
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {});
    });

    _loadDocuments();
  }

  // ===========================================================================
  // LOAD REAL DATA
  // ===========================================================================

  Future<void> _loadDocuments() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final documents =
      await _storageService.getRecentDocuments();

      if (!mounted) return;

      setState(() {
        if (documents.isNotEmpty) {
          // ---------------------------------------------------------------
          // REAL DATA
          // ---------------------------------------------------------------
          _documents = documents;
          _usingMockData = false;
        } else {
          // ---------------------------------------------------------------
          // MOCK FALLBACK
          // ---------------------------------------------------------------
          _documents = _mockDocuments;
          _usingMockData = true;
        }

        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'Recent documents loading failed: $e',
      );

      if (!mounted) return;

      // ---------------------------------------------------------------
      // MOCK FALLBACK IF STORAGE FAILS
      // ---------------------------------------------------------------

      setState(() {
        _documents = _mockDocuments;
        _usingMockData = true;
        _isLoading = false;
      });
    }
  }

  // ===========================================================================
  // FILTER + SEARCH
  // ===========================================================================

  List<RecentDocument> get _filteredDocuments {
    final searchQuery =
    _searchController.text.trim().toLowerCase();

    return _documents.where((document) {
      // ---------------------------------------------------------------
      // SEARCH
      // ---------------------------------------------------------------

      final matchesSearch =
      document.documentName.toLowerCase().contains(
        searchQuery,
      );

      if (!matchesSearch) {
        return false;
      }

      // ---------------------------------------------------------------
      // FILTER
      // ---------------------------------------------------------------

      if (selectedFilter == 'All') {
        return true;
      }

      final risk =
      document.report.riskLevel.toLowerCase();

      switch (selectedFilter) {
        case 'High Risk':
          return risk == 'high';

        case 'Medium Risk':
          return risk == 'medium';

        case 'Low Risk':
          return risk == 'low';

        default:
          return true;
      }
    }).toList();
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VistaraColors.lilacWhite,

      body: SafeArea(
        child: Column(
          children: [
            // =================================================================
            // HEADER
            // =================================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                18,
                20,
                8,
              ),
              child: Row(
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

                  const Spacer(),

                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: _loadDocuments,
                    icon: const Icon(
                      Icons.refresh_rounded,
                    ),
                    color: VistaraColors.plumCharcoal,
                  ),
                ],
              ),
            ),

            // =================================================================
            // TITLE
            // =================================================================

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Recent Documents',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color:
                        VistaraColors.plumCharcoal,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // =================================================================
            // SEARCH
            // =================================================================

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: VistaraColors.plumCharcoal,
                ),
                decoration: InputDecoration(
                  hintText: 'Search documents...',
                  hintStyle: GoogleFonts.poppins(
                    color: VistaraColors.neutral,
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: VistaraColors.mutedText,
                  ),
                  suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                    ),
                  )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                  const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: VistaraColors.lavenderGray
                          .withValues(alpha: .25),
                    ),
                  ),
                  enabledBorder:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: VistaraColors.lavenderGray
                          .withValues(alpha: .25),
                    ),
                  ),
                  focusedBorder:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: VistaraColors.ochreAmber
                          .withValues(alpha: .65),
                      width: 1.3,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // =================================================================
            // FILTERS
            // =================================================================

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Row(
                children: [
                  _filterChip('All'),
                  _filterChip('High Risk'),
                  _filterChip('Medium Risk'),
                  _filterChip('Low Risk'),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // =================================================================
            // DOCUMENT LIST
            // =================================================================

            Expanded(
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color:
                  VistaraColors.ochreAmber,
                ),
              )
                  : _filteredDocuments.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                color:
                VistaraColors.ochreAmber,
                onRefresh:
                _loadDocuments,
                child: ListView.separated(
                  padding:
                  const EdgeInsets.fromLTRB(
                    20,
                    4,
                    20,
                    24,
                  ),
                  itemCount:
                  _filteredDocuments.length,
                  separatorBuilder:
                      (_, __) =>
                  const SizedBox(
                    height: 12,
                  ),
                  itemBuilder:
                      (context, index) {
                    final document =
                    _filteredDocuments[
                    index];

                    return _documentCard(
                      document,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // FILTER CHIP
  // ===========================================================================

  Widget _filterChip(String label) {
    final selected =
        selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.only(
        right: 8,
      ),
      child: ChoiceChip(
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: selected
                ? FontWeight.w600
                : FontWeight.w500,
            color: selected
                ? VistaraColors.plumCharcoal
                : VistaraColors.mutedText,
          ),
        ),
        selected: selected,
        onSelected: (_) {
          setState(() {
            selectedFilter = label;
          });
        },
        selectedColor:
        VistaraColors.ochreAmber
            .withValues(alpha: .22),
        backgroundColor: Colors.white,
        side: BorderSide(
          color: selected
              ? VistaraColors.ochreAmber
              .withValues(alpha: .45)
              : VistaraColors.lavenderGray
              .withValues(alpha: .25),
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(20),
        ),
      ),
    );
  }

  // ===========================================================================
  // DOCUMENT CARD
  // ===========================================================================

  Widget _documentCard(
      RecentDocument document,
      ) {
    final report = document.report;

    final risk =
    _formatRisk(report.riskLevel);

    final score = report.overallScore;

    return Material(
      color: Colors.white,
      borderRadius:
      BorderRadius.circular(18),
      child: InkWell(
        borderRadius:
        BorderRadius.circular(18),
        onTap: () {
          _openReport(document);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ===============================================================
              // TOP ROW
              // ===============================================================

              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: VistaraColors
                          .ochreAmber
                          .withValues(alpha: .12),
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color:
                      VistaraColors.ochreAmber,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          document.documentName,
                          maxLines: 1,
                          overflow:
                          TextOverflow.ellipsis,
                          style:
                          GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight:
                            FontWeight.w600,
                            color: VistaraColors
                                .plumCharcoal,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          document.formattedDate,
                          style:
                          GoogleFonts.poppins(
                            fontSize: 11,
                            color:
                            VistaraColors.neutral,
                          ),
                        ),
                      ],
                    ),
                  ),

                  _riskBadge(risk),
                ],
              ),

              const SizedBox(height: 16),

              // ===============================================================
              // SCORE
              // ===============================================================

              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                      BorderRadius.circular(
                        10,
                      ),
                      child:
                      LinearProgressIndicator(
                        value:
                        (score.clamp(0, 100)) /
                            100,
                        minHeight: 6,
                        backgroundColor:
                        VistaraColors
                            .lavenderGray
                            .withValues(
                          alpha: .22,
                        ),
                        valueColor:
                        AlwaysStoppedAnimation<
                            Color>(
                          VistaraColors.riskColor(
                            risk,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Text(
                    '$score/100',
                    style:
                    GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight:
                      FontWeight.w600,
                      color: VistaraColors
                          .plumCharcoal,
                    ),
                  ),

                  const SizedBox(width: 4),

                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color:
                    VistaraColors.neutral,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ===============================================================
              // RISK COUNTS
              // ===============================================================

              Row(
                children: [
                  _riskCount(
                    'High',
                    report.highRiskCount,
                    VistaraColors.highRisk,
                  ),

                  const SizedBox(width: 8),

                  _riskCount(
                    'Medium',
                    report.mediumRiskCount,
                    VistaraColors.mediumRisk,
                  ),

                  const SizedBox(width: 8),

                  _riskCount(
                    'Low',
                    report.lowRiskCount,
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

  // ===========================================================================
  // RISK COUNT
  // ===========================================================================

  Widget _riskCount(
      String label,
      int count,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: .08,
        ),
        borderRadius:
        BorderRadius.circular(10),
      ),
      child: Text(
        '$count $label',
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // ===========================================================================
  // RISK BADGE
  // ===========================================================================

  Widget _riskBadge(String risk) {
    final color =
    VistaraColors.riskColor(risk);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: .14,
        ),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Text(
        risk,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // ===========================================================================
  // EMPTY STATE
  // ===========================================================================

  Widget _buildEmptyState() {
    final isSearching =
        _searchController.text.trim().isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: VistaraColors
                    .lavenderGray
                    .withValues(alpha: .16),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.description_outlined,
                size: 34,
                color: VistaraColors.neutral,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              isSearching
                  ? 'No documents found'
                  : 'No documents in this category',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color:
                VistaraColors.plumCharcoal,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              isSearching
                  ? 'Try a different document name.'
                  : 'Analyze a document to see it here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                height: 1.5,
                color:
                VistaraColors.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // OPEN REPORT
  // ===========================================================================

  void _openReport(
      RecentDocument document,
      ) {
    if (_usingMockData) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'This is demo data. Analyze a real document to open its report.',
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportScreen(
          report: document.report,
        ),
      ),
    );
  }

  // ===========================================================================
  // FORMAT RISK
  // ===========================================================================

  String _formatRisk(String risk) {
    final normalized =
    risk.trim().toLowerCase();

    switch (normalized) {
      case 'high':
        return 'High Risk';

      case 'medium':
        return 'Medium Risk';

      case 'low':
        return 'Low Risk';

      default:
        return risk;
    }
  }

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}