import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdfrx/pdfrx.dart';

import '../models/contract_report.dart';
import '../theme/vistara_theme.dart';
import 'risk_detail_screen.dart';

class DocumentViewerScreen extends StatefulWidget {
  final Uint8List fileBytes;
  final String filename;
  final ContractReport report;

  const DocumentViewerScreen({
    super.key,
    required this.fileBytes,
    required this.filename,
    required this.report,
  });

  @override
  State<DocumentViewerScreen> createState() =>
      _DocumentViewerScreenState();
}

class _DocumentViewerScreenState
    extends State<DocumentViewerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VistaraColors.lilacWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: Stack(
                children: [
                  // ---------------------------------------------------------
                  // ACTUAL USER PDF
                  // ---------------------------------------------------------
                  Container(
                    color: const Color(0xFFECE8ED),
                    child: PdfViewer.data(
                      widget.fileBytes,
                      sourceName: widget.filename,
                      params: const PdfViewerParams(
                        margin: 12,
                      ),
                    ),
                  ),

                  // ---------------------------------------------------------
                  // RISK LEGEND
                  // ---------------------------------------------------------
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 18,
                    child: _buildRiskLegend(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // HEADER
  // =========================================================================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        8,
        8,
        8,
        10,
      ),
      decoration: BoxDecoration(
        color: VistaraColors.lilacWhite,
        border: Border(
          bottom: BorderSide(
            color: VistaraColors.lavenderGray
                .withValues(alpha: 0.20),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
            ),
            color: VistaraColors.plumCharcoal,
          ),

          const SizedBox(width: 4),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  _displayFilename(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color:
                    VistaraColors.plumCharcoal,
                  ),
                ),

                const SizedBox(height: 1),

                Text(
                  'Document Viewer',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color:
                    VistaraColors.mutedText,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              // Search can be added later.
            },
            icon: const Icon(
              Icons.search_rounded,
            ),
            color: VistaraColors.plumCharcoal,
          ),

          IconButton(
            onPressed: _showOptions,
            icon: const Icon(
              Icons.more_vert_rounded,
            ),
            color: VistaraColors.plumCharcoal,
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // RISK LEGEND
  // =========================================================================

  Widget _buildRiskLegend() {
    final report = widget.report;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 28,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF0ECF1),
          borderRadius:
          BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.12,
              ),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _riskItem(
              report.highRiskCount,
              'High',
              VistaraColors.highRisk,
            ),

            _divider(),

            _riskItem(
              report.mediumRiskCount,
              'Medium',
              VistaraColors.mediumRisk,
            ),

            _divider(),

            _riskItem(
              report.lowRiskCount,
              'Low',
              VistaraColors.lowRisk,
            ),
          ],
        ),
      ),
    );
  }

  Widget _riskItem(
      int count,
      String label,
      Color color,
      ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 7),

        Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              '$count',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color:
                VistaraColors.plumCharcoal,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color:
                VistaraColors.plumCharcoal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(
        horizontal: 13,
      ),
      color: VistaraColors.lavenderGray
          .withValues(alpha: 0.55),
    );
  }

  // =========================================================================
  // OPTIONS
  // =========================================================================

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),

              ListTile(
                leading: const Icon(
                  Icons.description_outlined,
                ),
                title: Text(
                  widget.filename,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              ListTile(
                leading: const Icon(
                  Icons.close_rounded,
                ),
                title: const Text('Close viewer'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  String _displayFilename() {
    final name = widget.filename;

    if (name.toLowerCase().endsWith('.pdf')) {
      return name.substring(
        0,
        name.length - 4,
      );
    }

    return name;
  }
}