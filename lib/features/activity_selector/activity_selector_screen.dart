import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/debug_navigation_drawer.dart';
import '../auth/providers/auth_provider.dart';

class ActivitySelectorScreen extends ConsumerWidget {
  const ActivitySelectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    String authStatusLabel = 'Guest User';
    if (authState.isAuthenticated) {
      authStatusLabel = 'Authenticated (${authState.authMethod ?? "standard"})';
      if (authState.email != null && authState.email!.isNotEmpty) {
        authStatusLabel += ': ${authState.email}';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Selector'),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu),
              tooltip: 'Open Route Menu',
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: const DebugNavigationDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  boxShadow: AppTheme.softShadowList,
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
                      child: const Icon(Icons.hiking, size: 36, color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Select Your Activity',
                      style: theme.textTheme.displayLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      avatar: Icon(
                        authState.isGuest ? Icons.person_outline : Icons.verified_user,
                        color: authState.isGuest ? AppColors.accentAlt : AppColors.primary,
                        size: 18,
                      ),
                      label: Text(authStatusLabel),
                      backgroundColor: AppColors.background,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Successfully navigated from Auth Screen! Select trekking, hiking, camping, or wildlife safaris below.',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                      icon: const Icon(Icons.navigation),
                      label: const Text('Explore All Feature Routes'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
