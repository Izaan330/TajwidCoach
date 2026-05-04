import 'dart:async';
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
  SheikhModel? _currentSheikh;
  bool _isLoading = false;

  StreamSubscription<DocumentSnapshot>? _currentSheikhSubscription;
  StreamSubscription<List<RecordingModel>>? _pendingReviewsSubscription;
  StreamSubscription<List<String>>? _myStudentsSubscription;

  List<SheikhModel> get availableSheikhs => _availableSheikhs;
  SheikhModel? get currentSheikh => _currentSheikh;
  List<RecordingModel> get pendingReviews => _pendingReviews;
  List<String> get myStudentUids => _myStudentUids;
  List<UserModel> get myStudents => 
      _myStudentUids.map((uid) => _studentProfiles[uid] ?? UserModel(uid: uid, name: 'Loading...', phone: '')).toList();
  bool get isLoading => _isLoading;

  bool canAcceptMoreStudents(SheikhModel sheikh) {
    if (sheikh.tier != SheikhTier.basic) return true;
    return (sheikh.students.length) < 10; // Basic limit is 10 students
  }

  SheikhProvider() {
    _fetchAvailableSheikhs();
  }

  Future<void> _fetchAvailableSheikhs() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection('sheikhs')
          .where('isVerified', isEqualTo: true)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        _availableSheikhs = snapshot.docs
            .map((doc) => SheikhModel.fromMap(doc.data()))
            .toList();
      } else {
        // Mock data for testing when Firestore is empty
        _availableSheikhs = _getMockSheikhs();
      }
    } catch (e) {
      debugPrint('Error fetching sheikhs: $e');
      _availableSheikhs = _getMockSheikhs();
    }
    _isLoading = false;
    notifyListeners();
  }

  List<SheikhModel> _getMockSheikhs() {
    return const [
      SheikhModel(
        id: 'mock_1',
        name: 'Sheikh Ahmed Al-Misri',
        englishName: 'Ahmed Al-Misri',
        phone: '+20 123 456 789',
        masjid: 'Al-Azhar Mosque',
        city: 'Cairo',
        rating: 4.9,
        totalStudents: 1250,
        isVerified: true,
        specializations: ['Hafs an Asim', 'Tajwid Theory'],
        bio: 'Senior Sheikh at Al-Azhar with over 15 years of experience in teaching Tajwid and Qira\'at.',
        pricePerSession: 500,
      ),
      SheikhModel(
        id: 'mock_2',
        name: 'Sheikh Abdullah Mansour',
        englishName: 'Abdullah Mansour',
        phone: '+966 50 123 4567',
        masjid: 'Masjid An-Nabawi',
        city: 'Medina',
        rating: 4.8,
        totalStudents: 850,
        isVerified: true,
        specializations: ['Warsh an Nafi', 'Hifz'],
        bio: 'Specialist in Quranic memorization and the Warsh recitation style. Based in the holy city of Medina.',
        pricePerSession: 750,
      ),
      SheikhModel(
        id: 'mock_3',
        name: 'Ustadha Fatima Zahra',
        englishName: 'Fatima Zahra',
        phone: '+44 20 7123 4567',
        masjid: 'Central Mosque',
        city: 'London',
        rating: 5.0,
        totalStudents: 420,
        isVerified: true,
        specializations: ['Child Education', 'Female Only Classes', 'Tajwid'],
        bio: 'Dedicated teacher for children and women, focusing on foundational Tajwid and beautiful recitation.',
        pricePerSession: 400,
      ),
    ];
  }

  /// Listen for pending reviews if the current user is a sheikh.
  void listenToPendingReviews(String sheikhId) {
    // Also fetch current sheikh data
    _listenToCurrentSheikh(sheikhId);
    
    _pendingReviewsSubscription?.cancel();
    _pendingReviewsSubscription = _service.getPendingReviews(sheikhId).listen((recordings) {
      _pendingReviews = recordings;
      notifyListeners();
    });
  }

  void _listenToCurrentSheikh(String sheikhId) {
    _currentSheikhSubscription?.cancel();
    _currentSheikhSubscription = _firestore
        .collection('sheikhs')
        .doc(sheikhId)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        _currentSheikh = SheikhModel.fromMap(doc.data()!);
        notifyListeners();
      } else {
        // Mock fallback for demo/development if doc doesn't exist
        if (_currentSheikh == null) {
          _currentSheikh = SheikhModel(
            id: sheikhId,
            name: 'Sheikh User',
            englishName: 'Sheikh User',
            phone: '',
            masjid: 'Demo Masjid',
            city: 'Demo City',
            isVerified: false,
            isAvailable: true,
          );
          notifyListeners();
        }
      }
    }, onError: (e) {
      debugPrint('Error listening to current sheikh: $e');
    });
  }

  /// Listen for assigned students and fetch their profiles.
  void listenToMyStudents(String sheikhId) {
    _myStudentsSubscription?.cancel();
    _myStudentsSubscription = _service.getSheikhStudentUids(sheikhId).listen((uids) async {
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

  Future<void> toggleAvailability(String sheikhId, bool isAvailable) async {
    // Optimistic update for current sheikh to make UI feel snappy
    if (_currentSheikh != null && _currentSheikh!.id == sheikhId) {
      _currentSheikh = SheikhModel.fromMap({
        ..._currentSheikh!.toMap(),
        'isAvailable': isAvailable,
      });
      notifyListeners();
    }

    try {
      await _firestore.collection('sheikhs').doc(sheikhId).update({
        'isAvailable': isAvailable,
      });
      
      // Update local state in available list if present
      final index = _availableSheikhs.indexWhere((s) => s.id == sheikhId);
      if (index != -1) {
        final updated = SheikhModel.fromMap({
          ..._availableSheikhs[index].toMap(),
          'isAvailable': isAvailable,
        });
        _availableSheikhs[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error toggling availability: $e');
      // Revert local state if needed? For now we just log.
      // If we have a listener, it will eventually sync back to server state.
    }
  }

  @override
  void dispose() {
    _currentSheikhSubscription?.cancel();
    _pendingReviewsSubscription?.cancel();
    _myStudentsSubscription?.cancel();
    super.dispose();
  }

  Stream<List<IjazahCertificate>> getStudentCertificates(String userId) {
    return _firestore
        .collection('certificates')
        .where('studentId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => IjazahCertificate.fromMap(doc.data()))
            .toList());
  }

  Future<void> enrollWithSheikh(String userId, String sheikhId) async {
    // Fetch latest sheikh data to check capacity
    final doc = await _firestore.collection('sheikhs').doc(sheikhId).get();
    if (!doc.exists) throw Exception('Sheikh not found');
    
    final sheikh = SheikhModel.fromMap(doc.data()!);
    if (!canAcceptMoreStudents(sheikh)) {
      throw Exception('This Sheikh has reached their student limit. Try a Sheikh Pro or Madrasa!');
    }

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
