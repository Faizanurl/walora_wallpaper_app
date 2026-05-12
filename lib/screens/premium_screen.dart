import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../providers/user_provider.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  int _selectedPlan = 1; // 0=monthly, 1=yearly, 2=lifetime
  bool _isPurchasing = false;

  final _plans = [
    const _Plan(
      id: 'monthly',
      label: 'Monthly',
      price: '\$2.99',
      period: '/month',
      priceInUSD: 2.99,
      badge: null,
      iapId: 'com.wallpaperapp.premium.monthly',
    ),
    const _Plan(
      id: 'yearly',
      label: 'Yearly',
      price: '\$19.99',
      period: '/year',
      priceInUSD: 19.99,
      badge: 'BEST VALUE',
      iapId: 'com.wallpaperapp.premium.yearly',
      perMonth: '\$1.67/mo',
    ),
    const _Plan(
      id: 'lifetime',
      label: 'Lifetime',
      price: '\$49.99',
      period: 'one-time',
      priceInUSD: 49.99,
      badge: 'POPULAR',
      iapId: 'com.wallpaperapp.premium.lifetime',
    ),
  ];

  final _features = [
    const _Feature(
        icon: Icons.cloud_upload_rounded,
        title: 'Upload Wallpapers',
        desc: 'Share your own wallpapers with the community',
        isExclusive: true),
    const _Feature(
        icon: Icons.download_rounded,
        title: 'Unlimited Downloads',
        desc: 'Download in original 4K resolution',
        isExclusive: false),
    const _Feature(
        icon: Icons.auto_awesome,
        title: 'AI Picks Unlimited',
        desc: 'Full access to AI-curated recommendations',
        isExclusive: false),
    const _Feature(
        icon: Icons.block,
        title: 'Ad-Free Experience',
        desc: 'No banners, no interruptions',
        isExclusive: false),
    const _Feature(
        icon: Icons.collections_bookmark,
        title: 'Unlimited Collections',
        desc: 'Create as many collections as you want',
        isExclusive: false),
    const _Feature(
        icon: Icons.devices,
        title: 'Multi-Device Sync',
        desc: 'Sync favorites across all your devices',
        isExclusive: false),
    const _Feature(
        icon: Icons.wallpaper,
        title: 'Auto Wallpaper Changer',
        desc: 'Schedule automatic wallpaper changes',
        isExclusive: false),
    const _Feature(
        icon: Icons.support_agent,
        title: 'Priority Support',
        desc: '24/7 dedicated premium support',
        isExclusive: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          // Background gradient orbs
          Positioned(
            top: -100,
            right: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.accentOrange.withValues(alpha: 0.2),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.accentPurple.withValues(alpha: 0.15),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const GlassContainer(
                          padding: EdgeInsets.all(10),
                          borderRadius: 12,
                          child:
                              Icon(Icons.close, color: Colors.white, size: 20),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Restore Purchase',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),

                        // Crown icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF59E0B)
                                    .withValues(alpha: 0.5),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.workspace_premium,
                              color: Colors.white, size: 40),
                        )
                            .animate()
                            .scale(
                                begin: const Offset(0.5, 0.5),
                                curve: Curves.elasticOut,
                                duration: 700.ms)
                            .fadeIn(),

                        const SizedBox(height: 16),

                        const Text(
                          'Go Premium',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                        ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.3),

                        const SizedBox(height: 6),

                        const Text(
                          'Unlock the full Wallpaper experience\nand share your creativity',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ).animate(delay: 200.ms).fadeIn(),

                        const SizedBox(height: 28),

                        // Plan selector
                        Row(
                          children: _plans.asMap().entries.map((e) {
                            final isSelected = _selectedPlan == e.key;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedPlan = e.key),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: EdgeInsets.only(
                                    left: e.key == 0 ? 0 : 6,
                                    right: e.key == 2 ? 0 : 6,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 8),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFFF59E0B),
                                              Color(0xFFEF4444)
                                            ],
                                          )
                                        : null,
                                    color:
                                        isSelected ? null : AppColors.darkCard,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.transparent
                                          : Colors.white.withValues(alpha: 0.1),
                                      width: 1.5,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFFF59E0B)
                                                  .withValues(alpha: 0.3),
                                              blurRadius: 16,
                                              spreadRadius: 2,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Column(
                                    children: [
                                      if (e.value.badge != null)
                                        Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 6),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.white
                                                    .withValues(alpha: 0.25)
                                                : AppColors.accentOrange
                                                    .withValues(alpha: 0.2),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            e.value.badge!,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : AppColors.accentOrange,
                                              fontSize: 8,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        )
                                      else
                                        const SizedBox(height: 20),
                                      Text(
                                        e.value.label,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.textSecondary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        e.value.price,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        e.value.period,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                                  .withValues(alpha: 0.7)
                                              : AppColors.textMuted,
                                          fontSize: 10,
                                        ),
                                      ),
                                      if (e.value.perMonth != null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 2),
                                          child: Text(
                                            e.value.perMonth!,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                      .withValues(alpha: 0.8)
                                                  : AppColors.accentGreen,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.3),

                        const SizedBox(height: 28),

                        // Features list
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.darkCard,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.06)),
                          ),
                          child: Column(
                            children: _features.asMap().entries.map((e) {
                              return Padding(
                                padding: EdgeInsets.only(
                                    bottom:
                                        e.key < _features.length - 1 ? 16 : 0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        gradient: e.value.isExclusive
                                            ? const LinearGradient(
                                                colors: [
                                                  Color(0xFFF59E0B),
                                                  Color(0xFFEF4444)
                                                ],
                                              )
                                            : LinearGradient(
                                                colors: [
                                                  AppColors.accentBlue
                                                      .withValues(alpha: 0.2),
                                                  AppColors.accentPurple
                                                      .withValues(alpha: 0.2),
                                                ],
                                              ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        e.value.icon,
                                        color: e.value.isExclusive
                                            ? Colors.white
                                            : AppColors.accentBlue,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                e.value.title,
                                                style: const TextStyle(
                                                  color: AppColors.textPrimary,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              if (e.value.isExclusive) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    gradient:
                                                        const LinearGradient(
                                                      colors: [
                                                        Color(0xFFF59E0B),
                                                        Color(0xFFEF4444)
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                  child: const Text(
                                                    'EXCLUSIVE',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 8,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            e.value.desc,
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.check_circle_rounded,
                                        color: AppColors.accentGreen, size: 20),
                                  ],
                                ),
                              )
                                  .animate(
                                      delay: Duration(
                                          milliseconds: 400 + e.key * 60))
                                  .fadeIn()
                                  .slideX(begin: 0.2);
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Terms
                        const Text(
                          'Cancel anytime • Secure payment via Google Play / App Store\nBy subscribing you agree to our Terms of Service',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom CTA (fixed)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.darkBg,
                    AppColors.darkBg.withValues(alpha: 0)
                  ],
                ),
              ),
              child: Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  if (userProvider.isPremium) {
                    return Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color:
                                AppColors.accentGreen.withValues(alpha: 0.4)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              color: AppColors.accentGreen, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'You are already Premium! 🎉',
                            style: TextStyle(
                              color: AppColors.accentGreen,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return GestureDetector(
                    onTap: _isPurchasing
                        ? null
                        : () => _purchase(context, userProvider),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFF59E0B).withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isPurchasing
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.workspace_premium,
                                      color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Get ${_plans[_selectedPlan].label} — ${_plans[_selectedPlan].price}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _purchase(
      BuildContext context, UserProvider userProvider) async {
    setState(() => _isPurchasing = true);

    // Simulate IAP purchase flow (replace with actual in_app_purchase plugin)
    await Future.delayed(const Duration(seconds: 2));

    // On success:
    await userProvider.setPremium(true, planId: _plans[_selectedPlan].id);

    if (!mounted || !context.mounted) return;

    setState(() => _isPurchasing = false);

    // Success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PurchaseSuccessDialog(
        planLabel: _plans[_selectedPlan].label,
        onContinue: () {
          Navigator.pop(context); // close dialog
          Navigator.pop(context); // close premium screen
        },
      ),
    );
  }
}

// ─── Success Dialog ───────────────────────────────────────────────────────────

class _PurchaseSuccessDialog extends StatelessWidget {
  final String planLabel;
  final VoidCallback onContinue;

  const _PurchaseSuccessDialog(
      {required this.planLabel, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: const Icon(Icons.workspace_premium,
                  color: Colors.white, size: 40),
            )
                .animate()
                .scale(begin: const Offset(0.3, 0.3), curve: Curves.elasticOut),
            const SizedBox(height: 20),
            const Text(
              'Welcome to Premium! 🎉',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your $planLabel plan is now active.\nYou can now upload wallpapers and enjoy all premium features!',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GradientButton(
              label: 'Start Exploring',
              colors: const [Color(0xFFF59E0B), Color(0xFFEF4444)],
              onTap: onContinue,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Data Classes ─────────────────────────────────────────────────────────────

class _Plan {
  final String id, label, price, period, iapId;
  final double priceInUSD;
  final String? badge, perMonth;

  const _Plan({
    required this.id,
    required this.label,
    required this.price,
    required this.period,
    required this.priceInUSD,
    required this.iapId,
    this.badge,
    this.perMonth,
  });
}

class _Feature {
  final IconData icon;
  final String title, desc;
  final bool isExclusive;

  const _Feature(
      {required this.icon,
      required this.title,
      required this.desc,
      this.isExclusive = false});
}
