import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sheikh_model.dart';
import '../models/recording_model.dart';
import '../models/user_model.dart';
import '../services/recording_service.dart';
import '../models/ijazah_model.dart';


class SheikhProvider extends ChangeNotifier {
  final RecordingService _service = RecordingService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<SheikhModel> _availableSheikhs = [];
  List<RecordingModel> _pendingReviews = [];
  List<String> _myStudentUids = [];
  final Map<String, UserModel> _studentProfiles = {};
  bool _isLoading = false;

  List<SheikhModel> get availableSheikhs => _availableSheikhs;
  List<RecordingModel> get pendingReviews => _pendingReviews;
  List<String> get myStudentUids => _myStudentUids;
  List<UserModel> get myStudents => 
      _myStudentUids.map((uid) => _studentProfiles[uid] ?? UserModel(uid: uid, name: 'Loading...', phone: '')).toList();
  bool get isLoading => _isLoading;

  SheikhProvider() {
    _fetchAvailableSheikhs();
  }

  Future<void> _fetchAvailableSheikhs() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore.collection('sheikhs').get();
      _availableSheikhs = snapshot.docs
          .map((doc) => SheikhModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching sheikhs: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Listen for pending reviews if the current user is a sheikh.
  void listenToPendingReviews(String sheikhId) {
    _service.getPendingReviews(sheikhId).listen((recordings) {
      _pendingReviews = recordings;
      notifyListeners();
    });
  }

  /// Listen for assigned students and fetch their profiles.
  void listenToMyStudents(String sheikhId) {
    _service.getSheikhStudentUids(sheikhId).listen((uids) async {
      _myStudentUids = uids;
      
      // Fetch missing profiles
      for (final uid in uids) {
        if (!_studentProfiles.containsKey(uid)) {
          _fetchStudentProfile(uid);
        }
      }
      notifyListeners();
    });
  }

  Future<void> _fetchStudentProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _studentProfiles[uid] = UserModel.fromMap(doc.data()!);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching student profile: $e');
    }
  }

  Future<void> submitFeedback(String recordingId, String feedback, bool approved) async {
    await _service.submitFeedback(recordingId, feedback, approved);
  }

  Future<void> submitRequest(RecordingModel recording) async {
    await _service.submitRecording(recording);
  }

  Future<void> enrollWithSheikh(String userId, String sheikhId) async {
    // 1. Update user's sheikhId
    await _firestore.collection('users').doc(userId).update({'sheikhId': sheikhId});
    
    // 2. Add student to sheikh's list
    await _firestore.collection('sheikhs').doc(sheikhId).update({
      'students': FieldValue.arrayUnion([userId]),
      'currentStudents': FieldValue.increment(1),
    });
  }

  Future<void> submitIjazah(IjazahCertificate certificate) async {
    // 1. Save certificate
    await _firestore.collection('certificates').doc(certificate.id).set({
      'studentId': certificate.studentId,
      'studentName': certificate.studentName,
      'sheikhId': certificate.sheikhId,
      'sheikhName': certificate.sheikhName,
      'sheikhSignature': certificate.sheikhSignature,
      'masjid': certificate.masjid,
      'attestation': certificate.attestation,
      'issuedDate': certificate.issuedDate.toIso8601String(),
    });

    // 2. Award badge to student
    await _firestore.collection('users').doc(certificate.studentId).update({
      'badges': FieldValue.arrayUnion(['ijazah_${certificate.attestation.toLowerCase().replaceAll(' ', '_')}']),
    });
  }
}
