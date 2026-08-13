import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // Platform-specific base URL
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://localhost:8000';
    }
  }

  Future<Map<String, dynamic>> analyzeContract({
    Uint8List? fileBytes,
    String? filename,
    String? text,
    bool isMock = false,
  }) async {
    if (fileBytes == null && text == null) {
      throw ArgumentError('Either file or text must be provided');
    }

    final uri = Uri.parse('$baseUrl/analyze?mock=$isMock');
    final request = http.MultipartRequest('POST', uri);

    // Add PDF file if provided
    if (fileBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: filename ?? 'contract.pdf',
        ),
      );
    }

    // Add text if provided
    if (text != null && text.isNotEmpty) {
      request.fields['text'] = text;
    }

    try {
      print('Sending request to: $uri');
      print('Has file: ${fileBytes != null}, Has text: ${text != null}');
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return jsonData;
      } else {
        throw Exception(
          'Failed to analyze contract. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      print('API Error: $e');
      throw Exception('Error analyzing contract: $e');
    }
  }
}
