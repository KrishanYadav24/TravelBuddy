import 'package:flutter/material.dart';
import '../../core/widgets/base_placeholder_screen.dart';

class BrowseByStateScreen extends StatelessWidget {
  const BrowseByStateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BasePlaceholderScreen(
      title: 'Browse By State',
      routePath: '/browse-by-state',
      icon: Icons.map_outlined,
    );
  }
}
