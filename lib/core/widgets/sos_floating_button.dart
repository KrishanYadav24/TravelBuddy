import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SosFloatingButton extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final String? destinationName;

  const SosFloatingButton({
    super.key,
    this.latitude,
    this.longitude,
    this.destinationName,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: 'sos_fab_${latitude ?? 0}_${longitude ?? 0}',
      backgroundColor: const Color(0xFFD32F2F),
      foregroundColor: Colors.white,
      tooltip: 'Emergency SOS',
      onPressed: () {
        context.push('/emergency');
      },
      child: const Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.warning_amber_rounded, size: 20),
        ],
      ),
    );
  }
}
