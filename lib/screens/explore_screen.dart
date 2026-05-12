import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../providers/wallpaper_provider.dart';
import 'wallpaper_detail_screen.dart';
import 'search_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final List<String> _tabs = [
    'All',
    'Nature',
    'Anime',
    'Abstract',
    'Space',
    'Minimal',
    'City'
  ];
  String _selectedTab = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Explore',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ).animate().fadeIn().slideX(begin: -0.2),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    ),
                    child: const GlassContainer(
                      padding: EdgeInsets.all(10),
                      borderRadius: 12,
                      child: Icon(Icons.search, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Filter tabs
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: _tabs.length,
                itemBuilder: (context, i) {
                  final tab = _tabs[i];
                  return CategoryChip(
                    label: tab,
                    isSelected: _selectedTab == tab,
                    onTap: () => setState(() => _selectedTab = tab),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Grid
            Expanded(
              child: Consumer<WallpaperProvider>(
                builder: (context, provider, _) {
                  final wallpapers = provider.wallpapers;
                  if (wallpapers.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.accentBlue),
                    );
                  }
                  return MasonryGridView.count(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    crossAxisCount: 3,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    itemCount: wallpapers.length,
                    itemBuilder: (context, i) {
                      final w = wallpapers[i];
                      final heights = [160.0, 120.0, 140.0];
                      return WallpaperCard(
                        wallpaper: w,
                        isFavorite: provider.isFavorite(w.id),
                        height: heights[i % heights.length],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WallpaperDetailScreen(wallpaper: w),
                          ),
                        ),
                        onFavorite: () => provider.toggleFavorite(w.id),
                      )
                          .animate(delay: Duration(milliseconds: i * 30))
                          .fadeIn(duration: 250.ms);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
