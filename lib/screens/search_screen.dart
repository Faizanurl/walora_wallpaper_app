import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../providers/wallpaper_provider.dart';
import 'wallpaper_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  final _trending = [
    'Mountain',
    'Galaxy',
    'Anime',
    'Sunset',
    'Abstract',
    'Ocean',
    'Forest',
    'Neon'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focus,
                      onChanged: (q) =>
                          context.read<WallpaperProvider>().search(q),
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search wallpapers...',
                        prefixIcon: const Icon(Icons.search,
                            color: AppColors.textMuted, size: 20),
                        suffixIcon: _controller.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _controller.clear();
                                  context.read<WallpaperProvider>().search('');
                                  setState(() {});
                                },
                                child: const Icon(Icons.close,
                                    color: AppColors.textMuted, size: 18),
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 200.ms),

            Expanded(
              child: Consumer<WallpaperProvider>(
                builder: (context, provider, _) {
                  if (provider.searchQuery.isEmpty) {
                    return _buildTrending();
                  }
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.accentBlue),
                    );
                  }
                  if (provider.searchResults.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off,
                              color: AppColors.textMuted, size: 56),
                          const SizedBox(height: 12),
                          Text(
                            'No results for "${provider.searchQuery}"',
                            style:
                                const TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    );
                  }
                  return MasonryGridView.count(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    itemCount: provider.searchResults.length,
                    itemBuilder: (context, i) {
                      final w = provider.searchResults[i];
                      return WallpaperCard(
                        wallpaper: w,
                        isFavorite: provider.isFavorite(w.id),
                        height: i % 3 == 0 ? 240.0 : 180.0,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  WallpaperDetailScreen(wallpaper: w)),
                        ),
                        onFavorite: () => provider.toggleFavorite(w.id),
                      ).animate(delay: Duration(milliseconds: i * 50)).fadeIn();
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

  Widget _buildTrending() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trending Searches',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _trending.asMap().entries.map((e) {
              return GestureDetector(
                onTap: () {
                  _controller.text = e.value;
                  context.read<WallpaperProvider>().search(e.value);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.07)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.trending_up,
                          color: AppColors.accentBlue, size: 14),
                      const SizedBox(width: 5),
                      Text(e.value,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
              )
                  .animate(delay: Duration(milliseconds: e.key * 60))
                  .fadeIn()
                  .slideX(begin: 0.2);
            }).toList(),
          ),
        ],
      ),
    );
  }
}
