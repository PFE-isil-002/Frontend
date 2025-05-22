import 'package:flutter/material.dart';
import 'package:pfe_dashboard/main_layout.dart';
import 'injector.dart';

void main() {
  setupInjection();
  runApp(UAVDashboardApp());
}

class UAVDashboardApp extends StatelessWidget {
  const UAVDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UAV Dashboard',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainLayout(),
    );
  }
}
