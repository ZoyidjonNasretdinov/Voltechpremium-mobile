import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/scanner/screens/scanner_screen.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() {
  runApp(const LoyaltyApp());
}

class LoyaltyApp extends StatelessWidget {
  const LoyaltyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, ThemeMode currentMode, child) {
        return ValueListenableBuilder<String>(
          valueListenable: localeNotifier,
          builder: (context, locale, child) {
            return MaterialApp(
              title: 'Völtech Premium',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: currentMode,
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const ScannerScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: localeNotifier,
      builder: (context, locale, child) {
        return Scaffold(
          body: _pages[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: [
              BottomNavigationBarItem(icon: const Icon(Icons.home), label: 'basic'.tr), // Using 'basic' or could add 'home'
              BottomNavigationBarItem(icon: const Icon(Icons.qr_code_scanner), label: 'Scanner'), // Add scanner translation later if needed
            ],
          ),
        );
      },
    );
  }
}
