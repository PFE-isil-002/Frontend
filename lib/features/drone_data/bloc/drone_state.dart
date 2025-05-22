import '../domain/entities/drone_info.dart';

abstract class DroneInfoState {}

class DroneInfoLoading extends DroneInfoState {}

class DroneInfoLoaded extends DroneInfoState {
  final List<DroneInfo> drones;

  DroneInfoLoaded(this.drones);
}

class DroneInfoError extends DroneInfoState {
  final String message;

  DroneInfoError(this.message);
}
