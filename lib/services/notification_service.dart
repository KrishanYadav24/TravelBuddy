import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/env_config.dart';

class TravelBuddyNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;

  const TravelBuddyNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
  });
}

class NotificationService {
  final List<TravelBuddyNotification> _notifications = [
    TravelBuddyNotification(
      id: 'notif_1',
      title: 'Weather Warning: Swargarohini Ridge',
      body: 'Heavy snowfall expected near Kedarkantha Summit on Thursday. Ensure thermal gear.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    TravelBuddyNotification(
      id: 'notif_2',
      title: 'New Destination in Uttarakhand',
      body: 'Har Ki Dun Valley has been added to top recommended summer treks!',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  /// Initialize FCM tokens or register local notification channels
  Future<void> initialize() async {
    if (!EnvConfig.useMockData) {
      try {
        // Firebase Cloud Messaging Integration Point
        // await FirebaseMessaging.instance.requestPermission();
        // final token = await FirebaseMessaging.instance.getToken();
      } catch (_) {}
    }
  }

  /// Get active list of notifications
  List<TravelBuddyNotification> getNotifications() => List.unmodifiable(_notifications);

  /// Trigger a local weather alert notification for saved trips
  void triggerWeatherAlert({required String tripName, required String warningDetails}) {
    _notifications.insert(
      0,
      TravelBuddyNotification(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Weather Alert: $tripName',
        body: warningDetails,
        timestamp: DateTime.now(),
      ),
    );
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService();
  service.initialize();
  return service;
});
