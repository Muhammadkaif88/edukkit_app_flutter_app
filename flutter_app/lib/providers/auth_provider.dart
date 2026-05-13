import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/cloudflare_service.dart';

enum UserRole { guest, student, teacher, admin }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final CloudflareService _cloudflareService = CloudflareService();
  UserRole _role = UserRole.guest;
  String _userName = 'Guest';
  String? _userEmail;
  String? _userPhotoUrl;
  bool _isLoading = false;

  UserRole get role => _role;
  String get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userPhotoUrl => _userPhotoUrl;
  bool get isLoading => _isLoading;

  AuthProvider() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        _role = UserRole.guest;
        _userName = 'Guest';
        _userEmail = null;
        _userPhotoUrl = null;
        notifyListeners();
      } else {
        _isLoading = true;
        notifyListeners();
        
        try {
          // Sync user with Cloudflare D1
          final userData = await _cloudflareService.syncUser(
            id: user.uid,
            name: user.displayName ?? 'Student',
            email: user.email ?? '',
            photoUrl: user.photoURL,
          ).timeout(const Duration(seconds: 5));

          // Always capture photo URL from the Firebase user object
          _userEmail = user.email;
          _userPhotoUrl = user.photoURL;

          if (userData != null) {
            final roleStr = userData['role'] as String?;
            _userName = userData['name'] ?? user.displayName ?? 'Student';
            
            if (roleStr == 'admin') {
              _role = UserRole.admin;
            } else if (roleStr == 'teacher') {
              _role = UserRole.teacher;
            } else {
              _role = UserRole.student;
            }
          } else {
            _role = UserRole.student;
            _userName = user.displayName ?? 'Student';
          }
        } catch (e) {
          debugPrint("Cloudflare sync failed, falling back to Firebase: $e");
          _role = UserRole.student;
          _userName = user.displayName ?? 'Student';
          _userEmail = user.email;
          _userPhotoUrl = user.photoURL;
        }
        
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      debugPrint("Sign in failed: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithEmailPassword(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signInWithEmailPassword(email, password);
      // authStateChanges listener will fire and update _userName automatically
    } catch (e) {
      debugPrint("Email sign in failed: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUpWithEmailPassword(String email, String password, String displayName) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signUpWithEmailPassword(email, password, displayName);
      // authStateChanges listener will fire; manually set name as well
      _userName = displayName;
      _role = UserRole.student;
      notifyListeners();
    } catch (e) {
      debugPrint("Email sign up failed: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> uploadProfilePhoto(List<int> imageBytes, String extension) async {
    try {
      final url = await _authService.uploadProfilePhoto(imageBytes, extension);
      _userPhotoUrl = url;
      notifyListeners();
      return url;
    } catch (e) {
      debugPrint('Profile photo upload failed: $e');
      return null;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
  }
}
