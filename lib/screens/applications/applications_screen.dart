import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:job_board_flutter_app/services/auth_service.dart';
import 'package:job_board_flutter_app/services/job_service.dart';
import 'package:job_board_flutter_app/models/job_model.dart';
import 'package:job_board_flutter_app/models/application_model.dart';
import 'package:job_board_flutter_app/widgets/job_card.dart';
import 'package:job_board_flutter_app/widgets/application_card.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
// Import the new ApplicantsScreen
import 'package:job_board_flutter_app/screens/applications/applicants_screen.dart';

class ApplicationsScreen extends StatefulWidget {
  final bool showPostedJobs;

  const ApplicationsScreen({
    Key? key,
    this.showPostedJobs = false,
  }) : super(key: key);

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;

  List<JobModel> _postedJobs = [];
  List<ApplicationModel> _applications = [];
  Map<String, JobModel> _jobsMap = {};

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: widget.showPostedJobs ? 2 : 1, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final jobService = Provider.of<JobService>(context, listen: false);

      if (authService.user == null) {
        setState(() {
          _errorMessage = 'You need to be logged in to view applications';
          _isLoading = false;
        });
        return;
      }

      await jobService.getAllJobs();
      if (widget.showPostedJobs) {
        _postedJobs =
        await jobService.getJobsPostedByUser(authService.user!.id);
      }
      _applications =
      await jobService.getUserApplications(authService.user!.id);
      _jobsMap = {for (var job in jobService.jobs) job.id: job};
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        Text(widget.showPostedJobs ? 'My Posted Jobs' : 'My Applications'),
        elevation: 0,
        bottom: widget.showPostedJobs
            ? TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context)
              .colorScheme
              .onSurface
              .withOpacity(0.7),
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(text: 'Posted Jobs'),
            Tab(text: 'Applications'),
          ],
        )
            : null,
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
            const Icon(Icons.error_outline,
                size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Try Again'),
            ),
          ],
        ),
      )
          : widget.showPostedJobs
          ? TabBarView(
        controller: _tabController,
        children: [
          _buildPostedJobsList(),
          _buildApplicationsList(),
        ],
      )
          : _buildApplicationsList(),
    );
  }

  Widget _buildPostedJobsList() {
    if (_postedJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_off,
                size: 64,
                color:
                Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('No jobs posted yet',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text('Create your first job posting',
                style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7))),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Post a Job'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: Theme.of(context).colorScheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _postedJobs.length,
        itemBuilder: (context, index) {
          final job = _postedJobs[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                JobCard(job: job, showApplicationCount: true),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => ApplicantsScreen(job: job)));
                    },
                    child: const Text('View Applicants'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildApplicationsList() {
    if (_applications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined,
                size: 64,
                color:
                Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('No applications yet',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text('Your job applications will appear here',
                style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7))),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.search),
              label: const Text('Find Jobs'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: Theme.of(context).colorScheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _applications.length,
        itemBuilder: (context, index) {
          final application = _applications[index];
          final job = _jobsMap[application.jobId];
          
          if (job == null) {
            return const SizedBox.shrink();
          }
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ApplicationCard(
              application: application,
              job: job,
            ),
          );
        },
      ),
    );
  }
}