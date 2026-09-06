import 'package:flutter/material.dart';
import '../../core/widgets/base_placeholder_screen.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BasePlaceholderScreen(
      title: 'Community Screen',
      routePath: '/community',
      icon: Icons.groups,
    );
  }
}
