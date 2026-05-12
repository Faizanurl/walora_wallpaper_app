import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../providers/wallpaper_provider.dart';
import 'wallpaper_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Favorites',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ).animate().fadeIn(),
                  const GlassContainer(
                    padding: EdgeInsets.all(10),
                    borderRadius: 12,
                    child: Icon(Icons.menu, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),

            // Tab bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accentBlue, AppColors.accentPurple],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'Wallpapers'),
                  Tab(text: 'Collections'),
                ],
              ),
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _WallpapersFavTab(),
                  _CollectionsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WallpapersFavTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<WallpaperProvider>(
      builder: (context, provider, _) {
        final favs = provider.wallpapers
            .where((w) => provider.isFavorite(w.id))
            .toList();

        if (favs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.darkSurface,
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    color: AppColors.textMuted,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Favorites Yet',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap the heart on any wallpaper\nto add it here',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
              ],
            ).animate().fadeIn(),
          );
        }

        return MasonryGridView.count(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          itemCount: favs.length,
          itemBuilder: (context, i) {
            final w = favs[i];
            final height = i % 3 == 0 ? 240.0 : 180.0;
            return WallpaperCard(
              wallpaper: w,
              isFavorite: true,
              height: height,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WallpaperDetailScreen(wallpaper: w),
                ),
              ),
              onFavorite: () => provider.toggleFavorite(w.id),
            ).animate(delay: Duration(milliseconds: i * 50)).fadeIn();
          },
        );
      },
    );
  }
}

class _CollectionsTab extends StatelessWidget {
  final _collections = [
    _Collection(
        'Nature Collection', 56, 'https://picsum.photos/seed/nature1/400/300'),
    _Collection(
        'Anime Collection', 36, 'https://picsum.photos/seed/anime1/400/300'),
    _Collection(
        'Dark Collection', 42, 'https://picsum.photos/seed/dark1/400/300'),
    _Collection(
        'Space Collection', 28, 'https://picsum.photos/seed/space1/400/300'),
    _Collection('Minimal Collection', 30,
        'https://picsum.photos/seed/minimal1/400/300'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemCount: _collections.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return GestureDetector(
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.accentBlue.withValues(alpha: 0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: AppColors.accentBlue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'New Collection',
                    style: TextStyle(
                      color: AppColors.accentBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final col = _collections[i - 1];
        return _CollectionTile(collection: col)
            .animate(delay: Duration(milliseconds: i * 80))
            .fadeIn()
            .slideX(begin: 0.2);
      },
    );
  }
}

class _Collection {
  final String name;
  final int count;
  final String coverUrl;
  _Collection(this.name, this.count, this.coverUrl);
}

class _CollectionTile extends StatelessWidget {
  final _Collection collection;
  const _CollectionTile({required this.collection});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              bottomLeft: Radius.circular(14),
            ),
            child: Image.network(
              collection.coverUrl,
              width: 80,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                  width: 80, height: 72, color: AppColors.darkSurface),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  collection.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${collection.count} Wallpapers',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: AppColors.textMuted, size: 20),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}
