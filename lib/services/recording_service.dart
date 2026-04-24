import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/recording_model.dart';

class RecordingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads an audio file to Firebase Storage and returns the download URL.
  Future<String> uploadRecordingFile(String filePath, String userId) async {
    final file = File(filePath);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.m4a';
    final ref = _storage.ref().child('recitations').child(userId).child(fileName);
    
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  /// Submits a student's recording for review by a specific sheikh.
  Future<void> submitRecording(RecordingModel recording) async {
    await _firestore
        .collection('recordings')
        .doc(recording.id)
        .set(recording.toMap());
  }

  /// Fetches recordings waiting for review for a specific sheikh.
  Stream<List<RecordingModel>> getPendingReviews(String sheikhId) {
    return _firestore
        .collection('recordings')
        .where('sheikhId', isEqualTo: sheikhId)
        .where('sheikhApproved', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RecordingModel.fromMap(doc.data()))
            .toList());
  }

  /// Fetches a sheikh's assigned students by reading their base profile info.
  /// (This usually requires a many-to-many or student.sheikhId relationship)
  Stream<List<String>> getSheikhStudentUids(String sheikhId) {
    return _firestore
        .collection('users')
        .where('sheikhId', isEqualTo: sheikhId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  /// Submits feedback for a recording.
  Future<void> submitFeedback(String recordingId, String feedback, bool approved) async {
    await _firestore.collection('recordings').doc(recordingId).update({
      'sheikhFeedback': feedback,
      'sheikhApproved': approved,
    });
  }

  /// Fetches all recordings for a specific student.
  Stream<List<RecordingModel>> getStudentHistory(String userId) {
    return _firestore
        .collection('recordings')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RecordingModel.fromMap(doc.data()))
            .toList());
  }
}
