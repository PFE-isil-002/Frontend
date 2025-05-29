import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/utils/position_converter.dart';
import '../../domain/entities/drone_data.dart'; // Ensure this includes the new classes

class DroneMap extends StatefulWidget {
  final List<DroneData> droneDataList;
  final double referenceLat;
  final double referenceLon;
  final Function(DroneData)? onDroneSelected;
  final void Function(LatLng latLng)? onMapTap;
  final LatLng? startPoint;
  final LatLng? endPoint;
  final List<LatLng> collectedWaypoints;
  final OutsiderStatusData? outsiderStatus;

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
    this.outsiderStatus,
  });

  @override
  State<DroneMap> createState() => _DroneMapState();
}

class _DroneMapState extends State<DroneMap> with TickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final converter = PositionConverter(
      referenceLat: widget.referenceLat,
      referenceLon: widget.referenceLon,
    );

    final latestDrone =
        widget.droneDataList.isNotEmpty ? widget.droneDataList.last : null;

    // Convert all drone positions to LatLng for the path
    final List<LatLng> dronePathPoints = widget.droneDataList.map((data) {
      final latlon = converter.convertToLatLon(data.x, data.y);
      return LatLng(latlon['latitude']!, latlon['longitude']!);
    }).toList();

    // Convert outsider drone's flight history to LatLng for the path
    final List<LatLng> outsiderPathPoints = widget.outsiderStatus != null
        ? widget.outsiderStatus!.outsiderTelemetry.flightHistory.map((pos) {
            final latlon = converter.convertToLatLon(pos.x, pos.y);
            return LatLng(latlon['latitude']!, latlon['longitude']!);
          }).toList()
        : [];

    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(widget.referenceLat, widget.referenceLon),
        initialZoom: 17,
        onTap: (_, latLng) {
          if (widget.onMapTap != null) {
            widget.onMapTap!(latLng);
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.drone_anomaly_detection',
        ),
        // Existing drone path - only draw if there are at least two points
        if (dronePathPoints.length >= 2)
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
        if (outsiderPathPoints.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: outsiderPathPoints,
                color: _getOutsiderDroneColor(),
                strokeWidth: 3.0,
                useStrokeWidthInMeter: true,
              ),
            ],
          ),
        // Add drone position circle (proximity indicator) - now teal
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
                color: Colors.teal.withOpacity(0.1),
                borderColor: Colors.teal,
                borderStrokeWidth: 1,
              ),
            ],
          ),
        // Add outsider drone position circle (smaller radius)
        if (widget.outsiderStatus != null)
          CircleLayer(
            circles: [
              CircleMarker(
                point: LatLng(
                  converter.convertToLatLon(
                      widget.outsiderStatus!.outsiderTelemetry.position.x,
                      widget.outsiderStatus!.outsiderTelemetry.position
                          .y)['latitude']!,
                  converter.convertToLatLon(
                      widget.outsiderStatus!.outsiderTelemetry.position.x,
                      widget.outsiderStatus!.outsiderTelemetry.position
                          .y)['longitude']!,
                ),
                radius: 25, // Smaller radius for outsider drone (25 meters)
                color: _getOutsiderDroneColor().withOpacity(0.1),
                borderColor: _getOutsiderDroneColor(),
                borderStrokeWidth: 1,
              ),
            ],
          ),
        // Flight history dots for main drone (excluding the latest position)
        if (dronePathPoints.length > 1)
          MarkerLayer(
            markers: dronePathPoints
                .take(dronePathPoints.length - 1) // Exclude the latest position
                .map((point) => Marker(
                      width: 8.0,
                      height: 8.0,
                      point: point,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.teal,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                      ),
                    ))
                .toList(),
          ),
        // Markers layer
        MarkerLayer(
          markers: [
            if (widget.startPoint != null)
              Marker(
                width: 40.0,
                height: 40.0,
                point: widget.startPoint!,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.green,
                  size: 40,
                ),
              ),
            if (widget.endPoint != null)
              Marker(
                width: 40.0,
                height: 40.0,
                point: widget.endPoint!,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            // Collected Waypoints - show only the latest SVG (simulating drone movement)
            if (widget.collectedWaypoints.isNotEmpty)
              Marker(
                width: 50.0,
                height: 50.0,
                point: widget
                    .collectedWaypoints.last, // Only show the latest waypoint
                child: Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  child: _buildWaypointDroneIcon(),
                ),
              ),
            // Main drone marker with animation
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
                      if (widget.onDroneSelected != null) {
                        widget.onDroneSelected!(latestDrone);
                      }
                    },
                    child: _buildAnimatedDroneIcon(),
                  ),
                ),
              ),
            // Outsider drone marker
            if (widget.outsiderStatus != null)
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(
                  converter.convertToLatLon(
                      widget.outsiderStatus!.outsiderTelemetry.position.x,
                      widget.outsiderStatus!.outsiderTelemetry.position
                          .y)['latitude']!,
                  converter.convertToLatLon(
                      widget.outsiderStatus!.outsiderTelemetry.position.x,
                      widget.outsiderStatus!.outsiderTelemetry.position
                          .y)['longitude']!,
                ),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: _buildOutsiderDroneIcon(),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnimatedDroneIcon() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseController.value * 0.1), // Subtle pulse effect
          child: Container(
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
                  // SVG without rotation
                  SvgPicture.asset(
                    "assets/images/logo.svg",
                    width: 28,
                    height: 28,
                    placeholderBuilder: (BuildContext context) => const Icon(
                      Icons.airplanemode_active,
                      color: Colors.teal,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOutsiderDroneIcon() {
    Color iconColor = _getOutsiderDroneColor();
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseController.value * 0.15),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: iconColor, width: 2),
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
                    Icons.warning_amber,
                    color: iconColor,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaypointDroneIcon() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseController.value * 0.15),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.purple, width: 2),
            ),
            child: ClipOval(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // SVG without rotation for waypoint drone too
                  SvgPicture.asset(
                    "assets/images/logo.svg",
                    width: 35,
                    height: 35,
                    fit: BoxFit.contain,
                    placeholderBuilder: (BuildContext context) => const Icon(
                      Icons.airplanemode_active,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getOutsiderDroneColor() {
    if (widget.outsiderStatus == null) {
      return Colors.grey;
    }
    switch (widget.outsiderStatus!.status) {
      case 'pending':
        return Colors.orange;
      case 'blocked':
        return Colors.red;
      case 'authenticated':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
