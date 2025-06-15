import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:job_board_flutter_app/models/job_model.dart';
import 'package:job_board_flutter_app/services/auth_service.dart';
import 'package:job_board_flutter_app/models/user_model.dart';
import 'package:job_board_flutter_app/screens/applications/apply_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';

class JobDetailScreen extends StatefulWidget {
  final JobModel job;

  const JobDetailScreen({
    super.key,
    required this.job,
  });

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSaved = false;
  bool _isApplied = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkJobStatus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _checkJobStatus() {
    final authService = Provider.of<AuthService>(context, listen: false);
    setState(() {
      _isSaved = authService.isJobSaved(widget.job.id);
      _isApplied = authService.isJobApplied(widget.job.id);
    });
  }

  Future<void> _toggleSaveJob() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    if (authService.user == null) {
      _showLoginRequiredDialog('save jobs');
      return;
    }
    
    setState(() {
      _isSaved = !_isSaved;
    });
    
    try {
      if (_isSaved) {
        await authService.saveJob(widget.job.id);
        _showSnackBar('Job saved successfully!');
      } else {
        await authService.unsaveJob(widget.job.id);
        _showSnackBar('Job removed from saved list');
      }
    } catch (e) {
      setState(() {
        _isSaved = !_isSaved; // Revert the state
      });
      _showSnackBar('Failed to update saved status');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLoginRequiredDialog(String action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: Text('You need to login to $action.'),
        actions: [
          TextButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
              // Navigate to login screen
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  Future<void> _applyForJob() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.user;
    
    if (user == null) {
      _showLoginRequiredDialog('apply for jobs');
      return;
    }
    
    if (user.role == UserRole.jobPoster) {
      _showSnackBar('Job posters cannot apply for jobs');
      return;
    }
    
    if (_isApplied) {
      _showSnackBar('You have already applied for this job');
      return;
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ApplyScreen(job: widget.job),
      ),
    );
  }

  Future<void> _contactEmployer() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: widget.job.contactEmail,
      query: 'subject=Regarding ${widget.job.title} position',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _showSnackBar('Could not launch email client');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;
    final isCurrentUserPoster = user?.id == widget.job.posterID;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            floating: false,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.job.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  widget.job.companyLogo != null
                      ? CachedNetworkImage(
                          imageUrl: widget.job.companyLogo!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Theme.of(context).primaryColor.withOpacity(0.2),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Theme.of(context).primaryColor,
                            child: const Icon(
                              Icons.business,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        )
                      : Container(
                          color: Theme.of(context).primaryColor,
                          child: const Icon(
                            Icons.business,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(_isSaved ? Icons.bookmark : Icons.bookmark_outline),
                onPressed: _toggleSaveJob,
                tooltip: _isSaved ? 'Unsave Job' : 'Save Job',
              ),
            ],
          ),
          
          // Content
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company and Location Info
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              widget.job.company.substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.job.company,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      widget.job.location,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Posted ${timeago.format(widget.job.postedDate)}',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Quick Info Chips (horizontal scroll)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _InfoChip(
                            icon: Icons.work_outline,
                            label: widget.job.employmentType,
                          ),
                          const SizedBox(width: 8),
                          _InfoChip(
                            icon: Icons.attach_money,
                            label: widget.job.salary,
                          ),
                          const SizedBox(width: 8),
                          _InfoChip(
                            icon: Icons.location_on,
                            label: widget.job.isRemote ? 'Remote' : 'On-site',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tabs
                  TabBar(
                    controller: _tabController,
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    tabs: const [
                      Tab(text: 'Description'),
                      Tab(text: 'Requirements'),
                      Tab(text: 'Company'),
                    ],
                  ),

                  // Tab Content area with fixed height
                  SizedBox(
                    height: 300,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Description Tab
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            widget.job.description,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ),

                        // Requirements Tab
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: ListView.builder(
                            itemCount: widget.job.requirements.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Theme.of(context).colorScheme.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        widget.job.requirements[index],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        // Company Tab
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'About ${widget.job.company}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                                      'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
                                      'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris '
                                      'nisi ut aliquip ex ea commodo consequat.',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                SafeArea(
                                  child: Text(
                                    'Contact Information',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.email_outlined,
                                      size: 20,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      widget.job.contactEmail,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                if (widget.job.contactPhone != null) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.phone_outlined,
                                        size: 20,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        widget.job.contactPhone!,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100), // Bottom padding for buttons
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isCurrentUserPoster ? null : _applyForJob,
                icon: _isApplied
                    ? const Icon(Icons.check_circle)
                    : const Icon(Icons.send),
                label: Text(_isApplied ? 'Applied' : 'Apply Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isApplied
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  disabledBackgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: _contactEmployer,
              icon: const Icon(Icons.email_outlined),
              label: const Text('Contact'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}