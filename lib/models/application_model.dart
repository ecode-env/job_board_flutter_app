import 'package:intl/intl.dart';
import 'package:flutter/material.dart';


class ApplicationModel {
  final String id;
  final String jobId;
  final String userId;
  final String resumeUrl;
  final String coverLetter;
  final DateTime appliedDate;
  final ApplicationStatus status;

  ApplicationModel({
    required this.id,
    required this.jobId,
    required this.userId,
    required this.resumeUrl,
    this.coverLetter = '',
    required this.appliedDate,
    this.status = ApplicationStatus.pending,
  });

  factory ApplicationModel.fromMap(Map<String, dynamic> map, String id) {
    return ApplicationModel(
      id: id,
      jobId: map['jobId'] ?? '',
      userId: map['userId'] ?? '',
      resumeUrl: map['resumeUrl'] ?? '',
      coverLetter: map['coverLetter'] ?? '',
      appliedDate: (map['appliedDate'] as dynamic)?.toDate() ?? DateTime.now(),
      status: ApplicationStatus.values.firstWhere(
        (status) => status.toString() == map['status'],
        orElse: () => ApplicationStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'userId': userId,
      'resumeUrl': resumeUrl,
      'coverLetter': coverLetter,
      'appliedDate': appliedDate,
      'status': status.toString(),
    };
  }

  String get formattedAppliedDate {
    return DateFormat('MMM dd, yyyy').format(appliedDate);
  }
}

enum ApplicationStatus {
  pending,
  reviewed,
  shortlisted,
  rejected,
  interviewing
}

extension ApplicationStatusExtension on ApplicationStatus {
  String get displayName {
    switch (this) {
      case ApplicationStatus.pending:
        return 'Pending';
      case ApplicationStatus.reviewed:
        return 'Reviewed';
      case ApplicationStatus.shortlisted:
        return 'Shortlisted';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.interviewing:
        return 'Interviewing';
    }
  }

  Color getStatusColor() {
    switch (this) {
      case ApplicationStatus.pending:
        return Colors.grey;
      case ApplicationStatus.reviewed:
        return Colors.blue;
      case ApplicationStatus.shortlisted:
        return Colors.green;
      case ApplicationStatus.rejected:
        return Colors.red;
      case ApplicationStatus.interviewing:
        return Colors.purple;
    }
  }
}

