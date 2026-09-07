import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleGoogleAuth() {
    ref.read(authProvider.notifier).loginWithGoogle();
    context.go('/activity-selector');
  }

  void _handleAppleAuth() {
    ref.read(authProvider.notifier).loginWithApple();
    context.go('/activity-selector');
  }

  void _handleEmailAuth() {
    final email = _emailController.text.trim();
    if (email.isNotEmpty) {
      ref.read(authProvider.notifier).loginWithEmail(email);
    } else {
      ref.read(authProvider.notifier).loginWithEmail('user@example.com');
    }
    context.go('/activity-selector');
  }

  void _handleGuestAuth() {
    ref.read(authProvider.notifier).continueAsGuest();
    context.go('/activity-selector');
  }

  @override
  Widget build(BuildContext context) {
    // Platform check to render Apple button on iOS only
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background image with blur filter
          // TODO: Replace placeholder network photo with real trail photography asset
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
            child: CachedNetworkImage(
              imageUrl: 'https://picsum.photos/id/1016/1080/1920', // TODO: Replace with real photography
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: AppColors.primary),
              errorWidget: (context, url, error) => Container(color: AppColors.primary),
            ),
          ),

          // Dark tint layer over background image for visual contrast
          Container(
            color: Colors.black.withValues(alpha: 0.35),
          ),

          // 2. Centered Frosted-Glass Card Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.0), // 24 corner radius
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.85), // surface 85% opacity
                        borderRadius: BorderRadius.circular(24.0),
                        border: Border.all(color: AppColors.border, width: 1.0), // 1px border color
                      ),
                      padding: const EdgeInsets.all(28.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // App Branding Title
                          Text(
                            'Welcome to TravelBuddy',
                            style: AppTypography.textTheme.headlineMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to sync your itineraries, offline maps, and wishlist.',
                            style: AppTypography.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 28),

                          // Google Sign-In Button
                          OutlinedButton.icon(
                            onPressed: _handleGoogleAuth,
                            icon: const Icon(
                              Icons.g_mobiledata_rounded,
                              size: 28,
                              color: AppColors.textPrimary,
                            ),
                            label: const Text('Continue with Google'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              foregroundColor: AppColors.textPrimary,
                              side: const BorderSide(color: AppColors.border, width: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                          // Apple Sign-In Button (iOS Platform Only)
                          if (isIOS) ...[
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: _handleAppleAuth,
                              icon: const Icon(
                                Icons.apple,
                                size: 24,
                                color: AppColors.textPrimary,
                              ),
                              label: const Text('Continue with Apple'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                foregroundColor: AppColors.textPrimary,
                                side: const BorderSide(color: AppColors.border, width: 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),

                          // Divider with "or" text
                          Row(
                            children: [
                              const Expanded(child: Divider(color: AppColors.border)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: Text(
                                  'or',
                                  style: AppTypography.textTheme.labelSmall,
                                ),
                              ),
                              const Expanded(child: Divider(color: AppColors.border)),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Email Input Form
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: AppTypography.textTheme.bodyLarge,
                                  decoration: const InputDecoration(
                                    labelText: 'Email Address',
                                    hintText: 'name@example.com',
                                    prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _handleEmailAuth,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Continue',
                                    style: AppTypography.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // "Continue as guest" text link
                          Center(
                            child: GestureDetector(
                              onTap: _handleGuestAuth,
                              child: Text(
                                'Continue as guest',
                                style: AppTypography.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.accentAlt,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.accentAlt,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
