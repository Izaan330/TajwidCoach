import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/sheikh_model.dart';

class AuthProvider extends ChangeNotifier {
  final bool isFirebaseAvailable;
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isPremium => _user?.isPremium ?? false;
  bool get isSheikh => _user?.isSheikh ?? false;

  StreamSubscription<DocumentSnapshot>? _userSubscription;

  AuthProvider({required this.isFirebaseAvailable}) {
    if (isFirebaseAvailable) {
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _init();
    } else {
      debugPrint('AuthProvider: Firebase unavailable. Using Guest Mode.');
      _initGuest();
    }
  }

  void _initGuest() {
    _user = null;
  }

  void _init() {
    _auth?.authStateChanges().listen((User? user) async {
      _userSubscription?.cancel();
      if (user == null) {
        _user = null;
        notifyListeners();
      } else {
        _listenToUserDetails(user.uid);
      }
    });
  }

  void _listenToUserDetails(String uid) {
    _userSubscription = _firestore?.collection('users').doc(uid).snapshots().listen((doc) {
      if (doc.exists) {
        _user = UserModel.fromMap(doc.data()!);
      } else {
        // Only set default if we don't have a user already (prevent overwriting local updates)
        if (_user == null || _user?.name == 'Student' || _user?.name == 'Guest Student') {
          _user = UserModel(uid: uid, name: 'Student', phone: '');
        }
      }
      notifyListeners();
    }, onError: (e) {
      debugPrint('Error listening to user details: $e');
    });
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }


  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    try {
      if (isFirebaseAvailable && _auth != null) {
        await _auth!.signInWithEmailAndPassword(email: email, password: password);
      } else {
        await Future.delayed(const Duration(seconds: 1));
        _user = const UserModel(
          uid: 'guest_user_123',
          name: 'Guest Student',
          email: 'guest@example.com',
          phone: '',
          premiumStatus: 'premium',
        );
      }
      _error = null;
    } on FirebaseAuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Sign in failed: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    _setLoading(true);
    try {
      if (isFirebaseAvailable && _auth != null && _firestore != null) {
        final cred = await _auth!.createUserWithEmailAndPassword(
            email: email, password: password);
        
        final newUser = UserModel(
          uid: cred.user!.uid,
          name: name,
          email: email,
          phone: '',
        );

        await _firestore!.collection('users').doc(cred.user!.uid).set(newUser.toMap());
        _user = newUser;
      } else {
        await Future.delayed(const Duration(seconds: 1));
        _user = UserModel(
          uid: 'guest_user_123',
          name: name,
          email: email,
          phone: '',
        );
      }
      _error = null;
    } on FirebaseAuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Account creation failed: $e';
    } finally {
      _setLoading(false);
    }
  }

  String? _verificationId;

  Future<void> signOut() async {
    if (isFirebaseAvailable && _auth != null) {
      await _auth!.signOut();
    }
    _user = null;
    notifyListeners();
  }

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    _setLoading(true);
    _error = null;
    try {
      if (isFirebaseAvailable && _auth != null) {
        await _auth!.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await _auth!.signInWithCredential(credential);
          },
          verificationFailed: (FirebaseAuthException e) {
            _error = e.message;
            _setLoading(false);
          },
          codeSent: (String verificationId, int? resendToken) {
            _verificationId = verificationId;
            _setLoading(false);
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            _verificationId = verificationId;
          },
        );
      } else {
        await Future.delayed(const Duration(seconds: 1));
        _verificationId = 'mock_verification_id';
        _setLoading(false);
      }
    } catch (e) {
      _error = 'Phone verification failed: $e';
      _setLoading(false);
    }
  }

  Future<void> signInWithSmsCode(String smsCode) async {
    _setLoading(true);
    try {
      if (isFirebaseAvailable && _auth != null && _verificationId != null) {
        final credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: smsCode,
        );
        await _auth!.signInWithCredential(credential);
      } else if (_verificationId == 'mock_verification_id') {
        await Future.delayed(const Duration(seconds: 1));
        _user = const UserModel(
          uid: 'mock_user_id',
          name: 'Mock User',
          phone: '+1234567890',
        );
      } else {
        _error = 'Verification session expired. Please try again.';
      }
      _error = null;
    } on FirebaseAuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Sign in failed: $e';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> initDemoUser() async {
    _user = const UserModel(
      uid: 'demo_user',
      name: 'Demo Student',
      email: 'demo@tajwidcoach.ai',
      phone: '',
      premiumStatus: 'premium',
    );
    notifyListeners();
  }

  Future<void> updatePremiumStatus(String status) async {
    if (_user == null) return;
    try {
      if (isFirebaseAvailable && _firestore != null) {
        await _firestore!
            .collection('users')
            .doc(_user!.uid)
            .set({'premiumStatus': status}, SetOptions(merge: true));
      }
      _user = _user!.copyWith(premiumStatus: status);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating premium status: $e');
    }
  }

  Future<void> upgradeToSheikh(SheikhModel sheikhData) async {
    if (_user == null) return;
    _error = null;
    _setLoading(true);
    try {
      bool isRealUser = _auth?.currentUser != null && _auth?.currentUser?.uid == _user!.uid;
      
      if (isFirebaseAvailable && _firestore != null && isRealUser) {
        final batch = _firestore!.batch();
        
        // 1. Update User Role
        batch.set(
          _firestore!.collection('users').doc(_user!.uid),
          {
            'role': 'sheikh',
            'name': sheikhData.name,
            'masjid': sheikhData.masjid,
            'city': sheikhData.city,
          },
          SetOptions(merge: true),
        );

        // 2. Create Sheikh Profile
        batch.set(_firestore!.collection('sheikhs').doc(_user!.uid), sheikhData.toMap());

        await batch.commit();
      } else {
        // Mock Upgrade
        await Future.delayed(const Duration(seconds: 2));
      }
      
      // Update local state
      _user = _user!.copyWith(
        role: 'sheikh',
        name: sheikhData.name,
        masjid: sheikhData.masjid,
        city: sheikhData.city,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error upgrading to sheikh: $e');
      // Fallback to local state upgrade so the UI can proceed in dev mode
      _user = _user!.copyWith(
        role: 'sheikh',
        name: sheikhData.name,
        masjid: sheikhData.masjid,
        city: sheikhData.city,
      );
      _error = null; // Do not block UI
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    _error = null;
    try {
      if (isFirebaseAvailable && _auth != null) {
        await _auth!.sendPasswordResetEmail(email: email);
      } else {
        await Future.delayed(const Duration(seconds: 1));
      }
    } catch (e) {
      _error = 'Failed to send reset email: $e';
    }
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    if (_user == null) return;
    _setLoading(true);
    _error = null;
    try {
      if (isFirebaseAvailable && _auth != null && _firestore != null) {
        final uid = _user!.uid;
        // 1. Delete Firestore Data
        await _firestore!.collection('users').doc(uid).delete();
        // Optionally delete sheikh data if applicable
        await _firestore!.collection('sheikhs').doc(uid).delete();
        
        // 2. Delete Auth User
        await _auth!.currentUser?.delete();
      }
      _user = null;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _error = 'Please log out and log in again to delete your account.';
      } else {
        _error = e.message;
      }
    } catch (e) {
      _error = 'Account deletion failed: $e';
    } finally {
      _setLoading(false);
    }
  }

  void updateUser(UserModel updated) {
    _user = updated;
    notifyListeners();
  }

  /// Force-refreshes the user document from Firestore.
  /// Call this after role upgrades (e.g., becoming a sheikh) to guarantee
  /// the local state reflects the server state immediately.
  Future<void> refreshUserFromFirestore() async {
    if (_user == null || _firestore == null) return;
    try {
      final doc = await _firestore!.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        _user = UserModel.fromMap(doc.data()!);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error refreshing user: $e');
    }
  }
}
