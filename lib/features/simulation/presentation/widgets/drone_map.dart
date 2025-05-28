import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/utils/position_converter.dart';
import '../../domain/entities/drone_data.dart'; // Ensure this includes the new classes

class DroneMap extends StatelessWidget {
  final List<DroneData> droneDataList;
  final double referenceLat;
  final double referenceLon;
  final Function(DroneData)? onDroneSelected;
  final void Function(LatLng latLng)? onMapTap;
  final LatLng? startPoint;
  final LatLng? endPoint;
  final List<LatLng> collectedWaypoints;
  final OutsiderStatusData? outsiderStatus; // New parameter for outsider drone

  const DroneMap({
    super.key,
    required this.droneDataList,
    required this.referenceLat,
    required this.referenceLon,
    this.onDroneSelected,
    this.onMapTap,
    this.startPoint,
    this.endPoint,
    this.collectedWaypoints = const [],
    this.outsiderStatus, // Initialize the new parameter
  });

  @override
  Widget build(BuildContext context) {
    final converter = PositionConverter(
      referenceLat: referenceLat,
      referenceLon: referenceLon,
    );

    final latestDrone = droneDataList.isNotEmpty ? droneDataList.last : null;

    // Convert all drone positions to LatLng for the path
    final List<LatLng> dronePathPoints = droneDataList.map((data) {
      final latlon = converter.convertToLatLon(data.x, data.y);
      return LatLng(latlon['latitude']!, latlon['longitude']!);
    }).toList();

    // Convert outsider drone's flight history to LatLng for the path
    final List<LatLng> outsiderPathPoints = outsiderStatus != null
        ? outsiderStatus!.outsiderTelemetry.flightHistory.map((pos) {
            final latlon = converter.convertToLatLon(pos.x, pos.y);
            return LatLng(latlon['latitude']!, latlon['longitude']!);
          }).toList()
        : [];

    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(referenceLat, referenceLon),
        initialZoom: 17,
        onTap: (_, latLng) {
          if (onMapTap != null) {
            onMapTap!(latLng);
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.drone_anomaly_detection',
        ),
        // Existing drone path - only draw if there are at least two points
        if (dronePathPoints.length >= 2) // Added check for at least 2 points
          PolylineLayer(
            polylines: [
              Polyline(
                points: dronePathPoints,
                color: Colors.blueAccent,
                strokeWidth: 3.0,
              ),
            ],
          ),
        // Outsider drone flight history path - only draw if there are at least two points
        if (outsiderPathPoints.length >= 2) // Added check for at least 2 points
          PolylineLayer(
            polylines: [
              Polyline(
                points: outsiderPathPoints,
                color:
                    _getOutsiderDroneColor(), // Dynamic color based on status
                strokeWidth: 3.0,
                useStrokeWidthInMeter: true,
              ),
            ],
          ),
        // Start and End points
        MarkerLayer(
          markers: [
            if (startPoint != null)
              Marker(
                width: 40.0,
                height: 40.0,
                point: startPoint!,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.green,
                  size: 40,
                ),
              ),
            if (endPoint != null)
              Marker(
                width: 40.0,
                height: 40.0,
                point: endPoint!,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            // Collected Waypoints
            ...collectedWaypoints.map(
              (point) => Marker(
                width: 20.0,
                height: 20.0,
                point: point,
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.purple,
                  size: 20,
                ),
              ),
            ),
            // Main drone marker
            if (latestDrone != null)
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(
                  converter.convertToLatLon(
                      latestDrone.x, latestDrone.y)['latitude']!,
                  converter.convertToLatLon(
                      latestDrone.x, latestDrone.y)['longitude']!,
                ),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () {
                      if (onDroneSelected != null) {
                        onDroneSelected!(latestDrone);
                      }
                    },
                    child: _buildDroneIcon(),
                  ),
                ),
              ),
            // Outsider drone marker
            if (outsiderStatus != null)
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(
                  converter.convertToLatLon(
                      outsiderStatus!.outsiderTelemetry.position.x,
                      outsiderStatus!
                          .outsiderTelemetry.position.y)['latitude']!,
                  converter.convertToLatLon(
                      outsiderStatus!.outsiderTelemetry.position.x,
                      outsiderStatus!
                          .outsiderTelemetry.position.y)['longitude']!,
                ),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child:
                      _buildOutsiderDroneIcon(), // New function for outsider drone icon
                ),
              ),
          ],
        ),
        // Add drone position circle (proximity indicator)
        if (latestDrone != null)
          CircleLayer(
            circles: [
              CircleMarker(
                point: LatLng(
                  converter.convertToLatLon(
                      latestDrone.x, latestDrone.y)['latitude']!,
                  converter.convertToLatLon(
                      latestDrone.x, latestDrone.y)['longitude']!,
                ),
                radius: 50, // 50 meters radius
                color: Colors.blue.withOpacity(0.1),
                borderColor: Colors.blue,
                borderStrokeWidth: 1,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildDroneIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.airplanemode_active,
              color: Colors.teal,
              size: 24,
            ),
            SvgPicture.asset(
              "assets/images/logo.svg",
              width: 32,
              height: 32,
              fit: BoxFit.contain,
              placeholderBuilder: (BuildContext context) => const Icon(
                Icons.airplanemode_active,
                color: Colors.teal,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // New function to build the outsider drone icon with dynamic color
  Widget _buildOutsiderDroneIcon() {
    Color iconColor = _getOutsiderDroneColor();
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.warning_amber, // Or another icon for outsider drone
              color: iconColor,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }


  Color _getOutsiderDroneColor() {
    if (outsiderStatus == null) {
      return Colors.grey; // Default color if no status
    }
    switch (outsiderStatus!.status) {
      case 'pending':
        return Colors.grey;
      case 'blocked':
        return Colors.red;
      case 'authenticated':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
