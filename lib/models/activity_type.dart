import 'package:flutter/material.dart';

/// Data model representing a trip activity category and its sub-types.
class ActivityType {
  final String id;
  final String label;
  final IconData iconData;
  final String backgroundImageUrl;
  final List<String> subTypes;

  const ActivityType({
    required this.id,
    required this.label,
    required this.iconData,
    required this.backgroundImageUrl,
    required this.subTypes,
  });

  /// Static collection of the 5 top-level India trip activity categories.
  static const List<ActivityType> staticActivities = [
    ActivityType(
      id: 'trekking',
      label: 'Trekking & Hiking',
      iconData: Icons.hiking,
      backgroundImageUrl: 'https://picsum.photos/id/1018/600/800',
      subTypes: ['Day hike', 'Multi-day trek', 'Himalayan trek'],
    ),
    ActivityType(
      id: 'wildlife',
      label: 'Wildlife & Safari Expeditions',
      iconData: Icons.pets,
      backgroundImageUrl: 'https://picsum.photos/id/1024/600/800',
      subTypes: ['National park safari', 'Bird watching', 'Marine/coastal wildlife'],
    ),
    ActivityType(
      id: 'cultural',
      label: 'Cultural Immersion Trips',
      iconData: Icons.temple_hindu,
      backgroundImageUrl: 'https://picsum.photos/id/1040/600/800',
      subTypes: ['Heritage & monuments', 'Village homestays', 'Festival tourism', 'Craft & food trails', 'Pilgrimage'],
    ),
    ActivityType(
      id: 'wellness',
      label: 'Wellness & Relaxation Escapes',
      iconData: Icons.spa,
      backgroundImageUrl: 'https://picsum.photos/id/1015/600/800',
      subTypes: ['Yoga & meditation retreat', 'Ayurveda & spa', 'Nature/forest bathing', 'Silent retreat'],
    ),
    ActivityType(
      id: 'road_trip',
      label: 'Road Trips',
      iconData: Icons.directions_car,
      backgroundImageUrl: 'https://picsum.photos/id/1079/600/800',
      subTypes: ['Mountain pass drives', 'Coastal drives', 'Desert circuits', 'Multi-state loops'],
    ),
  ];
}
