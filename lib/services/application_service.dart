import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:job_board_flutter_app/models/application_model.dart';

/// Service to fetch applications from Firestore
class ApplicationService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Streams list of applications for a specific jobId
  static Stream<List<ApplicationModel>> streamApplications(String jobId) {
    return _db
        .collection('applications')
        .where('jobId', isEqualTo: jobId)
        .orderBy('appliedDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data();
      return ApplicationModel.fromMap(data, doc.id);
    }).toList());
  }
}
