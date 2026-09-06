import 'package:flutter/material.dart';
import '../../core/widgets/base_placeholder_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BasePlaceholderScreen(
      title: 'Profile Screen',
      routePath: '/profile',
      icon: Icons.person,
    );
  }
}
