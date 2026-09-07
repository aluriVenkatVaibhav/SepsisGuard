import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sepsis_guard/services/app_state.dart';

import 'dashboard_header.dart';
import 'risk_card.dart';
import 'summary_row.dart';
import 'vitals_section.dart';
import '../../services/bluetooth_service.dart';
import '../../services/websocket_service.dart';
import '../../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController pulseController;
  late AnimationController glowController;

  late Animation<double> pulseAnimation;
  late Animation<double> glowAnimation;

  late Timer timer;
  int seconds = 0;
  bool trainingActionLoading = false;

  final BluetoothService bluetooth = BluetoothService();
  final WebSocketService websocket = WebSocketService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    pulseAnimation = Tween(begin: 0.9, end: 1.1).animate(pulseController);

    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    glowAnimation = Tween(begin: 0.2, end: 0.5).animate(glowController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);

      bluetooth.startScan(appState);
      websocket.connect(appState);

      appState.fetchLatestVitals();
    });

    /// UI timer
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        seconds++;
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    pulseController.dispose();
    glowController.dispose();
    timer.cancel();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final appState = Provider.of<AppState>(context, listen: false);
      bluetooth.startScan(appState);
      websocket.connect(appState);
      appState.fetchLatestVitals();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? const [Color(0xFF0F172A), Color(0xFF111827)]
                  : const [Color(0xFFF6F8FC), Color(0xFFEFF2F9)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔥 ADD THIS BLOCK HERE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: trainingActionLoading
                          ? null
                          : () async {
                              setState(() {
                                trainingActionLoading = true;
                              });
                        final appState = Provider.of<AppState>(
                          context,
                          listen: false,
                        );
                              final result = await ApiService.startTraining(
                                appState.selectedPatient.backendId,
                              );
                              appState.setTrainingState(
                                result?["status"] == "TRAINING_STARTED",
                              );
                              if (mounted) {
                                final ok = result?["status"] == "TRAINING_STARTED";
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      ok
                                          ? "Training started"
                                          : "Failed to start training",
                                    ),
                                  ),
                                );
                              }
                              if (!mounted) return;
                              setState(() {
                                trainingActionLoading = false;
                              });
                            },
                      child: Text("Start Training"),
                    ),

                    ElevatedButton(
                      onPressed: trainingActionLoading
                          ? null
                          : () async {
                              setState(() {
                                trainingActionLoading = true;
                              });
                        final appState = Provider.of<AppState>(
                          context,
                          listen: false,
                        );
                              final result = await ApiService.stopTraining(
                                appState.selectedPatient.backendId,
                              );
                              if (result?["status"] == "TRAINING_COMPLETED") {
                                appState.setTrainingState(false);
                                appState.fetchLatestVitals();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Training completed"),
                                    ),
                                  );
                                }
                              } else if (mounted) {
                                final err =
                                    result?["error"]?.toString() ??
                                    "Training stop failed";
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text(err)));
                              }
                              if (!mounted) return;
                              setState(() {
                                trainingActionLoading = false;
                              });
                            },
                      child: Text("Stop Training"),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                DashboardHeader(pulseAnimation: pulseAnimation),

                const SizedBox(height: 28),

                appState.isTraining
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          "Training in progress... windows: ${appState.trainingWindows}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : RiskCard(glowAnimation: glowAnimation, seconds: seconds),

                const SizedBox(height: 24),

                const SummaryRow(),

                const SizedBox(height: 32),

                const VitalsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
