import 'package:flutter/material.dart';
import '../../core/widgets/base_placeholder_screen.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BasePlaceholderScreen(
      title: 'Interactive Map Screen',
      routePath: '/map',
      icon: Icons.map,
    );
  }
}
