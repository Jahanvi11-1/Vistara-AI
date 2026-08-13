import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import '../models/contract_report.dart';
import 'report_screen.dart';
import 'recent_documents_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  PlatformFile? _selectedFile;
  bool _isAnalyzing = false;
  final ApiService _apiService = ApiService();

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'txt'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _selectedFile = result.files.single;
        _textController.clear();
      });
    }
  }

  Future<void> _analyzeContract() async {
    if (_selectedFile == null && _textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a file or enter text'),
          backgroundColor: Color(0xFFBA1A1A),
        ),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      final jsonData = await _apiService.analyzeContract(
        fileBytes: _selectedFile?.bytes,
        filename: _selectedFile?.name,
        text: _textController.text.isNotEmpty ? _textController.text : null,
        isMock: false,
      );

      final report = ContractReport.fromJson(jsonData);

      if (!mounted) return;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReportScreen(report: report),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: const Color(0xFFBA1A1A),
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF4F0F5),
      body: Row(
        children: [
          // Sidebar Navigation
          if (!isMobile)
            Container(
              width: 200,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLogo(),
                  const SizedBox(height: 24),
                  _buildNavItem(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    isActive: true,
                    onTap: () {},
                  ),
                  _buildNavItem(
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard',
                    isActive: false,
                    onTap: () {},
                  ),
                  _buildNavItem(
                    icon: Icons.add_circle_outline,
                    label: 'New Analysis',
                    isActive: false,
                    onTap: () {
                      setState(() {
                        _selectedFile = null;
                        _textController.clear();
                      });
                    },
                  ),
                  _buildNavItem(
                    icon: Icons.folder_outlined,
                    label: 'Recent Documents',
                    isActive: false,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RecentDocumentsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildNavItem(
                    icon: Icons.assessment_outlined,
                    label: 'Reports',
                    isActive: false,
                    onTap: () {},
                  ),
                  const Spacer(),
                  _buildNavItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    isActive: false,
                    onTap: () {},
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16.0 : 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isMobile),
                  SizedBox(height: isMobile ? 24 : 48),
                  _buildHeroSection(isMobile),
                  SizedBox(height: isMobile ? 24 : 32),
                  _buildPrimaryActions(isMobile),
                  SizedBox(height: isMobile ? 32 : 48),
                  _buildMainContent(isMobile),
                  SizedBox(height: isMobile ? 32 : 48),
                  _buildHowItWorks(isMobile),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF83540C),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Vistara AI',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C1B1F),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'CONTRACT RISK PLATFORM',
            style: GoogleFonts.beVietnamPro(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: const Color(0xFF504538),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF4F0F5) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isActive
              ? const Border(
                  left: BorderSide(color: Color(0xFF83540C), width: 3),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive
                  ? const Color(0xFF83540C)
                  : const Color(0xFF504538),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? const Color(0xFF1C1B1F)
                      : const Color(0xFF504538),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    if (isMobile) {
      return Row(
        children: [
          Expanded(
            child: Text(
              'Vistara AI',
              style: GoogleFonts.beVietnamPro(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1C1B1F),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            color: const Color(0xFF504538),
            onPressed: () {},
          ),
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFFB8A9C9),
            child: const Icon(Icons.person, color: Colors.white, size: 16),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFD5C4B3).withValues(alpha: 0.3),
              ),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search documents...',
                hintStyle: GoogleFonts.beVietnamPro(
                  fontSize: 14,
                  color: const Color(0xFF837566),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF837566),
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          color: const Color(0xFF504538),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.help_outline),
          color: const Color(0xFF504538),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFFB8A9C9),
          child: const Icon(Icons.person, color: Colors.white, size: 20),
        ),
      ],
    );
  }

  Widget _buildHeroSection(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Understand your contract\nbefore it becomes a problem.',
          style: GoogleFonts.beVietnamPro(
            fontSize: isMobile ? 28 : 48,
            fontWeight: FontWeight.w700,
            height: 1.17,
            letterSpacing: isMobile ? -0.56 : -0.96,
            color: const Color(0xFF1C1B1F),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Vistara identifies potentially risky clauses, explains them in plain language, and helps you understand what deserves your attention before you agree.',
          style: GoogleFonts.beVietnamPro(
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.w400,
            height: 1.5,
            color: const Color(0xFF504538),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryActions(bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: _isAnalyzing ? null : () => _pickFile(),
            icon: const Icon(Icons.description_outlined, size: 20),
            label: Text(
              'Upload Document',
              style: GoogleFonts.beVietnamPro(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF83540C),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecentDocumentsScreen(),
                ),
              );
            },
            child: Text(
              'View Recent',
              style: GoogleFonts.beVietnamPro(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1C1B1F),
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(
                color: const Color(0xFF1C1B1F).withValues(alpha: 0.1),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: _isAnalyzing ? null : () => _pickFile(),
          icon: const Icon(Icons.description_outlined, size: 20),
          label: Text(
            'Upload Document',
            style: GoogleFonts.beVietnamPro(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF83540C),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RecentDocumentsScreen(),
              ),
            );
          },
          child: Text(
            'View Recent Documents',
            style: GoogleFonts.beVietnamPro(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1C1B1F),
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            side: BorderSide(
              color: const Color(0xFF1C1B1F).withValues(alpha: 0.1),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _buildAnalyzeSection(),
          const SizedBox(height: 24),
          _buildRecentAnalysis(),
          const SizedBox(height: 24),
          _buildTimeSaved(),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _buildAnalyzeSection(),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildRecentAnalysis(),
              const SizedBox(height: 24),
              _buildTimeSaved(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzeSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analyze your document',
            style: GoogleFonts.beVietnamPro(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1C1B1F),
            ),
          ),
          const SizedBox(height: 24),
          
          // Upload Area or Selected File
          if (_selectedFile != null)
            _buildSelectedFile()
          else if (_textController.text.isNotEmpty)
            _buildTextPreview()
          else
            _buildUploadArea(),
            
          const SizedBox(height: 24),
          
          // Text Input
          if (_selectedFile == null) ...[
            Text(
              'Or paste your contract text',
              style: GoogleFonts.beVietnamPro(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF837566),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF4F0F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFD5C4B3).withValues(alpha: 0.3),
                ),
              ),
              child: TextField(
                controller: _textController,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'Paste contract text here...\n\nYou can paste the full contract or specific clauses you want analyzed.',
                  hintStyle: GoogleFonts.beVietnamPro(
                    fontSize: 14,
                    color: const Color(0xFF837566),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                ),
                style: GoogleFonts.beVietnamPro(
                  fontSize: 14,
                  color: const Color(0xFF1C1B1F),
                  height: 1.5,
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && _selectedFile != null) {
                    setState(() => _selectedFile = null);
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Analyze Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isAnalyzing ? null : _analyzeContract,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF83540C),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isAnalyzing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Analyze Contract',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadArea() {
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        height: 280,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F0F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFD5C4B3).withValues(alpha: 0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0A458).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.cloud_upload_outlined,
                    size: 40,
                    color: Color(0xFF83540C),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Drop your PDF here or click to browse',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C1B1F),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'PDF, DOCX, TXT • Max 50MB',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 14,
                    color: const Color(0xFF837566),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  constraints: const BoxConstraints(maxWidth: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF83540C).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Click to select file',
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF83540C),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedFile() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F0F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF83540C).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF83540C).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.description,
              color: Color(0xFF83540C),
              size: 28,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedFile!.name,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C1B1F),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${(_selectedFile!.size / 1024).toStringAsFixed(1)} KB • Ready to analyze',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 14,
                    color: const Color(0xFF837566),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.close),
              color: const Color(0xFF837566),
              onPressed: () {
                setState(() => _selectedFile = null);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextPreview() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F0F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF83540C).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF83540C).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.article,
                  color: Color(0xFF83540C),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Text Input • ${_textController.text.length} characters',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1C1B1F),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() => _textController.clear());
                },
                child: Text(
                  'Clear',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 14,
                    color: const Color(0xFF83540C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _textController.text,
              style: GoogleFonts.beVietnamPro(
                fontSize: 14,
                color: const Color(0xFF504538),
                height: 1.5,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAnalysis() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Analysis',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1C1B1F),
                ),
              ),
              const Icon(
                Icons.arrow_forward,
                size: 20,
                color: Color(0xFF837566),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildRecentItem(
            title: 'Non-Disclosure Agreement_v2.pdf',
            risk: '3 HIGH RISK CLAUSES',
            isHighRisk: true,
          ),
          const SizedBox(height: 16),
          _buildRecentItem(
            title: 'Employment_Contract_2024.docx',
            risk: '1 MEDIUM RISK CLAUSE',
            isHighRisk: false,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentItem({
    required String title,
    required String risk,
    required bool isHighRisk,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F0F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isHighRisk ? Icons.warning : Icons.info_outline,
                size: 16,
                color: isHighRisk
                    ? const Color(0xFFBA1A1A)
                    : const Color(0xFF83540C),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C1B1F),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            risk,
            style: GoogleFonts.beVietnamPro(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: const Color(0xFF837566),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSaved() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TIME SAVED',
            style: GoogleFonts.beVietnamPro(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: const Color(0xFF83540C),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '14 hrs',
            style: GoogleFonts.beVietnamPro(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1C1B1F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Estimated review time saved this month based on document volume.',
            style: GoogleFonts.beVietnamPro(
              fontSize: 14,
              height: 1.5,
              color: const Color(0xFF504538),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorks(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How Vistara works',
          style: GoogleFonts.beVietnamPro(
            fontSize: isMobile ? 24 : 32,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1C1B1F),
          ),
        ),
        const SizedBox(height: 32),
        isMobile
            ? Column(
                children: [
                  _buildStep(
                    number: '1',
                    title: 'Upload',
                    description:
                        'Securely upload your legal document or paste the text directly.',
                    icon: Icons.cloud_upload_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildStep(
                    number: '2',
                    title: 'Analyze',
                    description:
                        'Our AI scans the document, identifying standard clauses and flagging anomalies.',
                    icon: Icons.analytics_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildStep(
                    number: '3',
                    title: 'Understand',
                    description:
                        'Complex legalese is translated into plain, actionable language.',
                    icon: Icons.translate,
                  ),
                  const SizedBox(height: 16),
                  _buildStep(
                    number: '4',
                    title: 'Decide',
                    description:
                        'Review flagged risks and make informed decisions.',
                    icon: Icons.check_circle_outline,
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: _buildStep(
                      number: '1',
                      title: 'Upload',
                      description:
                          'Securely upload your legal document or paste the text directly into the engine.',
                      icon: Icons.cloud_upload_outlined,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildStep(
                      number: '2',
                      title: 'Analyze',
                      description:
                          'Our AI scans the document, identifying standard clauses and flagging anomalies.',
                      icon: Icons.analytics_outlined,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildStep(
                      number: '3',
                      title: 'Understand',
                      description:
                          'Complex legalese is translated into plain, actionable language for clear comprehension.',
                      icon: Icons.translate,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildStep(
                      number: '4',
                      title: 'Decide',
                      description:
                          'Review flagged risks and make informed decisions on negotiations or signatures.',
                      icon: Icons.check_circle_outline,
                    ),
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F0F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: const Color(0xFF83540C),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '$number. ',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF83540C),
                ),
              ),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C1B1F),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.beVietnamPro(
              fontSize: 14,
              height: 1.5,
              color: const Color(0xFF504538),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}