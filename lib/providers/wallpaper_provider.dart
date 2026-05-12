import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wallpaper_model.dart';
import '../services/firebase_service.dart';

class WallpaperProvider extends ChangeNotifier {
  final FirebaseService _service = FirebaseService();

  List<WallpaperModel> _wallpapers = [];
  List<WallpaperModel> _featuredWallpapers = [];
  List<WallpaperModel> _aiPicks = [];
  List<WallpaperModel> _searchResults = [];
  List<CategoryModel> _categories = [];
  Set<String> _favorites = {};
  String _selectedCategory = 'All';
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String _searchQuery = '';

  // Getters
  List<WallpaperModel> get wallpapers => _wallpapers;
  List<WallpaperModel> get featuredWallpapers => _featuredWallpapers;
  List<WallpaperModel> get aiPicks => _aiPicks;
  List<WallpaperModel> get searchResults => _searchResults;
  List<CategoryModel> get categories => _categories;
  Set<String> get favorites => _favorites;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;

  List<WallpaperModel> get favoriteWallpapers =>
      _wallpapers.where((w) => _favorites.contains(w.id)).toList();

  bool isFavorite(String id) => _favorites.contains(id);

  Future<void> initialize() async {
    await loadFavorites();
    await fetchWallpapers();
    await fetchFeatured();
    await fetchAIPicks();
    await fetchCategories();
  }

  Future<void> fetchWallpapers({bool refresh = false}) async {
    if (refresh) {
      _wallpapers = [];
      _hasMore = true;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Use sample data for demo (replace with Firebase in production)
      await Future.delayed(const Duration(milliseconds: 600));
      final data = SampleData.generateWallpapers(20);
      _wallpapers = data;
      _hasMore = true;
    } catch (e) {
      developer.log('Error fetching wallpapers', error: e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMoreWallpapers() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 800));
      final moreData = SampleData.generateWallpapers(10);
      _wallpapers.addAll(moreData);
      _hasMore = _wallpapers.length < 100;
    } catch (e) {
      developer.log('Error loading more', error: e);
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> fetchFeatured() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _featuredWallpapers = SampleData.generateWallpapers(5);
    } catch (e) {
      developer.log('Error fetching featured', error: e);
    }
    notifyListeners();
  }

  Future<void> fetchAIPicks() async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      _aiPicks = SampleData.generateWallpapers(15);
    } catch (e) {
      developer.log('Error fetching AI picks', error: e);
    }
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    try {
      _categories = SampleData.categories;
    } catch (e) {
      developer.log('Error fetching categories', error: e);
    }
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    fetchWallpapers(refresh: true);
    notifyListeners();
  }

  Future<void> search(String query) async {
    _searchQuery = query;
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _searchResults = SampleData.generateWallpapers(12)
          .where((w) =>
              w.title.toLowerCase().contains(query.toLowerCase()) ||
              w.category.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      developer.log('Search error', error: e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFavorite(String wallpaperId) async {
    if (_favorites.contains(wallpaperId)) {
      _favorites.remove(wallpaperId);
      await _service.removeFromFavorites(wallpaperId);
    } else {
      _favorites.add(wallpaperId);
      await _service.addToFavorites(wallpaperId);
    }
    await saveFavorites();
    notifyListeners();
  }

  Future<void> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('favorites') ?? [];
      _favorites = saved.toSet();
    } catch (e) {
      developer.log('Error loading favorites', error: e);
    }
    notifyListeners();
  }

  Future<void> saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorites', _favorites.toList());
    } catch (e) {
      developer.log('Error saving favorites', error: e);
    }
  }
}
