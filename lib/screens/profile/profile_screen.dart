import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:job_board_flutter_app/services/auth_service.dart';
import 'package:job_board_flutter_app/services/theme_service.dart';
import 'package:job_board_flutter_app/models/user_model.dart';
import 'package:job_board_flutter_app/screens/auth/login_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _positionController = TextEditingController();
  
  bool _isEditing = false;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  
  File? _selectedImage;
  File? _selectedResume;
  String? _resumeFileName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final user = Provider.of<AuthService>(context, listen: false).user;
    
    if (user != null) {
      _nameController.text = user.name ?? '';
      _companyController.text = user.company ?? '';
      _positionController.text = user.position ?? '';
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick image: $e';
      });
    }
  }

  Future<void> _pickResume() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null) {
        setState(() {
          _selectedResume = File(result.files.single.path!);
          _resumeFileName = result.files.single.name;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick file: $e';
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // In a real app, you'd upload the image and resume to storage
      // and get download URLs. For this example, we'll use mock URLs.
      String? photoUrl;
      String? resumeUrl;
      
      if (_selectedImage != null) {
        photoUrl = 'https://example.com/profile/${authService.user!.id}.jpg';
      }
      
      if (_selectedResume != null) {
        resumeUrl = 'https://example.com/resumes/${authService.user!.id}.pdf';
      }
      
      // Update user profile
      await authService.updateUserProfile(
        name: _nameController.text.trim(),
        photoUrl: photoUrl,
        resumeUrl: resumeUrl,
        company: _companyController.text.trim(),
        position: _positionController.text.trim(),
      );
      
      setState(() {
        _isEditing = false;
      });
      
      _showSnackBar('Profile updated successfully!');
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update profile: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<AuthService>(context, listen: false).signOut();
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to sign out: $e';
        _isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_circle,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'You are not logged in',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
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
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _loadUserData();
                  _selectedImage = null;
                  _selectedResume = null;
                  _resumeFileName = null;
                });
              },
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: SpinKitThreeBounce(
                color: Theme.of(context).colorScheme.primary,
                size: 30,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Picture
                  GestureDetector(
                    onTap: _isEditing ? _pickImage : null,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : (user.photoUrl != null ? NetworkImage(user.photoUrl!) as ImageProvider : null),
                          child: (_selectedImage == null && user.photoUrl == null)
                              ? Text(
                            (user.name?.isNotEmpty == true
                                ? user.name![0]
                                : user.email[0]
                            ).toUpperCase(),
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                              : null,
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // User Name
                  _isEditing
                      ? TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        )
                      : Text(
                          user.name ?? 'No Name',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  
                  // User Email
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                  
                  // User Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      user.role == UserRole.jobSeeker ? 'Job Seeker' : 'Job Poster',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Error Message
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Profile Details
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
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
                        Text(
                          'Profile Details',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        
                        // Company (for Job Posters)
                        if (user.role == UserRole.jobPoster) ...[
                          const SizedBox(height: 16),
                          _isEditing
                              ? TextField(
                                  controller: _companyController,
                                  decoration: const InputDecoration(
                                    labelText: 'Company',
                                    prefixIcon: Icon(Icons.business),
                                  ),
                                )
                              : _ProfileField(
                                  icon: Icons.business,
                                  title: 'Company',
                                  value: user.company,
                                ),
                          const SizedBox(height: 16),
                          _isEditing
                              ? TextField(
                                  controller: _positionController,
                                  decoration: const InputDecoration(
                                    labelText: 'Position',
                                    prefixIcon: Icon(Icons.work),
                                  ),
                                )
                              : _ProfileField(
                                  icon: Icons.work,
                                  title: 'Position',
                                  value: user.position,
                                ),
                        ],
                        
                        // Resume (for Job Seekers)
                        if (user.role == UserRole.jobSeeker) ...[
                          const SizedBox(height: 16),
                          _isEditing
                              ? GestureDetector(
                                  onTap: _pickResume,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _selectedResume != null
                                            ? Theme.of(context).colorScheme.primary
                                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            _selectedResume != null ? Icons.description : Icons.upload_file,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _selectedResume != null ? 'Resume uploaded' : 'Upload your resume',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: _selectedResume != null
                                                      ? Theme.of(context).colorScheme.primary
                                                      : Theme.of(context).colorScheme.onSurface,
                                                ),
                                              ),
                                              if (_resumeFileName != null) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  _resumeFileName!,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                                  ),
                                                ),
                                              ] else ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  user.resumeUrl != null ? 'Update your resume' : 'No resume uploaded yet',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : _ProfileField(
                                  icon: Icons.description,
                                  title: 'Resume',
                                  value: user.resumeUrl != null ? 'Resume uploaded' : 'No resume uploaded',
                                  valueColor: user.resumeUrl != null
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Save Button (when editing)
                  if (_isEditing)
                    ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveProfile,
                      icon: _isSaving
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.onPrimary,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(_isSaving ? 'Saving...' : 'Save Profile'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Sign Out Button
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _signOut,
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final Color? valueColor;

  const _ProfileField({
    required this.icon,
    required this.title,
    this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value ?? 'Not set',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}