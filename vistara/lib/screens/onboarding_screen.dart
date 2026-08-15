import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/vistara_theme.dart';
import 'main_navigation.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VistaraColors.lilacWhite,

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 18),

            // ─────────────────────────────────────────────
            // BRAND
            // ─────────────────────────────────────────────

            Text(
              'VISTARA',
              style: GoogleFonts.poppins(
                fontSize: 27,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: VistaraColors.ochreAmber,
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                ),

                child: Column(
                  children: [
                    // ─────────────────────────────────────────────
                    // ILLUSTRATION
                    // ─────────────────────────────────────────────

                    Expanded(
                      flex: 5,
                      child: Container(
                        margin: const EdgeInsets.only(
                          top: 20,
                          bottom: 18,
                        ),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: VistaraColors.lavenderGray
                                .withValues(alpha: 0.18),
                          ),
                        ),

                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(28),
                            child: SvgPicture.asset(
                              'assets/illustrations/onboarding.svg',
                              width: 240,
                              height: 240,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ─────────────────────────────────────────────
                    // HEADLINE
                    // ─────────────────────────────────────────────

                    Text(
                      'Understand before\nyou agree.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 29,
                        height: 1.15,
                        fontWeight: FontWeight.w700,
                        color: VistaraColors.plumCharcoal,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ─────────────────────────────────────────────
                    // DESCRIPTION
                    // ─────────────────────────────────────────────

                    Text(
                      'Vistara identifies potentially risky '
                          'terms, explains them in plain language, '
                          'and helps you understand what deserves '
                          'your attention.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        height: 1.5,
                        color: VistaraColors.mutedText,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─────────────────────────────────────────────
                    // GET STARTED BUTTON
                    // ─────────────────────────────────────────────

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const MainNavigation(),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Text(
                              'Get Started',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(width: 10),

                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 21,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ─────────────────────────────────────────────
                    // ACCOUNT NOTE
                    // ─────────────────────────────────────────────

                    Text(
                      'No account required',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: VistaraColors.mutedText,
                      ),
                    ),

                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),

            // ─────────────────────────────────────────────
            // DISCLAIMER
            // ─────────────────────────────────────────────

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE8E0E8),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 17,
                    color: VistaraColors.neutral,
                  ),

                  const SizedBox(width: 7),

                  Flexible(
                    child: Text(
                      'AI-powered risk analysis. Not legal advice.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: VistaraColors.neutral,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}