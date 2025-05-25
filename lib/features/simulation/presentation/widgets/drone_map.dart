// lib/features/simulation/presentation/widgets/drone_map.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/utils/position_converter.dart';
import '../../domain/entities/drone_data.dart';

class DroneMap extends StatelessWidget {
  final List<DroneData> droneDataList;
  final double referenceLat;
  final double referenceLon;
  final Function(DroneData)? onDroneSelected;
  final void Function(LatLng latLng)? onMapTap;
  final LatLng? startPoint;
  final LatLng? endPoint;
  final List<LatLng> collectedWaypoints;

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
        // Base map tiles
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
        ),

        // Start point marker
        if (startPoint != null)
          MarkerLayer(
            markers: [
              Marker(
                point: startPoint!,
                width: 40,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.8),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

        // End point marker
        if (endPoint != null)
          MarkerLayer(
            markers: [
              Marker(
                point: endPoint!,
                width: 40,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.red, width: 2),
                  ),
                  child: const Icon(
                    Icons.stop,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

        // Collected waypoints as small blue dots
        if (collectedWaypoints.isNotEmpty)
          MarkerLayer(
            markers: collectedWaypoints.map((waypoint) {
              return Marker(
                point: waypoint,
                width: 16,
                height: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                ),
              );
            }).toList(),
          ),

        // Drone path visualization (red line showing where drone has been)
        if (dronePathPoints.length > 1)
          PolylineLayer(
            polylines: [
              Polyline(
                points: dronePathPoints,
                color: Colors.red.withOpacity(0.8),
                strokeWidth: 3.0,
              ),
            ],
          ),

        // Previous drone positions as small dots (optional - shows historical positions)
        if (dronePathPoints.length > 1)
          MarkerLayer(
            markers: dronePathPoints
                .take(dronePathPoints.length - 1) // Exclude the latest position
                .map((point) {
              return Marker(
                point: point,
                width: 8,
                height: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.6),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 0.5),
                  ),
                ),
              );
            }).toList(),
          ),

        // Current drone position circle (proximity indicator)
        if (latestDrone != null)
          CircleLayer(
            circles: [
              () {
                final latlon =
                    converter.convertToLatLon(latestDrone.x, latestDrone.y);
                return CircleMarker(
                  point: LatLng(latlon['latitude']!, latlon['longitude']!),
                  radius: 30,
                  useRadiusInMeter: true,
                  color: Colors.teal.withOpacity(0.15),
                  borderColor: Colors.teal.withOpacity(0.4),
                  borderStrokeWidth: 1.5,
                );
              }()
            ],
          ),

        // Current drone position (SVG icon) - this is the main moving drone
        if (latestDrone != null)
          MarkerLayer(
            markers: [
              () {
                final latlon =
                    converter.convertToLatLon(latestDrone.x, latestDrone.y);
                return Marker(
                  point: LatLng(latlon['latitude']!, latlon['longitude']!),
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
                );
              }()
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
            // Fallback icon in case SVG fails to load
            Icon(
              Icons.airplanemode_active,
              color: Colors.teal,
              size: 24,
            ),
            // SVG overlay - will show if the asset exists and loads successfully
            SvgPicture.asset(
              "assets/images/logo.svg",
              width: 32,
              height: 32,
              fit: BoxFit.contain,
              // Add error handling
              placeholderBuilder: (BuildContext context) => Icon(
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
}
