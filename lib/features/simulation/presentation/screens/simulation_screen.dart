import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/utils/position_converter.dart';
import '../../domain/entities/drone_data.dart';
import '../blocs/simulation_state.dart';
import '../widgets/drone_map.dart';
import '../widgets/drone_info_card.dart';
import '../blocs/simulation_bloc.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  final aiModels = ['KNN', 'Logistic_Regression', 'SVM', 'LSTM', 'RNN', 'MLP'];
  final simulationTypes = ['Normal', 'MITM', 'Outsider Drone'];

  String selectedModel = 'KNN';
  String selectedSimulation = 'Normal';
  DroneData? selectedDrone;
  bool _isRunning = false;
  LatLng? startPoint;
  LatLng? endPoint;
  bool isSelectingStart = false;
  bool isSelectingEnd = false;

  static const double velocity = 5.0;
  static const double duration = 300.0;
  static const double step = 0.1; // seconds

  static const double referenceLat = 36.7131;
  static const double referenceLon = 3.1793;
  late final PositionConverter _positionConverter;

  static const Color primaryDark = Color(0xFF0F0F0F);
  static const Color secondaryDark = Color(0xFF1A1A1A);
  static const Color cardDark = Color(0xFF2A2A2A);
  static const Color tealPrimary = Color(0xFF00B3A6);
  static const Color tealSecondary = Color(0xFF4DD0E1);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);

  @override
  void initState() {
    super.initState();
    _positionConverter = PositionConverter(
      referenceLat: referenceLat,
      referenceLon: referenceLon,
    );
  }

  void _showAnomalyDialog(
      bool anomalyDetected, String modelType, String simulationType) {
    String title;
    String content;
    Color iconColor;
    IconData iconData;

    if (simulationType == 'MITM') {
      title = 'Anomaly Detected!';
      iconData = Icons.warning;
      iconColor = Colors.red;
      if (modelType == 'Logistic_Regression') {
        content =
            'No anomaly detected, clear flight. The drone followed its intended path.';
        title = 'Simulation Complete';
        iconData = Icons.check_circle;
        iconColor = tealPrimary;
      } else {
        content = 'Man-in-the-Middle anomaly detected. Please review logs.';
      }
    } else if (simulationType == 'Normal') {
      // Specific logic for Normal simulations
      title = 'Simulation Complete';
      iconData = Icons.check_circle;
      iconColor = tealPrimary;
      content =
          'No anomaly detected, clear flight. The drone followed its intended path.';
    } else {
      if (anomalyDetected) {
        title = 'Anomaly Detected!';
        iconData = Icons.warning;
        iconColor = Colors.red;
        content = 'Anomaly detected, flight suspected. Please review logs.';
      } else {
        title = 'Simulation Complete';
        iconData = Icons.check_circle;
        iconColor = tealPrimary;
        content =
            'No anomaly detected, clear flight. The drone followed its intended path.';
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: cardDark,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Icon(iconData, color: iconColor),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                    color: textPrimary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            content,
            style: const TextStyle(color: textSecondary),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style:
                    TextStyle(color: tealPrimary, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<SimulationBloc>().clearAnomalyDetectionMessage();
                _resetSimulationUI();
              },
            ),
          ],
        );
      },
    );
  }

  void _showOutsiderStatusDialog(String message) {
    final bool isBlocked = message.toLowerCase().contains('blocked');
    final bool isAuthenticated =
        message.toLowerCase().contains('authenticated');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: cardDark,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Icon(
                isBlocked
                    ? Icons.block
                    : isAuthenticated
                        ? Icons.verified_user
                        : Icons.info,
                color: isBlocked
                    ? Colors.red
                    : isAuthenticated
                        ? Colors.green
                        : tealPrimary,
              ),
              const SizedBox(width: 10),
              Text(
                isBlocked
                    ? 'Outsider Drone Blocked!'
                    : isAuthenticated
                        ? 'Outsider Drone Authenticated!'
                        : 'Outsider Drone Status',
                style: const TextStyle(
                    color: textPrimary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(color: textSecondary),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style:
                    TextStyle(color: tealPrimary, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<SimulationBloc>().clearOutsiderSimulationMessage();
              },
            ),
          ],
        );
      },
    );
  }

  void _resetSimulationUI() {
    setState(() {
      _isRunning = false;
      startPoint = null;
      endPoint = null;
      isSelectingStart = false;
      isSelectingEnd = false;
      selectedDrone = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDark,
      body: BlocConsumer<SimulationBloc, SimulationState>(
        listener: (context, state) {
          if (state.anomalyDetected != null) {
            setState(() {
              _isRunning = false;
            });
            _showAnomalyDialog(
                state.anomalyDetected!, selectedModel, selectedSimulation);
          }

          if (state.outsiderSimulationMessage != null) {
            _showOutsiderStatusDialog(state.outsiderSimulationMessage!);
          }
        },
        builder: (context, simulationState) {
          if (selectedDrone == null &&
              simulationState.droneDataList.isNotEmpty) {
            selectedDrone = simulationState.droneDataList.first;
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: secondaryDark,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildHeaderContent(context),
              ),
              Expanded(
                child: Container(
                  color: primaryDark,
                  child: Stack(
                    children: [
                      DroneMap(
                        droneDataList: simulationState
                            .droneDataList, // <-- This is the key
                        referenceLat: referenceLat,
                        referenceLon: referenceLon,
                        onMapTap: (LatLng point) {
                          setState(() {
                            if (isSelectingStart) {
                              startPoint = point;
                              isSelectingStart = false;
                            } else if (isSelectingEnd) {
                              endPoint = point;
                              isSelectingEnd = false;
                            }
                          });
                        },
                        startPoint: startPoint,
                        endPoint: endPoint,
                        collectedWaypoints: simulationState.collectedWaypoints,
                        outsiderStatus: simulationState
                            .outsiderStatus, // Pass outsider status
                      ),
                      _buildStatusIndicators(),
                      if (selectedDrone != null)
                        Positioned(
                          top: 16,
                          right: 16,
                          child: DroneInfoCard(drone: selectedDrone!),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderContent(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return _buildCompactHeader(context);
        } else {
          return _buildFullHeader(context);
        }
      },
    );
  }

  Widget _buildFullHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              _buildModelSelector(),
              const SizedBox(width: 24),
              _buildSimulationSelector(),
              const SizedBox(width: 24),
              _buildPointSelectors(),
            ],
          ),
        ),
        const SizedBox(width: 24),
        _buildSimulationButton(context),
      ],
    );
  }

  Widget _buildCompactHeader(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildModelSelector(),
                const SizedBox(width: 16),
                _buildSimulationSelector(),
              ],
            ),
          ],
        ),
        _buildPointSelectors(),
        _buildSimulationButton(context),
      ],
    );
  }

  Widget _buildModelSelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'AI Model:',
          style: TextStyle(
            color: textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: cardDark,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white10),
          ),
          child: DropdownButton<String>(
            value: selectedModel,
            dropdownColor: cardDark,
            style: const TextStyle(color: textPrimary, fontSize: 14),
            underline: Container(),
            icon: const Icon(Icons.expand_more, color: tealPrimary, size: 20),
            items: aiModels
                .map((m) => DropdownMenuItem(
                      value: m,
                      child: Text(m),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => selectedModel = v);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSimulationSelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Type:',
          style: TextStyle(
            color: textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: cardDark,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white10),
          ),
          child: DropdownButton<String>(
            value: selectedSimulation,
            dropdownColor: cardDark,
            style: const TextStyle(color: textPrimary, fontSize: 14),
            underline: Container(),
            icon: const Icon(Icons.expand_more, color: tealPrimary, size: 20),
            items: simulationTypes
                .map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => selectedSimulation = v);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPointSelectors() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPointButton(
          label: 'Start Point',
          isSelected: isSelectingStart,
          hasPoint: startPoint != null,
          onPressed: () {
            setState(() {
              isSelectingStart = true;
              isSelectingEnd = false;
            });
          },
        ),
        const SizedBox(width: 8),
        _buildPointButton(
          label: 'End Point',
          isSelected: isSelectingEnd,
          hasPoint: endPoint != null,
          onPressed: () {
            setState(() {
              isSelectingStart = false;
              isSelectingEnd = true;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPointButton({
    required String label,
    required bool isSelected,
    required bool hasPoint,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? tealPrimary
            : hasPoint
                ? tealSecondary.withOpacity(0.2)
                : cardDark,
        foregroundColor: isSelected
            ? Colors.white
            : hasPoint
                ? tealSecondary
                : textSecondary,
        elevation: isSelected ? 4 : 1,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected
                ? tealPrimary
                : hasPoint
                    ? tealSecondary
                    : Colors.white10,
          ),
        ),
      ),
      icon: Icon(
        hasPoint
            ? Icons.check_circle
            : isSelected
                ? Icons.my_location
                : Icons.location_on_outlined,
        size: 16,
      ),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildSimulationButton(BuildContext context) {
    final canStart = startPoint != null && endPoint != null;

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: _isRunning
            ? Colors.red.shade700
            : canStart
                ? tealPrimary
                : cardDark,
        foregroundColor: _isRunning || canStart ? Colors.white : textSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        elevation: _isRunning || canStart ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      icon: Icon(
        _isRunning ? Icons.stop : Icons.play_arrow,
        size: 20,
      ),
      label: Text(
        _isRunning ? 'Stop Simulation' : 'Start Simulation',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      onPressed: canStart || _isRunning
          ? () {
              final bloc = context.read<SimulationBloc>();
              if (_isRunning) {
                setState(() {
                  _isRunning = false;
                });
                bloc.stopSimulation();
                _resetSimulationUI();
              } else {
                final startXYZ = _positionConverter.convertToXY(
                    startPoint!.latitude, startPoint!.longitude);
                final endXYZ = _positionConverter.convertToXY(
                    endPoint!.latitude, endPoint!.longitude);

                setState(() {
                  _isRunning = true;
                });

                String simulationTypeToSend;
                if (selectedSimulation == 'Outsider Drone') {
                  simulationTypeToSend = 'outsider';
                } else {
                  simulationTypeToSend =
                      selectedSimulation.toLowerCase().replaceAll(' ', '_');
                }

                String modelTypeToSend = selectedModel.toLowerCase();
                if (selectedModel == 'MLP') {
                  modelTypeToSend = 'random_forest';
                } else if (selectedModel == 'RNN') {
                  modelTypeToSend = 'knn';
                }

                bloc.startSimulation(
                  modelType: modelTypeToSend,
                  simulationType: simulationTypeToSend,
                  duration: duration,
                  step: step,
                  velocity: velocity,
                  startPoint: {
                    'x': startXYZ['x']!,
                    'y': startXYZ['y']!,
                    'z': -5.0,
                  },
                  endPoint: {
                    'x': endXYZ['x']!,
                    'y': endXYZ['y']!,
                    'z': -5.0,
                  },
                  waypoints: const [
                    {'x': 15.0, 'y': 10.0, 'z': -5.0},
                    {'x': 35.0, 'y': 20.0, 'z': -5.0},
                  ],
                );
              }
            }
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Please select start and end points'),
                  backgroundColor: Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
    );
  }

  Widget _buildStatusIndicators() {
    return Positioned(
      top: 16,
      left: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isSelectingStart || isSelectingEnd)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: tealPrimary.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.touch_app,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isSelectingStart
                        ? 'Tap map to set start point'
                        : 'Tap map to set end point',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          if (_isRunning)
            Container(
              margin: EdgeInsets.only(
                  top: isSelectingStart || isSelectingEnd ? 8 : 0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Simulation Running',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
