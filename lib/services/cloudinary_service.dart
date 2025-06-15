import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class CloudinaryService {
  // Cloudinary credentials (replace with your own)
  static const String cloudName = 'dtuzqi3nc'; // From Cloudinary Dashboard
  static const String uploadPreset = 'job-board-eyob'; // Your unsigned preset

  Future<String?> uploadResume(File file, String userId) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    // Create multipart request
    var request = http.MultipartRequest('POST', url);

    // Add upload preset and folder
    request.fields['upload_preset'] = uploadPreset;
    request.fields['folder'] = 'resumes/$userId'; // Store in user-specific folder

    // Add file
    final fileStream = http.ByteStream(file.openRead());
    final fileLength = await file.length();
    final multipartFile = http.MultipartFile(
      'file',
      fileStream,
      fileLength,
      filename: path.basename(file.path),
    );
    request.files.add(multipartFile);

    try {
      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final json = jsonDecode(responseBody.body);
        final secureUrl = json['secure_url'] as String;
        return secureUrl; // e.g., https://res.cloudinary.com/your-cloud-name/image/upload/resumes/user123/file.pdf
      } else {
        throw Exception('Upload failed: ${responseBody.body}');
      }
    } catch (e) {
      throw Exception('Failed to upload to Cloudinary: $e');
    }
  }
}