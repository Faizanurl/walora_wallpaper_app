import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider extends ChangeNotifier {
  bool _isPremium = false;
  String _premiumPlan = '';
  String _userName = 'Alex Morgan';
  String _userEmail = 'alex.morgan@email.com';
  String _userAvatar = 'https://i.pravatar.cc/150?img=3';
  int _downloads = 128;
  int _favoritesCount = 56;
  int _collectionsCount = 12;
  int _uploadCount = 0;

  bool get isPremium => _isPremium;
  String get premiumPlan => _premiumPlan;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userAvatar => _userAvatar;
  int get downloads => _downloads;
  int get favoritesCount => _favoritesCount;
  int get collectionsCount => _collectionsCount;
  int get uploadCount => _uploadCount;

  Future<void> initialize() async {
    await _loadFromPrefs();
    await _syncFromFirestore();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool('is_premium') ?? false;
    _premiumPlan = prefs.getString('premium_plan') ?? '';
    _uploadCount = prefs.getInt('upload_count') ?? 0;
    notifyListeners();
  }

  Future<void> _syncFromFirestore() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final uid = currentUser?.uid;
      if (uid == null) {
        _userName = 'Guest';
        _userEmail = 'Sign in to sync your profile';
        _userAvatar = 'https://i.pravatar.cc/150?img=3';
        notifyListeners();
        return;
      }

      _userName = currentUser!.displayName ??
          (currentUser.isAnonymous ? 'Guest User' : _userName);
      _userEmail = currentUser.isAnonymous
          ? 'Anonymous account'
          : currentUser.email ?? '';
      _userAvatar = currentUser.photoURL ?? _userAvatar;

      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _isPremium = data['is_premium'] ?? false;
        _premiumPlan = data['premium_plan'] ?? '';
        _userName = data['name'] ?? _userName;
        _userEmail = data['email'] ?? _userEmail;
        _userAvatar = data['avatar'] ?? _userAvatar;
        _downloads = data['downloads'] ?? _downloads;
        _favoritesCount = data['favorites_count'] ?? _favoritesCount;
        _collectionsCount = data['collections_count'] ?? _collectionsCount;
        _uploadCount = data['upload_count'] ?? _uploadCount;
        notifyListeners();
      }
    } catch (_) {
      // Firebase/network errors should not break local profile rendering.
    }
  }

  Future<void> refreshFromAuth() async {
    await _syncFromFirestore();
  }

  Future<void> setPremium(bool value, {String planId = ''}) async {
    _isPremium = value;
    _premiumPlan = planId;

    // Save locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', value);
    await prefs.setString('premium_plan', planId);

    // Sync to Firestore
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'is_premium': value,
          'premium_plan': planId,
          'premium_since': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {}

    notifyListeners();
  }

  Future<void> incrementUploadCount() async {
    _uploadCount++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('upload_count', _uploadCount);
    notifyListeners();
  }

  // For demo: toggle premium directly
  Future<void> togglePremiumDemo() async {
    await setPremium(!_isPremium, planId: _isPremium ? '' : 'yearly');
  }
}
