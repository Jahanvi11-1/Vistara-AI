

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/contract_report.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../theme/vistara_theme.dart';

import 'document_viewer_screen.dart';
import 'analyzing_screen.dart';
import 'report_screen.dart';

class AnalyzeScreen extends StatefulWidget {
  const AnalyzeScreen({super.key});

  @override
  State<AnalyzeScreen> createState() =>
      _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  final TextEditingController _textController =
  TextEditingController();

  PlatformFile? _selectedFile;

  bool _isLoading = false;

  final ApiService _apiService = ApiService();

  final StorageService _storageService =
  StorageService();

  // ===========================================================================
  // PICK PDF
  // ===========================================================================

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null &&
        result.files.single.bytes != null) {
      setState(() {
        _selectedFile = result.files.single;
      });
    }
  }

  // ===========================================================================
  // LOCAL PDF TEST
  // ===========================================================================

  Future<void> _openLocalPdf() async {
    try {
      final byteData =
      await DefaultAssetBundle.of(context)
          .load(
        'assets/test/contract3.pdf',
      );

      final bytes =
      byteData.buffer.asUint8List();

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DocumentViewerScreen(
            fileBytes: bytes,
            filename: 'contract3.pdf',
            report: ContractReport(
              filename: 'contract3.pdf',
              overallScore: 70,
              riskLevel: 'Medium',
              highRiskCount: 1,
              mediumRiskCount: 1,
              lowRiskCount: 1,

              flaggedClauses: [
                ClauseRisk(
                  clauseText:
                  'The Tenant acknowledges that the property is accepted in its current condition and agrees that the Landlord shall have no responsibility for defects, damages, or conditions existing before or during the tenancy unless the Landlord expressly agrees otherwise in writing.',
                  severity: 'High',
                  category: 'Liability / Landlord Exemption',
                  plainExplanation:
                  'The tenant accepts the property as-is and releases the landlord from fixing defects.',
                  worstCaseScenario:
                  'The tenant could become responsible for expensive structural repairs.',
                ),

                ClauseRisk(
                  clauseText:
                  'Unless the Tenant provides written notice at least 120 days before the expiration date, this Agreement shall automatically renew for another twelve-month period.',
                  severity: 'Medium',
                  category: 'Automatic Renewal',
                  plainExplanation:
                  'The agreement automatically renews unless the tenant gives notice four months before expiry.',
                  worstCaseScenario:
                  'Missing the notice deadline could lock the tenant into another twelve-month term.',
                ),

                ClauseRisk(
                  clauseText:
                  'The Tenant shall pay monthly rent of ₹35,000 on or before the first day of each calendar month.',
                  severity: 'Low',
                  category: 'Rent Payment',
                  plainExplanation:
                  'The tenant must pay the monthly rent by the first day of each month.',
                  worstCaseScenario:
                  'A missed payment deadline could result in late fees under the agreement.',
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint(
        'Local PDF error: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Could not open local PDF: $e',
          ),
        ),
      );
    }
  }

  // ===========================================================================
  // ANALYZE CONTRACT
  // ===========================================================================

  Future<void> _analyzeContract() async {
    if (_selectedFile == null &&
        _textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please upload a PDF or enter contract text.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // -----------------------------------------------------------------------
      // SHOW ANALYZING SCREEN
      // -----------------------------------------------------------------------

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
          const AnalyzingScreen(),
        ),
      );

      // -----------------------------------------------------------------------
      // SEND TO BACKEND
      // -----------------------------------------------------------------------

      final jsonData =
      await _apiService.analyzeContract(
        fileBytes:
        _selectedFile?.bytes,
        filename:
        _selectedFile?.name,
        text:
        _textController.text
            .trim()
            .isNotEmpty
            ? _textController.text
            .trim()
            : null,
        isMock: false,
      );

      // -----------------------------------------------------------------------
      // CREATE REPORT
      // -----------------------------------------------------------------------

      final report =
      ContractReport.fromJson(
        jsonData,
      );

      // -----------------------------------------------------------------------
      // SAVE REPORT
      // -----------------------------------------------------------------------

      final documentName =
          _selectedFile?.name ??
              'Text Analysis';

      await _storageService.saveReport(
        report,
        documentName,
      );

      if (!mounted) return;

      // -----------------------------------------------------------------------
      // CLOSE ANALYZING SCREEN
      // -----------------------------------------------------------------------

      Navigator.pop(context);

      // -----------------------------------------------------------------------
      // PDF → DOCUMENT VIEWER
      // TEXT → REPORT SCREEN
      // -----------------------------------------------------------------------

      if (_selectedFile?.bytes != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                DocumentViewerScreen(
                  fileBytes:
                  _selectedFile!.bytes!,
                  filename:
                  _selectedFile!.name,
                  report: report,
                ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ReportScreen(
                  report: report,
                ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      // Close analyzing screen if it is open.
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Unable to analyze document.\n$e',
          ),
          backgroundColor:
          VistaraColors.highRisk,
          duration:
          const Duration(seconds: 6),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      VistaraColors.lilacWhite,

      appBar: AppBar(
        title: Text(
          'Analyze Contract',
          style:
          GoogleFonts.poppins(
            fontSize: 19,
            fontWeight:
            FontWeight.w700,
          ),
        ),
      ),

      body: SingleChildScrollView(
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
            // =================================================================
            // TITLE
            // =================================================================

            Text(
              'Analyze your document',
              style:
              GoogleFonts.poppins(
                fontSize: 25,
                fontWeight:
                FontWeight.w700,
                color: VistaraColors
                    .plumCharcoal,
              ),
            ),

            const SizedBox(
              height: 7,
            ),

            Text(
              'Upload a contract or paste its text to identify clauses that may deserve attention.',
              style:
              GoogleFonts.poppins(
                fontSize: 12,
                height: 1.5,
                color: VistaraColors
                    .mutedText,
              ),
            ),

            const SizedBox(
              height: 22,
            ),

            // =================================================================
            // PDF UPLOAD
            // =================================================================

            Text(
              'Upload Document',
              style:
              GoogleFonts.poppins(
                fontSize: 15,
                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            InkWell(
              onTap: _pickFile,
              borderRadius:
              BorderRadius.circular(
                18,
              ),

              child: Container(
                width:
                double.infinity,

                padding:
                const EdgeInsets.all(
                  22,
                ),

                decoration:
                BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(
                    18,
                  ),
                  border: Border.all(
                    color: VistaraColors
                        .lavenderGray
                        .withValues(
                      alpha: 0.25,
                    ),
                  ),
                ),

                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,

                      decoration:
                      BoxDecoration(
                        color:
                        VistaraColors
                            .ochreAmber
                            .withValues(
                          alpha: 0.14,
                        ),
                        borderRadius:
                        BorderRadius
                            .circular(
                          15,
                        ),
                      ),

                      child: Icon(
                        _selectedFile != null
                            ? Icons
                            .check_rounded
                            : Icons
                            .upload_file_rounded,
                        color:
                        VistaraColors
                            .ochreAmber,
                        size: 27,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    Text(
                      _selectedFile != null
                          ? _selectedFile!
                          .name
                          : 'Tap to upload PDF',

                      textAlign:
                      TextAlign.center,

                      style:
                      GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight:
                        FontWeight.w600,
                        color:
                        VistaraColors
                            .plumCharcoal,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      _selectedFile != null
                          ? 'PDF selected'
                          : 'PDF documents only',

                      style:
                      GoogleFonts.poppins(
                        fontSize: 10,
                        color:
                        VistaraColors
                            .mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            // =================================================================
            // TEXT INPUT
            // =================================================================

            Text(
              'Or paste contract text',
              style:
              GoogleFonts.poppins(
                fontSize: 15,
                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            TextField(
              controller:
              _textController,
              maxLines: 9,

              style:
              GoogleFonts.poppins(
                fontSize: 12,
                color: VistaraColors
                    .plumCharcoal,
              ),

              decoration:
              const InputDecoration(
                hintText:
                'Paste your contract text here...',
                alignLabelWithHint:
                true,
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            // =================================================================
            // ANALYZE BUTTON
            // =================================================================

            SizedBox(
              width:
              double.infinity,
              height: 55,

              child:
              ElevatedButton(
                onPressed:
                _isLoading
                    ? null
                    : _analyzeContract,

                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .center,

                  children: [
                    const Icon(
                      Icons
                          .auto_awesome_rounded,
                      size: 19,
                    ),

                    const SizedBox(
                      width: 9,
                    ),

                    Text(
                      'Analyze Contract',
                      style:
                      GoogleFonts
                          .poppins(
                        fontWeight:
                        FontWeight
                            .w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // =================================================================
            // LOCAL PDF TEST BUTTON
            // =================================================================

            const SizedBox(
              height: 12,
            ),

            SizedBox(
              width:
              double.infinity,
              height: 48,

              child:
              OutlinedButton.icon(
                onPressed:
                _openLocalPdf,

                icon: const Icon(
                  Icons
                      .picture_as_pdf_rounded,
                ),

                label: Text(
                  'Test Local PDF',
                  style:
                  GoogleFonts
                      .poppins(
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            // =================================================================
            // DISCLAIMER
            // =================================================================

            Center(
              child: Text(
                'AI-powered analysis. Not legal advice.',
                style:
                GoogleFonts.poppins(
                  fontSize: 9.5,
                  color:
                  VistaraColors
                      .neutral,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}