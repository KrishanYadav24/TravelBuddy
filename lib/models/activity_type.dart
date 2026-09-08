import 'package:flutter/material.dart';

/// Data model representing a trip activity type.
class ActivityType {
  final String id;
  final String label;
  final IconData iconData;
  final String? iconAsset; // TODO: Replace Material IconData with custom SVGs later
  final String backgroundImageUrl; // TODO: Replace placeholder network URLs with real photography

  const ActivityType({
    required this.id,
    required this.label,
    required this.iconData,
    this.iconAsset,
    required this.backgroundImageUrl,
  });

  /// Static collection of the 8 core India trip activities.
  static const List<ActivityType> staticActivities = [
    ActivityType(
      id: 'trek',
      label: 'Trek',
      iconData: Icons.hiking,
      backgroundImageUrl: 'https://picsum.photos/id/1018/600/800', // Himalayan peak
    ),
    ActivityType(
      id: 'hike',
      label: 'Hike',
      iconData: Icons.directions_walk,
      backgroundImageUrl: 'https://picsum.photos/id/1043/600/800', // Forest trail
    ),
    ActivityType(
      id: 'safari',
      label: 'Wildlife Safari',
      iconData: Icons.pets,
      backgroundImageUrl: 'https://picsum.photos/id/1024/600/800', // Tiger reserve/jungle
    ),
    ActivityType(
      id: 'beach',
      label: 'Beach',
      iconData: Icons.beach_access,
      backgroundImageUrl: 'https://picsum.photos/id/1057/600/800', // Ocean coastline
    ),
    ActivityType(
      id: 'heritage',
      label: 'Heritage / Monument',
      iconData: Icons.account_balance,
      backgroundImageUrl: 'https://picsum.photos/id/1040/600/800', // Ancient architecture
    ),
    ActivityType(
      id: 'camping',
      label: 'Camping',
      iconData: Icons.cabin,
      backgroundImageUrl: 'https://picsum.photos/id/1015/600/800', // Wilderness camp
    ),
    ActivityType(
      id: 'road_trip',
      label: 'Road Trip',
      iconData: Icons.directions_car,
      backgroundImageUrl: 'https://picsum.photos/id/1079/600/800', // Scenic highway
    ),
    ActivityType(
      id: 'pilgrimage',
      label: 'Pilgrimage',
      iconData: Icons.temple_hindu,
      backgroundImageUrl: 'https://picsum.photos/id/1025/600/800', // Sacred site
    ),
  ];
}
