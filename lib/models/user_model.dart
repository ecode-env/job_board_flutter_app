enum UserRole { jobSeeker, jobPoster }

class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final UserRole role;
  final List<String> savedJobs;
  final List<String> appliedJobs;
  final String? resumeUrl;
  final String? company;
  final String? position;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    required this.role,
    this.savedJobs = const [],
    this.appliedJobs = const [],
    this.resumeUrl,
    this.company,
    this.position,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      name: map['name'],
      photoUrl: map['photoUrl'],
      role: UserRole.values.firstWhere(
        (role) => role.toString() == map['role'],
        orElse: () => UserRole.jobSeeker,
      ),
      savedJobs: List<String>.from(map['savedJobs'] ?? []),
      appliedJobs: List<String>.from(map['appliedJobs'] ?? []),
      resumeUrl: map['resumeUrl'],
      company: map['company'],
      position: map['position'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'role': role.toString(),
      'savedJobs': savedJobs,
      'appliedJobs': appliedJobs,
      'resumeUrl': resumeUrl,
      'company': company,
      'position': position,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    UserRole? role,
    List<String>? savedJobs,
    List<String>? appliedJobs,
    String? resumeUrl,
    String? company,
    String? position,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      savedJobs: savedJobs ?? this.savedJobs,
      appliedJobs: appliedJobs ?? this.appliedJobs,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      company: company ?? this.company,
      position: position ?? this.position,
    );
  }
}