import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_twind/flutter_twind.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/scanner/screens/scanner_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/demo/screens/twind_demo_screen.dart';
import 'core/twind/twind_ui.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);
final ValueNotifier<int> cardDesignNotifier = ValueNotifier<int>(0);
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> setThemeMode(ThemeMode mode) async {
  if (themeNotifier.value != mode) {
    themeNotifier.value = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'app_theme_mode',
        mode == ThemeMode.light ? 'light' : 'dark',
      );
    } catch (_) {}
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize flutter_twind configuration
  WindConfig.initialize();
  SmartStyleParser.addColorSystem('voltech', {
    'red': AppTheme.voltechRed,
    'gold': AppTheme.voltechGold,
    'black': AppTheme.premiumBlack,
    'dark': AppTheme.premiumDarkGray,
  });

  // Lock orientation to portrait on iOS/phones for consistent Apple HIG compliant UX
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  try {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('app_theme_mode');
    if (savedTheme == 'light') {
      themeNotifier.value = ThemeMode.light;
    } else if (savedTheme == 'dark') {
      themeNotifier.value = ThemeMode.dark;
    }

    final savedLocale = prefs.getString('app_locale');
    if (savedLocale != null && ['uz', 'ru', 'en'].contains(savedLocale)) {
      localeNotifier.value = savedLocale;
    }

    final savedCardDesign = prefs.getInt('selected_card_design');
    if (savedCardDesign != null) {
      cardDesignNotifier.value = savedCardDesign;
    }
  } catch (_) {}

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
              navigatorKey: navigatorKey,
              routes: {
                '/login': (context) => const LoginScreen(),
                '/twind-demo': (context) => const TwindDemoScreen(),
              },
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

  final List<Widget> _pages = [const HomeScreen(), const ScannerScreen()];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: localeNotifier,
      builder: (context, locale, child) {
        return PopScope(
          canPop: _currentIndex == 0,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              setState(() => _currentIndex = 0);
            }
          },
          child: Scaffold(
            body: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              items: [
                BottomNavigationBarItem(
                  icon: const AppIcon(AppIcons.home, size: 24),
                  label: 'basic'.tr,
                ),
                BottomNavigationBarItem(
                  icon: const AppIcon(AppIcons.scan, size: 24),
                  label: 'scanner'.tr,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
