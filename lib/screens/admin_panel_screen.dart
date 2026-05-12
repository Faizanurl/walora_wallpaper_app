import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

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
                    'Admin Panel',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ).animate().fadeIn(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Stats row
                  const Row(
                    children: [
                      _StatCard('Total Wallpapers', '4,560',
                          Icons.photo_library_outlined, AppColors.accentBlue),
                      SizedBox(width: 10),
                      _StatCard('Downloads', '1.2M', Icons.download_rounded,
                          AppColors.accentGreen),
                    ],
                  ).animate(delay: 100.ms).fadeIn(),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      _StatCard('Users', '48K', Icons.people_outline,
                          AppColors.accentPurple),
                      SizedBox(width: 10),
                      _StatCard('Revenue', '\$2.4K', Icons.attach_money,
                          AppColors.accentOrange),
                    ],
                  ).animate(delay: 150.ms).fadeIn(),

                  const SizedBox(height: 20),

                  // Upload button
                  GradientButton(
                    label: 'Upload New Wallpaper',
                    icon: Icons.cloud_upload_outlined,
                    height: 52,
                    onTap: () => _showUploadDialog(context),
                  ).animate(delay: 200.ms).fadeIn(),

                  const SizedBox(height: 16),

                  _AdminTile(
                          icon: Icons.grid_view,
                          label: 'Manage Wallpapers',
                          subtitle: '4,560 total',
                          onTap: () {})
                      .animate(delay: 250.ms)
                      .fadeIn()
                      .slideX(begin: 0.2),
                  _AdminTile(
                          icon: Icons.category_outlined,
                          label: 'Manage Categories',
                          subtitle: '8 categories',
                          onTap: () {})
                      .animate(delay: 300.ms)
                      .fadeIn()
                      .slideX(begin: 0.2),
                  _AdminTile(
                          icon: Icons.bar_chart,
                          label: 'Analytics',
                          subtitle: 'View detailed stats',
                          onTap: () {})
                      .animate(delay: 350.ms)
                      .fadeIn()
                      .slideX(begin: 0.2),
                  _AdminTile(
                          icon: Icons.people_outline,
                          label: 'User Management',
                          subtitle: '48K users',
                          onTap: () {})
                      .animate(delay: 400.ms)
                      .fadeIn()
                      .slideX(begin: 0.2),
                  _AdminTile(
                          icon: Icons.notifications_outlined,
                          label: 'Push Notifications',
                          subtitle: 'Send to all users',
                          onTap: () {})
                      .animate(delay: 450.ms)
                      .fadeIn()
                      .slideX(begin: 0.2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUploadDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Upload Wallpaper',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            GestureDetector(
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.accentBlue.withValues(alpha: 0.3),
                      style: BorderStyle.solid),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload_outlined,
                        color: AppColors.accentBlue, size: 36),
                    SizedBox(height: 8),
                    Text('Tap to select image',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            const TextField(
              decoration: InputDecoration(hintText: 'Title'),
              style: TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            const TextField(
              decoration: InputDecoration(hintText: 'Category'),
              style: TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            GradientButton(
                label: 'Upload',
                height: 48,
                onTap: () => Navigator.pop(context)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _AdminTile(
      {required this.icon,
      required this.label,
      required this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.accentBlue, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
