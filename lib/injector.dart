import 'package:get_it/get_it.dart';

import 'core/websockets/websocket_client.dart';
import 'features/simulation/data/repository/simulation_repository.dart';
final GetIt getIt = GetIt.instance;

void setupInjection() {
  getIt.registerLazySingleton(() => WebSocketClient());
  getIt.registerLazySingleton(() => SimulationRepository(getIt<WebSocketClient>()));
}
