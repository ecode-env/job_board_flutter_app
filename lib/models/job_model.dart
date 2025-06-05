import 'package:intl/intl.dart';

class JobModel {
  final String id;
  final String title;
  final String company;
  final String description;
  final String location;
  final List<String> requirements;
  final String salary;
  final String posterID;
  final String contactEmail;
  final String? contactPhone;
  final DateTime postedDate;
  final String employmentType; // Full-time, Part-time, Contract, etc.
  final String? companyLogo;
  final bool isRemote;
  final int applicationCount;

  JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.description,
    required this.location,
    required this.requirements,
    required this.salary,
    required this.posterID,
    required this.contactEmail,
    this.contactPhone,
    required this.postedDate,
    required this.employmentType,
    this.companyLogo,
    required this.isRemote,
    this.applicationCount = 0,
  });

  factory JobModel.fromMap(Map<String, dynamic> map, String id) {
    return JobModel(
      id: id,
      title: map['title'] ?? '',
      company: map['company'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      requirements: List<String>.from(map['requirements'] ?? []),
      salary: map['salary'] ?? '',
      posterID: map['posterID'] ?? '',
      contactEmail: map['contactEmail'] ?? '',
      contactPhone: map['contactPhone'],
      postedDate: (map['postedDate'] as dynamic)?.toDate() ?? DateTime.now(),
      employmentType: map['employmentType'] ?? 'Full-time',
      companyLogo: map['companyLogo'],
      isRemote: map['isRemote'] ?? false,
      applicationCount: map['applicationCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'company': company,
      'description': description,
      'location': location,
      'requirements': requirements,
      'salary': salary,
      'posterID': posterID,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'postedDate': postedDate,
      'employmentType': employmentType,
      'companyLogo': companyLogo,
      'isRemote': isRemote,
      'applicationCount': applicationCount,
    };
  }

  String get formattedPostedDate {
    return DateFormat('MMM dd, yyyy').format(postedDate);
  }

  String get shortDescription {
    if (description.length > 100) {
      return '${description.substring(0, 100)}...';
    }
    return description;
  }
}