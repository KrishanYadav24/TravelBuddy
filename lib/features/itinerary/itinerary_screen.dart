import 'package:flutter/material.dart';
import '../../core/widgets/base_placeholder_screen.dart';

class ItineraryScreen extends StatelessWidget {
  const ItineraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BasePlaceholderScreen(
      title: 'Itinerary Screen',
      routePath: '/itinerary',
      icon: Icons.event_note,
    );
  }
}
