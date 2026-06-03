import 'package:flutter_test/flutter_test.dart';
import 'package:tajwid_coach/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthProvider Verification', () {
    late AuthProvider authProvider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      // Initialize in Guest/Mock mode (isFirebaseAvailable: false)
      authProvider = AuthProvider(isFirebaseAvailable: false);
    });

    test('Initial state in guest mode is authenticated as guest user', () {
      expect(authProvider.isAuthenticated, true);
      expect(authProvider.user?.uid, 'guest_user');
    });

    test('Sign Up (Mock) sets user correctly', () async {
      await authProvider.signUp('test@example.com', 'password123', 'Test User');
      
      expect(authProvider.isAuthenticated, true);
      expect(authProvider.user?.name, 'Test User');
      expect(authProvider.user?.email, 'test@example.com');
      expect(authProvider.error, null);
    });

    test('Sign In (Mock) sets guest user', () async {
      await authProvider.signIn('test@example.com', 'password123');
      
      expect(authProvider.isAuthenticated, true);
      expect(authProvider.user?.uid, 'guest_user_123');
      expect(authProvider.error, null);
    });

    test('Forgot Password (Mock) does not error', () async {
      await authProvider.sendPasswordResetEmail('test@example.com');
      expect(authProvider.error, null);
    });

    test('Sign Out clears user state', () async {
      await authProvider.initDemoUser();
      expect(authProvider.isAuthenticated, true);
      
      await authProvider.signOut();
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.user, null);
    });

    test('Delete Account (Mock) clears user state', () async {
      await authProvider.initDemoUser();
      expect(authProvider.isAuthenticated, true);
      
      await authProvider.deleteAccount();
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.user, null);
    });
  });
}
