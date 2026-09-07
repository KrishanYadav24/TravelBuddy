import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Data model for an onboarding slide.
class OnboardingSlideData {
  final String title;
  final String subtitle;
  final String imageUrl; // TODO: Replace placeholder network URLs with real photography assets
  final bool showLogo;

  const OnboardingSlideData({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.showLogo = false,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // Slide content configuration with placeholder images from picsum.photos
  // TODO: Replace placeholder picsum URLs with production trail & landscape photography
  static const List<OnboardingSlideData> _slides = [
    OnboardingSlideData(
      title: 'Discover India, your way',
      subtitle: 'Explore hidden trails, sacred peaks, and serene backwaters tailored to your journey.',
      imageUrl: 'https://picsum.photos/id/1018/1080/1920', // TODO: Replace with real photography
      showLogo: true,
    ),
    OnboardingSlideData(
      title: 'Find treks, hikes & more — mapped for you',
      subtitle: 'Curated routes with elevation profiles, waypoint guides, and interactive maps.',
      imageUrl: 'https://picsum.photos/id/1043/1080/1920', // TODO: Replace with real photography
      showLogo: false,
    ),
    OnboardingSlideData(
      title: 'Know the best time to go, always',
      subtitle: 'Real-time weather insights, seasonal forecasts, and offline safety recommendations.',
      imageUrl: 'https://picsum.photos/id/1015/1080/1920', // TODO: Replace with real photography
      showLogo: false,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToAuth() {
    context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. PageView for user-controlled swipe
          PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return _buildSlideItem(slide, index == _slides.length - 1);
            },
          ),

          // 2. Persistent "Skip" text button at top-right
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: TextButton(
              onPressed: _navigateToAuth,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                backgroundColor: Colors.black.withValues(alpha: 0.25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Skip',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // 3. Page indicator dots at bottom
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => _buildIndicatorDot(index == _currentIndex),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlideItem(OnboardingSlideData slide, bool isLastSlide) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background full-bleed photo
        // TODO: Replace with real photography asset
        CachedNetworkImage(
          imageUrl: slide.imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: AppColors.primary,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: AppColors.primary,
            child: const Icon(Icons.terrain, size: 64, color: AppColors.primaryLight),
          ),
        ),

        // Gradient overlay to guarantee high legibility for white text
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.35),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.75),
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
        ),

        // Content layout
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Slide 1 Logo with fade & scale animation
                if (slide.showLogo) ...[
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Opacity(
                          opacity: value.clamp(0.0, 1.0),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.85),
                        border: Border.all(color: AppColors.accent, width: 2),
                      ),
                      child: const Icon(
                        Icons.explore_outlined,
                        size: 48,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Headline text (Fraunces typography)
                Text(
                  slide.title,
                  style: AppTypography.textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    shadows: [
                      const Shadow(
                        blurRadius: 8.0,
                        color: Colors.black45,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 12),

                // Subtitle text (Inter typography)
                Text(
                  slide.subtitle,
                  style: AppTypography.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 100), // space for dots & CTA button

                // Slide 3 CTA Button: "Get Started" (accent-colored, full width, 16 corner radius)
                if (isLastSlide)
                  ElevatedButton(
                    onPressed: _navigateToAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16), // exact 16 corner radius
                      ),
                    ),
                    child: Text(
                      'Get Started',
                      style: AppTypography.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 52), // maintain height layout consistency
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIndicatorDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.accent : AppColors.border,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
