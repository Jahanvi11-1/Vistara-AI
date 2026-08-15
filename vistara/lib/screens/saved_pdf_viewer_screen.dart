import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import '../theme/vistara_theme.dart';

class SavedPdfViewerScreen extends StatefulWidget {
  final String pdfPath;
  final String filename;

  const SavedPdfViewerScreen({
    super.key,
    required this.pdfPath,
    required this.filename,
  });

  @override
  State<SavedPdfViewerScreen> createState() =>
      _SavedPdfViewerScreenState();
}

class _SavedPdfViewerScreenState
    extends State<SavedPdfViewerScreen> {
  bool _fileExists = false;

  @override
  void initState() {
    super.initState();
    _checkFile();
  }

  Future<void> _checkFile() async {
    final file = File(widget.pdfPath);
    final exists = await file.exists();

    if (!mounted) return;

    setState(() {
      _fileExists = exists;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VistaraColors.lilacWhite,

      appBar: AppBar(
        backgroundColor: VistaraColors.lilacWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: VistaraColors.plumCharcoal,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Text(
          widget.filename,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: VistaraColors.plumCharcoal,
          ),
        ),
      ),

      body: _buildViewer(),
    );
  }

  Widget _buildViewer() {
    if (!_fileExists) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.picture_as_pdf_outlined,
                size: 54,
                color: VistaraColors.ochreAmber,
              ),

              const SizedBox(height: 18),

              const Text(
                'PDF not found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: VistaraColors.plumCharcoal,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'The saved PDF could not be found on this device.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: VistaraColors.mutedText,
                ),
              ),

              const SizedBox(height: 20),

              OutlinedButton(
                onPressed: _checkFile,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return PdfViewer.file(
      widget.pdfPath,
      params: const PdfViewerParams(
        backgroundColor: VistaraColors.lilacWhite,
      ),
    );
  }
}