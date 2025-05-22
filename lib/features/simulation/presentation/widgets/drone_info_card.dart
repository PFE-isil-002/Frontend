import 'package:flutter/material.dart';
import '../../domain/entities/drone_data.dart';

class DroneInfoCard extends StatelessWidget {
  final DroneData drone;

  const DroneInfoCard({
    super.key,
    required this.drone,
  });

  @override
  Widget build(BuildContext context) {
    final batteryLevel = "20%";
    final latitude = 36.7131 + (drone.x / 111000);
    final longitude = 3.1793 + (drone.y / (111000 * 0.83));

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black26,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Drone 1',
                  style: const TextStyle(
                    color: Color(0xFF00B3A6),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Drone information
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Battery Level:', batteryLevel),
                const SizedBox(height: 12),
                const Text(
                  'Localisation:',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'latitude: ${latitude.toStringAsFixed(6)}° N',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'longitude: ${longitude.toStringAsFixed(6)}° N',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  'State:',
                  'armed',
                  valueColor: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
