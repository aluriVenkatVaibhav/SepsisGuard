import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../settings_screen.dart';

class DashboardHeader extends StatelessWidget {
  final Animation<double> pulseAnimation;

  const DashboardHeader({super.key, required this.pulseAnimation});

  void _openProfileMenu(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Switch Patient",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 12),

              ...appState.patients.map((patient) {
                final isSelected = patient.id == appState.selectedPatient.id;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade300,
                    child: Text(
                      patient.name[0],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  title: Text(patient.name),
                  subtitle: Text(patient.id),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    appState.switchPatient(patient);
                    Navigator.pop(context);
                  },
                );
              }),

              const Divider(),

              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text("Settings"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appState.selectedPatient.id,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              appState.selectedPatient.name,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),

        Row(
          children: [
            IconButton(
              icon: Icon(
                appState.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              ),
              onPressed: () => appState.toggleTheme(),
            ),

            const SizedBox(width: 8),

            const Text(
              "LIVE",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(width: 6),

            ScaleTransition(
              scale: pulseAnimation,
              child: const CircleAvatar(
                radius: 6,
                backgroundColor: Colors.green,
              ),
            ),

            const SizedBox(width: 12),

            GestureDetector(
              onTap: () => _openProfileMenu(context),
              child: const CircleAvatar(radius: 18, child: Icon(Icons.person)),
            ),
          ],
        ),
      ],
    );
  }
}
