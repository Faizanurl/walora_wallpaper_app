import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _lastErrorMessage;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  String? get lastErrorMessage => _lastErrorMessage;

  bool get isLoggedIn => _auth.currentUser != null;
  bool get isGuest => _auth.currentUser?.isAnonymous ?? false;

  Future<UserCredential?> signInWithGoogle() async {
    _lastErrorMessage = null;

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _lastErrorMessage = 'Google sign in cancelled';
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      await _syncUserDocument(userCredential.user!);
      return userCredential;
    } catch (e, stackTrace) {
      _lastErrorMessage = _friendlyAuthError(e);
      developer.log('Google sign in error', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<UserCredential?> signInAnonymously() async {
    _lastErrorMessage = null;

    try {
      final userCredential = await _auth.signInAnonymously();
      await _syncUserDocument(userCredential.user!);
      return userCredential;
    } catch (e, stackTrace) {
      _lastErrorMessage = _friendlyAuthError(e);
      developer.log('Anonymous sign in error',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> _syncUserDocument(User user) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        await userDoc.set({
          'user_id': user.uid,
          'name':
              user.displayName ?? (user.isAnonymous ? 'Guest User' : 'User'),
          'email': user.email ?? '',
          'avatar': user.photoURL ?? '',
          'is_premium': false,
          'downloads': 0,
          'favorites_count': 0,
          'collections_count': 0,
          'created_at': FieldValue.serverTimestamp(),
          'last_login': FieldValue.serverTimestamp(),
        });
      } else {
        await userDoc.update({
          'last_login': FieldValue.serverTimestamp(),
        });
      }
    } catch (e, stackTrace) {
      developer.log(
        'User signed in, but Firestore profile sync failed',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  String _friendlyAuthError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'network-request-failed':
          return 'Network error. Check internet and try again.';
        case 'operation-not-allowed':
          return 'This sign in provider is disabled in Firebase Console.';
        case 'account-exists-with-different-credential':
          return 'This email is already linked with another sign in method.';
        case 'invalid-credential':
          return 'Invalid Firebase credential. Check Google sign in setup.';
        default:
          return error.message ?? 'Firebase auth failed: ${error.code}';
      }
    }

    return 'Sign in failed. Check Firebase/Google configuration.';
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data();
  }
}
