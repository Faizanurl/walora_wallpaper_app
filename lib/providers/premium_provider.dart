import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum PremiumPlan { none, monthly, yearly, lifetime }

class PremiumProvider extends ChangeNotifier {
  bool _isPremium = false;
  PremiumPlan _activePlan = PremiumPlan.none;
  DateTime? _expiryDate;
  bool _isLoading = false;

  bool get isPremium => _isPremium;
  PremiumPlan get activePlan => _activePlan;
  DateTime? get expiryDate => _expiryDate;
  bool get isLoading => _isLoading;

  // Can upload wallpapers only if premium
  bool get canUploadWallpapers => _isPremium;

  String get planName {
    switch (_activePlan) {
      case PremiumPlan.monthly:
        return 'Monthly Plan';
      case PremiumPlan.yearly:
        return 'Yearly Plan';
      case PremiumPlan.lifetime:
        return 'Lifetime Plan';
      default:
        return 'Free Plan';
    }
  }

  String get planBadge {
    switch (_activePlan) {
      case PremiumPlan.monthly:
        return 'PRO Monthly';
      case PremiumPlan.yearly:
        return 'PRO Yearly';
      case PremiumPlan.lifetime:
        return 'PRO Lifetime';
      default:
        return 'Free';
    }
  }

  Future<void> initialize() async {
    await _loadFromPrefs();
    await _syncWithFirestore();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPremium = prefs.getBool('is_premium') ?? false;
      final planIndex = prefs.getInt('premium_plan') ?? 0;
      _activePlan = PremiumPlan.values[planIndex];
      final expiryStr = prefs.getString('premium_expiry');
      if (expiryStr != null) {
        _expiryDate = DateTime.tryParse(expiryStr);
        // Check if expired
        if (_expiryDate != null &&
            _expiryDate!.isBefore(DateTime.now()) &&
            _activePlan != PremiumPlan.lifetime) {
          _isPremium = false;
          _activePlan = PremiumPlan.none;
          _expiryDate = null;
        }
      }
    } catch (e) {
      developer.log('Error loading premium prefs', error: e);
    }
    notifyListeners();
  }

  Future<void> _syncWithFirestore() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        final data = doc.data()!;
        _isPremium = data['is_premium'] ?? false;
        final planStr = data['premium_plan'] ?? 'none';
        _activePlan = _planFromString(planStr);

        final expiryTs = data['premium_expiry'] as Timestamp?;
        if (expiryTs != null) {
          _expiryDate = expiryTs.toDate();
          if (_expiryDate!.isBefore(DateTime.now()) &&
              _activePlan != PremiumPlan.lifetime) {
            _isPremium = false;
            _activePlan = PremiumPlan.none;
            _expiryDate = null;
            await _updateFirestore();
          }
        }

        await _saveToPrefs();
        notifyListeners();
      }
    } catch (e) {
      developer.log('Firestore sync error', error: e);
    }
  }

  /// Called after successful payment
  Future<bool> activatePremium(PremiumPlan plan) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate payment processing (replace with actual payment gateway)
      await Future.delayed(const Duration(seconds: 2));

      _isPremium = true;
      _activePlan = plan;

      // Set expiry based on plan
      switch (plan) {
        case PremiumPlan.monthly:
          _expiryDate = DateTime.now().add(const Duration(days: 30));
          break;
        case PremiumPlan.yearly:
          _expiryDate = DateTime.now().add(const Duration(days: 365));
          break;
        case PremiumPlan.lifetime:
          _expiryDate = null; // Never expires
          break;
        default:
          break;
      }

      await _saveToPrefs();
      await _updateFirestore();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      developer.log('Activation error', error: e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> cancelPremium() async {
    _isPremium = false;
    _activePlan = PremiumPlan.none;
    _expiryDate = null;
    await _saveToPrefs();
    await _updateFirestore();
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', _isPremium);
    await prefs.setInt('premium_plan', _activePlan.index);
    if (_expiryDate != null) {
      await prefs.setString('premium_expiry', _expiryDate!.toIso8601String());
    } else {
      await prefs.remove('premium_expiry');
    }
  }

  Future<void> _updateFirestore() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'is_premium': _isPremium,
        'premium_plan': _planToString(_activePlan),
        'premium_expiry':
            _expiryDate != null ? Timestamp.fromDate(_expiryDate!) : null,
        'can_upload': _isPremium,
      });
    } catch (e) {
      developer.log('Firestore update error', error: e);
    }
  }

  PremiumPlan _planFromString(String s) {
    switch (s) {
      case 'monthly':
        return PremiumPlan.monthly;
      case 'yearly':
        return PremiumPlan.yearly;
      case 'lifetime':
        return PremiumPlan.lifetime;
      default:
        return PremiumPlan.none;
    }
  }

  String _planToString(PremiumPlan p) {
    switch (p) {
      case PremiumPlan.monthly:
        return 'monthly';
      case PremiumPlan.yearly:
        return 'yearly';
      case PremiumPlan.lifetime:
        return 'lifetime';
      default:
        return 'none';
    }
  }
}
