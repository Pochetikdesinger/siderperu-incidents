import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/report.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080/api'; // For Android emulator
  // Use 'http://localhost:8080/api' for iOS simulator

  // Send a single report to the backend
  Future<bool> syncReport(Report report) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reportes'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(report.toJson()),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error syncing report: $e');
      return false;
    }
  }

  // Get all reports from backend
  Future<List<Report>> getReports() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/reportes'));
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Report.fromMap(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting reports: $e');
      return [];
    }
  }

  // Send email with reports
  Future<bool> sendReportsEmail() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reportes/send-email'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error sending email: $e');
      return false;
    }
  }
}
