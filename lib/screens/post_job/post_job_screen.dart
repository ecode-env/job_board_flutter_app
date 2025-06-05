import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:job_board_flutter_app/services/auth_service.dart';
import 'package:job_board_flutter_app/services/job_service.dart';
import 'package:job_board_flutter_app/models/job_model.dart';
import 'package:job_board_flutter_app/widgets/custom_button.dart';
import 'package:job_board_flutter_app/widgets/custom_text_field.dart';
import 'package:job_board_flutter_app/utils/validators.dart';
import 'package:uuid/uuid.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  final List<TextEditingController> _requirementControllers = [TextEditingController()];
  
  String _employmentType = 'Full-time';
  bool _isRemote = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  final List<String> _employmentTypes = [
    'Full-time',
    'Part-time',
    'Contract',
    'Temporary',
    'Internship',
    'Freelance',
  ];

  @override
  void initState() {
    super.initState();
    _populateEmployerInfo();
  }

  void _populateEmployerInfo() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.user;
    
    if (user != null) {
      _emailController.text = user.email;
      if (user.company != null) {
        _companyController.text = user.company!;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    
    for (var controller in _requirementControllers) {
      controller.dispose();
    }
    
    super.dispose();
  }

  void _addRequirement() {
    setState(() {
      _requirementControllers.add(TextEditingController());
    });
  }

  void _removeRequirement(int index) {
    if (_requirementControllers.length > 1) {
      setState(() {
        _requirementControllers[index].dispose();
        _requirementControllers.removeAt(index);
      });
    }
  }

  Future<void> _postJob() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
        _errorMessage = null;
      });

      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        final jobService = Provider.of<JobService>(context, listen: false);
        
        if (authService.user == null) {
          setState(() {
            _errorMessage = 'You need to be logged in to post a job';
            _isSubmitting = false;
          });
          return;
        }
        
        // Get requirements
        List<String> requirements = [];
        for (var controller in _requirementControllers) {
          if (controller.text.isNotEmpty) {
            requirements.add(controller.text.trim());
          }
        }
        
        // Create job model
        final uuid = Uuid();
        JobModel newJob = JobModel(
          id: uuid.v4(),
          title: _titleController.text.trim(),
          company: _companyController.text.trim(),
          description: _descriptionController.text.trim(),
          location: _locationController.text.trim(),
          requirements: requirements,
          salary: _salaryController.text.trim(),
          posterID: authService.user!.id,
          contactEmail: _emailController.text.trim(),
          contactPhone: _phoneController.text.isEmpty ? null : _phoneController.text.trim(),
          postedDate: DateTime.now(),
          employmentType: _employmentType,
          isRemote: _isRemote,
        );
        
        // Create the job
        await jobService.createJob(newJob);
        
        if (mounted) {
          // Show success dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Job Posted'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your job for ${_titleController.text} has been posted successfully!',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    
                    // Clear form
                    _titleController.clear();
                    _descriptionController.clear();
                    _locationController.clear();
                    _salaryController.clear();
                    _phoneController.clear();
                    
                    // Reset requirements
                    for (var controller in _requirementControllers) {
                      controller.dispose();
                    }
                    _requirementControllers.clear();
                    _requirementControllers.add(TextEditingController());
                    
                    // Reset state
                    setState(() {
                      _employmentType = 'Full-time';
                      _isRemote = false;
                    });
                  },
                  child: const Text('Post Another Job'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back to jobs list
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to post job: $e';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a Job'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Job Details',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
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
                const SizedBox(height: 16),
              ],
              
              // Job Title
              CustomTextField(
                controller: _titleController,
                hintText: 'Job Title',
                labelText: 'Job Title',
                prefixIcon: Icons.work_outline,
                validator: Validators.validateRequired,
              ),
              const SizedBox(height: 16),
              
              // Company
              CustomTextField(
                controller: _companyController,
                hintText: 'Company Name',
                labelText: 'Company',
                prefixIcon: Icons.business,
                validator: Validators.validateRequired,
              ),
              const SizedBox(height: 16),
              
              // Location
              CustomTextField(
                controller: _locationController,
                hintText: 'Job Location',
                labelText: 'Location',
                prefixIcon: Icons.location_on_outlined,
                validator: Validators.validateRequired,
              ),
              const SizedBox(height: 16),
              
              // Employment Type
              DropdownButtonFormField<String>(
                value: _employmentType,
                decoration: InputDecoration(
                  labelText: 'Employment Type',
                  prefixIcon: const Icon(Icons.business_center_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                ),
                items: _employmentTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _employmentType = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Salary
              CustomTextField(
                controller: _salaryController,
                hintText: 'e.g., \$60,000 - \$80,000 per year',
                labelText: 'Salary',
                prefixIcon: Icons.attach_money,
                validator: Validators.validateRequired,
              ),
              const SizedBox(height: 16),
              
              // Remote Work Option
              SwitchListTile(
                title: const Text('Remote Work Available'),
                value: _isRemote,
                onChanged: (bool value) {
                  setState(() {
                    _isRemote = value;
                  });
                },
                tileColor: Theme.of(context).inputDecorationTheme.fillColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 24),
              
              // Description
              Text(
                'Job Description',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CustomTextField(
                      controller: _descriptionController,
                      hintText: 'Provide a detailed description of the job...',
                      labelText: 'Description',
                      maxLines: 8,
                      textInputAction: TextInputAction.newline,
                      keyboardType: TextInputType.multiline,
                      validator: Validators.validateRequired,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              
              // Requirements
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Requirements',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _addRequirement,
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Requirements List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _requirementControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _requirementControllers[index],
                            hintText: 'Requirement ${index + 1}',
                            validator: Validators.validateRequired,
                          ),
                        ),
                        if (_requirementControllers.length > 1)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            color: Colors.red,
                            onPressed: () => _removeRequirement(index),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              
              // Contact Information
              Text(
                'Contact Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Email
              CustomTextField(
                controller: _emailController,
                hintText: 'Contact Email',
                labelText: 'Email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 16),
              
              // Phone (Optional)
              CustomTextField(
                controller: _phoneController,
                hintText: 'Contact Phone (Optional)',
                labelText: 'Phone (Optional)',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 32),
              
              // Submit Button
              CustomButton(
                text: 'Post Job',
                onPressed: _isSubmitting ? null : _postJob,
                isLoading: _isSubmitting,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}