import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/drone_data.dart';
import '../widgets/drone_map.dart';
import '../widgets/drone_info_card.dart';
import '../blocs/simulation_bloc.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  final aiModels = [
    'KNN',
    'Logistic Regression',
    'SVM',
    'LSTM',
    'RNN',
    'Random Forest'
  ];
  final simulationTypes = ['Normal', 'Man in the Middle', 'Outsider Drone'];

  String selectedModel = 'KNN';
  String selectedSimulation = 'Normal';
  DroneData? selectedDrone;
  bool _isRunning = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<SimulationBloc, List<DroneData>>(
        builder: (context, drones) {
          // Auto-select the first drone if available and none is selected
          if (selectedDrone == null && drones.isNotEmpty) {
            selectedDrone = drones.first;
          }

          return Row(
            children: [
              // Main content area
              Expanded(
                child: Column(
                  children: [
                    // Header with controls
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: const Color(0xFF1A1A1A),
                      child: Row(
                        children: [
                          Row(
                            children: [
                              const Text(
                                'AI Model:',
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: DropdownButton<String>(
                                  value: selectedModel,
                                  dropdownColor: const Color(0xFF2A2A2A),
                                  style: const TextStyle(color: Colors.white),
                                  underline: Container(),
                                  icon: const Icon(Icons.arrow_drop_down,
                                      color: Colors.teal),
                                  items: aiModels
                                      .map((m) => DropdownMenuItem(
                                          value: m, child: Text(m)))
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() => selectedModel = v);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 24),
                              // Simulation type selection
                              const Text(
                                'Simulation:',
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: DropdownButton<String>(
                                  value: selectedSimulation,
                                  dropdownColor: const Color(0xFF2A2A2A),
                                  style: const TextStyle(color: Colors.white),
                                  underline: Container(),
                                  icon: const Icon(Icons.arrow_drop_down,
                                      color: Colors.teal),
                                  items: simulationTypes
                                      .map((s) => DropdownMenuItem(
                                          value: s, child: Text(s)))
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() => selectedSimulation = v);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 24),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00B3A6),
                              foregroundColor: Colors.white,
                            ),
                            icon: Icon(
                                _isRunning ? Icons.stop : Icons.play_arrow),
                            label: Text(_isRunning
                                ? 'Stop Simulation'
                                : 'Start Simulation'),
                            onPressed: () {
                              final bloc = context.read<SimulationBloc>();
                              if (_isRunning) {
                                setState(() {
                                  _isRunning = false;
                                });
                                bloc.stopSimulation();
                              } else {
                                setState(() {
                                  _isRunning = true;
                                });
                                bloc.startSimulation(
                                  selectedModel.toLowerCase(),
                                  selectedSimulation
                                      .toLowerCase()
                                      .replaceAll(' ', '_'),
                                  60,
                                  0.1,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Stack(
                        children: [
                          DroneMap(
                            droneDataList: drones,
                            referenceLat: 36.7131,
                            referenceLon: 3.1793,
                          ),

                          // Drone info card (shown when a drone is selected)
                          if (selectedDrone != null)
                            Positioned(
                              top: 16,
                              right: 16,
                              child: DroneInfoCard(drone: selectedDrone!),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
