import 'package:flutter/material.dart';
import '../../core/widgets/base_placeholder_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BasePlaceholderScreen(
      title: 'Auth Screen',
      routePath: '/auth',
      icon: Icons.lock,
    );
  }
}
