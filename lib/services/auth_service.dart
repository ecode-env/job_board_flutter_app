import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:job_board_flutter_app/models/user_model.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  UserModel? _user;
  UserModel? get user => _user;
  
  // Auth state stream
  Stream<UserModel?> get authStateChanges => _auth.authStateChanges().asyncMap(
    (user) async {
      if (user == null) {
        _user = null;
        return null;
      }
      
      try {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          _user = UserModel.fromMap(doc.data() as Map<String, dynamic>, user.uid);
          return _user;
        } else {
          _user = null;
          return null;
        }
      } catch (e) {
        _user = null;
        return null;
      }
    },
  );
  
  // Sign in with email and password
  Future<UserModel?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          _user = UserModel.fromMap(doc.data() as Map<String, dynamic>, user.uid);
          notifyListeners();
          return _user;
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw e.code;
    } catch (e) {
      throw 'unknown-error';
    }
  }

  // Register with email and password
  Future<UserModel?> register(String email, String password, String name, UserRole role) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        // Create a new document for the user
        UserModel newUser = UserModel(
          id: user.uid,
          email: email,
          name: name,
          role: role,
        );
        
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        _user = newUser;
        notifyListeners();
        return newUser;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
  
  // Update user profile
  Future<void> updateUserProfile({
    String? name,
    String? photoUrl,
    String? resumeUrl,
    String? company,
    String? position,
  }) async {
    try {
      if (_user == null) return;
      
      Map<String, dynamic> data = {};
      
      if (name != null) data['name'] = name;
      if (photoUrl != null) data['photoUrl'] = photoUrl;
      if (resumeUrl != null) data['resumeUrl'] = resumeUrl;
      if (company != null) data['company'] = company;
      if (position != null) data['position'] = position;
      
      await _firestore.collection('users').doc(_user!.id).update(data);
      
      // Update local user model
      _user = _user!.copyWith(
        name: name ?? _user!.name,
        photoUrl: photoUrl ?? _user!.photoUrl,
        resumeUrl: resumeUrl ?? _user!.resumeUrl,
        company: company ?? _user!.company,
        position: position ?? _user!.position,
      );
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
  
  // Save job to user's saved jobs
  Future<void> saveJob(String jobId) async {
    try {
      if (_user == null) return;
      
      List<String> updatedSavedJobs = List.from(_user!.savedJobs);
      
      if (!updatedSavedJobs.contains(jobId)) {
        updatedSavedJobs.add(jobId);
        
        await _firestore.collection('users').doc(_user!.id).update({
          'savedJobs': updatedSavedJobs,
        });
        
        _user = _user!.copyWith(savedJobs: updatedSavedJobs);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Remove job from user's saved jobs
  Future<void> unsaveJob(String jobId) async {
    try {
      if (_user == null) return;
      
      List<String> updatedSavedJobs = List.from(_user!.savedJobs);
      
      if (updatedSavedJobs.contains(jobId)) {
        updatedSavedJobs.remove(jobId);
        
        await _firestore.collection('users').doc(_user!.id).update({
          'savedJobs': updatedSavedJobs,
        });
        
        _user = _user!.copyWith(savedJobs: updatedSavedJobs);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Add job to user's applied jobs
  Future<void> addAppliedJob(String jobId) async {
    try {
      if (_user == null) return;
      
      List<String> updatedAppliedJobs = List.from(_user!.appliedJobs);
      
      if (!updatedAppliedJobs.contains(jobId)) {
        updatedAppliedJobs.add(jobId);
        
        await _firestore.collection('users').doc(_user!.id).update({
          'appliedJobs': updatedAppliedJobs,
        });
        
        _user = _user!.copyWith(appliedJobs: updatedAppliedJobs);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Check if job is saved
  bool isJobSaved(String jobId) {
    if (_user == null) return false;
    return _user!.savedJobs.contains(jobId);
  }
  
  // Check if job is applied
  bool isJobApplied(String jobId) {
    if (_user == null) return false;
    return _user!.appliedJobs.contains(jobId);
  }
}