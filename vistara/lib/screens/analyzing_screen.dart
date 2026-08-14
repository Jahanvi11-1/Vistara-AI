import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/vistara_theme.dart';

class AnalyzingScreen extends StatelessWidget {
  const AnalyzingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      VistaraColors.lilacWhite,

      body: SafeArea(
        child: Center(
          child: Padding(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 48,
            ),

            child: Container(
              width: double.infinity,

              padding:
              const EdgeInsets.fromLTRB(
                28,
                46,
                28,
                34,
              ),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius:
                BorderRadius.circular(28),

                border: Border.all(
                  color: VistaraColors
                      .lavenderGray
                      .withValues(
                    alpha: 0.22,
                  ),
                ),

                boxShadow: [
                  BoxShadow(
                    color: VistaraColors
                        .plumCharcoal
                        .withValues(
                      alpha: 0.05,
                    ),
                    blurRadius: 25,
                    offset:
                    const Offset(0, 10),
                  ),
                ],
              ),

              child: Column(
                children: [
                  SizedBox(
                    width: 115,
                    height: 115,
                    child: Stack(
                      alignment:
                      Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor:
                          const AlwaysStoppedAnimation(
                            VistaraColors
                                .ochreAmber,
                          ),
                          backgroundColor:
                          VistaraColors
                              .lavenderGray
                              .withValues(
                            alpha: 0.22,
                          ),
                        ),

                        Container(
                          width: 42,
                          height: 42,
                          decoration:
                          BoxDecoration(
                            color: VistaraColors
                                .ochreAmber
                                .withValues(
                              alpha: 0.12,
                            ),
                            shape:
                            BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons
                                .description_outlined,
                            color:
                            VistaraColors
                                .ochreAmber,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 42),

                  Text(
                    'Analyzing your\ndocument',
                    textAlign:
                    TextAlign.center,
                    style:
                    GoogleFonts.poppins(
                      fontSize: 30,
                      height: 1.18,
                      fontWeight:
                      FontWeight.w700,
                      color:
                      VistaraColors
                          .plumCharcoal,
                    ),
                  ),

                  const SizedBox(height: 42),

                  _step(
                    'Reading document',
                    true,
                  ),

                  const SizedBox(height: 22),

                  _step(
                    'Identifying clauses',
                    true,
                  ),

                  const SizedBox(height: 22),

                  _step(
                    'Evaluating potential risks',
                    true,
                    active: true,
                  ),

                  const SizedBox(height: 22),

                  _step(
                    'Preparing explanations',
                    false,
                  ),

                  const SizedBox(height: 40),

                  Divider(
                    color: VistaraColors
                        .lavenderGray
                        .withValues(
                      alpha: 0.25,
                    ),
                  ),

                  const SizedBox(height: 28),

                  Text(
                    'ANALYZING YOUR CONTRACT',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      letterSpacing: 1.5,
                      fontWeight:
                      FontWeight.w700,
                      color:
                      VistaraColors
                          .plumCharcoal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _step(
      String text,
      bool completed, {
        bool active = false,
      }) {
    final color = completed || active
        ? VistaraColors.ochreAmber
        : VistaraColors.neutral;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: active
                  ? 2
                  : 0,
            ),
            color: completed && !active
                ? VistaraColors
                .ochreAmber
                : Colors.transparent,
          ),
          child: completed && !active
              ? const Icon(
            Icons.check_rounded,
            size: 23,
            color: Colors.white,
          )
              : Center(
            child: Container(
              width: active
                  ? 11
                  : 8,
              height: active
                  ? 11
                  : 8,
              decoration:
              BoxDecoration(
                color: color,
                shape:
                BoxShape.circle,
              ),
            ),
          ),
        ),

        const SizedBox(width: 18),

        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: active
                  ? FontWeight.w600
                  : FontWeight.w400,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}