abstract class DroneInfoEvent {}

class LoadDronesInfo extends DroneInfoEvent {}

class RefreshDroneInfo extends DroneInfoEvent {
  final String droneId;

  RefreshDroneInfo(this.droneId);
}
