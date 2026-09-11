import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'services/emergency_service.dart';

class EmergencyScreen extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String? destinationName;

  const EmergencyScreen({
    super.key,
    this.latitude = 30.7268,
    this.longitude = 78.4354,
    this.destinationName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // High contrast dark theme for urgent clarity
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text('SOS Emergency Assistance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =================================================================
            // Current GPS Location Coordinates Box
            // =================================================================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD32F2F), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.my_location, color: Colors.redAccent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        destinationName != null ? 'Current Location ($destinationName)' : 'Current GPS Coordinates',
                        style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    '${latitude.toStringAsFixed(4)}° N, ${longitude.toStringAsFixed(4)}° E',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white12,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.copy, size: 18),
                            label: const Text('Copy GPS', style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () async {
                              await EmergencyService.copyCoordinates(latitude, longitude);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('GPS Coordinates copied to clipboard!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.share, size: 18),
                            label: const Text('Share Location', style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () {
                              EmergencyService.shareLocation(
                                lat: latitude,
                                lng: longitude,
                                destinationName: destinationName,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // =================================================================
            // Direct Emergency Helplines (Min 56px height tap targets)
            // =================================================================
            const Text(
              'Emergency Helplines',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildEmergencyButton(
              context: context,
              title: 'CALL LOCAL POLICE',
              subtitle: 'National Emergency Response (112)',
              icon: Icons.local_police,
              color: const Color(0xFFD32F2F),
              phoneNumber: '112',
            ),
            const SizedBox(height: 12),

            _buildEmergencyButton(
              context: context,
              title: 'FOREST DEPT HELPLINE',
              subtitle: 'Trek Rescue & Wildlife Control (1800115554)',
              icon: Icons.forest,
              color: const Color(0xFF2E7D32),
              phoneNumber: '1800115554',
            ),
            const SizedBox(height: 12),

            _buildEmergencyButton(
              context: context,
              title: 'DISASTER MANAGEMENT',
              subtitle: 'State Emergency Operation Center (1070)',
              icon: Icons.warning_rounded,
              color: const Color(0xFFE65100),
              phoneNumber: '1070',
            ),
            const SizedBox(height: 24),

            // =================================================================
            // Nearest Hospital Section
            // =================================================================
            const Text(
              'Nearest Medical Facility',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.local_hospital, color: Colors.blueAccent, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'District Hospital Uttarkashi',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Emergency Unit • ~12 km away (40 mins)',
                              style: TextStyle(color: Colors.white60, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.call),
                            label: const Text('Call Hospital', style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () {
                              EmergencyService.makePhoneCall('+911374222102');
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blueAccent,
                              side: const BorderSide(color: Colors.blueAccent, width: 2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.directions),
                            label: const Text('Directions', style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () {
                              EmergencyService.openMapDirections(
                                lat: latitude,
                                lng: longitude,
                                label: 'District Hospital Uttarkashi',
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // =================================================================
            // Offline Mountain Safety Checklist Card
            // =================================================================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shield_outlined, color: Colors.amber, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Offline Mountain SOS Protocol',
                        style: TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    '1. Remain calm. Conserve device battery power.\n'
                    '2. Use 3 short whistle blows or flash light signals every minute.\n'
                    '3. Do not leave the marked trail unless advised by local authorities.',
                    style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String phoneNumber,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60, // Meets min 56px requirement
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: () async {
          final success = await EmergencyService.makePhoneCall(phoneNumber);
          if (!success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Dialing $phoneNumber ($title)...')),
            );
          }
        },
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Icon(Icons.call, size: 22),
          ],
        ),
      ),
    );
  }
}
