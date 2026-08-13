import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/contract_report.dart';

class StorageService {
  static const String _reportsKey = 'contract_reports';
  static const int _maxReports = 20; // Keep only the 20 most recent reports

  /// Save a ContractReport to local storage
  Future<void> saveReport(ContractReport report, String documentName) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing reports
    final reports = await getRecentReports();
    
    // Create a new report entry with metadata
    final reportData = {
      'documentName': documentName,
      'timestamp': DateTime.now().toIso8601String(),
      'report': report.toJson(),
    };
    
    // Add new report at the beginning of the list
    reports.insert(0, reportData);
    
    // Keep only the most recent reports
    if (reports.length > _maxReports) {
      reports.removeRange(_maxReports, reports.length);
    }
    
    // Save to shared preferences
    final jsonString = json.encode(reports);
    await prefs.setString(_reportsKey, jsonString);
  }

  /// Get all recent reports
  Future<List<Map<String, dynamic>>> getRecentReports() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_reportsKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    try {
      final List<dynamic> decoded = json.decode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      // If there's an error parsing, return empty list
      return [];
    }
  }

  /// Get recent reports as ContractReport objects with metadata
  Future<List<RecentDocument>> getRecentDocuments() async {
    final reports = await getRecentReports();
    
    return reports.map((reportData) {
      return RecentDocument(
        documentName: reportData['documentName'] as String,
        timestamp: DateTime.parse(reportData['timestamp'] as String),
        report: ContractReport.fromJson(
          reportData['report'] as Map<String, dynamic>,
        ),
      );
    }).toList();
  }

  /// Delete a specific report by index
  Future<void> deleteReport(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final reports = await getRecentReports();
    
    if (index >= 0 && index < reports.length) {
      reports.removeAt(index);
      final jsonString = json.encode(reports);
      await prefs.setString(_reportsKey, jsonString);
    }
  }

  /// Clear all saved reports
  Future<void> clearAllReports() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_reportsKey);
  }

  /// Get the count of saved reports
  Future<int> getReportCount() async {
    final reports = await getRecentReports();
    return reports.length;
  }
}

/// Model class to hold recent document information
class RecentDocument {
  final String documentName;
  final DateTime timestamp;
  final ContractReport report;

  RecentDocument({
    required this.documentName,
    required this.timestamp,
    required this.report,
  });

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
