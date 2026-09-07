import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SwitchListTile(
              value: appState.isDarkMode,
              title: const Text("Dark Mode"),
              onChanged: (_) {
                appState.toggleTheme();
              },
            ),

            const Divider(),

            const ListTile(
              leading: Icon(Icons.notifications_none),
              title: Text("Notifications"),
            ),

            const ListTile(
              leading: Icon(Icons.security),
              title: Text("Privacy"),
            ),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () async {
                await AuthService.logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/login",
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
