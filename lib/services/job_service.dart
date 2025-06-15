import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:job_board_flutter_app/models/job_model.dart';
import 'package:job_board_flutter_app/models/application_model.dart';

class JobService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final List<JobModel> _jobs = [];
  List<JobModel> get jobs => _jobs;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _locationFilter = '';
  String get locationFilter => _locationFilter;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setLocationFilter(String location) {
    _locationFilter = location;
    notifyListeners();
  }

  Future<List<JobModel>> getAllJobs() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('jobs').orderBy('postedDate', descending: true).get();
      _jobs.clear();
      for (var doc in snapshot.docs) {
        JobModel job = JobModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        _jobs.add(job);
      }
      notifyListeners();
      return _jobs;
    } catch (e) {
      rethrow;
    }
  }

  List<JobModel> getFilteredJobs() {
    if (_searchQuery.isEmpty && _locationFilter.isEmpty) {
      return _jobs;
    }
    return _jobs.where((job) {
      bool matchesSearch = _searchQuery.isEmpty ||
          job.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          job.company.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          job.description.toLowerCase().contains(_searchQuery.toLowerCase());
      bool matchesLocation = _locationFilter.isEmpty ||
          job.location.toLowerCase().contains(_locationFilter.toLowerCase());
      return matchesSearch && matchesLocation;
    }).toList();
  }

  Future<JobModel?> getJobById(String jobId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('jobs').doc(jobId).get();
      if (doc.exists) {
        return JobModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<JobModel> createJob(JobModel job) async {
    try {
      DocumentReference docRef = await _firestore.collection('jobs').add(job.toMap());
      JobModel newJob = job.copyWith(id: docRef.id);
      _jobs.add(newJob);
      notifyListeners();
      return newJob;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadResume(File file, String userId) async {
    try {
      String fileName = 'resumes/$userId-${DateTime.now().millisecondsSinceEpoch}.pdf';
      TaskSnapshot snapshot = await _storage.ref(fileName).putFile(file);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload resume: $e');
    }
  }

  Future<void> applyForJob({
    required String jobId,
    required String userId,
    required String resumeUrl,
    String coverLetter = '',
  }) async {
    try {
      final uuid = Uuid();
      String applicationId = uuid.v4();

      ApplicationModel application = ApplicationModel(
        id: applicationId,
        jobId: jobId,
        userId: userId,
        resumeUrl: resumeUrl,
        coverLetter: coverLetter,
        appliedDate: DateTime.now(),
      );

      await _firestore.collection('applications').doc(applicationId).set(application.toMap());

      DocumentSnapshot jobDoc = await _firestore.collection('jobs').doc(jobId).get();
      if (jobDoc.exists) {
        int currentCount = (jobDoc.data() as Map<String, dynamic>)['applicationCount'] ?? 0;
        await _firestore.collection('jobs').doc(jobId).update({
          'applicationCount': currentCount + 1,
        });
      }

      int index = _jobs.indexWhere((job) => job.id == jobId);
      if (index != -1) {
        _jobs[index] = _jobs[index].copyWith(applicationCount: _jobs[index].applicationCount + 1);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ApplicationModel>> getUserApplications(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('applications')
          .where('userId', isEqualTo: userId)
          .orderBy('appliedDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ApplicationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<JobModel>> getJobsPostedByUser(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('jobs')
          .where('posterID', isEqualTo: userId)
          .orderBy('postedDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => JobModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
  
  // Get applications for a specific job
  Future<List<ApplicationModel>> getJobApplications(String jobId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('applications')
          .where('jobId', isEqualTo: jobId)
          .orderBy('appliedDate', descending: true)
          .get();
      
      List<ApplicationModel> applications = [];
      
      for (var doc in snapshot.docs) {
        ApplicationModel application = ApplicationModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        applications.add(application);
      }
      
      return applications;
    } catch (e) {
      rethrow;
    }
  }
}

extension JobModelExtension on JobModel {
  JobModel copyWith({
    String? id,
    String? title,
    String? company,
    String? description,
    String? location,
    List<String>? requirements,
    String? salary,
    String? posterID,
    String? contactEmail,
    String? contactPhone,
    DateTime? postedDate,
    String? employmentType,
    String? companyLogo,
    bool? isRemote,
    int? applicationCount,
  }) {
    return JobModel(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      description: description ?? this.description,
      location: location ?? this.location,
      requirements: requirements ?? this.requirements,
      salary: salary ?? this.salary,
      posterID: posterID ?? this.posterID,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      postedDate: postedDate ?? this.postedDate,
      employmentType: employmentType ?? this.employmentType,
      companyLogo: companyLogo ?? this.companyLogo,
      isRemote: isRemote ?? this.isRemote,
      applicationCount: applicationCount ?? this.applicationCount,
    );
  }
}