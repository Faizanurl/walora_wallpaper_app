import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../providers/wallpaper_provider.dart';
import '../models/wallpaper_model.dart';
import 'wallpaper_detail_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<WallpaperProvider>().loadMoreWallpapers();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Consumer<WallpaperProvider>(
          builder: (context, provider, _) {
            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                // App bar
                SliverToBoxAdapter(
                  child: _buildHeader(context),
                ),

                // Categories
                SliverToBoxAdapter(
                  child: _buildCategories(provider),
                ),

                // Featured
                SliverToBoxAdapter(
                  child: _buildFeaturedSection(provider),
                ),

                // Popular This Week
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Popular This Week',
                    onSeeAll: () {},
                  ),
                ),

                // Masonry grid
                if (provider.isLoading && provider.wallpapers.isEmpty)
                  SliverToBoxAdapter(child: _buildShimmerGrid())
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    sliver: SliverMasonryGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      itemBuilder: (context, index) {
                        if (index >= provider.wallpapers.length) {
                          return provider.isLoadingMore
                              ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.accentBlue,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink();
                        }
                        final wallpaper = provider.wallpapers[index];
                        final height = index % 3 == 0 ? 240.0 : 180.0;
                        return WallpaperCard(
                          wallpaper: wallpaper,
                          isFavorite: provider.isFavorite(wallpaper.id),
                          height: height,
                          onTap: () => _openDetail(context, wallpaper),
                          onFavorite: () =>
                              provider.toggleFavorite(wallpaper.id),
                        )
                            .animate(delay: Duration(milliseconds: index * 50))
                            .fadeIn(duration: 300.ms)
                            .slideY(begin: 0.2, curve: Curves.easeOut);
                      },
                      childCount: provider.wallpapers.length +
                          (provider.isLoadingMore ? 1 : 0),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),
              const Text(
                "Let's find your perfect wallpaper",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ).animate(delay: 100.ms).fadeIn(),
            ],
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.accentBlue, AppColors.accentPurple],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentBlue.withValues(alpha: 0.4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 22),
            ),
          ).animate(delay: 200.ms).fadeIn().scale(
                begin: const Offset(0.5, 0.5),
                curve: Curves.elasticOut,
              ),
        ],
      ),
    );
  }

  Widget _buildCategories(WallpaperProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
              ),
              child: const Row(
                children: [
                  SizedBox(width: 14),
                  Icon(Icons.search, color: AppColors.textMuted, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Search wallpapers...',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                  Spacer(),
                  Icon(Icons.tune, color: AppColors.textMuted, size: 18),
                  SizedBox(width: 14),
                ],
              ),
            ),
          ),
        ),

        // Category horizontal list
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: provider.categories.isNotEmpty
                ? provider.categories.length
                : SampleData.categories.length,
            itemBuilder: (context, i) {
              final cats = provider.categories.isNotEmpty
                  ? provider.categories
                  : SampleData.categories;
              final cat = cats[i];
              return Column(
                children: [
                  GestureDetector(
                    onTap: () => provider.setCategory(cat.name),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: provider.selectedCategory == cat.name
                            ? const LinearGradient(
                                colors: [
                                  AppColors.accentBlue,
                                  AppColors.accentPurple
                                ],
                              )
                            : null,
                        color: provider.selectedCategory == cat.name
                            ? null
                            : AppColors.darkSurface,
                        border: Border.all(
                          color: provider.selectedCategory == cat.name
                              ? Colors.transparent
                              : Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Center(
                        child: Text(cat.icon,
                            style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cat.name,
                    style: TextStyle(
                      color: provider.selectedCategory == cat.name
                          ? AppColors.accentBlue
                          : AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: provider.selectedCategory == cat.name
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedSection(WallpaperProvider provider) {
    if (provider.featuredWallpapers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Featured', onSeeAll: () {}),
        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemCount: provider.featuredWallpapers.length,
            itemBuilder: (context, i) {
              final w = provider.featuredWallpapers[i];
              return GestureDetector(
                onTap: () => _openDetail(context, w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: w.thumbnailUrl,
                        width: 140,
                        height: 190,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          width: 140,
                          height: 190,
                          color: AppColors.darkSurface,
                        ),
                      ),
                      // Lock icon overlay for premium
                      if (w.isPremium)
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.lock_outline,
                                color: Colors.white, size: 14),
                          ),
                        ),
                    ],
                  ),
                ),
              )
                  .animate(delay: Duration(milliseconds: i * 100))
                  .fadeIn()
                  .slideX(begin: 0.3);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: MasonryGridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemCount: 6,
        itemBuilder: (_, i) {
          final height = i % 3 == 0 ? 240.0 : 180.0;
          return Container(
            height: height,
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(14),
            ),
          ).animate(onPlay: (c) => c.repeat()).shimmer(
                duration: 1200.ms,
                color: AppColors.darkElevated,
              );
        },
      ),
    );
  }

  void _openDetail(BuildContext context, WallpaperModel wallpaper) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) =>
            WallpaperDetailScreen(wallpaper: wallpaper),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
