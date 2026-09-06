import 'package:flutter/material.dart';
import '../../core/widgets/base_placeholder_screen.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BasePlaceholderScreen(
      title: 'Offline Mode Screen',
      routePath: '/offline',
      icon: Icons.wifi_off,
    );
  }
}
