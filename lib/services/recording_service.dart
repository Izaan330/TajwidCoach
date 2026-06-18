import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/recording_model.dart';

class RecordingService {
  FirebaseFirestore? _firestore;
  FirebaseStorage? _storage;

  RecordingService() {
    try {
      _firestore = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;
    } catch (_) {}
  }

  /// Uploads an audio file to Firebase Storage and returns the download URL.
  Future<String> uploadRecordingFile(String filePath, String userId) async {
    if (_storage == null) throw Exception('Firebase Storage not available');
    final file = File(filePath);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.m4a';
    final ref = _storage!.ref().child('recitations').child(userId).child(fileName);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  /// Submits a student's recording for review by a specific sheikh.
  Future<void> submitRecording(RecordingModel recording) async {
    if (_firestore == null) return;

    String? audioUrl = recording.audioUrl;
    if (recording.audioLocalPath != null && _storage != null) {
      try {
        audioUrl = await uploadRecordingFile(recording.audioLocalPath!, recording.userId);
      } catch (e) {
        // Fallback or log if upload fails
      }
    }

    final finalRecording = RecordingModel(
      id: recording.id,
      userId: recording.userId,
      ayahReference: recording.ayahReference,
      surahName: recording.surahName,
      tajwidScore: recording.tajwidScore,
      weakWords: recording.weakWords,
      weakRuleIds: recording.weakRuleIds,
      audioUrl: audioUrl,
      audioLocalPath: recording.audioLocalPath,
      timestamp: recording.timestamp,
      sheikhFeedback: recording.sheikhFeedback,
      sheikhId: recording.sheikhId,
      sheikhApproved: recording.sheikhApproved,
      durationSeconds: recording.durationSeconds,
    );

    await _firestore!
        .collection('recordings')
        .doc(finalRecording.id)
        .set(finalRecording.toMap());
  }

  /// Fetches recordings waiting for review for a specific sheikh.
  Stream<List<RecordingModel>> getPendingReviews(String sheikhId) {
    if (_firestore == null) return const Stream.empty();
    return _firestore!
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
  Stream<List<Map<String, dynamic>>> getSheikhStudentProfiles(String sheikhId) {
    if (_firestore == null) return const Stream.empty();
    return _firestore!
        .collection('users')
        .where('sheikhId', isEqualTo: sheikhId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = Map<String, dynamic>.from(doc.data());
              if (data['uid'] == null) {
                data['uid'] = doc.id;
              }
              return data;
            }).toList());
  }

  /// Uploads a feedback audio file to Firebase Storage.
  Future<String> uploadFeedbackAudioFile(String filePath, String sheikhId) async {
    if (_storage == null) throw Exception('Firebase Storage not available');
    final file = File(filePath);
    final fileName = 'feedback_${DateTime.now().millisecondsSinceEpoch}.m4a';
    final ref = _storage!.ref().child('feedbacks').child(sheikhId).child(fileName);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  /// Submits feedback for a recording.
  Future<void> submitFeedback(String recordingId, String feedback, bool approved, {String? feedbackAudioUrl}) async {
    if (_firestore == null) return;
    await _firestore!.collection('recordings').doc(recordingId).update({
      'sheikhFeedback': feedback,
      'sheikhApproved': approved,
      'sheikhFeedbackAudioUrl': feedbackAudioUrl,
    });
  }

  /// Fetches all recordings for a specific student.
  Stream<List<RecordingModel>> getStudentHistory(String userId) {
    if (_firestore == null) return const Stream.empty();
    return _firestore!
        .collection('recordings')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => RecordingModel.fromMap(doc.data()))
              .toList();
          list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return list;
        });
  }
}
