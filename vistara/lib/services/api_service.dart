import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  // ============================================================
  // BACKEND URL
  // ============================================================

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }

    return 'http://127.0.0.1:8000';
  }

  // ============================================================
  // HELPERS
  // ============================================================

  /// Returns the correct [MediaType] for a given filename extension so that
  /// multipart uploads send `image/jpeg` etc. instead of the default
  /// `application/octet-stream`.
  static MediaType _mediaTypeFromName(String name) {
    final ext = name.toLowerCase().split('.').last;
    const map = {
      'jpg': 'jpeg',
      'jpeg': 'jpeg',
      'png': 'png',
      'webp': 'webp',
    };
    final subtype = map[ext];
    if (subtype == null) return MediaType('application', 'octet-stream');
    return MediaType('image', subtype);
  }

  // ============================================================
  // ANALYZE CONTRACT
  // ============================================================

  Future<Map<String, dynamic>> analyzeContract({
    Uint8List? fileBytes,
    String? filename,
    List<({Uint8List bytes, String name})>? imageFiles,
    String? text,
    bool isMock = false,
    bool redactPii = true,
  }) async {
    final hasFile = fileBytes != null;
    final hasImages = imageFiles != null && imageFiles.isNotEmpty;
    final hasText = text != null && text.trim().isNotEmpty;

    if (!hasFile && !hasImages && !hasText) {
      throw Exception(
        'Please upload a document, image(s), or enter contract text.',
      );
    }

    final uri = Uri.parse(
      '$baseUrl/analyze?mock=$isMock&redact_pii=$redactPii',
    );

    final request = http.MultipartRequest(
      'POST',
      uri,
    );

    // ============================================================
    // PDF / FILE
    // ============================================================

    if (hasFile) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: filename ?? 'contract.pdf',
        ),
      );
    }

    // ============================================================
    // IMAGES
    // ============================================================

    if (hasImages) {
      for (final img in imageFiles) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'images',
            img.bytes,
            filename: img.name,
            contentType: _mediaTypeFromName(img.name),
          ),
        );
      }
    }

    // ============================================================
    // TEXT
    // ============================================================

    if (hasText) {
      // ignore: unnecessary_non_null_assertion
      request.fields['text'] = text!.trim();
    }

    try {
      debugPrint('========================================');
      debugPrint('VISTARA API REQUEST');
      debugPrint('URL: $uri');
      debugPrint('File: ${filename ?? "none"}');
      debugPrint('File bytes: ${fileBytes?.length ?? 0}');
      debugPrint('Images: ${imageFiles?.length ?? 0}');
      debugPrint('Has text: $hasText');
      debugPrint('Mock: $isMock');
      debugPrint('Redact PII: $redactPii');
      debugPrint('========================================');

      // ==========================================================
      // SEND REQUEST
      // ==========================================================

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(
        streamedResponse,
      );

      debugPrint(
        'Response status: ${response.statusCode}',
      );

      debugPrint(
        'Response body: ${response.body}',
      );

      // ==========================================================
      // SUCCESS
      // ==========================================================

      if (response.statusCode == 200) {
        try {
          final decoded = jsonDecode(response.body);

          if (decoded is! Map<String, dynamic>) {
            throw Exception(
              'Backend returned an unexpected response format.',
            );
          }

          return decoded;
        } catch (e) {
          throw Exception(
            'Could not read the analysis result from the backend.',
          );
        }
      }

      // ==========================================================
      // BACKEND ERROR
      // ==========================================================

      String errorMessage = 'Failed to analyze contract.';

      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          final detail = decoded['detail'];

          if (detail != null) {
            errorMessage = detail.toString();
          }
        }
      } catch (_) {
        // Backend response was not JSON.
        errorMessage = response.body.isNotEmpty
            ? response.body
            : 'Server returned an empty error response.';
      }

      // ==========================================================
      // SPECIFIC STATUS MESSAGES
      // ==========================================================

      if (response.statusCode == 401) {
        errorMessage =
        'Gemini authentication failed. Please check the API key.';
      } else if (response.statusCode == 429) {
        errorMessage =
        'Gemini API quota has been exceeded. Please try again later.';
      } else if (response.statusCode >= 500) {
        errorMessage =
        'The Vistara backend encountered an error:\n$errorMessage';
      }

      throw Exception(errorMessage);
    } catch (e) {
      debugPrint(
        '========================================',
      );

      debugPrint(
        'VISTARA API ERROR',
      );

      debugPrint(
        e.toString(),
      );

      debugPrint(
        '========================================',
      );

      // Don't double-wrap our own useful error.
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        'Unable to analyze the document: $e',
      );
    }
  }
}