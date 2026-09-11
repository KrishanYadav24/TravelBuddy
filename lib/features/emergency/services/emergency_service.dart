import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class EmergencyService {
  /// Make a phone call using url_launcher's tel: scheme
  static Future<bool> makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri uri = Uri(scheme: 'tel', path: cleanNumber);
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      } else {
        // Fallback try launching anyway
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      return false;
    }
  }

  /// Open external map application with latitude/longitude directions or query
  static Future<bool> openMapDirections({required double lat, required double lng, String? label}) async {
    final String query = label != null ? Uri.encodeComponent(label) : '$lat,$lng';
    final Uri mapUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng&query_place_id=$query');
    try {
      if (await canLaunchUrl(mapUri)) {
        return await launchUrl(mapUri, mode: LaunchMode.externalApplication);
      } else {
        return await launchUrl(mapUri);
      }
    } catch (_) {
      return false;
    }
  }

  /// Copy GPS coordinates text to system clipboard
  static Future<void> copyCoordinates(double lat, double lng) async {
    final text = '${lat.toStringAsFixed(4)}° N, ${lng.toStringAsFixed(4)}° E';
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// Share current location via share_plus
  static Future<void> shareLocation({required double lat, required double lng, String? destinationName}) async {
    final locationText = destinationName != null
        ? 'EMERGENCY LOCATION: $destinationName (Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}). Maps link: https://maps.google.com/?q=$lat,$lng'
        : 'EMERGENCY LOCATION: Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}. Maps link: https://maps.google.com/?q=$lat,$lng';
    // ignore: deprecated_member_use
    await Share.share(locationText, subject: 'Emergency Location Beacon');
  }
}
