import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../providers/user_provider.dart';
import '../services/firebase_service.dart';
import '../models/wallpaper_model.dart';
import 'premium_screen.dart';

class UploadWallpaperScreen extends StatefulWidget {
  const UploadWallpaperScreen({super.key});

  @override
  State<UploadWallpaperScreen> createState() => _UploadWallpaperScreenState();
}

class _UploadWallpaperScreenState extends State<UploadWallpaperScreen> {
  File? _selectedImage;
  final _titleController = TextEditingController();
  final _tagsController = TextEditingController();
  String _selectedCategory = 'Nature';
  bool _isPremium = false;
  bool _isUploading = false;
  double _uploadProgress = 0;
  String _uploadStatus = '';

  final _categories = [
    'Nature',
    'Anime',
    'Abstract',
    'Space',
    'Minimal',
    'City',
    'Cars',
    'Dark'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      setState(() => _isPremium = userProvider.isPremium);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _tagsController.dispose();
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
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
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
                  const SizedBox(width: 14),
                  const Text(
                    'Upload Wallpaper',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  // Premium badge
                  Consumer<UserProvider>(
                    builder: (context, user, _) => user.isPremium
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.workspace_premium,
                                    color: Colors.white, size: 12),
                                SizedBox(width: 4),
                                Text('Premium',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ).animate().fadeIn(),

            Expanded(
              child: Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  if (!userProvider.isPremium) {
                    return _buildPremiumGate(context);
                  }
                  return _buildUploadForm(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Premium Gate ─────────────────────────────────────────────────────────

  Widget _buildPremiumGate(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentOrange.withValues(alpha: 0.2),
                    AppColors.accentPink.withValues(alpha: 0.2),
                  ],
                ),
                border: Border.all(
                    color: AppColors.accentOrange.withValues(alpha: 0.4),
                    width: 2),
              ),
              child: const Icon(Icons.lock_rounded,
                  color: AppColors.accentOrange, size: 48),
            )
                .animate()
                .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut),

            const SizedBox(height: 24),

            const Text(
              'Premium Feature',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ).animate(delay: 200.ms).fadeIn(),

            const SizedBox(height: 10),

            const Text(
              'Only Premium members can upload\nwallpapers to the community.\n\nUpgrade now to share your\nbeautiful wallpapers with everyone!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 15, height: 1.6),
            ).animate(delay: 300.ms).fadeIn(),

            const SizedBox(height: 32),

