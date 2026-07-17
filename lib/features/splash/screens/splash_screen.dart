import 'package:flutter/material.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/screens/pending_approval_screen.dart';
import '../../../core/api_service.dart';
import '../../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();

    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    final startTime = DateTime.now();
    final apiService = ApiService();
    final token = await apiService.getToken();
    
    final elapsed = DateTime.now().difference(startTime);
    final remaining = const Duration(seconds: 3) - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }
    
    if (!mounted) return;
    
    if (token != null && token.isNotEmpty) {
      final profileRes = await apiService.getProfile();
      if (!mounted) return;
      
      if (profileRes['success'] == true && profileRes['data'] != null && profileRes['data']['status'] == 'PENDING') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const PendingApprovalScreen(),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainNavigation(),
          ),
        );
      }
    } else {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 250,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
