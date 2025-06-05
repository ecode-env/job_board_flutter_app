import 'package:flutter/material.dart';
import 'package:job_board_flutter_app/models/application_model.dart';
import 'package:job_board_flutter_app/models/job_model.dart';
import 'package:job_board_flutter_app/screens/jobs/job_detail_screen.dart';

class ApplicationCard extends StatelessWidget {
  final ApplicationModel application;
  final JobModel job;

  const ApplicationCard({
    super.key,
    required this.application,
    required this.job,
  });

  void _viewResume(BuildContext context) {
    // In a real app, you'd download the PDF and show it
    // For this example, we'll just show a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resume Viewer'),
        content: const Text('PDF viewer would open here in a real app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => JobDetailScreen(job: job),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with company and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Company info
                Expanded(
                  child: Row(
                    children: [
                      // Company logo or initial
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            job.company.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Company name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.company,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Applied on ${application.formattedAppliedDate}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Status indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: application.status.getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    application.status.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: application.status.getStatusColor(),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Job title
            Text(
              job.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 8),
            
            // Job location and type
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  job.location,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.work_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  job.employmentType,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Resume button
            OutlinedButton.icon(
              onPressed: () => _viewResume(context),
              icon: const Icon(Icons.description_outlined),
              label: const Text('View Resume'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: const Size(120, 36),
              ),
            ),
          ],
        ),
      ),
    );
  }
}