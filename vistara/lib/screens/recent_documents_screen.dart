import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/vistara_theme.dart';

class RecentDocumentsScreen extends StatefulWidget {
  const RecentDocumentsScreen({super.key});

  @override
  State<RecentDocumentsScreen> createState() =>
      _RecentDocumentsScreenState();
}

class _RecentDocumentsScreenState
    extends State<RecentDocumentsScreen> {
  String selectedFilter = 'All';

  final List<Map<String, dynamic>> documents = [
    {
      'name': 'Apartment Lease',
      'date': 'Today',
      'risk': 'High Risk',
      'score': 78,
    },
    {
      'name': 'Freelance Agreement',
      'date': 'Yesterday',
      'risk': 'Medium Risk',
      'score': 62,
    },
    {
      'name': 'Student Loan Agreement',
      'date': 'Aug 10',
      'risk': 'High Risk',
      'score': 71,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VistaraColors.lilacWhite,

      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
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
                ],
              ),
            ),

            // TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Recent Documents',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: VistaraColors.plumCharcoal,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // SEARCH
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search documents...',
                  hintStyle: GoogleFonts.poppins(
                    color: VistaraColors.neutral,
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: VistaraColors.mutedText,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: VistaraColors.lavenderGray
                          .withValues(alpha: .25),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: VistaraColors.lavenderGray
                          .withValues(alpha: .25),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // FILTERS
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
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

            // DOCUMENT LIST
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                itemCount: documents.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final document = documents[index];

                  return _documentCard(document);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label) {
    final selected = selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
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
        selectedColor: VistaraColors.ochreAmber
            .withValues(alpha: .22),
        backgroundColor: Colors.white,
        side: BorderSide(
          color: VistaraColors.lavenderGray
              .withValues(alpha: .25),
        ),
      ),
    );
  }

  Widget _documentCard(Map<String, dynamic> document) {
    final String risk = document['risk'];
    final int score = document['score'];

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          // Later connect this to the saved ContractReport.
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: VistaraColors.ochreAmber
                          .withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(12),
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
                          document['name'],
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color:
                            VistaraColors.plumCharcoal,
                          ),
                        ),
                        Text(
                          document['date'],
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: VistaraColors.neutral,
                          ),
                        ),
                      ],
                    ),
                  ),

                  _riskBadge(risk),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                      BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: score / 100,
                        minHeight: 6,
                        backgroundColor:
                        VistaraColors.lavenderGray
                            .withValues(alpha: .22),
                        valueColor:
                        AlwaysStoppedAnimation<Color>(
                          VistaraColors.riskColor(risk),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Text(
                    '$score/100',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: VistaraColors.plumCharcoal,
                    ),
                  ),

                  const SizedBox(width: 4),

                  const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: VistaraColors.neutral,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _riskBadge(String risk) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: VistaraColors.riskColor(risk)
            .withValues(alpha: .14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        risk,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: VistaraColors.riskColor(risk),
        ),
      ),
    );
  }
}