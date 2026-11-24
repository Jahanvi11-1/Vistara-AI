import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pasteboard/pasteboard.dart';

import '../models/contract_report.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../theme/vistara_theme.dart';

import 'document_viewer_screen.dart';
import 'analyzing_screen.dart';
import 'report_screen.dart';

// ===========================================================================
// ALLOWED IMAGE EXTENSIONS (must match backend)
// ===========================================================================

const Set<String> _kAllowedImageExts = {
  'jpg',
  'jpeg',
  'png',
  'webp',
};

const int _kMaxImageBytes = 20 * 1024 * 1024; // 20 MB

// ===========================================================================
// SELECTED IMAGE MODEL
// ===========================================================================

class _SelectedImage {
  final Uint8List bytes;
  final String name;

  const _SelectedImage({required this.bytes, required this.name});
}

// ===========================================================================
// ANALYZE SCREEN
// ===========================================================================

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

  final List<_SelectedImage> _selectedImages = [];

  bool _isLoading = false;

  final ApiService _apiService = ApiService();

  final StorageService _storageService = StorageService();

  // ===========================================================================
  // KEYBOARD SHORTCUT HANDLER
  // ===========================================================================

  late final FocusNode _keyboardFocusNode;

  @override
  void initState() {
    super.initState();
    _keyboardFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _textController.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  // ===========================================================================
  // PICK PDF
  // ===========================================================================

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _selectedFile = result.files.single;
        // Switching to PDF clears image selection
        _selectedImages.clear();
      });
    }
  }

  // ===========================================================================
  // PICK IMAGES
  // ===========================================================================

  Future<void> _pickImages() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: _kAllowedImageExts.toList(),
      allowMultiple: true,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final List<String> errors = [];
    final List<_SelectedImage> added = [];

    for (final f in result.files) {
      if (f.bytes == null) continue;
      final validation = _validateImageFile(f.bytes!, f.name);
      if (validation != null) {
        errors.add(validation);
        continue;
      }
      added.add(_SelectedImage(bytes: f.bytes!, name: f.name));
    }

    if (added.isNotEmpty) {
      setState(() {
        // Switching to images clears PDF selection
        _selectedFile = null;
        _selectedImages.addAll(added);
      });
    }

    if (errors.isNotEmpty && mounted) {
      _showError(errors.join('\n'));
    }
  }

  // ===========================================================================
  // PASTE FROM CLIPBOARD
  // ===========================================================================

  Future<void> _pasteFromClipboard() async {
    try {
      final Uint8List? imageBytes = await Pasteboard.image;

      if (imageBytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'No image found in clipboard. '
                'Copy an image first, then paste.',
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      final validation = _validateImageFile(imageBytes, 'pasted_image.png');
      if (validation != null) {
        if (mounted) _showError(validation);
        return;
      }

      final name =
          'pasted_image_${DateTime.now().millisecondsSinceEpoch}.png';

      setState(() {
        // Pasted image joins the same pool as picked images
        _selectedFile = null;
        _selectedImages.add(_SelectedImage(bytes: imageBytes, name: name));
      });
    } catch (e) {
      if (mounted) {
        _showError('Could not read clipboard: $e');
      }
    }
  }

  // ===========================================================================
  // VALIDATE IMAGE FILE (client-side)
  // ===========================================================================

  String? _validateImageFile(Uint8List bytes, String name) {
    if (bytes.isEmpty) return 'File "$name" is empty.';

    if (bytes.length > _kMaxImageBytes) {
      final mb = (bytes.length / (1024 * 1024)).toStringAsFixed(1);
      return '"$name" is ${mb}MB — exceeds the 20 MB limit.';
    }

    final ext = name.toLowerCase().split('.').last;
    if (!_kAllowedImageExts.contains(ext)) {
      return '"$name" has unsupported format .$ext. '
          'Allowed: JPG, JPEG, PNG, WEBP.';
    }

    return null;
  }

  // ===========================================================================
  // REMOVE IMAGE
  // ===========================================================================

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // ===========================================================================
  // LOCAL PDF TEST
  // ===========================================================================

  Future<void> _openLocalPdf() async {
    try {
      final byteData =
          await DefaultAssetBundle.of(context).load(
        'assets/test/contract3.pdf',
      );

      final bytes = byteData.buffer.asUint8List();

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
      debugPrint('Local PDF error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open local PDF: $e'),
        ),
      );
    }
  }

  // ===========================================================================
  // ANALYZE CONTRACT
  // ===========================================================================

  Future<void> _analyzeContract() async {
    final hasFile = _selectedFile?.bytes != null;
    final hasImages = _selectedImages.isNotEmpty;
    final hasText = _textController.text.trim().isNotEmpty;

    if (!hasFile && !hasImages && !hasText) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please upload a PDF, select/paste images, or enter contract text.',
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
          builder: (_) => const AnalyzingScreen(),
        ),
      );

      // -----------------------------------------------------------------------
      // SEND TO BACKEND
      // -----------------------------------------------------------------------

      final jsonData = await _apiService.analyzeContract(
        fileBytes: _selectedFile?.bytes,
        filename: _selectedFile?.name,
        imageFiles: hasImages
            ? _selectedImages
                .map((img) => (bytes: img.bytes, name: img.name))
                .toList()
            : null,
        text: hasText ? _textController.text.trim() : null,
        isMock: false,
      );

      // -----------------------------------------------------------------------
      // CREATE REPORT
      // -----------------------------------------------------------------------

      final report = ContractReport.fromJson(jsonData);

      // -----------------------------------------------------------------------
      // SAVE REPORT
      // -----------------------------------------------------------------------

      final documentName = _selectedFile?.name ??
          (hasImages
              ? (_selectedImages.length == 1
                  ? _selectedImages.first.name
                  : '${_selectedImages.length} images')
              : 'Text Analysis');

      await _storageService.saveReport(report, documentName);

      if (!mounted) return;

      // -----------------------------------------------------------------------
      // CLOSE ANALYZING SCREEN
      // -----------------------------------------------------------------------

      Navigator.pop(context);

      // -----------------------------------------------------------------------
      // PDF → DOCUMENT VIEWER
      // IMAGES / TEXT → REPORT SCREEN
      // -----------------------------------------------------------------------

      if (_selectedFile?.bytes != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DocumentViewerScreen(
              fileBytes: _selectedFile!.bytes!,
              filename: _selectedFile!.name,
              report: report,
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReportScreen(report: report),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      // Close analyzing screen if it is open.
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to analyze document.\n$e'),
          backgroundColor: VistaraColors.highRisk,
          duration: const Duration(seconds: 6),
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
  // HELPERS
  // ===========================================================================

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(fontSize: 12)),
        backgroundColor: VistaraColors.highRisk,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: (event) {
        // Cmd+V (macOS) / Ctrl+V (Windows/Linux) — paste image
        // Only fires when focus is NOT inside the text field
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.keyV &&
            (HardwareKeyboard.instance.isMetaPressed ||
                HardwareKeyboard.instance.isControlPressed)) {
          // Check the primary focus is not the text field
          final focused = FocusManager.instance.primaryFocus;
          if (focused == null ||
              focused.context?.widget is! EditableText) {
            _pasteFromClipboard();
          }
        }
      },
      child: Scaffold(
        backgroundColor: VistaraColors.lilacWhite,

        appBar: AppBar(
          title: Text(
            'Analyze Contract',
            style: GoogleFonts.poppins(
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===============================================================
              // TITLE
              // ===============================================================

              Text(
                'Analyze your document',
                style: GoogleFonts.poppins(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: VistaraColors.plumCharcoal,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                'Upload a contract or paste its text to identify clauses that may deserve attention.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  height: 1.5,
                  color: VistaraColors.mutedText,
                ),
              ),

              const SizedBox(height: 22),

              // ===============================================================
              // PDF UPLOAD
              // ===============================================================

              Text(
                'Upload Document',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              InkWell(
                onTap: _pickFile,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: VistaraColors.lavenderGray.withValues(
                        alpha: 0.25,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: VistaraColors.ochreAmber.withValues(
                            alpha: 0.14,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          _selectedFile != null
                              ? Icons.check_rounded
                              : Icons.upload_file_rounded,
                          color: VistaraColors.ochreAmber,
                          size: 27,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        _selectedFile != null
                            ? _selectedFile!.name
                            : 'Tap to upload PDF',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: VistaraColors.plumCharcoal,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        _selectedFile != null
                            ? 'PDF selected'
                            : 'PDF documents only',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: VistaraColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // ===============================================================
              // IMAGE UPLOAD
              // ===============================================================

              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Upload Images',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _pasteFromClipboard,
                    icon: const Icon(
                      Icons.content_paste_rounded,
                      size: 16,
                    ),
                    label: Text(
                      'Paste',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: VistaraColors.ochreAmber,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              InkWell(
                onTap: _pickImages,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: VistaraColors.lavenderGray.withValues(
                        alpha: 0.25,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: VistaraColors.ochreAmber.withValues(
                            alpha: 0.14,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          _selectedImages.isNotEmpty
                              ? Icons.check_rounded
                              : Icons.image_outlined,
                          color: VistaraColors.ochreAmber,
                          size: 27,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        _selectedImages.isNotEmpty
                            ? '${_selectedImages.length} image${_selectedImages.length == 1 ? '' : 's'} selected'
                            : 'Tap to select images',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: VistaraColors.plumCharcoal,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        _selectedImages.isNotEmpty
                            ? 'Tap to add more • Use Paste for clipboard'
                            : 'JPG, JPEG, PNG, WEBP • Multiple allowed',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: VistaraColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ---------------------------------------------------------------
              // IMAGE PREVIEW LIST
              // ---------------------------------------------------------------

              if (_selectedImages.isNotEmpty) ...[
                const SizedBox(height: 14),
                _ImagePreviewList(
                  images: _selectedImages,
                  onRemove: _removeImage,
                ),
              ],

              const SizedBox(height: 25),

              // ===============================================================
              // TEXT INPUT
              // ===============================================================

              Text(
                'Or paste contract text',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: _textController,
                maxLines: 9,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: VistaraColors.plumCharcoal,
                ),
                decoration: const InputDecoration(
                  hintText: 'Paste your contract text here...',
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 24),

              // ===============================================================
              // ANALYZE BUTTON
              // ===============================================================

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _analyzeContract,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        size: 19,
                      ),

                      const SizedBox(width: 9),

                      Text(
                        'Analyze Contract',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ===============================================================
              // LOCAL PDF TEST BUTTON
              // ===============================================================

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _openLocalPdf,
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  label: Text(
                    'Test Local PDF',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ===============================================================
              // DISCLAIMER
              // ===============================================================

              Center(
                child: Text(
                  'AI-powered analysis. Not legal advice.',
                  style: GoogleFonts.poppins(
                    fontSize: 9.5,
                    color: VistaraColors.neutral,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// IMAGE PREVIEW LIST WIDGET
// ===========================================================================

class _ImagePreviewList extends StatelessWidget {
  final List<_SelectedImage> images;
  final void Function(int index) onRemove;

  const _ImagePreviewList({
    required this.images,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final img = images[index];
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Image thumbnail
              Container(
                width: 90,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: VistaraColors.lavenderGray.withValues(alpha: 0.3),
                  ),
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.memory(
                          img.bytes,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: VistaraColors.mutedText,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        child: Text(
                          '${index + 1}',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: VistaraColors.mutedText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Remove button
              Positioned(
                top: -6,
                right: -6,
                child: GestureDetector(
                  onTap: () => onRemove(index),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: VistaraColors.highRisk,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
