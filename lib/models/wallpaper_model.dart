import 'package:cloud_firestore/cloud_firestore.dart';

class WallpaperModel {
  final String id;
  final String imageUrl;
  final String thumbnailUrl;
  final String title;
  final String category;
  final String author;
  final String authorAvatar;
  final int likes;
  final int downloads;
  final String resolution;
  final DateTime timestamp;
  final bool isPremium;
  final List<String> tags;
  final double rating;

  WallpaperModel({
    required this.id,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.title,
    required this.category,
    this.author = 'Unknown',
    this.authorAvatar = '',
    this.likes = 0,
    this.downloads = 0,
    this.resolution = '1920x1080',
    required this.timestamp,
    this.isPremium = false,
    this.tags = const [],
    this.rating = 4.5,
  });

  factory WallpaperModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WallpaperModel(
      id: doc.id,
      imageUrl: data['image_url'] ?? '',
      thumbnailUrl: data['thumbnail_url'] ?? data['image_url'] ?? '',
      title: data['title'] ?? 'Untitled',
      category: data['category'] ?? 'Nature',
      author: data['author'] ?? 'Unknown',
      authorAvatar: data['author_avatar'] ?? '',
      likes: data['likes'] ?? 0,
      downloads: data['downloads'] ?? 0,
      resolution: data['resolution'] ?? '1920x1080',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPremium: data['is_premium'] ?? false,
      tags: List<String>.from(data['tags'] ?? []),
      rating: (data['rating'] ?? 4.5).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'image_url': imageUrl,
      'thumbnail_url': thumbnailUrl,
      'title': title,
      'category': category,
      'author': author,
      'author_avatar': authorAvatar,
      'likes': likes,
      'downloads': downloads,
      'resolution': resolution,
      'timestamp': Timestamp.fromDate(timestamp),
      'is_premium': isPremium,
      'tags': tags,
      'rating': rating,
    };
  }

  WallpaperModel copyWith({
    int? likes,
    int? downloads,
  }) {
    return WallpaperModel(
      id: id,
      imageUrl: imageUrl,
      thumbnailUrl: thumbnailUrl,
      title: title,
      category: category,
      author: author,
      authorAvatar: authorAvatar,
      likes: likes ?? this.likes,
      downloads: downloads ?? this.downloads,
      resolution: resolution,
      timestamp: timestamp,
      isPremium: isPremium,
      tags: tags,
      rating: rating,
    );
  }
}

class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final int count;
  final String coverUrl;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.count,
    required this.coverUrl,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? '🌿',
      count: data['count'] ?? 0,
      coverUrl: data['cover_url'] ?? '',
    );
  }
}

class CollectionModel {
  final String id;
  final String name;
  final int count;
  final String coverUrl;

  CollectionModel({
    required this.id,
    required this.name,
    required this.count,
    required this.coverUrl,
  });
}

// Sample data for demo
class SampleData {
  static final List<CategoryModel> categories = [
    CategoryModel(
        id: '1',
        name: 'Nature',
        icon: '🌿',
        count: 1250,
        coverUrl: 'https://picsum.photos/seed/nature/400/600'),
    CategoryModel(
        id: '2',
        name: 'Anime',
        icon: '🎌',
        count: 750,
        coverUrl: 'https://picsum.photos/seed/anime/400/600'),
    CategoryModel(
        id: '3',
        name: 'Abstract',
        icon: '🎨',
        count: 980,
        coverUrl: 'https://picsum.photos/seed/abstract/400/600'),
    CategoryModel(
        id: '4',
        name: 'Space',
        icon: '🚀',
        count: 820,
        coverUrl: 'https://picsum.photos/seed/space/400/600'),
    CategoryModel(
        id: '5',
        name: 'Minimal',
        icon: '⬜',
        count: 850,
        coverUrl: 'https://picsum.photos/seed/minimal/400/600'),
    CategoryModel(
        id: '6',
        name: 'City',
        icon: '🏙️',
        count: 720,
        coverUrl: 'https://picsum.photos/seed/city/400/600'),
    CategoryModel(
        id: '7',
        name: 'Cars',
        icon: '🚗',
        count: 540,
        coverUrl: 'https://picsum.photos/seed/cars/400/600'),
    CategoryModel(
        id: '8',
        name: 'Dark',
        icon: '🌑',
        count: 430,
        coverUrl: 'https://picsum.photos/seed/dark/400/600'),
  ];

  static List<WallpaperModel> generateWallpapers(int count) {
    final seeds = [
      'forest',
      'mountain',
      'ocean',
      'galaxy',
      'city',
      'abstract',
      'anime',
      'sunset',
      'aurora',
      'waterfall',
      'desert',
      'snow'
    ];
    return List.generate(count, (i) {
      final seed = seeds[i % seeds.length];
      return WallpaperModel(
        id: 'wp_$i',
        imageUrl: 'https://picsum.photos/seed/$seed$i/1080/1920',
        thumbnailUrl: 'https://picsum.photos/seed/$seed$i/400/700',
        title: _titles[i % _titles.length],
        category: SampleData.categories[i % SampleData.categories.length].name,
        author: _authors[i % _authors.length],
        authorAvatar: 'https://i.pravatar.cc/150?img=${i % 30 + 1}',
        likes: (100 + i * 37) % 5000,
        downloads: ((200 + i * 53) % 2000000),
        resolution: _resolutions[i % _resolutions.length],
        timestamp: DateTime.now().subtract(Duration(days: i)),
        isPremium: i % 4 == 0,
        rating: 4.0 + (i % 10) * 0.1,
      );
    });
  }

  static const List<String> _titles = [
    'Mountain Reflection',
    'Aurora Dreams',
    'Deep Ocean',
    'Galactic Voyage',
    'Urban Nightscape',
    'Cherry Blossom',
    'Desert Storm',
    'Crystal Waters',
    'Neon City',
    'Ethereal Forest',
    'Cosmic Dust',
    'Misty Mountains',
  ];

  static const List<String> _authors = [
    'Alex Morgan',
    'John Smith',
    'Emma Davis',
    'Chris Wilson',
    'Sarah Lee',
    'Mike Chen',
    'Luna Park',
    'Ryan Torres',
  ];

  static const List<String> _resolutions = [
    '1920x1080',
    '2560x1440',
    '3840x2160',
    '1080x1920',
    '1440x2560',
  ];
}
