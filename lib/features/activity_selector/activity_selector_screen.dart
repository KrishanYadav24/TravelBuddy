import 'package:flutter/material.dart';
import '../../core/widgets/base_placeholder_screen.dart';

class ActivitySelectorScreen extends StatelessWidget {
  const ActivitySelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BasePlaceholderScreen(
      title: 'Activity Selector Screen',
      routePath: '/activity-selector',
      icon: Icons.hiking,
    );
  }
}
