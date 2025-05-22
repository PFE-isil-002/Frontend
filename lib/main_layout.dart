import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfe_dashboard/core/websockets/websocket_client.dart';
import 'package:pfe_dashboard/features/simulation/data/repository/simulation_repository.dart';
import 'features/drone_data/bloc/drone_bloc.dart';
import 'features/simulation/presentation/screens/simulation_screen.dart';
import 'features/drone_data/presentation/drone_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/simulation/presentation/widgets/sidebar_navigation.dart';
import 'features/simulation/presentation/blocs/simulation_bloc.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  String _selectedPage = 'Home';

  Widget _getPage() {
    switch (_selectedPage) {
      case 'Home':
        return const HomeScreen();
      case 'Drone':
        return BlocProvider(
          create: (_) => DroneInfoBloc(),
          child: const DroneScreen(),
        );
      case 'Simulation':
        // Wrap SimulationScreen with BlocProvider
        return BlocProvider(
          create: (_) =>
              SimulationBloc(SimulationRepository(WebSocketClient())),
          child: const SimulationScreen(),
        );
      default:
        return BlocProvider(
          create: (_) =>
              SimulationBloc(SimulationRepository(WebSocketClient())),
          child: const SimulationScreen(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SidebarNavigation(
            username: 'Admin',
            onItemSelected: (page) {
              setState(() {
                _selectedPage = page;
              });
            },
            selectedPage: _selectedPage,
          ),
          Expanded(
            child: _getPage(),
          ),
        ],
      ),
    );
  }
}
