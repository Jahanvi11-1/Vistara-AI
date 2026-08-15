import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdfrx/pdfrx.dart';

import '../models/contract_report.dart';
import '../theme/vistara_theme.dart';
import 'report_screen.dart';
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
  late final PdfViewerController _pdfController;

  final Map<int, List<_ClauseHighlight>> _highlightsByPage = {};

  final Set<int> _pagesBeingProcessed = {};

  bool _highlightProcessingStarted = false;

  @override
  void initState() {
    super.initState();

    _pdfController = PdfViewerController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startHighlightProcessing();
    });
  }

  @override
  void dispose() {
    // pdfrx 2.4.7 PdfViewerController does not expose dispose().
    super.dispose();
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

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
                  Container(
                    color: const Color(0xFFECE8ED),
                    child: PdfViewer.data(
                      widget.fileBytes,
                      sourceName: widget.filename,
                      controller: _pdfController,
                      params: PdfViewerParams(
                        margin: 12,
                        pagePaintCallbacks: [
                          _paintClauseHighlights,
                        ],
                      ),
                    ),
                  ),

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

      // ---------------------------------------------------------------
      // CONTINUE TO REPORT
      // ---------------------------------------------------------------
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            16,
            10,
            16,
            16,
          ),
          decoration: BoxDecoration(
            color: VistaraColors.lilacWhite,
            border: Border(
              top: BorderSide(
                color: VistaraColors.lavenderGray.withValues(
                  alpha: 0.20,
                ),
              ),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _openRiskReport,

              style: ElevatedButton.styleFrom(
                backgroundColor:
                VistaraColors.plumCharcoal,
                foregroundColor: Colors.white,
                elevation: 0,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),

              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Text(
                    'View Risk Report',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(width: 8),

                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 19,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  // ===========================================================================
  // HIGHLIGHT PROCESSING
  // ===========================================================================

  Future<void> _startHighlightProcessing() async {
    if (_highlightProcessingStarted) {
      return;
    }

    _highlightProcessingStarted = true;

    // Wait for the PDF controller.
    for (int attempt = 0; attempt < 50; attempt++) {
      if (_pdfController.isReady) {
        break;
      }

      await Future.delayed(
        const Duration(milliseconds: 200),
      );
    }

    if (!_pdfController.isReady) {
      debugPrint(
        '❌ PDF controller was not ready.',
      );
      return;
    }

    debugPrint(
      '========================================',
    );
    debugPrint(
      'VISTARA VERIFIED HIGHLIGHT PROCESSING STARTED',
    );
    debugPrint(
      'Clauses: ${widget.report.flaggedClauses.length}',
    );
    debugPrint(
      'High: ${widget.report.highRiskCount}',
    );
    debugPrint(
      'Medium: ${widget.report.mediumRiskCount}',
    );
    debugPrint(
      'Low: ${widget.report.lowRiskCount}',
    );
    debugPrint(
      '========================================',
    );

    try {
      await _pdfController.useDocument(
            (document) async {
          debugPrint(
            'PDF pages: ${document.pages.length}',
          );

          for (final page in document.pages) {
            if (!mounted) {
              return;
            }

            await _processPage(page);
          }
        },
      );
    } catch (e, stackTrace) {
      debugPrint(
        '❌ Highlight processing error: $e',
      );

      debugPrint(
        '$stackTrace',
      );
    }

    _pdfController.invalidate();

    if (mounted) {
      setState(() {});
    }

    debugPrint(
      '========================================',
    );
    debugPrint(
      'VISTARA VERIFIED HIGHLIGHT PROCESSING FINISHED',
    );
    debugPrint(
      'Pages with highlights: ${_highlightsByPage.length}',
    );
    debugPrint(
      '========================================',
    );
  }

  // ===========================================================================
  // PROCESS PAGE
  // ===========================================================================

  Future<void> _processPage(PdfPage page) async {
    final int pageNumber = page.pageNumber;

    if (_pagesBeingProcessed.contains(pageNumber)) {
      return;
    }

    _pagesBeingProcessed.add(pageNumber);

    try {
      debugPrint(
        '--- Processing page $pageNumber ---',
      );

      // -----------------------------------------------------------------------
      // Only process clauses that the backend has verified.
      // -----------------------------------------------------------------------

      final List<ClauseRisk> clausesForThisPage =
      widget.report.flaggedClauses.where(
            (ClauseRisk clause) {
          if (!clause.evidenceVerified) {
            debugPrint(
              '⏭️ SKIPPING UNVERIFIED CLAUSE '
                  '[${clause.severity}] '
                  '"${_shorten(clause.clauseText)}"',
            );
            return false;
          }

          // If backend supplied a page number, use it.
          if (clause.matchedPage != null) {
            return clause.matchedPage == pageNumber;
          }

          // If no page was supplied, allow searching this page.
          return true;
        },
      ).toList();

      if (clausesForThisPage.isEmpty) {
        return;
      }

      // -----------------------------------------------------------------------
      // WAIT FOR THE REAL PAGE INSTANCE
      // -----------------------------------------------------------------------

      debugPrint(
        'Waiting for page $pageNumber to load...',
      );

      final PdfPage? loadedPage =
      await page.waitForLoaded(
        timeout: const Duration(seconds: 15),
      );

      if (loadedPage == null) {
        debugPrint(
          '❌ Page $pageNumber failed to load within timeout.',
        );
        return;
      }

      debugPrint(
        '✅ Page $pageNumber loaded: '
            '${loadedPage.isLoaded}',
      );

      // -----------------------------------------------------------------------
      // LOAD RAW TEXT + CHARACTER RECTANGLES
      // -----------------------------------------------------------------------

      final PdfPageRawText? rawText =
      await loadedPage.loadText();

      if (rawText == null) {
        debugPrint(
          '❌ Page $pageNumber returned null text.',
        );
        return;
      }

      final String fullText = rawText.fullText;
      final List<PdfRect> charRects = rawText.charRects;

      debugPrint(
        'Text length: ${fullText.length}',
      );

      debugPrint(
        'Character rectangles: ${charRects.length}',
      );

      if (fullText.isEmpty) {
        debugPrint(
          '⚠️ Page $pageNumber has no readable text.',
        );
        return;
      }

      if (charRects.isEmpty) {
        debugPrint(
          '⚠️ Page $pageNumber has text but no character rectangles.',
        );
        return;
      }

      // -----------------------------------------------------------------------
      // MATCH ONLY VERIFIED CLAUSES
      // -----------------------------------------------------------------------

      for (final ClauseRisk clause in clausesForThisPage) {
        if (!mounted) {
          return;
        }

        _findVerifiedClauseInPage(
          fullText,
          charRects,
          clause,
          pageNumber,
        );
      }

      _pdfController.invalidate();

      if (mounted) {
        setState(() {});
      }
    } catch (e, stackTrace) {
      debugPrint(
        '❌ Could not process page $pageNumber: $e',
      );

      debugPrint(
        '$stackTrace',
      );
    } finally {
      _pagesBeingProcessed.remove(pageNumber);
    }
  }

  // ===========================================================================
  // VERIFIED CLAUSE MATCHING
  // ===========================================================================

  void _findVerifiedClauseInPage(
      String sourceText,
      List<PdfRect> charRects,
      ClauseRisk clause,
      int pageNumber,
      ) {
    // -------------------------------------------------------------------------
    // SAFETY CHECK
    //
    // Never highlight anything that the backend did not verify.
    // -------------------------------------------------------------------------

    if (!clause.evidenceVerified) {
      debugPrint(
        '⛔ NOT HIGHLIGHTING UNVERIFIED CLAUSE '
            '[${clause.severity}]',
      );
      return;
    }

    // -------------------------------------------------------------------------
    // CONFIDENCE CHECK
    //
    // Backend currently returns 1.0 for verified exact matches.
    // We keep a conservative threshold so an accidentally weak match
    // cannot produce a misleading visual highlight.
    // -------------------------------------------------------------------------

    if (clause.matchConfidence < 0.80) {
      debugPrint(
        '⛔ NOT HIGHLIGHTING LOW-CONFIDENCE CLAUSE '
            '[${clause.severity}] '
            'confidence=${clause.matchConfidence}',
      );
      return;
    }

    // -------------------------------------------------------------------------
    // PAGE CHECK
    // -------------------------------------------------------------------------

    if (clause.matchedPage != null &&
        clause.matchedPage != pageNumber) {
      return;
    }

    final String clauseText =
    clause.clauseText.trim();

    if (clauseText.isEmpty) {
      return;
    }

    final String severity =
    clause.severity.trim();

    final List<_TokenPosition> sourceTokens =
    _tokenizeWithPositions(sourceText);

    final List<String> clauseTokens =
    _tokenizeWords(clauseText);

    if (sourceTokens.isEmpty ||
        clauseTokens.isEmpty) {
      return;
    }

    // -------------------------------------------------------------------------
    // IMPORTANT:
    //
    // We intentionally DO NOT use the previous partial-span fallback here.
    //
    // No:
    //   "find 3 words"
    //   "find 6 words"
    //   "find closest chunk"
    //
    // If the verified clause cannot be located safely, we simply don't
    // highlight it. The risk still exists in the report.
    // -------------------------------------------------------------------------

    final List<_TokenSequenceMatch> exactMatches =
    _findTokenSequence(
      sourceTokens,
      clauseTokens,
    );

    if (exactMatches.isEmpty) {
      debugPrint(
        '⚠️ VERIFIED CLAUSE COULD NOT BE LOCATED '
            'SAFELY ON PAGE $pageNumber '
            '[$severity]',
      );

      debugPrint(
        '   Clause: "${_shorten(clauseText)}"',
      );

      return;
    }

    // -------------------------------------------------------------------------
    // If the same exact clause appears more than once, choose the first match.
    //
    // Backend verification has already confirmed the evidence. We don't invent
    // another location.
    // -------------------------------------------------------------------------

    final _TokenSequenceMatch match =
        exactMatches.first;

    debugPrint(
      '✅ VERIFIED FULL CLAUSE '
          '[$severity] '
          'page=$pageNumber '
          'matches=${exactMatches.length} '
          'confidence=${clause.matchConfidence}',
    );

    _addMatchHighlights(
      charRects,
      clause,
      pageNumber,
      match.start,
      match.end,
    );
  }

  // ===========================================================================
  // TOKENIZE SOURCE TEXT
  // ===========================================================================

  List<_TokenPosition> _tokenizeWithPositions(
      String text,
      ) {
    final List<_TokenPosition> result =
    <_TokenPosition>[];

    final RegExp regex = RegExp(
      r'[a-z0-9₹]+',
      caseSensitive: false,
    );

    int wordIndex = 0;

    for (final RegExpMatch match
    in regex.allMatches(text.toLowerCase())) {
      final String? value =
      match.group(0);

      if (value == null ||
          value.isEmpty) {
        continue;
      }

      result.add(
        _TokenPosition(
          word: value,
          start: match.start,
          end: match.end,
          wordIndex: wordIndex,
        ),
      );

      wordIndex++;
    }

    return result;
  }

  // ===========================================================================
  // TOKENIZE CLAUSE
  // ===========================================================================

  List<String> _tokenizeWords(
      String text,
      ) {
    final String normalized =
    _normalizeText(text);

    if (normalized.isEmpty) {
      return <String>[];
    }

    return normalized
        .split(' ')
        .where(
          (String word) => word.isNotEmpty,
    )
        .toList();
  }

  // ===========================================================================
  // FIND EXACT NORMALIZED TOKEN SEQUENCE
  // ===========================================================================

  List<_TokenSequenceMatch> _findTokenSequence(
      List<_TokenPosition> source,
      List<String> target,
      ) {
    if (target.isEmpty ||
        source.length < target.length) {
      return <_TokenSequenceMatch>[];
    }

    final List<_TokenSequenceMatch> matches =
    <_TokenSequenceMatch>[];

    for (
    int i = 0;
    i <= source.length - target.length;
    i++
    ) {
      bool matched = true;

      for (
      int j = 0;
      j < target.length;
      j++
      ) {
        if (source[i + j].word != target[j]) {
          matched = false;
          break;
        }
      }

      if (matched) {
        matches.add(
          _TokenSequenceMatch(
            start: source[i].start,
            end: source[
            i + target.length - 1
            ].end,
            firstWordIndex:
            source[i].wordIndex,
            lastWordIndex:
            source[
            i + target.length - 1
            ].wordIndex,
          ),
        );
      }
    }

    return matches;
  }

  // ===========================================================================
  // ADD MATCH HIGHLIGHTS
  // ===========================================================================

  void _addMatchHighlights(
      List<PdfRect> charRects,
      ClauseRisk clause,
      int pageNumber,
      int start,
      int end,
      ) {
    if (charRects.isEmpty) {
      return;
    }

    final int safeStart =
    start.clamp(
      0,
      charRects.length,
    );

    final int safeEnd =
    end.clamp(
      0,
      charRects.length,
    );

    if (safeStart >= safeEnd) {
      return;
    }

    final List<_CharacterRect> characters =
    <_CharacterRect>[];

    for (
    int i = safeStart;
    i < safeEnd;
    i++
    ) {
      final PdfRect rect =
      charRects[i];

      if (rect.width <= 0 ||
          rect.height <= 0) {
        continue;
      }

      characters.add(
        _CharacterRect(
          rect: rect,
          index: i,
        ),
      );
    }

    if (characters.isEmpty) {
      return;
    }

    final List<PdfRect> lineRects =
    _buildLineHighlightRects(
      characters,
    );

    if (lineRects.isEmpty) {
      return;
    }

    final List<_ClauseHighlight>
    pageHighlights =
    _highlightsByPage.putIfAbsent(
      pageNumber,
          () => <_ClauseHighlight>[],
    );

    for (final PdfRect rect
    in lineRects) {
      _addHighlightIfNew(
        pageHighlights,
        _ClauseHighlight(
          clause: clause,
          bounds: rect,
        ),
      );
    }
  }

  // ===========================================================================
  // BUILD LINE RECTANGLES
  // ===========================================================================

  List<PdfRect> _buildLineHighlightRects(
      List<_CharacterRect> characters,
      ) {
    if (characters.isEmpty) {
      return <PdfRect>[];
    }

    final List<_CharacterRect> sorted =
    <_CharacterRect>[
      ...characters,
    ];

    sorted.sort(
          (
          _CharacterRect a,
          _CharacterRect b,
          ) {
        final int vertical =
        b.rect.center.y.compareTo(
          a.rect.center.y,
        );

        if (vertical != 0) {
          return vertical;
        }

        return a.rect.left.compareTo(
          b.rect.left,
        );
      },
    );

    final List<List<_CharacterRect>>
    lines =
    <List<_CharacterRect>>[];

    for (final _CharacterRect character
    in sorted) {
      List<_CharacterRect>? matchingLine;

      for (final List<_CharacterRect> line
      in lines) {
        if (_sameVisualLine(
          character.rect,
          line.first.rect,
        )) {
          matchingLine = line;
          break;
        }
      }

      if (matchingLine == null) {
        lines.add(
          <_CharacterRect>[
            character,
          ],
        );
      } else {
        matchingLine.add(character);
      }
    }

    final List<PdfRect> result =
    <PdfRect>[];

    for (final List<_CharacterRect> line
    in lines) {
      if (line.isEmpty) {
        continue;
      }

      line.sort(
            (
            _CharacterRect a,
            _CharacterRect b,
            ) =>
            a.rect.left.compareTo(
              b.rect.left,
            ),
      );

      double left =
          line.first.rect.left;

      double right =
          line.first.rect.right;

      double bottom =
          line.first.rect.bottom;

      double top =
          line.first.rect.top;

      for (
      final _CharacterRect character
      in line.skip(1)
      ) {
        if (character.rect.left < left) {
          left = character.rect.left;
        }

        if (character.rect.right > right) {
          right = character.rect.right;
        }

        if (character.rect.bottom < bottom) {
          bottom = character.rect.bottom;
        }

        if (character.rect.top > top) {
          top = character.rect.top;
        }
      }

      // Small padding so the highlight looks natural.
      const double horizontalPadding = 0.5;
      const double verticalPadding = 1.2;

      final PdfRect highlightRect =
      PdfRect(
        left - horizontalPadding,
        top + verticalPadding,
        right + horizontalPadding,
        bottom - verticalPadding,
      );

      if (highlightRect.width > 0 &&
          highlightRect.height > 0) {
        result.add(highlightRect);
      }
    }

    return result;
  }

  // ===========================================================================
  // SAME VISUAL LINE
  // ===========================================================================

  bool _sameVisualLine(
      PdfRect a,
      PdfRect b,
      ) {
    final double aCenter =
        a.center.y;

    final double bCenter =
        b.center.y;

    final double averageHeight =
        (a.height + b.height) / 2;

    final double tolerance =
        averageHeight * 0.60;

    return (aCenter - bCenter)
        .abs() <=
        tolerance;
  }

  // ===========================================================================
  // DUPLICATE CHECK
  // ===========================================================================

  void _addHighlightIfNew(
      List<_ClauseHighlight> highlights,
      _ClauseHighlight newHighlight,
      ) {
    for (final _ClauseHighlight existing
    in highlights) {
      if (existing.clause ==
          newHighlight.clause &&
          _rectsOverlap(
            existing.bounds,
            newHighlight.bounds,
          )) {
        return;
      }
    }

    highlights.add(
      newHighlight,
    );
  }

  // ===========================================================================
  // RECTANGLE OVERLAP
  // ===========================================================================

  bool _rectsOverlap(
      PdfRect a,
      PdfRect b,
      ) {
    const double tolerance = 1.5;

    return !(
        a.right <
            b.left - tolerance ||
            b.right <
                a.left - tolerance ||
            a.top <
                b.bottom - tolerance ||
            b.top <
                a.bottom - tolerance
    );
  }

  // ===========================================================================
  // NORMALIZE TEXT
  // ===========================================================================

  String _normalizeText(
      String text,
      ) {
    return text
        .toLowerCase()
        .replaceAll(
      RegExp(r'[^a-z0-9₹]+'),
      ' ',
    )
        .replaceAll(
      RegExp(r'\s+'),
      ' ',
    )
        .trim();
  }

  // ===========================================================================
  // SHORTEN DEBUG TEXT
  // ===========================================================================

  String _shorten(
      String text, {
        int maxLength = 100,
      }) {
    final String clean =
    text.replaceAll(
      RegExp(r'\s+'),
      ' ',
    );

    if (clean.length <= maxLength) {
      return clean;
    }

    return '${clean.substring(0, maxLength)}...';
  }

  // ===========================================================================
  // PAINT HIGHLIGHTS
  // ===========================================================================

  void _paintClauseHighlights(
      ui.Canvas canvas,
      Rect pageRect,
      PdfPage page,
      ) {
    final List<_ClauseHighlight>?
    pageHighlights =
    _highlightsByPage[
    page.pageNumber];

    if (pageHighlights == null ||
        pageHighlights.isEmpty) {
      return;
    }

    for (final _ClauseHighlight highlight
    in pageHighlights) {
      final Rect rect =
      highlight.bounds.toRect(
        page: page,
        scaledPageSize: pageRect.size,
      );

      final Rect translatedRect =
      rect.translate(
        pageRect.left,
        pageRect.top,
      );

      final ui.Paint paint =
      ui.Paint()
        ..color =
        _highlightColor(
          highlight.clause.severity,
        )
        ..style =
            ui.PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          translatedRect,
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  // ===========================================================================
  // DYNAMIC RISK COLORS
  // ===========================================================================

  Color _highlightColor(
      String severity,
      ) {
    switch (
    severity.trim().toLowerCase()) {
      case 'high':
        return VistaraColors.highRisk
            .withValues(
          alpha: 0.28,
        );

      case 'medium':
        return VistaraColors.mediumRisk
            .withValues(
          alpha: 0.40,
        );

      case 'low':
        return VistaraColors.lowRisk
            .withValues(
          alpha: 0.40,
        );

      default:
        return VistaraColors.ochreAmber
            .withValues(
          alpha: 0.28,
        );
    }
  }

  // ===========================================================================
  // HEADER
  // ===========================================================================

  Widget _buildHeader() {
    return Container(
      padding:
      const EdgeInsets.fromLTRB(
        8,
        8,
        8,
        10,
      ),
      decoration: BoxDecoration(
        color:
        VistaraColors.lilacWhite,
        border: Border(
          bottom: BorderSide(
            color: VistaraColors
                .lavenderGray
                .withValues(
              alpha: 0.20,
            ),
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
            color:
            VistaraColors.plumCharcoal,
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
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight:
                    FontWeight.w700,
                    color: VistaraColors
                        .plumCharcoal,
                  ),
                ),

                const SizedBox(
                  height: 1,
                ),

                Text(
                  'Document Viewer',
                  style:
                  GoogleFonts.poppins(
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
            color:
            VistaraColors.plumCharcoal,
          ),

          IconButton(
            onPressed: _showOptions,
            icon: const Icon(
              Icons.more_vert_rounded,
            ),
            color:
            VistaraColors.plumCharcoal,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // RISK LEGEND
  // ===========================================================================

  Widget _buildRiskLegend() {
    final ContractReport report =
        widget.report;

    return Center(
      child: Container(
        margin:
        const EdgeInsets.symmetric(
          horizontal: 28,
        ),
        padding:
        const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: const Color(
            0xFFF0ECF1,
          ),
          borderRadius:
          BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(
                alpha: 0.12,
              ),
              blurRadius: 18,
              offset:
              const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize:
          MainAxisSize.min,
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
      mainAxisSize:
      MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration:
          BoxDecoration(
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
              style:
              GoogleFonts.poppins(
                fontSize: 14,
                fontWeight:
                FontWeight.w700,
                color: VistaraColors
                    .plumCharcoal,
              ),
            ),

            Text(
              label,
              style:
              GoogleFonts.poppins(
                fontSize: 11,
                fontWeight:
                FontWeight.w600,
                color: VistaraColors
                    .plumCharcoal,
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
      margin:
      const EdgeInsets.symmetric(
        horizontal: 13,
      ),
      color: VistaraColors
          .lavenderGray
          .withValues(
        alpha: 0.55,
      ),
    );
  }
// ===========================================================================
// OPEN RISK REPORT
// ===========================================================================

  void _openRiskReport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportScreen(
          report: widget.report,
        ),
      ),
    );
  }
  // ===========================================================================
  // OPTIONS
  // ===========================================================================

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape:
      const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              const SizedBox(
                height: 10,
              ),

              ListTile(
                leading: const Icon(
                  Icons.description_outlined,
                ),
                title: Text(
                  widget.filename,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                ),
              ),

              ListTile(
                leading: const Icon(
                  Icons.close_rounded,
                ),
                title: const Text(
                  'Close viewer',
                ),
                onTap: () {
                  Navigator.pop(
                    context,
                  );
                },
              ),

              const SizedBox(
                height: 8,
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // FILENAME
  // ===========================================================================

  String _displayFilename() {
    final String name =
        widget.filename;

    if (name
        .toLowerCase()
        .endsWith('.pdf')) {
      return name.substring(
        0,
        name.length - 4,
      );
    }

    return name;
  }
}

// =============================================================================
// CHARACTER RECTANGLE
// =============================================================================

class _CharacterRect {
  final PdfRect rect;
  final int index;

  const _CharacterRect({
    required this.rect,
    required this.index,
  });
}

// =============================================================================
// TOKEN POSITION
// =============================================================================

class _TokenPosition {
  final String word;
  final int start;
  final int end;
  final int wordIndex;

  const _TokenPosition({
    required this.word,
    required this.start,
    required this.end,
    required this.wordIndex,
  });
}

// =============================================================================
// TOKEN SEQUENCE MATCH
// =============================================================================

class _TokenSequenceMatch {
  final int start;
  final int end;
  final int firstWordIndex;
  final int lastWordIndex;

  const _TokenSequenceMatch({
    required this.start,
    required this.end,
    required this.firstWordIndex,
    required this.lastWordIndex,
  });
}

// =============================================================================
// CLAUSE HIGHLIGHT
// =============================================================================

class _ClauseHighlight {
  final ClauseRisk clause;
  final PdfRect bounds;

  const _ClauseHighlight({
    required this.clause,
    required this.bounds,
  });
}