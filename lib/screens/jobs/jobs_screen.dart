import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:job_board_flutter_app/services/job_service.dart';
import 'package:job_board_flutter_app/services/theme_service.dart';
import 'package:job_board_flutter_app/widgets/job_card.dart';
import 'package:job_board_flutter_app/widgets/search_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final _searchController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isLoading = true;
  final bool _isLoadingMore = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadJobs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final jobService = Provider.of<JobService>(context, listen: false);
      await jobService.getAllJobs();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load jobs. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onSearch(String query) {
    final jobService = Provider.of<JobService>(context, listen: false);
    jobService.setSearchQuery(query);
  }

  void _onLocationFilter(String location) {
    final jobService = Provider.of<JobService>(context, listen: false);
    jobService.setLocationFilter(location);
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final jobService = Provider.of<JobService>(context);
    final filteredJobs = jobService.getFilteredJobs();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Board'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              themeService.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              themeService.toggleTheme();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                CustomSearchBar(
                  controller: _searchController,
                  hintText: 'Search jobs, companies...',
                  prefixIcon: Icons.search,
                  onChanged: _onSearch,
                ),
                const SizedBox(height: 12),
                CustomSearchBar(
                  controller: _locationController,
                  hintText: 'Location',
                  prefixIcon: Icons.location_on_outlined,
                  onChanged: _onLocationFilter,
                ),
              ],
            ),
          ),
          
          // Content Section
          Expanded(
            child: _isLoading
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
                              onPressed: _loadJobs,
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      )
                    : filteredJobs.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No jobs found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try adjusting your search criteria',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadJobs,
                            color: Theme.of(context).colorScheme.primary,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredJobs.length + (_isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == filteredJobs.length) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      child: SpinKitThreeBounce(
                                        color: Theme.of(context).colorScheme.primary,
                                        size: 24,
                                      ),
                                    ),
                                  );
                                }
                                
                                final job = filteredJobs[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: JobCard(job: job),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}