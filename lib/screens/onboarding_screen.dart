import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _pages = [
    const _OnboardPage(
      title: 'Stunning Wallpapers',
      subtitle: 'For Every Screen',
      body:
          'Explore thousands of high quality wallpapers in various categories.',
      gradient: [Color(0xFF0D1B2E), Color(0xFF1A3A5C)],
      accentColor: AppColors.accentBlue,
      imageSeeds: ['mountain', 'forest', 'ocean'],
    ),
    const _OnboardPage(
      title: 'AI-Powered',
      subtitle: 'Recommendations',
      body:
          'Let our AI pick wallpapers that match your unique style and preferences.',
      gradient: [Color(0xFF1A0D2E), Color(0xFF2D1A5C)],
      accentColor: AppColors.accentPurple,
      imageSeeds: ['galaxy', 'nebula', 'cosmos'],
    ),
    const _OnboardPage(
      title: 'Personalize',
      subtitle: 'Your Experience',
      body:
          'Save favorites, create collections, and set beautiful wallpapers instantly.',
      gradient: [Color(0xFF0D2E1A), Color(0xFF1A5C3A)],
      accentColor: AppColors.accentGreen,
      imageSeeds: ['aurora', 'sunset', 'waterfall'],
    ),
  ];

  void _goToNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _OnboardingPage(page: _pages[index]);
            },
          ),

          // Skip button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20,
            child: TextButton(
              onPressed: _finish,
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(context).padding.bottom + 24,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: WormEffect(
                      dotColor: AppColors.textMuted,
                      activeDotColor: _pages[_currentPage].accentColor,
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 6,
                    ),
                  ),
                  GestureDetector(
                    onTap: _goToNext,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            _pages[_currentPage].accentColor,
                            _pages[_currentPage]
                                .accentColor
                                .withValues(alpha: 0.7),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _pages[_currentPage]
                                .accentColor
                                .withValues(alpha: 0.4),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _currentPage == _pages.length - 1
                            ? Icons.check
                            : Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardPage {
  final String title;
  final String subtitle;
  final String body;
  final List<Color> gradient;
  final Color accentColor;
  final List<String> imageSeeds;

  const _OnboardPage({
    required this.title,
    required this.subtitle,
    required this.body,
    required this.gradient,
    required this.accentColor,
    required this.imageSeeds,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardPage page;

  const _OnboardingPage({required this.page});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: page.gradient,
        ),
      ),
      child: Column(
        children: [
          // Phone mockup area
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 60,
                left: 24,
                right: 24,
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Back phones
                    ...List.generate(2, (i) {
                      return Transform(
                        transform: Matrix4.identity()
                          ..translateByDouble(
                            (i == 0 ? -60.0 : 60.0),
                            i == 0 ? 20.0 : 20.0,
                            0,
                            1,
                          )
                          ..rotateZ(i == 0 ? -0.2 : 0.2),
                        child: _PhoneMockup(
                          seed: page.imageSeeds[i + 1],
                          size: 160,
                        ),
                      );
                    }),
                    // Front phone
                    _PhoneMockup(
                      seed: page.imageSeeds[0],
                      size: 200,
                      accentColor: page.accentColor,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Text content
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${page.title}\n',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextSpan(
                          text: page.subtitle,
                          style: TextStyle(
                            color: page.accentColor,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.3),
                  const SizedBox(height: 16),
                  Text(
                    page.body,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                ],
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _PhoneMockup extends StatelessWidget {
  final String seed;
  final double size;
  final Color? accentColor;

  const _PhoneMockup(
      {required this.seed, required this.size, this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 0.55,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.12),
        border: Border.all(
          color: accentColor?.withValues(alpha: 0.6) ??
              Colors.white.withValues(alpha: 0.2),
          width: accentColor != null ? 2 : 1,
        ),
        boxShadow: [
          if (accentColor != null)
            BoxShadow(
              color: accentColor!.withValues(alpha: 0.3),
              blurRadius: 24,
              spreadRadius: 4,
            ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Image.network(
        'https://picsum.photos/seed/$seed/400/700',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: AppColors.darkSurface),
      ),
    );
  }
}