            // Features teaser
            ...[
              '✅  Upload unlimited wallpapers',
              '✅  Get featured on the home feed',
              '✅  Track your downloads & likes',
              '✅  Build your creator profile',
            ].asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Text(
                      e.value,
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 14),
                    ),
                  )
                      .animate(delay: Duration(milliseconds: 400 + e.key * 70))
                      .fadeIn()
                      .slideX(begin: 0.2),
                )),

            const SizedBox(height: 28),

            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PremiumScreen()),
              ),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.workspace_premium,
                        color: Colors.white, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Upgrade to Premium',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16),
                    ),
                  ],
                ),
              ),
            )
                .animate(delay: 700.ms)
                .fadeIn()
                .scale(begin: const Offset(0.9, 0.9)),
          ],
        ),
      ),
    );
  }

  // ─── Upload Form ──────────────────────────────────────────────────────────

  Widget _buildUploadForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image picker area
          GestureDetector(
            onTap: _pickImage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _selectedImage != null
                      ? AppColors.accentBlue.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.1),
                  width: 1.5,
                ),
                image: _selectedImage != null
                    ? DecorationImage(
                        image: FileImage(_selectedImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _selectedImage == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.accentBlue.withValues(alpha: 0.2),
                                AppColors.accentPurple.withValues(alpha: 0.2),
                              ],
                            ),
                          ),
                          child: const Icon(Icons.add_photo_alternate_outlined,
                              color: AppColors.accentBlue, size: 30),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Tap to select image',
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'JPG, PNG up to 20MB • Min 1080x1920',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 12),
                        ),
                      ],
                    )
                  : Stack(
                      children: [
                        Positioned(
                          top: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedImage = null),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                        const Positioned(
                          bottom: 10,
                          left: 10,
                          child: GlassContainer(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            borderRadius: 8,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle,
                                    color: AppColors.accentGreen, size: 14),
                                SizedBox(width: 5),
                                Text('Image selected',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ).animate().fadeIn().slideY(begin: 0.2),

          const SizedBox(height: 20),

          // Title field
          _fieldLabel('Title *'),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'e.g. Mountain Sunset Reflection',
              prefixIcon:
                  Icon(Icons.title, color: AppColors.textMuted, size: 20),
            ),
          ).animate(delay: 100.ms).fadeIn(),

          const SizedBox(height: 14),

          // Category
          _fieldLabel('Category *'),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: _categories.length,
              itemBuilder: (context, i) => GestureDetector(
                onTap: () => setState(() => _selectedCategory = _categories[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: _selectedCategory == _categories[i]
                        ? const LinearGradient(colors: [
                            AppColors.accentBlue,
                            AppColors.accentPurple
                          ])
                        : null,
                    color: _selectedCategory == _categories[i]
                        ? null
                        : AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedCategory == _categories[i]
                          ? Colors.transparent
                          : Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Text(
                    _categories[i],
                    style: TextStyle(
                      color: _selectedCategory == _categories[i]
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ).animate(delay: 150.ms).fadeIn(),

          const SizedBox(height: 14),

          // Tags
          _fieldLabel('Tags (optional)'),
          TextField(
            controller: _tagsController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'mountain, nature, sunset  (comma separated)',
              prefixIcon: Icon(Icons.tag, color: AppColors.textMuted, size: 20),
            ),
          ).animate(delay: 200.ms).fadeIn(),

          const SizedBox(height: 14),

          // Premium checkbox
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _isPremium = !_isPremium),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      gradient: _isPremium
                          ? const LinearGradient(
                              colors: [Color(0xFFF59E0B), Color(0xFFEF4444)])
                          : null,
                      color: _isPremium ? null : AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _isPremium
                            ? Colors.transparent
                            : Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: _isPremium
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mark as Premium Wallpaper',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'Only premium members can download this',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.workspace_premium,
                    color: AppColors.accentOrange, size: 20),
              ],
            ),
          ).animate(delay: 250.ms).fadeIn(),

          const SizedBox(height: 24),

          // Upload progress
          if (_isUploading) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: AppColors.accentBlue, strokeWidth: 2),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _uploadStatus,
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: _uploadProgress,
                    backgroundColor: AppColors.darkSurface,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.accentBlue),
                    borderRadius: BorderRadius.circular(4),
                    minHeight: 6,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Submit button
          GradientButton(
            label: 'Upload Wallpaper',
            icon: Icons.cloud_upload_rounded,
            height: 54,
            isLoading: _isUploading,
            onTap: _submit,
          ).animate(delay: 300.ms).fadeIn(),

          const SizedBox(height: 16),

          // Guidelines
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.accentBlue.withValues(alpha: 0.2)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: AppColors.accentBlue, size: 16),
                    SizedBox(width: 6),
                    Text('Upload Guidelines',
                        style: TextStyle(
                            color: AppColors.accentBlue,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '• Minimum resolution: 1080 x 1920\n'
                  '• Max file size: 20MB (JPG or PNG)\n'
                  '• No watermarks or logos\n'
                  '• You must own the rights to the image\n'
                  '• No adult or offensive content',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.6),
                ),
              ],
            ),
          ).animate(delay: 350.ms).fadeIn(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        label,
        style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 95,
    );
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _submit() async {
    // Validation
    if (_selectedImage == null) {
      _showSnack('Please select an image', isError: true);
      return;
    }
    if (_titleController.text.trim().isEmpty) {
      _showSnack('Please enter a title', isError: true);
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
      _uploadStatus = 'Preparing upload...';
    });

    try {
      // Simulate upload steps
      setState(() {
        _uploadStatus = 'Uploading image...';
        _uploadProgress = 0.1;
      });
      await Future.delayed(const Duration(milliseconds: 600));

      setState(() {
        _uploadProgress = 0.4;
      });
      await Future.delayed(const Duration(milliseconds: 600));

      // Upload to Firebase Storage
      final fileName = 'wp_${DateTime.now().millisecondsSinceEpoch}';
      setState(() {
        _uploadStatus = 'Processing...';
        _uploadProgress = 0.6;
      });

      final imageUrl =
          await FirebaseService().uploadWallpaper(_selectedImage!, fileName);

      setState(() {
        _uploadStatus = 'Saving metadata...';
        _uploadProgress = 0.85;
      });

      // Save metadata to Firestore
      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();
      final wallpaper = WallpaperModel(
        id: fileName,
        imageUrl: imageUrl,
        thumbnailUrl: imageUrl,
        title: _titleController.text.trim(),
        category: _selectedCategory,
        timestamp: DateTime.now(),
        isPremium: _isPremium,
        tags: tags,
      );

      await FirebaseService().addWallpaperMetadata(wallpaper);

      setState(() {
        _uploadProgress = 1.0;
        _uploadStatus = 'Done!';
      });
      await Future.delayed(const Duration(milliseconds: 400));

      setState(() => _isUploading = false);
      if (!mounted) return;

      _showSnack('✅ Wallpaper uploaded successfully!');
      Navigator.pop(context);
    } catch (e) {
      setState(() => _isUploading = false);
      _showSnack('❌ Upload failed: ${e.toString()}', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.accentPink : AppColors.accentGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }
}
