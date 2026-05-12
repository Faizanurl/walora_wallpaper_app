import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/wallpaper_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─── Wallpapers ───────────────────────────────────────────────

  Stream<List<WallpaperModel>> getWallpapers({
    String? category,
    int limit = 20,
    DocumentSnapshot? lastDoc,
  }) {
    Query query = _firestore
        .collection('wallpapers')
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }
    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => WallpaperModel.fromFirestore(doc)).toList());
  }

  Future<List<WallpaperModel>> getWallpapersPaginated({
    String? category,
    int limit = 20,
    DocumentSnapshot? lastDoc,
  }) async {
    Query query = _firestore
        .collection('wallpapers')
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }
    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => WallpaperModel.fromFirestore(doc))
        .toList();
  }

  Future<List<WallpaperModel>> searchWallpapers(String query) async {
    final snapshot = await _firestore
        .collection('wallpapers')
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(20)
        .get();
    return snapshot.docs
        .map((doc) => WallpaperModel.fromFirestore(doc))
        .toList();
  }

  Future<List<WallpaperModel>> getFeaturedWallpapers() async {
    final snapshot = await _firestore
        .collection('wallpapers')
        .where('is_featured', isEqualTo: true)
        .limit(10)
        .get();
    return snapshot.docs
        .map((doc) => WallpaperModel.fromFirestore(doc))
        .toList();
  }

  Future<List<WallpaperModel>> getAIPicksWallpapers() async {
    final snapshot = await _firestore
        .collection('wallpapers')
        .orderBy('rating', descending: true)
        .limit(20)
        .get();
    return snapshot.docs
        .map((doc) => WallpaperModel.fromFirestore(doc))
        .toList();
  }

  Future<void> incrementDownloads(String wallpaperId) async {
    await _firestore.collection('wallpapers').doc(wallpaperId).update({
      'downloads': FieldValue.increment(1),
    });
  }

  Future<void> toggleLike(String wallpaperId, bool isLiked) async {
    await _firestore.collection('wallpapers').doc(wallpaperId).update({
      'likes': FieldValue.increment(isLiked ? 1 : -1),
    });
  }

  // ─── Categories ───────────────────────────────────────────────

  Future<List<CategoryModel>> getCategories() async {
    final snapshot = await _firestore.collection('categories').get();
    return snapshot.docs
        .map((doc) => CategoryModel.fromFirestore(doc))
        .toList();
  }

  // ─── Users / Favorites ────────────────────────────────────────

  Future<void> addToFavorites(String wallpaperId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(wallpaperId)
        .set({'timestamp': FieldValue.serverTimestamp()});
  }

  Future<void> removeFromFavorites(String wallpaperId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(wallpaperId)
        .delete();
  }

  Future<List<String>> getFavoriteIds() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<void> addToDownloadHistory(String wallpaperId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('downloads')
        .doc(wallpaperId)
        .set({'timestamp': FieldValue.serverTimestamp()});
  }

  // ─── Admin: Upload ─────────────────────────────────────────────

  Future<String> uploadWallpaper(File file, String fileName) async {
    final ref = _storage.ref().child('wallpapers/$fileName');
    final task = await ref.putFile(file);
    return await task.ref.getDownloadURL();
  }

  Future<void> addWallpaperMetadata(WallpaperModel wallpaper) async {
    await _firestore
        .collection('wallpapers')
        .doc(wallpaper.id)
        .set(wallpaper.toFirestore());
  }

  Future<void> deleteWallpaper(String wallpaperId) async {
    await _firestore.collection('wallpapers').doc(wallpaperId).delete();
  }
}
