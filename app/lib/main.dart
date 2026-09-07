import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'services/auth_service.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => AppState(), child: const MyApp()),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int currentIndex = 0;
  bool loading = true;
  bool loggedIn = false;

  final screens = const [DashboardScreen(), AnalyticsScreen()];

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    loggedIn = await AuthService.isLoggedIn();
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return Consumer<AppState>(
      builder: (context, appState, _) {
        final isDark = appState.isDarkMode;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "SepsisGuard",
          themeMode: appState.themeMode,

          routes: {
            "/login": (_) => const LoginScreen(),
            "/home": (_) => const DashboardScreen(),
          },

          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF6F8FC),
            primaryColor: const Color(0xFF5B7FFF),
            useMaterial3: true,
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            cardColor: const Color(0xFF1E293B),
            primaryColor: const Color(0xFF7C9CFF),
            useMaterial3: true,
          ),

          home: loggedIn
              ? Scaffold(
                  body: screens[currentIndex],
                  bottomNavigationBar: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: BottomNavigationBar(
                      currentIndex: currentIndex,
                      onTap: (index) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      type: BottomNavigationBarType.fixed,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      selectedItemColor: Theme.of(context).primaryColor,
                      unselectedItemColor: Colors.grey,
                      items: const [
                        BottomNavigationBarItem(
                          icon: Icon(Icons.dashboard),
                          label: "Dashboard",
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.show_chart),
                          label: "Analytics",
                        ),
                      ],
                    ),
                  ),
                )
              : const LoginScreen(),
        );
      },
    );
  }
}
