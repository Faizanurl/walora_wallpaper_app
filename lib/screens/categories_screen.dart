import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../providers/wallpaper_provider.dart';
import '../models/wallpaper_model.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const GlassContainer(
                      padding: EdgeInsets.all(10),
                      borderRadius: 12,
                      child:
                          Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Categories',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  const GlassContainer(
                    padding: EdgeInsets.all(10),
                    borderRadius: 12,
                    child: Icon(Icons.search, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ).animate().fadeIn(),
            Expanded(
              child: Consumer<WallpaperProvider>(
                builder: (context, provider, _) {
                  final cats = provider.categories.isNotEmpty
                      ? provider.categories
                      : SampleData.categories;
                  return MasonryGridView.count(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    itemCount: cats.length,
                    itemBuilder: (context, i) {
                      final cat = cats[i];
                      return GestureDetector(
                        onTap: () {
                          provider.setCategory(cat.name);
                          Navigator.pop(context);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              Image.network(
                                cat.coverUrl,
                                height: i % 2 == 0 ? 160.0 : 130.0,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: i % 2 == 0 ? 160.0 : 130.0,
                                  color: AppColors.darkSurface,
                                ),
                              ),
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.7)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 12,
                                left: 12,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(cat.icon,
                                        style: const TextStyle(fontSize: 20)),
                                    const SizedBox(height: 2),
                                    Text(
                                      cat.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      '${cat.count}+',
                                      style: TextStyle(
                                        color:
                                            Colors.white.withValues(alpha: 0.7),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                          .animate(delay: Duration(milliseconds: i * 70))
                          .fadeIn()
                          .scale(
                            begin: const Offset(0.9, 0.9),
                            curve: Curves.easeOut,
                          );
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
