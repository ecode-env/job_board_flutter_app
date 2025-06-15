import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:job_board_flutter_app/models/application_model.dart';
import 'package:job_board_flutter_app/models/job_model.dart';
import 'package:job_board_flutter_app/services/application_service.dart';

/// Shows all applicants for a given job, with cover letter and CV link.
class ApplicantsScreen extends StatelessWidget {
  final JobModel job;
  const ApplicantsScreen({Key? key, required this.job}) : super(key: key);

  Future<void> _openUrl(String url, BuildContext context) async {
    try {
      print("Launching resume URL: $url");
      final launched = await launchUrlString(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open resume URL')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Applicants for "${job.title}"')),
      body: StreamBuilder<List<ApplicationModel>>(
        stream: ApplicationService.streamApplications(job.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final apps = snapshot.data!;
          if (apps.isEmpty) {
            return const Center(child: Text('No applications yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            separatorBuilder: (_, __) => const Divider(),
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Applied: ${app.formattedAppliedDate}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text('Cover Letter:', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(app.coverLetter),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('View CV'),
                      onPressed: () => _openUrl(app.resumeUrl, context),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}