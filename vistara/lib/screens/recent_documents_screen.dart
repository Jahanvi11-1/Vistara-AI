import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';
import 'report_screen.dart';

class RecentDocumentsScreen extends StatefulWidget {
  const RecentDocumentsScreen({super.key});

  @override
  State<RecentDocumentsScreen> createState() => _RecentDocumentsScreenState();
}

class _RecentDocumentsScreenState extends State<RecentDocumentsScreen> {
  final StorageService _storageService = StorageService();
  List<RecentDocument> _documents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoading = true);
    final documents = await _storageService.getRecentDocuments();
    setState(() {
      _documents = documents;
      _isLoading = false;
    });
  }

  Future<void> _deleteDocument(int index) async {
    await _storageService.deleteReport(index);
    _loadDocuments();
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
          'Recent Documents',
          style: GoogleFonts.poppins(
            color: const Color(0xFF2D2D2D),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_documents.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFF6B4FA0)),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      'Clear All',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    content: Text(
                      'Are you sure you want to delete all recent documents?',
                      style: GoogleFonts.inter(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          'Clear All',
                          style: GoogleFonts.poppins(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await _storageService.clearAllReports();
                  _loadDocuments();
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6B4FA0)),
            )
          : _documents.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadDocuments,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24.0),
                    itemCount: _documents.length,
                    itemBuilder: (context, index) {
                      final document = _documents[index];
                      return _buildDocumentCard(document, index);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No Recent Documents',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Analyzed contracts will appear here',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(RecentDocument document, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key('doc_$index'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (direction) {
          _deleteDocument(index);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Document deleted',
                style: GoogleFonts.inter(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        },
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReportScreen(report: document.report),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8D5FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.description,
                        color: Color(0xFF6B4FA0),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            document.documentName,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2D2D2D),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            document.formattedDate,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Color(0xFF6B4FA0),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildInfoChip(
                      'Score: ${document.report.overallScore}/100',
                      _getScoreColor(document.report.overallScore),
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      '${document.report.flaggedClauses.length} risks',
                      const Color(0xFFFFE5E5),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF2D2D2D),
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    // Score is 0-100, where lower is more risky
    if (score >= 70) {
      return const Color(0xFFE5FFE5); // Green for safe
    } else if (score >= 40) {
      return const Color(0xFFFFF5E5); // Yellow/orange for medium risk
    } else {
      return const Color(0xFFFFE5E5); // Red for high risk
    }
  }
}
