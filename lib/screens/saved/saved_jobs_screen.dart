import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:job_board_flutter_app/services/auth_service.dart';
import 'package:job_board_flutter_app/services/job_service.dart';
import 'package:job_board_flutter_app/models/job_model.dart';
import 'package:job_board_flutter_app/widgets/job_card.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SavedJobsScreen extends StatefulWidget {
  const SavedJobsScreen({super.key});

  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<JobModel> _savedJobs = [];

  @override
  void initState() {
    super.initState();
    _loadSavedJobs();
  }

  Future<void> _loadSavedJobs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final jobService = Provider.of<JobService>(context, listen: false);
      
      if (authService.user == null) {
        setState(() {
          _errorMessage = 'You need to be logged in to view saved jobs';
          _isLoading = false;
        });
        return;
      }
      
      // Get all jobs first
      await jobService.getAllJobs();
      
      // Filter to only saved jobs
      _savedJobs = jobService.jobs.where(
        (job) => authService.user!.savedJobs.contains(job.id)
      ).toList();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load saved jobs. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Jobs'),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: SpinKitThreeBounce(
                color: Theme.of(context).colorScheme.primary,
                size: 30,
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadSavedJobs,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : _savedJobs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bookmark_outline,
                            size: 64,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No saved jobs yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Jobs you save will appear here',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Navigate to jobs screen (index 0)
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const Scaffold(body: Center(child: Text('Jobs'))),
                                ),
                              );
                            },
                            icon: const Icon(Icons.search),
                            label: const Text('Browse Jobs'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadSavedJobs,
                      color: Theme.of(context).colorScheme.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _savedJobs.length,
                        itemBuilder: (context, index) {
                          final job = _savedJobs[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Dismissible(
                              key: Key(job.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20.0),
                                color: Colors.red,
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              onDismissed: (direction) {
                                // Remove from saved jobs
                                Provider.of<AuthService>(context, listen: false).unsaveJob(job.id);
                                
                                // Remove from local list
                                setState(() {
                                  _savedJobs.removeAt(index);
                                });
                                
                                // Show snackbar
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${job.title} removed from saved jobs'),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: JobCard(job: job),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}