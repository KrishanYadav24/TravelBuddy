import 'package:flutter/material.dart';
import '../../core/widgets/base_placeholder_screen.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BasePlaceholderScreen(
      title: 'Emergency SOS Screen',
      routePath: '/emergency',
      icon: Icons.warning_amber,
    );
  }
}
