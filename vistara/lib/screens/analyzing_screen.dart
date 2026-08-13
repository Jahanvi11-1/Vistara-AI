import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnalyzingScreen extends StatelessWidget {
  const AnalyzingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FF), // Pastel blue background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const CircularProgressIndicator(
                strokeWidth: 3,
                color: Color(0xFF6B4FA0),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Analyzing Contract...',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This may take a few moments',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
