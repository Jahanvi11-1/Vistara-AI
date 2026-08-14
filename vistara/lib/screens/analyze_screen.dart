import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/contract_report.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../theme/vistara_theme.dart';

import 'analyzing_screen.dart';
import 'report_screen.dart';

class AnalyzeScreen extends StatefulWidget {
  const AnalyzeScreen({super.key});

  @override
  State<AnalyzeScreen> createState() =>
      _AnalyzeScreenState();
}

class _AnalyzeScreenState
    extends State<AnalyzeScreen> {
  final TextEditingController
  _textController =
  TextEditingController();

  PlatformFile? _selectedFile;

  bool _isLoading = false;

  final ApiService _apiService =
  ApiService();

  final StorageService _storageService =
  StorageService();

  Future<void> _pickFile() async {
    final result =
    await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null &&
        result.files.single.bytes != null) {
      setState(() {
        _selectedFile =
            result.files.single;
      });
    }
  }

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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
          const AnalyzingScreen(),
        ),
      );

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
            : null,
        isMock: false,
      );

      final report =
      ContractReport.fromJson(
        jsonData,
      );

      final documentName =
          _selectedFile?.name ??
              'Text Analysis';

      await _storageService.saveReport(
        report,
        documentName,
      );

      if (!mounted) return;

      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ReportScreen(
                report: report,
              ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Unable to analyze document.',
          ),
          backgroundColor:
          VistaraColors.highRisk,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      VistaraColors.lilacWhite,

      appBar: AppBar(
        title: Text(
          'Analyze Contract',
          style: GoogleFonts.poppins(
            fontSize: 19,
            fontWeight:
            FontWeight.w700,
          ),
        ),

        // IMPORTANT:
        // Analyze is a bottom-navigation tab.
        // Therefore don't use Navigator.pop here.
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
            Text(
              'Analyze your document',
              style: GoogleFonts.poppins(
                fontSize: 25,
                fontWeight:
                FontWeight.w700,
                color:
                VistaraColors
                    .plumCharcoal,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              'Upload a contract or paste its text to identify clauses that may deserve attention.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                height: 1.5,
                color:
                VistaraColors.mutedText,
              ),
            ),

            const SizedBox(height: 22),

            // --------------------------------------------------------
            // PDF UPLOAD
            // --------------------------------------------------------

            Text(
              'Upload Document',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(height: 10),

            InkWell(
              onTap: _pickFile,
              borderRadius:
              BorderRadius.circular(18),

              child: Container(
                width: double.infinity,
                padding:
                const EdgeInsets.all(22),

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
                        color: VistaraColors
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
                        _selectedFile !=
                            null
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

                    const SizedBox(height: 12),

                    Text(
                      _selectedFile !=
                          null
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

                    const SizedBox(height: 4),

                    Text(
                      _selectedFile !=
                          null
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

            const SizedBox(height: 25),

            // --------------------------------------------------------
            // TEXT
            // --------------------------------------------------------

            Text(
              'Or paste contract text',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller:
              _textController,
              maxLines: 9,

              style: GoogleFonts.poppins(
                fontSize: 12,
                color:
                VistaraColors
                    .plumCharcoal,
              ),

              decoration:
              const InputDecoration(
                hintText:
                'Paste your contract text here...',
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed:
                _isLoading
                    ? null
                    : _analyzeContract,

                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons
                          .auto_awesome_rounded,
                      size: 19,
                    ),
                    const SizedBox(width: 9),
                    Text(
                      'Analyze Contract',
                      style:
                      GoogleFonts.poppins(
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            Center(
              child: Text(
                'AI-powered analysis. Not legal advice.',
                style:
                GoogleFonts.poppins(
                  fontSize: 9.5,
                  color:
                  VistaraColors.neutral,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}