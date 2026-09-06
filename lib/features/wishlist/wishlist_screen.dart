import 'package:flutter/material.dart';
import '../../core/widgets/base_placeholder_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BasePlaceholderScreen(
      title: 'Wishlist Screen',
      routePath: '/wishlist',
      icon: Icons.favorite,
    );
  }
}
