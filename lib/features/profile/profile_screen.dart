import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/debug_navigation_drawer.dart';
import '../../models/community.dart';
import 'providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final notifier = ref.read(userProfileProvider.notifier);

    final availableStates = [
      'Uttarakhand',
      'Himachal Pradesh',
      'Karnataka',
      'Ladakh',
      'Sikkim',
      'Kerala',
      'Rajasthan',
      'Goa',
      'Meghalaya',
      'West Bengal',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile & Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Settings',
            onPressed: () {
              notifier.resetProfile();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile preferences reset to defaults')),
              );
            },
          ),
        ],
      ),
      drawer: const DebugNavigationDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =================================================================
            // Header: Avatar & Name
            // =================================================================
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                          child: const Icon(Icons.person, size: 40, color: AppColors.primary),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Avatar photo upload coming soon!')),
                              );
                            },
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.primary,
                              child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                profile.name,
                                style: AppTypography.textTheme.headlineMedium?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18, color: AppColors.primary),
                                onPressed: () => _showEditNameDialog(context, ref, profile.name),
                              ),
                            ],
                          ),
                          Text(
                            profile.email,
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Himalayan Trecker',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.accent),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // =================================================================
            // Fitness Level Selector (Segmented Control)
            // =================================================================
            const Text(
              'Fitness Level',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'TODO: Personalizes trek recommendations & altitude warnings on Map screen',
              style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            SegmentedButton<FitnessLevel>(
              segments: FitnessLevel.values.map((f) {
                return ButtonSegment<FitnessLevel>(
                  value: f,
                  label: Text(f.displayName, style: const TextStyle(fontSize: 12)),
                  icon: Icon(
                    f == FitnessLevel.beginner
                        ? Icons.directions_walk
                        : f == FitnessLevel.intermediate
                            ? Icons.hiking
                            : Icons.landscape,
                    size: 16,
                  ),
                );
              }).toList(),
              selected: {profile.fitnessLevel},
              onSelectionChanged: (newSelection) {
                if (newSelection.isNotEmpty) {
                  notifier.updateFitnessLevel(newSelection.first);
                }
              },
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: AppColors.primary,
                selectedForegroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // =================================================================
            // Preferred States Multi-Select Chips
            // =================================================================
            const Text(
              'Preferred Travel States',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: availableStates.map((stateName) {
                final isSelected = profile.preferredStates.contains(stateName);
                return FilterChip(
                  label: Text(stateName, style: const TextStyle(fontSize: 12)),
                  selected: isSelected,
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.primary,
                  onSelected: (_) {
                    notifier.togglePreferredState(stateName);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // =================================================================
            // Account & Application Sections
            // =================================================================
            const Text(
              'Account & Activity',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.border),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.map, color: AppColors.primary),
                    title: const Text('My Trips & Itineraries'),
                    subtitle: const Text('View saved past and upcoming travel itineraries'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/itinerary'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.rate_review, color: AppColors.accent),
                    title: const Text('My Reviews'),
                    subtitle: const Text('3 destination reviews published'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/profile/reviews'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.cloud_download, color: Colors.blue),
                    title: const Text('Offline Maps Manager'),
                    subtitle: const Text('Manage downloaded regional map packs'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/offline'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // =================================================================
            // Settings & Preferences Section
            // =================================================================
            const Text(
              'App Settings',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.border),
              ),
              child: Column(
                children: [
                  ExpansionTile(
                    leading: const Icon(Icons.notifications, color: Colors.orange),
                    title: const Text('Notification Settings'),
                    children: [
                      SwitchListTile(
                        title: const Text('Weather Alerts', style: TextStyle(fontSize: 13)),
                        subtitle: const Text('Receive warnings for severe weather on saved trips', style: TextStyle(fontSize: 11)),
                        value: profile.notifyWeatherAlerts,
                        onChanged: (val) => notifier.toggleWeatherAlerts(val),
                      ),
                      SwitchListTile(
                        title: const Text('New Destinations', style: TextStyle(fontSize: 13)),
                        subtitle: const Text('Alert when new spots are added in preferred states', style: TextStyle(fontSize: 11)),
                        value: profile.notifyNewDestinations,
                        onChanged: (val) => notifier.toggleNewDestinations(val),
                      ),
                      SwitchListTile(
                        title: const Text('Community Activity', style: TextStyle(fontSize: 13)),
                        subtitle: const Text('Replies to your questions & buddy responses', style: TextStyle(fontSize: 11)),
                        value: profile.notifyCommunityActivity,
                        onChanged: (val) => notifier.toggleCommunityActivity(val),
                      ),
                    ],
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.language, color: Colors.teal),
                    title: const Text('App Language'),
                    trailing: DropdownButton<String>(
                      value: profile.language,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'English', child: Text('English')),
                        DropdownMenuItem(value: 'Hindi', child: Text('Hindi (हिन्दी)')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          if (val == 'Hindi') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Hindi localization coming soon! Defaulting to English.')),
                            );
                          }
                          notifier.updateLanguage(val);
                        }
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.dark_mode, color: Colors.indigo),
                    title: const Text('Dark Mode'),
                    subtitle: const Text('TODO: Toggle application theme mode'),
                    value: profile.isDarkMode,
                    onChanged: (val) {
                      notifier.toggleDarkMode(val);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(val ? 'Dark mode preference saved' : 'Light mode preference saved')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // =================================================================
            // Logout Button
            // =================================================================
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => _showLogoutDialog(context),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Display Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => ctx.pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                final trimmed = controller.text.trim();
                if (trimmed.isNotEmpty) {
                  ref.read(userProfileProvider.notifier).updateName(trimmed);
                }
                ctx.pop();
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out of TravelBuddy?'),
          actions: [
            TextButton(
              onPressed: () => ctx.pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                ctx.pop();
                context.go('/auth');
              },
              child: const Text('Log Out', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
