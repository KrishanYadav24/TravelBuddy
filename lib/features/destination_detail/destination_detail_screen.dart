import 'package:flutter/material.dart';
import '../../core/widgets/base_placeholder_screen.dart';

class DestinationDetailScreen extends StatelessWidget {
  final String destinationId;

  const DestinationDetailScreen({
    super.key,
    required this.destinationId,
  });

  @override
  Widget build(BuildContext context) {
    return BasePlaceholderScreen(
      title: 'Destination Detail Screen (#$destinationId)',
      routePath: '/destination/$destinationId',
      icon: Icons.place,
    );
  }
}
