import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/contract_report.dart';
import 'analyzing_screen.dart';
import 'report_screen.dart';

class AnalyzeScreen extends StatefulWidget {
  const AnalyzeScreen({super.key});

  @override
  State<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  final TextEditingController _textController = TextEditingController();
  PlatformFile? _selectedFile;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true, // Important for Web
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _selectedFile = result.files.single;
      });
    }
  }

  Future<void> _analyzeContract() async {
    if (_selectedFile == null && _textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a file or enter text'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Show analyzing screen
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AnalyzingScreen(),
        ),
      );

      final jsonData = await _apiService.analyzeContract(
        fileBytes: _selectedFile?.bytes,
        filename: _selectedFile?.name,
        text: _textController.text.isNotEmpty ? _textController.text : null,
        isMock: false,
      );

      // Convert JSON to ContractReport model
      final report = ContractReport.fromJson(jsonData);

      // Save the report to local storage
      final documentName = _selectedFile?.name ?? 'Text Analysis';
      await _storageService.saveReport(report, documentName);

      if (!mounted) return;
      // Pop analyzing screen and push report screen
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReportScreen(report: report),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Pop analyzing screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F0), // Pastel peach background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6B4FA0)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Analyze Contract',
          style: GoogleFonts.poppins(
            color: const Color(0xFF2D2D2D),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Upload Document',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickFile,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE0E0E0),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _selectedFile != null
                          ? Icons.check_circle
                          : Icons.cloud_upload_outlined,
                      size: 64,
                      color: _selectedFile != null
                          ? Colors.green
                          : const Color(0xFF6B4FA0),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _selectedFile != null
                          ? _selectedFile!.name
                          : 'Tap to upload PDF',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Or Enter Text',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _textController,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'Paste contract text here...',
                  hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading ? null : _analyzeContract,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B4FA0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'Analyze Contract',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
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
