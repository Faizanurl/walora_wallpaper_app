import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/wallpaper_model.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../services/download_service.dart';
import 'package:provider/provider.dart';
import '../providers/wallpaper_provider.dart';

class FullscreenPreviewScreen extends StatefulWidget {
  final WallpaperModel wallpaper;

  const FullscreenPreviewScreen({super.key, required this.wallpaper});

  @override
  State<FullscreenPreviewScreen> createState() =>
      _FullscreenPreviewScreenState();
}

class _FullscreenPreviewScreenState extends State<FullscreenPreviewScreen> {
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Full screen image
            Positioned.fill(
              child: InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: widget.wallpaper.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (_, __) => Container(
                    color: AppColors.darkBg,
                    child: const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.accentBlue),
                    ),
                  ),
                ),
              ),
            ),

            // Controls overlay
            if (_showControls)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    16,
                    MediaQuery.of(context).padding.top + 8,
                    16,
                    16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const GlassContainer(
                          padding: EdgeInsets.all(8),
                          borderRadius: 10,
                          child: Icon(Icons.arrow_back,
                              color: Colors.white, size: 20),
                        ),
                      ),
                      const GlassContainer(
                        padding: EdgeInsets.all(8),
                        borderRadius: 10,
                        child: Icon(Icons.more_horiz,
                            color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),
              ),

            // Bottom actions
            if (_showControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    24,
                    24,
                    24,
                    MediaQuery.of(context).padding.bottom + 24,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _BottomAction(
                        icon: Icons.wallpaper,
                        label: 'Set',
                        onTap: () => _setWallpaper(context),
                      ),
                      _BottomAction(
                        icon: Icons.download_rounded,
                        label: 'Download',
                        onTap: () => _download(context),
                      ),
                      Consumer<WallpaperProvider>(
                        builder: (context, provider, _) {
                          final isFav =
                              provider.isFavorite(widget.wallpaper.id);
                          return _BottomAction(
                            icon:
                                isFav ? Icons.favorite : Icons.favorite_border,
                            label: 'Favorite',
                            color: isFav ? AppColors.accentPink : Colors.white,
                            onTap: () =>
                                provider.toggleFavorite(widget.wallpaper.id),
                          );
                        },
                      ),
                      _BottomAction(
                        icon: Icons.share_rounded,
                        label: 'Share',
                        onTap: () => _share(),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _download(BuildContext context) {
    DownloadService().downloadWallpaper(
      imageUrl: widget.wallpaper.imageUrl,
      fileName: 'wallpaper_${widget.wallpaper.id}',
      wallpaperId: widget.wallpaper.id,
    );
  }

  void _setWallpaper(BuildContext context) {
    _download(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('💾 Wallpaper saved! Set it from your gallery.'),
        backgroundColor: AppColors.accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _share() {
    DownloadService().shareWallpaper(
      imageUrl: widget.wallpaper.imageUrl,
      title: widget.wallpaper.title,
    );
  }
}

class _BottomAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  const _BottomAction({
    required this.icon,
    required this.label,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color ?? Colors.white, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
