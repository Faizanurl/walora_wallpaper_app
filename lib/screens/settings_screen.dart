import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = true;
  bool _autoWallpaper = false;
  bool _cloudSync = true;
  final String _fontSize = 'Medium';
  final String _changeInterval = '1 Hour';
  final String _imageQuality = 'High';

  final _accentColors = [
    const Color(0xFF3B82F6),
    const Color(0xFF06B6D4),
    const Color(0xFF10B981),
    const Color(0xFFF59E0B),
    const Color(0xFFEC4899),
  ];

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
                    'Settings',
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
                  const _SectionLabel('Appearance'),
                  _SettingsTile(
                    icon: Icons.dark_mode_outlined,
                    label: 'Dark Mode',
                    trailing: Switch(
                      value: _darkMode,
                      onChanged: (v) => setState(() => _darkMode = v),
                      activeThumbColor: AppColors.accentBlue,
                    ),
                  ).animate(delay: 100.ms).fadeIn().slideX(begin: 0.2),

                  _SettingsTile(
                    icon: Icons.palette_outlined,
                    label: 'Accent Color',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: _accentColors
                          .map((c) => GestureDetector(
                                onTap: () {},
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  margin: const EdgeInsets.only(left: 6),
                                  decoration: BoxDecoration(
                                    color: c,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ).animate(delay: 150.ms).fadeIn().slideX(begin: 0.2),

                  _SettingsTile(
                    icon: Icons.format_size,
                    label: 'Font Size',
                    trailing: Text(_fontSize,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                    onTap: () {},
                  ).animate(delay: 200.ms).fadeIn().slideX(begin: 0.2),

                  const SizedBox(height: 16),
                  const _SectionLabel('General'),

                  _SettingsTile(
                    icon: Icons.wallpaper,
                    label: 'Auto Wallpaper Changer',
                    trailing: Switch(
                      value: _autoWallpaper,
                      onChanged: (v) => setState(() => _autoWallpaper = v),
                      activeThumbColor: AppColors.accentBlue,
                    ),
                  ).animate(delay: 250.ms).fadeIn().slideX(begin: 0.2),

                  _SettingsTile(
                    icon: Icons.timer_outlined,
                    label: 'Change Interval',
                    trailing: Text(_changeInterval,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                    onTap: () {},
                  ).animate(delay: 300.ms).fadeIn().slideX(begin: 0.2),

                  _SettingsTile(
                    icon: Icons.folder_outlined,
                    label: 'Download Directory',
                    trailing: const Text('Internal Storage',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                    onTap: () {},
                  ).animate(delay: 350.ms).fadeIn().slideX(begin: 0.2),

                  _SettingsTile(
                    icon: Icons.high_quality_outlined,
                    label: 'Image Quality',
                    trailing: Text(_imageQuality,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                    onTap: () {},
                  ).animate(delay: 400.ms).fadeIn().slideX(begin: 0.2),

                  _SettingsTile(
                    icon: Icons.cloud_sync_outlined,
                    label: 'Cloud Sync',
                    trailing: Switch(
                      value: _cloudSync,
                      onChanged: (v) => setState(() => _cloudSync = v),
                      activeThumbColor: AppColors.accentBlue,
                    ),
                  ).animate(delay: 450.ms).fadeIn().slideX(begin: 0.2),

                  const SizedBox(height: 16),
                  const _SectionLabel('About'),

                  _SettingsTile(
                    icon: Icons.star_outline,
                    label: 'Rate Us',
                    onTap: () {},
                  ).animate(delay: 500.ms).fadeIn().slideX(begin: 0.2),

                  const _SettingsTile(
                    icon: Icons.info_outline,
                    label: 'Version',
                    trailing: Text('1.0.0',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                  ).animate(delay: 550.ms).fadeIn().slideX(begin: 0.2),

                  const SizedBox(height: 16),

                  // Sign out
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.accentPink.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.accentPink.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout,
                              color: AppColors.accentPink, size: 18),
                          SizedBox(width: 8),
                          Text('Sign Out',
                              style: TextStyle(
                                  color: AppColors.accentPink,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ).animate(delay: 600.ms).fadeIn(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile(
      {required this.icon, required this.label, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accentBlue, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ),
            if (trailing != null) trailing!,
            if (onTap != null && trailing == null)
              const Icon(Icons.chevron_right,
                  color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
