import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/wallpaper_model.dart';
import '../widgets/common_widgets.dart';
import '../providers/wallpaper_provider.dart';
import '../services/download_service.dart';
import 'fullscreen_preview_screen.dart';

class WallpaperDetailScreen extends StatefulWidget {
  final WallpaperModel wallpaper;

  const WallpaperDetailScreen({super.key, required this.wallpaper});

  @override
  State<WallpaperDetailScreen> createState() => _WallpaperDetailScreenState();
}

class _WallpaperDetailScreenState extends State<WallpaperDetailScreen> {
  bool _isDownloading = false;
  double _downloadProgress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          // Background image blur
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: widget.wallpaper.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: AppColors.darkBg),
            ),
          ),
          // Dark overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top bar
                _buildTopBar(context),

                const Spacer(),

                // Info card
                _buildInfoCard(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const GlassContainer(
              padding: EdgeInsets.all(10),
              borderRadius: 12,
              child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          Consumer<WallpaperProvider>(
            builder: (context, provider, _) {
              final isFav = provider.isFavorite(widget.wallpaper.id);
              return GestureDetector(
                onTap: () => provider.toggleFavorite(widget.wallpaper.id),
                child: GlassContainer(
                  padding: const EdgeInsets.all(10),
                  borderRadius: 12,
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? AppColors.accentPink : Colors.white,
                    size: 20,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildInfoCard(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      opacity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + subtitle
          Text(
            widget.wallpaper.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.wallpaper.category,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 14),

          // Author
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(widget.wallpaper.authorAvatar),
                backgroundColor: AppColors.darkSurface,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.wallpaper.author,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.accentBlue),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Follow',
                  style: TextStyle(
                    color: AppColors.accentBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stats
          Row(
            children: [
              _StatItem(
                value: widget.wallpaper.rating.toString(),
                label: 'Rating',
              ),
              const SizedBox(width: 1),
              _divider(),
              const SizedBox(width: 1),
              _StatItem(
                value: _formatNum(widget.wallpaper.downloads),
                label: 'Downloads',
              ),
              _divider(),
              _StatItem(
                value: widget.wallpaper.resolution,
                label: 'Resolution',
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: GradientButton(
                  label: 'Set Wallpaper',
                  icon: Icons.wallpaper,
                  height: 46,
                  isLoading: _isDownloading,
                  onTap: () => _onSetWallpaper(context),
                ),
              ),
              const SizedBox(width: 10),
              _ActionIconButton(
                icon: Icons.download_outlined,
                onTap: () => _onDownload(context),
                isLoading: _isDownloading,
                progress: _downloadProgress,
              ),
              const SizedBox(width: 10),
              _ActionIconButton(
                icon: Icons.fullscreen,
                onTap: () => _openFullscreen(context),
              ),
              const SizedBox(width: 10),
              _ActionIconButton(
                icon: Icons.share_outlined,
                onTap: () => _onShare(context),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .slideY(begin: 0.3, duration: 400.ms, curve: Curves.easeOut)
        .fadeIn();
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 30,
      color: Colors.white.withValues(alpha: 0.15),
      margin: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  String _formatNum(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  Future<void> _onDownload(BuildContext context) async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    final success = await DownloadService().downloadWallpaper(
      imageUrl: widget.wallpaper.imageUrl,
      fileName: 'wallpaper_${widget.wallpaper.id}',
      wallpaperId: widget.wallpaper.id,
      onProgress: (p) => setState(() => _downloadProgress = p),
    );

    if (!mounted || !context.mounted) return;

    setState(() => _isDownloading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? '✅ Wallpaper saved to gallery!' : '❌ Download failed',
        ),
        backgroundColor: success ? AppColors.accentGreen : AppColors.accentPink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _onSetWallpaper(BuildContext context) async {
    await _onDownload(context);
  }

  void _openFullscreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullscreenPreviewScreen(wallpaper: widget.wallpaper),
      ),
    );
  }

  void _onShare(BuildContext context) {
    DownloadService().shareWallpaper(
      imageUrl: widget.wallpaper.imageUrl,
      title: widget.wallpaper.title,
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isLoading;
  final double progress;

  const _ActionIconButton({
    required this.icon,
    this.onTap,
    this.isLoading = false,
    this.progress = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        width: 46,
        height: 46,
        padding: EdgeInsets.zero,
        borderRadius: 12,
        child: isLoading
            ? CircularProgressIndicator(
                value: progress > 0 ? progress : null,
                color: AppColors.accentBlue,
                strokeWidth: 2,
              )
            : Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
