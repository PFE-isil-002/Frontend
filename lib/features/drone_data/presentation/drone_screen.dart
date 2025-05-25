import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../bloc/drone_bloc.dart';
import '../bloc/drone_event.dart';
import '../bloc/drone_state.dart';
import '../domain/entities/drone_info.dart';

class DroneScreen extends StatelessWidget {
  const DroneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DroneInfoBloc(),
      child: const DroneScreenContent(),
    );
  }
}

class DroneScreenContent extends StatefulWidget {
  const DroneScreenContent({super.key});

  @override
  State<DroneScreenContent> createState() => _DroneScreenContentState();
}

class _DroneScreenContentState extends State<DroneScreenContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? selectedDroneId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<DroneInfoBloc>().add(LoadDronesInfo());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: BlocBuilder<DroneInfoBloc, DroneInfoState>(
        builder: (context, state) {
          if (state is DroneInfoLoading) {
            return Scaffold(
              backgroundColor: const Color(0xFF1A1A1A),
              body: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF00B3A6))),
            );
          }

          if (state is DroneInfoLoaded) {
            if (selectedDroneId == null && state.drones.isNotEmpty) {
              selectedDroneId = state.drones.first.id;
            }

            final selectedDrone = state.drones.firstWhere(
              (drone) => drone.id == selectedDroneId,
              orElse: () =>
                  state.drones.isEmpty ? DroneInfo.empty() : state.drones.first,
            );

            return Column(
              children: [
                // Header with drone selection and status
                Container(
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFF1A1A1A),
                  child: Row(
                    children: [
                      // Drone Selection
                      const Text(
                        'PX4 Drone:',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: DropdownButton<String>(
                          value: selectedDroneId,
                          dropdownColor: const Color(0xFF2A2A2A),
                          style: const TextStyle(color: Colors.white),
                          underline: Container(),
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.teal),
                          items: state.drones
                              .map((drone) => DropdownMenuItem(
                                    value: drone.id,
                                    child: Text('${drone.name} (${drone.id})'),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => selectedDroneId = value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Drone connection status
                      DroneStatusIndicator(
                          connected: selectedDrone.isConnected),

                      const Spacer(),

                      // Refresh button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B3A6),
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh Data'),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                // Tab bar
                Container(
                  color: const Color(0xFF262626),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF00B3A6),
                    unselectedLabelColor: Colors.white70,
                    indicatorColor: const Color(0xFF00B3A6),
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Parameters'),
                      Tab(text: 'Telemetry'),
                    ],
                  ),
                ),

                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Overview Tab
                      _buildOverviewTab(selectedDrone),

                      // Parameters Tab
                      _buildParametersTab(selectedDrone),

                      // Telemetry Tab
                      _buildTelemetryTab(selectedDrone),
                    ],
                  ),
                ),
              ],
            );
          }

          if (state is DroneInfoError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading drone data: ${state.message}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B3A6),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {},
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const Center(
              child: Text('No drone data available',
                  style: TextStyle(color: Colors.white70)));
        },
      ),
    );
  }

  Widget _buildOverviewTab(DroneInfo drone) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drone summary card
          Card(
            color: const Color(0xFF262626),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset('assets/icons/drone-on-icon.svg',
                          width: 48, height: 48),
                      const SizedBox(width: 30),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            drone.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Firmware: ${drone.firmwareVersion}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getFlightModeColor(drone.flightMode),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          drone.flightMode,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 32),
                  Row(
                    children: [
                      _buildInfoItem(
                          'Battery',
                          '${drone.batteryLevel.toStringAsFixed(1)}%',
                          _getBatteryIcon(drone.batteryLevel)),
                      _buildInfoItem('GPS', '${drone.gpsSatellites} satellites',
                          Icons.gps_fixed),
                      _buildInfoItem(
                          'Signal',
                          '${drone.signalStrength.toStringAsFixed(0)}%',
                          _getSignalIcon(drone.signalStrength)),
                      _buildInfoItem(
                          'Altitude',
                          '${drone.altitude.toStringAsFixed(1)}m',
                          Icons.height),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Current position
          const Text(
            'Current Position',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: const Color(0xFF262626),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildPositionItem(
                            'Latitude', drone.latitude.toStringAsFixed(6)),
                      ),
                      Expanded(
                        child: _buildPositionItem(
                            'Longitude', drone.longitude.toStringAsFixed(6)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPositionItem('Altitude',
                            '${drone.altitude.toStringAsFixed(2)} m'),
                      ),
                      Expanded(
                        child: _buildPositionItem('Ground Speed',
                            '${drone.groundSpeed.toStringAsFixed(2)} m/s'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Attitude information
          const Text(
            'Attitude',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: const Color(0xFF262626),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildAttitudeItem(
                        'Roll', '${drone.roll.toStringAsFixed(1)}°'),
                  ),
                  Expanded(
                    child: _buildAttitudeItem(
                        'Pitch', '${drone.pitch.toStringAsFixed(1)}°'),
                  ),
                  Expanded(
                    child: _buildAttitudeItem(
                        'Yaw', '${drone.yaw.toStringAsFixed(1)}°'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Mission status
          if (drone.missionItems > 0)
            Card(
              color: const Color(0xFF262626),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mission',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildMissionItem(
                              'Waypoints', drone.missionItems.toString()),
                        ),
                        Expanded(
                          flex: 3,
                          child: _buildMissionItem('Current Waypoint',
                              '${drone.currentWaypoint}/${drone.missionItems}'),
                        ),
                        Expanded(
                          flex: 3,
                          child: _buildMissionItem('Distance to Next',
                              '${drone.distanceToNext.toStringAsFixed(1)} m'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: drone.missionProgress,
                        backgroundColor: Colors.white12,
                        color: const Color(0xFF00B3A6),
                        minHeight: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildParametersTab(DroneInfo drone) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Parameter search
        TextField(
          decoration: InputDecoration(
            hintText: 'Search parameters...',
            fillColor: const Color(0xFF262626),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.search, color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
        ),

        const SizedBox(height: 24),

        // Parameter groups
        ExpansionTile(
          title: const Text('System Parameters',
              style: TextStyle(color: Colors.white)),
          iconColor: const Color(0xFF00B3A6),
          collapsedIconColor: Colors.white70,
          children: [
            DroneParameterCard(
              name: 'SYS_AUTOSTART',
              value: '4001',
              description: 'Auto-start script index',
              onEdit: (value) => _updateParameter('SYS_AUTOSTART', value),
            ),
            DroneParameterCard(
              name: 'SYS_MC_EST_GROUP',
              value: '2',
              description: 'Set estimator group',
              onEdit: (value) => _updateParameter('SYS_MC_EST_GROUP', value),
            ),
            DroneParameterCard(
              name: 'SYS_HAS_BARO',
              value: '1',
              description: 'Barometer available',
              onEdit: (value) => _updateParameter('SYS_HAS_BARO', value),
            ),
          ],
        ),

        ExpansionTile(
          title: const Text('Battery Parameters',
              style: TextStyle(color: Colors.white)),
          iconColor: const Color(0xFF00B3A6),
          collapsedIconColor: Colors.white70,
          children: [
            DroneParameterCard(
              name: 'BAT_N_CELLS',
              value: '4',
              description: 'Number of cells',
              onEdit: (value) => _updateParameter('BAT_N_CELLS', value),
            ),
            DroneParameterCard(
              name: 'BAT_V_EMPTY',
              value: '3.5',
              description: 'Empty cell voltage (V)',
              onEdit: (value) => _updateParameter('BAT_V_EMPTY', value),
            ),
            DroneParameterCard(
              name: 'BAT_V_CHARGED',
              value: '4.2',
              description: 'Full cell voltage (V)',
              onEdit: (value) => _updateParameter('BAT_V_CHARGED', value),
            ),
          ],
        ),

        ExpansionTile(
          title: const Text('Multicopter Position Control',
              style: TextStyle(color: Colors.white)),
          iconColor: const Color(0xFF00B3A6),
          collapsedIconColor: Colors.white70,
          children: [
            DroneParameterCard(
              name: 'MPC_XY_P',
              value: '0.95',
              description: 'Proportional gain for horizontal position',
              onEdit: (value) => _updateParameter('MPC_XY_P', value),
            ),
            DroneParameterCard(
              name: 'MPC_XY_VEL_P',
              value: '0.09',
              description: 'Proportional gain for horizontal velocity',
              onEdit: (value) => _updateParameter('MPC_XY_VEL_P', value),
            ),
            DroneParameterCard(
              name: 'MPC_Z_P',
              value: '1.0',
              description: 'Proportional gain for vertical position',
              onEdit: (value) => _updateParameter('MPC_Z_P', value),
            ),
          ],
        ),

        ExpansionTile(
          title: const Text('Sensors', style: TextStyle(color: Colors.white)),
          iconColor: const Color(0xFF00B3A6),
          collapsedIconColor: Colors.white70,
          children: [
            DroneParameterCard(
              name: 'SENS_BOARD_ROT',
              value: '0',
              description: 'Board rotation',
              onEdit: (value) => _updateParameter('SENS_BOARD_ROT', value),
            ),
            DroneParameterCard(
              name: 'CAL_GYRO0_XOFF',
              value: '0.0012',
              description: 'Gyroscope X calibration offset',
              onEdit: (value) => _updateParameter('CAL_GYRO0_XOFF', value),
            ),
            DroneParameterCard(
              name: 'CAL_ACC0_XOFF',
              value: '0.0143',
              description: 'Accelerometer X calibration offset',
              onEdit: (value) => _updateParameter('CAL_ACC0_XOFF', value),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTelemetryTab(DroneInfo drone) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Altitude and Vertical Speed',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: TelemetryChart(
              data: drone.altitudeHistory
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
              secondaryData: drone.verticalSpeedHistory
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
              primaryLabel: 'Altitude (m)',
              secondaryLabel: 'Vertical Speed (m/s)',
              primaryColor: const Color(0xFF00B3A6),
              secondaryColor: Colors.amber,
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Battery Voltage and Current',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: TelemetryChart(
              data: drone.voltageHistory
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
              secondaryData: drone.currentHistory
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
              primaryLabel: 'Voltage (V)',
              secondaryLabel: 'Current (A)',
              primaryColor: Colors.green,
              secondaryColor: Colors.red,
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Attitude',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: TelemetryChart(
              data: drone.rollHistory
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
              secondaryData: drone.pitchHistory
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
              tertiaryData: drone.yawHistory
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
              primaryLabel: 'Roll (°)',
              secondaryLabel: 'Pitch (°)',
              tertiaryLabel: 'Yaw (°)',
              primaryColor: Colors.blue,
              secondaryColor: Colors.orange,
              tertiaryColor: Colors.purple,
            ),
          ),

          const SizedBox(height: 24),

          // Raw telemetry data
          const Text(
            'Raw Telemetry Data',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: const Color(0xFF262626),
            elevation: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTelemetryDataRow('MAV_TYPE', drone.vehicleType),
                  _buildTelemetryDataRow(
                      'HEARTBEAT', 'Rate: 1Hz, Count: ${drone.heartbeatCount}'),
                  _buildTelemetryDataRow('SYS_STATUS',
                      'Sensors: ${drone.sensorsHealth}, CPU: ${drone.cpuLoad}%'),
                  _buildTelemetryDataRow('GLOBAL_POSITION_INT',
                      'Lat: ${drone.latitude}, Lon: ${drone.longitude}'),
                  _buildTelemetryDataRow('VFR_HUD',
                      'Airspeed: ${drone.airspeed.toStringAsFixed(1)} m/s'),
                  _buildTelemetryDataRow('ATTITUDE',
                      'Roll: ${drone.roll}°, Pitch: ${drone.pitch}°, Yaw: ${drone.yaw}°'),
                  _buildTelemetryDataRow('BATTERY_STATUS',
                      'Remaining: ${drone.batteryRemaining}%'),
                  _buildTelemetryDataRow('STATUSTEXT', drone.lastStatusText),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for UI components
  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF00B3A6), size: 28),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPositionItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildAttitudeItem(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMissionItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTelemetryDataRow(String name, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 180,
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white70,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

// Helper methods for UI logic
  Color _getFlightModeColor(String mode) {
    switch (mode) {
      case 'MANUAL':
        return Colors.blue;
      case 'STABILIZED':
        return Colors.teal;
      case 'ALTITUDE':
        return Colors.cyan;
      case 'POSITION':
        return Colors.green;
      case 'OFFBOARD':
        return Colors.purple;
      case 'RETURN':
        return Colors.orange;
      case 'MISSION':
        return Colors.amber;
      case 'LAND':
        return Colors.indigo;
      case 'ACRO':
        return Colors.deepOrange;
      case 'RATTITUDE':
        return Colors.lightBlue;
      default:
        return Colors.grey;
    }
  }

  IconData _getBatteryIcon(double level) {
    if (level > 80) {
      return Icons.battery_full;
    } else if (level > 60) {
      return Icons.battery_6_bar;
    } else if (level > 40) {
      return Icons.battery_4_bar;
    } else if (level > 20) {
      return Icons.battery_2_bar;
    } else {
      return Icons.battery_alert;
    }
  }

  IconData _getSignalIcon(double strength) {
    if (strength > 80) {
      return Icons.signal_cellular_4_bar;
    } else if (strength > 60) {
      return Icons.signal_cellular_alt_2_bar;
    } else if (strength > 40) {
      return Icons.signal_cellular_alt_2_bar;
    } else if (strength > 20) {
      return Icons.signal_cellular_alt_1_bar;
    } else {
      return Icons.signal_cellular_0_bar;
    }
  }

  void _updateParameter(String name, String value) {
    // In a real application, this would send the parameter update to the drone
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Updated $name to $value'),
        backgroundColor: const Color(0xFF00B3A6),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// Additional classes needed for the implementation

// Below are the necessary widgets needed for the drone screen

class DroneParameterCard extends StatelessWidget {
  final String name;
  final String value;
  final String description;
  final Function(String) onEdit;

  const DroneParameterCard({
    super.key,
    required this.name,
    required this.value,
    required this.description,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF333333),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Parameter info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Parameter value and edit button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF262626),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.edit,
                        color: Color(0xFF00B3A6), size: 20),
                    onPressed: () {
                      _showEditDialog(context);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final textController = TextEditingController(text: value);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF262626),
        title: Text('Edit $name', style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF333333),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white70),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B3A6),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              onEdit(textController.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class DroneStatusIndicator extends StatelessWidget {
  final bool connected;

  const DroneStatusIndicator({
    super.key,
    required this.connected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: connected
            ? Colors.green.withOpacity(0.3)
            : Colors.red.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: connected ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            connected ? 'Connected' : 'Disconnected',
            style: TextStyle(
              color: connected ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class TelemetryChart extends StatelessWidget {
  final List<FlSpot> data;
  final List<FlSpot>? secondaryData;
  final List<FlSpot>? tertiaryData;
  final String primaryLabel;
  final String? secondaryLabel;
  final String? tertiaryLabel;
  final Color primaryColor;
  final Color? secondaryColor;
  final Color? tertiaryColor;
  final String? title;
  final String? xAxisLabel;
  final String? yAxisLabel;

  const TelemetryChart({
    super.key,
    required this.data,
    this.secondaryData,
    this.tertiaryData,
    required this.primaryLabel,
    this.secondaryLabel,
    this.tertiaryLabel,
    required this.primaryColor,
    this.secondaryColor,
    this.tertiaryColor,
    this.title,
    this.xAxisLabel,
    this.yAxisLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF262626),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chart title
            if (title != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  title!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            // Chart legend
            Wrap(
              spacing: 16,
              children: [
                _buildLegendItem(primaryLabel, primaryColor),
                if (secondaryLabel != null && secondaryColor != null)
                  _buildLegendItem(secondaryLabel!, secondaryColor!),
                if (tertiaryLabel != null && tertiaryColor != null)
                  _buildLegendItem(tertiaryLabel!, tertiaryColor!),
              ],
            ),

            const SizedBox(height: 16),

            // Chart area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(16),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      drawHorizontalLine: true,
                      getDrawingHorizontalLine: (value) {
                        return const FlLine(
                          color: Color(0xFF404040),
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return const FlLine(
                          color: Color(0xFF404040),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        axisNameWidget: xAxisLabel != null
                            ? Text(
                                xAxisLabel!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              )
                            : null,
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: _calculateInterval(data, true),
                          getTitlesWidget: (double value, TitleMeta meta) {
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                value.toStringAsFixed(0),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        axisNameWidget: yAxisLabel != null
                            ? Text(
                                yAxisLabel!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              )
                            : null,
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: _calculateInterval(data, false),
                          reservedSize: 42,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                value.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                        color: const Color(0xFF404040),
                        width: 1,
                      ),
                    ),
                    minX: _getMinValue(data, true),
                    maxX: _getMaxValue(data, true),
                    minY: _getMinValue(data, false),
                    maxY: _getMaxValue(data, false),
                    lineBarsData: _buildLineChartBarData(),
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        tooltipRoundedRadius: 8,
                        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                          return touchedBarSpots.map((barSpot) {
                            //final flSpot = barSpot.bar;
                            String label = primaryLabel;
                            if (barSpot.barIndex == 1 &&
                                secondaryLabel != null) {
                              label = secondaryLabel!;
                            } else if (barSpot.barIndex == 2 &&
                                tertiaryLabel != null) {
                              label = tertiaryLabel!;
                            }
                            return LineTooltipItem(
                              '$label: ${barSpot.y.toStringAsFixed(2)}',
                              TextStyle(
                                color: barSpot.bar.color,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<LineChartBarData> _buildLineChartBarData() {
    List<LineChartBarData> lines = [];

    // Primary data line
    lines.add(
      LineChartBarData(
        spots: data,
        isCurved: true,
        color: primaryColor,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 4,
              color: primaryColor,
              strokeWidth: 2,
              strokeColor: const Color(0xFF262626),
            );
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          color: primaryColor.withOpacity(0.1),
        ),
      ),
    );

    // Secondary data line
    if (secondaryData != null && secondaryColor != null) {
      lines.add(
        LineChartBarData(
          spots: secondaryData!,
          isCurved: true,
          color: secondaryColor!,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: secondaryColor!,
                strokeWidth: 2,
                strokeColor: const Color(0xFF262626),
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: secondaryColor!.withOpacity(0.1),
          ),
        ),
      );
    }

    // Tertiary data line
    if (tertiaryData != null && tertiaryColor != null) {
      lines.add(
        LineChartBarData(
          spots: tertiaryData!,
          isCurved: true,
          color: tertiaryColor!,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: tertiaryColor!,
                strokeWidth: 2,
                strokeColor: const Color(0xFF262626),
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: tertiaryColor!.withOpacity(0.1),
          ),
        ),
      );
    }

    return lines;
  }

  double _getMinValue(List<FlSpot> spots, bool isX) {
    double min = isX ? spots.first.x : spots.first.y;
    for (FlSpot spot in spots) {
      double value = isX ? spot.x : spot.y;
      if (value < min) min = value;
    }

    // Include secondary and tertiary data in calculations
    if (secondaryData != null) {
      for (FlSpot spot in secondaryData!) {
        double value = isX ? spot.x : spot.y;
        if (value < min) min = value;
      }
    }
    if (tertiaryData != null) {
      for (FlSpot spot in tertiaryData!) {
        double value = isX ? spot.x : spot.y;
        if (value < min) min = value;
      }
    }

    return min;
  }

  double _getMaxValue(List<FlSpot> spots, bool isX) {
    double max = isX ? spots.first.x : spots.first.y;
    for (FlSpot spot in spots) {
      double value = isX ? spot.x : spot.y;
      if (value > max) max = value;
    }

    // Include secondary and tertiary data in calculations
    if (secondaryData != null) {
      for (FlSpot spot in secondaryData!) {
        double value = isX ? spot.x : spot.y;
        if (value > max) max = value;
      }
    }
    if (tertiaryData != null) {
      for (FlSpot spot in tertiaryData!) {
        double value = isX ? spot.x : spot.y;
        if (value > max) max = value;
      }
    }

    return max;
  }

  double _calculateInterval(List<FlSpot> spots, bool isX) {
    double min = _getMinValue(spots, isX);
    double max = _getMaxValue(spots, isX);
    double range = max - min;

    if (range == 0) return 1;

    // Calculate a reasonable interval for about 5-8 ticks
    double interval = range / 6;

    // Round to a nice number
    if (interval < 1) {
      return 0.5;
    } else if (interval < 5) {
      return 1;
    } else if (interval < 10) {
      return 5;
    } else if (interval < 50) {
      return 10;
    } else {
      return (interval / 10).round() * 10.0;
    }
  }
}

// Example usage:
class TelemetryChartExample extends StatelessWidget {
  const TelemetryChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample telemetry data
    final List<FlSpot> temperatureData = [
      const FlSpot(0, 25.5),
      const FlSpot(1, 26.2),
      const FlSpot(2, 27.8),
      const FlSpot(3, 29.1),
      const FlSpot(4, 28.7),
      const FlSpot(5, 30.2),
      const FlSpot(6, 31.5),
      const FlSpot(7, 29.8),
      const FlSpot(8, 28.2),
      const FlSpot(9, 27.1),
    ];

    final List<FlSpot> humidityData = [
      const FlSpot(0, 65.0),
      const FlSpot(1, 62.5),
      const FlSpot(2, 58.3),
      const FlSpot(3, 55.7),
      const FlSpot(4, 59.2),
      const FlSpot(5, 52.8),
      const FlSpot(6, 48.9),
      const FlSpot(7, 54.1),
      const FlSpot(8, 61.3),
      const FlSpot(9, 67.8),
    ];

    final List<FlSpot> pressureData = [
      const FlSpot(0, 1013.2),
      const FlSpot(1, 1012.8),
      const FlSpot(2, 1014.1),
      const FlSpot(3, 1015.5),
      const FlSpot(4, 1013.9),
      const FlSpot(5, 1016.2),
      const FlSpot(6, 1017.8),
      const FlSpot(7, 1015.1),
      const FlSpot(8, 1012.7),
      const FlSpot(9, 1011.5),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text('Telemetry Dashboard'),
        backgroundColor: const Color(0xFF262626),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: TelemetryChart(
                data: temperatureData,
                secondaryData: humidityData,
                tertiaryData: pressureData,
                primaryLabel: 'Temperature (°C)',
                secondaryLabel: 'Humidity (%)',
                tertiaryLabel: 'Pressure (hPa)',
                primaryColor: Colors.red,
                secondaryColor: Colors.blue,
                tertiaryColor: Colors.green,
                title: 'Environmental Telemetry',
                xAxisLabel: 'Time (hours)',
                yAxisLabel: 'Values',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildLegendItem(String label, Color color) {
  return Padding(
    padding: const EdgeInsets.only(right: 16),
    child: Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    ),
  );
}

class DroneSystemHealth extends StatelessWidget {
  final DroneInfo drone;

  const DroneSystemHealth({
    super.key,
    required this.drone,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF262626),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Health',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // System status indicators
            Row(
              children: [
                Expanded(
                  child: _buildHealthIndicator(
                    'Battery',
                    drone.batteryLevel,
                    icon: Icons.battery_full,
                  ),
                ),
                Expanded(
                  child: _buildHealthIndicator(
                    'GPS',
                    drone.gpsSatellites > 8
                        ? 100
                        : (drone.gpsSatellites / 8 * 100),
                    icon: Icons.gps_fixed,
                  ),
                ),
                Expanded(
                  child: _buildHealthIndicator(
                    'Signal',
                    drone.signalStrength,
                    icon: Icons.signal_cellular_alt,
                  ),
                ),
                Expanded(
                  child: _buildHealthIndicator(
                    'CPU',
                    (100 - drone.cpuLoad) as double,
                    icon: Icons.memory,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Component status
            Row(
              children: [
                Expanded(
                  child: _buildComponentStatus(
                    'Sensors',
                    drone.accelCalibrated &&
                        drone.gyroCalibrated &&
                        drone.magCalibrated,
                  ),
                ),
                Expanded(
                  child: _buildComponentStatus(
                    'Radio',
                    drone.rcCalibrated,
                  ),
                ),
                Expanded(
                  child: _buildComponentStatus(
                    'GPS',
                    drone.gpsSatellites >= 6,
                  ),
                ),
                Expanded(
                  child: _buildComponentStatus(
                    'Motors',
                    drone.escCalibrated,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthIndicator(String label, double value,
      {required IconData icon}) {
    Color getColor() {
      if (value > 75) return Colors.green;
      if (value > 50) return Colors.yellow;
      if (value > 25) return Colors.orange;
      return Colors.red;
    }

    return Column(
      children: [
        Icon(icon, color: getColor(), size: 28),
        const SizedBox(height: 8),
        Text(
          '${value.toStringAsFixed(0)}%',
          style: TextStyle(
            color: getColor(),
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildComponentStatus(String label, bool isOk) {
    return Column(
      children: [
        Icon(
          isOk ? Icons.check_circle : Icons.error,
          color: isOk ? Colors.green : Colors.red,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          isOk ? 'OK' : 'Error',
          style: TextStyle(
            color: isOk ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
