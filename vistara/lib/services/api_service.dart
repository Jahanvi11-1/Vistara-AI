import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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
  // ANALYZE CONTRACT
  // ============================================================

  Future<Map<String, dynamic>> analyzeContract({
    Uint8List? fileBytes,
    String? filename,
    String? text,
    bool isMock = false,
  }) async {
    if (fileBytes == null &&
        (text == null || text.trim().isEmpty)) {
      throw Exception(
        'Please upload a document or enter contract text.',
      );
    }

    final uri = Uri.parse(
      '$baseUrl/analyze?mock=$isMock',
    );

    final request = http.MultipartRequest(
      'POST',
      uri,
    );

    // ============================================================
    // PDF / FILE
    // ============================================================

    if (fileBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: filename ?? 'contract.pdf',
        ),
      );
    }

    // ============================================================
    // TEXT
    // ============================================================

    if (text != null && text.trim().isNotEmpty) {
      request.fields['text'] = text.trim();
    }

    try {
      debugPrint('========================================');
      debugPrint('VISTARA API REQUEST');
      debugPrint('URL: $uri');
      debugPrint('File: ${filename ?? "none"}');
      debugPrint('File bytes: ${fileBytes?.length ?? 0}');
      debugPrint('Has text: ${text != null && text.trim().isNotEmpty}');
      debugPrint('Mock: $isMock');
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

      String errorMessage =
          'Failed to analyze contract.';

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