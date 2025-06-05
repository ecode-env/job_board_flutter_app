import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:job_board_flutter_app/services/auth_service.dart';
import 'package:job_board_flutter_app/models/user_model.dart';
import 'package:job_board_flutter_app/screens/jobs/jobs_screen.dart';
import 'package:job_board_flutter_app/screens/applications/applications_screen.dart';
import 'package:job_board_flutter_app/screens/saved/saved_jobs_screen.dart';
import 'package:job_board_flutter_app/screens/profile/profile_screen.dart';
import 'package:job_board_flutter_app/screens/post_job/post_job_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() async {
    // Load initial jobs
    // This could be done here or in the individual screens
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;

    // Define different tab configurations based on user role
    final List<_TabItem> jobSeekerTabs = [
      _TabItem(
        icon: Icons.work_outline,
        label: 'Jobs',
        screen: const JobsScreen(),
      ),
      _TabItem(
        icon: Icons.bookmark_outline,
        label: 'Saved',
        screen: const SavedJobsScreen(),
      ),
      _TabItem(
        icon: Icons.description_outlined,
        label: 'Applications',
        screen: const ApplicationsScreen(),
      ),
      _TabItem(
        icon: Icons.person_outline,
        label: 'Profile',
        screen: const ProfileScreen(),
      ),
    ];

    final List<_TabItem> jobPosterTabs = [
      _TabItem(
        icon: Icons.work_outline,
        label: 'Jobs',
        screen: const JobsScreen(),
      ),
      _TabItem(
        icon: Icons.add_circle_outline,
        label: 'Post Job',
        screen: const PostJobScreen(),
      ),
      _TabItem(
        icon: Icons.business_center_outlined,
        label: 'My Jobs',
        screen: const ApplicationsScreen(showPostedJobs: true),
      ),
      _TabItem(
        icon: Icons.person_outline,
        label: 'Profile',
        screen: const ProfileScreen(),
      ),
    ];

    final tabs = user?.role == UserRole.jobPoster ? jobPosterTabs : jobSeekerTabs;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: tabs.map((tab) => tab.screen).toList(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          items: tabs.map((tab) {
            return BottomNavigationBarItem(
              icon: Icon(tab.icon),
              label: tab.label,
            );
          }).toList(),
          elevation: 8,
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  final Widget screen;

  _TabItem({
    required this.icon,
    required this.label,
    required this.screen,
  });
}