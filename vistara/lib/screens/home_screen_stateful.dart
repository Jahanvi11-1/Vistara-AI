import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/vistara_theme.dart';
import 'analyze_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      VistaraColors.lilacWhite,

      appBar: AppBar(
        backgroundColor:
        VistaraColors.lilacWhite,
        elevation: 0,

        titleSpacing: 20,

        title: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              'VISTARA',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight:
                FontWeight.w700,
                letterSpacing: 1.5,
                color:
                VistaraColors
                    .ochreAmber,
              ),
            ),

            Text(
              'Understand before you agree.',
              style: GoogleFonts.poppins(
                fontSize: 10,
                color:
                VistaraColors
                    .mutedText,
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics:
          const BouncingScrollPhysics(),

          padding:
          const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            30,
          ),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              // ======================================================
              // HERO
              // ======================================================

              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.all(24),

                decoration:
                BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(
                    24,
                  ),
                  border: Border.all(
                    color: VistaraColors
                        .lavenderGray
                        .withValues(
                      alpha: 0.20,
                    ),
                  ),
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration:
                      BoxDecoration(
                        color: VistaraColors
                            .ochreAmber
                            .withValues(
                          alpha: 0.13,
                        ),
                        borderRadius:
                        BorderRadius
                            .circular(
                          14,
                        ),
                      ),
                      child: const Icon(
                        Icons
                            .description_outlined,
                        color:
                        VistaraColors
                            .ochreAmber,
                        size: 25,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Review your\ncontract with confidence.',
                      style:
                      GoogleFonts.poppins(
                        fontSize: 25,
                        height: 1.18,
                        fontWeight:
                        FontWeight.w700,
                        color:
                        VistaraColors
                            .plumCharcoal,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Vistara finds potentially risky clauses and explains them in plain language.',
                      style:
                      GoogleFonts.poppins(
                        fontSize: 12,
                        height: 1.5,
                        color:
                        VistaraColors
                            .mutedText,
                      ),
                    ),

                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AnalyzeScreen(),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                          children: [
                            const Icon(
                              Icons
                                  .auto_awesome_rounded,
                              size: 18,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              'Getting started',
                              style: GoogleFonts
                                  .poppins(
                                fontSize: 13,
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ======================================================
              // HOW IT WORKS
              // ======================================================

              Text(
                'How Vistara works',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight:
                  FontWeight.w700,
                  color:
                  VistaraColors
                      .plumCharcoal,
                ),
              ),

              const SizedBox(height: 12),

              _InfoCard(
                number: '01',
                icon: Icons.upload_file_outlined,
                title: 'Upload your contract',
                description:
                'Upload a PDF or paste your contract text.',
              ),

              const SizedBox(height: 10),

              _InfoCard(
                number: '02',
                icon: Icons.search_rounded,
                title: 'Vistara identifies risks',
                description:
                'Potentially risky clauses are detected and categorized.',
              ),

              const SizedBox(height: 10),

              _InfoCard(
                number: '03',
                icon: Icons.lightbulb_outline_rounded,
                title: 'Understand before signing',
                description:
                'Get plain-language explanations and possible scenarios.',
              ),

              const SizedBox(height: 24),

              // ======================================================
              // DISCLAIMER
              // ======================================================

              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.all(15),

                decoration: BoxDecoration(
                  color: VistaraColors
                      .ochreAmber
                      .withValues(
                    alpha: 0.08,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    16,
                  ),
                ),

                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons
                          .info_outline_rounded,
                      size: 18,
                      color:
                      VistaraColors
                          .ochreAmber,
                    ),

                    const SizedBox(width: 9),

                    Expanded(
                      child: Text(
                        'Vistara provides AI-powered contract risk analysis for awareness and is not a substitute for legal advice.',
                        style: GoogleFonts
                            .poppins(
                          fontSize: 9.5,
                          height: 1.45,
                          color:
                          VistaraColors
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

      // IMPORTANT:
      // Home is normally displayed inside MainNavigation,
      // so MainNavigation supplies the bottom bar.
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String number;
  final IconData icon;
  final String title;
  final String description;

  const _InfoCard({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: VistaraColors
              .lavenderGray
              .withValues(
            alpha: 0.18,
          ),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: VistaraColors
                  .ochreAmber
                  .withValues(
                alpha: 0.11,
              ),
              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),
            child: Icon(
              icon,
              color:
              VistaraColors
                  .ochreAmber,
              size: 21,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      number,
                      style:
                      GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight:
                        FontWeight.w700,
                        color:
                        VistaraColors
                            .ochreAmber,
                      ),
                    ),

                    const SizedBox(width: 7),

                    Expanded(
                      child: Text(
                        title,
                        style:
                        GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight:
                          FontWeight.w600,
                          color:
                          VistaraColors
                              .plumCharcoal,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 3),

                Text(
                  description,
                  style:
                  GoogleFonts.poppins(
                    fontSize: 10,
                    height: 1.4,
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
    );
  }
}