import 'package:flutter/material.dart';
import '../../core/widgets/base_placeholder_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BasePlaceholderScreen(
      title: 'Onboarding Screen',
      routePath: '/onboarding',
      icon: Icons.explore,
    );
  }
}
