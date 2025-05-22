import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/simulation_repository.dart';
import '../../domain/entities/drone_data.dart';

class SimulationBloc extends Cubit<List<DroneData>> {
  final SimulationRepository repository;
  StreamSubscription<Map<String, dynamic>>? _subscription;

  SimulationBloc(this.repository) : super([]);

  void startSimulation(
    String modelType,
    String simulationType,
    double duration,
    double step,
  ) {
    // 1) clear any previous data
    emit([]);

    // 2) cancel old subscription (just in case)
    _subscription?.cancel();

    // 3) new subscription on the broadcast stream
    _subscription = repository
        .startSimulation(modelType, simulationType, duration, step)
        .listen(
      (rawMap) {
        try {
          final droneData = DroneData.fromMap(rawMap);
          final updated = List<DroneData>.from(state)..add(droneData);
          emit(updated);
        } catch (e) {
          print('Error parsing DroneData: \$e\n\$st');
        }
      },
      onError: (error) => print('Simulation stream error: \$error'),
    );
  }

  void stopSimulation() {
    // 1) tell server
    repository.stopSimulation();
    // 2) cancel receipt
    _subscription?.cancel();
    _subscription = null;
    // 3) clear data
    emit([]);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
