import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import 'settings_screen.dart';
import 'premium_screen.dart';
import 'upload_wallpaper_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Consumer<UserProvider>(
          builder: (context, user, _) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  // ─── Top Bar ────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SettingsScreen())),
                          child: const GlassContainer(
                            padding: EdgeInsets.all(10),
                            borderRadius: 12,
                            child: Icon(Icons.settings_outlined,
                                color: Colors.white, size: 20),
                          ),
                        ),
                        const Text('Profile',
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w600)),
                        const GlassContainer(
                          padding: EdgeInsets.all(10),
                          borderRadius: 12,
                          child: Icon(Icons.notifications_outlined,
                              color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(),

                  const SizedBox(height: 16),

                  // ─── Avatar ─────────────────────────────────────────────
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: user.isPremium
                                ? const Color(0xFFF59E0B)
                                : AppColors.accentBlue,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (user.isPremium
                                      ? const Color(0xFFF59E0B)
                                      : AppColors.accentBlue)
                                  .withValues(alpha: 0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: ClipOval(
                          child: Image.network(
                            user.userAvatar,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.darkSurface,
                              child: const Icon(Icons.person,
                                  color: Colors.white, size: 40),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: AppColors.accentBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.darkBg, width: 2),
                        ),
                        child: const Icon(Icons.edit,
                            color: Colors.white, size: 12),
                      ),
                    ],
                  ).animate(delay: 100.ms).fadeIn().scale(
                      begin: const Offset(0.7, 0.7), curve: Curves.elasticOut),

                  const SizedBox(height: 14),

                  Text(user.userName,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w700))
                      .animate(delay: 200.ms)
                      .fadeIn(),
                  const SizedBox(height: 4),
                  Text(user.userEmail,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13))
                      .animate(delay: 250.ms)
                      .fadeIn(),

                  const SizedBox(height: 12),

                  _AuthActions(
                    isLoggedIn: AuthService().isLoggedIn,
                    isGuest: AuthService().isGuest,
                    onGoogleSignIn: () => _signInWithGoogle(context, user),
                    onGuestSignIn: () => _signInAnonymously(context, user),
                    onSignOut: () => _signOut(context, user),
                  ).animate(delay: 280.ms).fadeIn(),

                  const SizedBox(height: 14),

                  // ─── Premium Badge / Upgrade Button ─────────────────────
                  if (user.isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFEF4444)]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.workspace_premium,
                            color: Colors.white, size: 14),
                        const SizedBox(width: 5),
                        Text(
                          'Premium Member • ${_planLabel(user.premiumPlan)}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      ]),
                    ).animate(delay: 300.ms).fadeIn()
                  else
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PremiumScreen())),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFFF59E0B), Color(0xFFEF4444)]),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                                color: const Color(0xFFF59E0B)
                                    .withValues(alpha: 0.4),
                                blurRadius: 16)
                          ],
                        ),
                        child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.workspace_premium,
                                  color: Colors.white, size: 16),
                              SizedBox(width: 7),
                              Text('⚡ Upgrade to Premium',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800)),
                            ]),
                      ),
                    )
                        .animate(delay: 300.ms)
                        .fadeIn()
                        .scale(begin: const Offset(0.9, 0.9)),

                  const SizedBox(height: 20),

                  // ─── Stats ───────────────────────────────────────────────
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Row(children: [
                      _Stat('${user.downloads}', 'Downloads'),
                      _vdivider(),
                      _Stat('${user.favoritesCount}', 'Favorites'),
                      _vdivider(),
                      _Stat('${user.collectionsCount}', 'Collections'),
                      if (user.isPremium) ...[
                        _vdivider(),
                        _Stat('${user.uploadCount}', 'Uploads')
                      ],
                    ]),
                  ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2),

                  const SizedBox(height: 16),

                  // ─── UPLOAD WALLPAPER BUTTON ─────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const UploadWallpaperScreen())),
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: user.isPremium
                              ? const LinearGradient(colors: [
                                  AppColors.accentBlue,
                                  AppColors.accentPurple
                                ])
                              : null,
                          color: user.isPremium ? null : AppColors.darkCard,
                          borderRadius: BorderRadius.circular(16),
                          border: user.isPremium
                              ? null
                              : Border.all(
                                  color: AppColors.accentBlue
                                      .withValues(alpha: 0.4)),
                          boxShadow: user.isPremium
                              ? [
                                  BoxShadow(
                                      color: AppColors.accentBlue
                                          .withValues(alpha: 0.35),
                                      blurRadius: 14,
                                      spreadRadius: 2)
                                ]
                              : null,
                        ),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                user.isPremium
                                    ? Icons.cloud_upload_rounded
                                    : Icons.lock_rounded,
                                color: user.isPremium
                                    ? Colors.white
                                    : AppColors.accentBlue,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Upload Wallpaper',
                                style: TextStyle(
                                  color: user.isPremium
                                      ? Colors.white
                                      : AppColors.accentBlue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (!user.isPremium) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [
                                      Color(0xFFF59E0B),
                                      Color(0xFFEF4444)
                                    ]),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('PREMIUM',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800)),
                                ),
                              ],
                            ]),
                      ),
                    ),
                  ).animate(delay: 480.ms).fadeIn().slideY(begin: 0.3),

                  const SizedBox(height: 12),

                  // ─── Menu Items ──────────────────────────────────────────
                  ..._menuItems(context, user),

                  const SizedBox(height: 16),

                  // ─── Premium CTA banner (free only) ─────────────────────
                  if (!user.isPremium)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PremiumScreen())),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              AppColors.accentOrange.withValues(alpha: 0.15),
                              AppColors.accentPink.withValues(alpha: 0.15),
                            ]),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColors.accentOrange
                                    .withValues(alpha: 0.4)),
                          ),
                          child: Row(children: [
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [
                                  Color(0xFFF59E0B),
                                  Color(0xFFEF4444)
                                ]),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.workspace_premium,
                                  color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text('Go Premium',
                                      style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700)),
                                  Text(
                                      'Upload wallpapers + unlock all features',
                                      style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12)),
                                ])),
                            const Icon(Icons.chevron_right,
                                color: AppColors.textSecondary),
                          ]),
                        ),
                      ),
                    ).animate(delay: 700.ms).fadeIn(),

                  const SizedBox(height: 28),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle(
      BuildContext context, UserProvider user) async {
    final credential = await AuthService().signInWithGoogle();
    if (!context.mounted) return;

    await user.refreshFromAuth();
    if (!context.mounted) return;

    _showAuthMessage(
      context,
      credential == null
          ? AuthService().lastErrorMessage ?? 'Google sign in failed'
          : 'Signed in with Google',
      credential != null,
    );
  }

  Future<void> _signInAnonymously(
      BuildContext context, UserProvider user) async {
    final credential = await AuthService().signInAnonymously();
    if (!context.mounted) return;

    await user.refreshFromAuth();
    if (!context.mounted) return;

    _showAuthMessage(
      context,
      credential == null
          ? AuthService().lastErrorMessage ?? 'Guest sign in failed'
          : 'Signed in as guest',
      credential != null,
    );
  }

  Future<void> _signOut(BuildContext context, UserProvider user) async {
    await AuthService().signOut();
    if (!context.mounted) return;

    await user.refreshFromAuth();
    if (!context.mounted) return;

    _showAuthMessage(context, 'Signed out', true);
  }

  void _showAuthMessage(BuildContext context, String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? AppColors.accentGreen : AppColors.accentPink,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _planLabel(String planId) {
    switch (planId) {
      case 'monthly':
        return 'Monthly';
      case 'yearly':
        return 'Yearly';
      case 'lifetime':
        return 'Lifetime';
      default:
        return 'Active';
    }
  }

  List<Widget> _menuItems(BuildContext context, UserProvider user) {
    final items = [
      {'icon': Icons.download_rounded, 'label': 'Downloads', 'trailing': ''},
      {'icon': Icons.history, 'label': 'History', 'trailing': ''},
      {
        'icon': Icons.cloud_sync_outlined,
        'label': 'Cloud Sync',
        'trailing': 'On'
      },
      {
        'icon': Icons.devices_outlined,
        'label': 'My Devices',
        'trailing': '3 Devices'
      },
    ];
    return items
        .asMap()
        .entries
        .map(
          (e) => Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(children: [
              Icon(e.value['icon'] as IconData,
                  color: AppColors.accentBlue, size: 20),
              const SizedBox(width: 12),
              Text(e.value['label'] as String,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
              const Spacer(),
              if ((e.value['trailing'] as String).isNotEmpty)
                Text(e.value['trailing'] as String,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right,
                  color: AppColors.textMuted, size: 18),
            ]),
          )
              .animate(delay: Duration(milliseconds: 520 + e.key * 60))
              .fadeIn()
              .slideX(begin: 0.2),
        )
        .toList();
  }
}

class _AuthActions extends StatelessWidget {
  final bool isLoggedIn;
  final bool isGuest;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onGuestSignIn;
  final VoidCallback onSignOut;

  const _AuthActions({
    required this.isLoggedIn,
    required this.isGuest,
    required this.onGoogleSignIn,
    required this.onGuestSignIn,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn) {
      return TextButton.icon(
        onPressed: onSignOut,
        icon: const Icon(Icons.logout, size: 18),
        label: Text(isGuest ? 'Sign out guest' : 'Sign out'),
        style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onGoogleSignIn,
              icon: const Icon(Icons.login, size: 18),
              label: const Text('Google'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onGuestSignIn,
              icon: const Icon(Icons.person_outline, size: 18),
              label: const Text('Guest'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _vdivider() =>
    Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.1));

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat(this.value, this.label);
  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11)),
        ]),
      );
}
