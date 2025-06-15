import 'dart:io';
import 'package:http/http.dart' as http;

class StorageService {
  static const String _supabaseUrl = 'https://gdzjozmmngiyuloecndx.supabase.co'; // Replace with your Supabase URL
  static const String _anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdkempvem1tbmdpeXVsb2VjbmR4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk4MTAxNzcsImV4cCI6MjA2NTM4NjE3N30.H5-5xCwflNxycuhkTRHrABTj04R4ygf-DwPrzbfEyfk'; // Replace with your Supabase anon/public API key
  static const String _bucketName = 'job-board'; // Replace with your bucket name

  Future<String> uploadResume(File file, String userId) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.pdf';
    final path = '$userId/$fileName';

    final uri = Uri.parse('$_supabaseUrl/storage/v1/object/$_bucketName/$path');
    final bytes = await file.readAsBytes();

    try {
      final response = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $_anonKey',
          'Content-Type': 'application/pdf',
        },
        body: bytes,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return '$_supabaseUrl/storage/v1/object/public/$_bucketName/$path';
      } else {
        throw Exception('Supabase upload failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to upload to Supabase: $e');
    }
  }
}
