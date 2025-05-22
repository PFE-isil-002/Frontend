import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/utils/position_converter.dart';
import '../../domain/entities/drone_data.dart';

class DroneMap extends StatefulWidget {
  final List<DroneData> droneDataList;
  final double referenceLat;
  final double referenceLon;
  final Function(DroneData)? onDroneSelected;

  const DroneMap({
    super.key,
    required this.droneDataList,
    required this.referenceLat,
    required this.referenceLon,
    this.onDroneSelected,
  });

  @override
  State<DroneMap> createState() => _DroneMapState();
}

class _DroneMapState extends State<DroneMap> {
  late PositionConverter converter;

  @override
  void initState() {
    super.initState();
    converter = PositionConverter(
      referenceLat: widget.referenceLat,
      referenceLon: widget.referenceLon,
    );
  }

  @override
  Widget build(BuildContext context) {
    
    final latestDrone =
        widget.droneDataList.isNotEmpty ? widget.droneDataList.last : null;

    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(widget.referenceLat, widget.referenceLon),
        initialZoom: 17,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
        ),
        // Circle for drone zone (only if drone exists)
        if (latestDrone != null)
          CircleLayer(
            circles: [
              () {
                final latlon =
                    converter.convertToLatLon(latestDrone.x, latestDrone.y);
                return CircleMarker(
                  key: const ValueKey('drone_circle'),
                  point: LatLng(latlon['latitude']!, latlon['longitude']!),
                  radius: 30,
                  useRadiusInMeter: true,
                  color: Colors.teal.withOpacity(0.2),
                  borderColor: Colors.teal.withOpacity(0.4),
                  borderStrokeWidth: 1.0,
                );
              }()
            ],
          ),
        // Drone marker (only if drone exists)
        if (latestDrone != null)
          MarkerLayer(
            markers: [
              () {
                final latlon =
                    converter.convertToLatLon(latestDrone.x, latestDrone.y);
                return Marker(
                  key: const ValueKey('drone_marker'),
                  point: LatLng(latlon['latitude']!, latlon['longitude']!),
                  width: 60,
                  height: 60,
                  child: GestureDetector(
                    onTap: () => widget.onDroneSelected?.call(latestDrone),
                    child: const DroneMarker(),
                  ),
                );
              }()
            ],
          ),
      ],
    );
  }
}

class DroneMarker extends StatelessWidget {
  const DroneMarker({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Drone icon
        SvgPicture.asset(
          'assets/images/logo.svg',
          width: 24,
          height: 24,
        ),
        // Drone identifier
        Positioned(
          bottom: -5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Drone 1', // Fixed label for single drone
              style: const TextStyle(
                color: Colors.teal,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
