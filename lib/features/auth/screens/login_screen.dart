import 'package:flutter/material.dart';
import 'package:flutter_twind/flutter_twind.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import 'pending_approval_screen.dart';
import '../../../main.dart';
import '../../../core/api_service.dart';
import '../../scanner/screens/scanner_screen.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/twind/twind_ui.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController(text: '+998');
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF9F9F9);
    final cardBg = isDark ? const Color(0xFF141416) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF26262B)
        : const Color(0xFFE2E8F0);
    const primaryRed = Color(0xFFE33124);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 20.0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Spacer(flex: 2),

                            // Logo with subtle Twind Container
                            Center(
                              child: WContainer(
                                className: 'p-2',
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  height: 76,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Title
                            WText(
                              'login_title'.tr,
                              className:
                                  'text-2xl font-bold text-center tracking-tight',
                              color: theme.colorScheme.onSurface,
                            ),
                            const SizedBox(height: 32),

                            // Phone Field
                            TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                labelText: 'phone'.tr,
                                hintText: '+998 90 123 45 67',
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: AppIcon(AppIcons.phone, size: 20),
                                ),
                                filled: true,
                                fillColor: cardBg,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: borderColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: borderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: primaryRed,
                                    width: 1.8,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Password Field
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                labelText: 'password_label'.tr,
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: AppIcon(AppIcons.lock, size: 20),
                                ),
                                suffixIcon: IconButton(
                                  icon: AppIcon(
                                    _obscurePassword
                                        ? AppIcons.eyeOff
                                        : AppIcons.eye,
                                    size: 20,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: cardBg,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: borderColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: borderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: primaryRed,
                                    width: 1.8,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Login Button
                            TwButton(
                              text: 'login_btn'.tr,
                              onPressed: _isLoading ? null : _handleLogin,
                              isLoading: _isLoading,
                              backgroundColor: primaryRed,
                            ),
                            const SizedBox(height: 16),

                            // Forgot Password Button
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgotPasswordScreen(),
                                    ),
                                  );
                                },
                                child: WText(
                                  'forgot_password'.tr,
                                  className:
                                      'text-sm font-semibold text-red-600',
                                  color: primaryRed,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // QR Check Button
                            Center(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(100),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ScannerScreen(),
                                    ),
                                  );
                                },
                                child: WContainer(
                                  className: isDark
                                      ? 'p-4 rounded-full bg-red-950/40'
                                      : 'p-4 rounded-full bg-red-600/10',
                                  child: const AppIcon(
                                    AppIcons.qrCode,
                                    size: 76,
                                    color: primaryRed,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: WText(
                                'check_via_qr'.tr,
                                className: 'text-xs font-medium text-gray-400',
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),

                            const Spacer(flex: 3),

                            // Register Footer Link
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 20.0,
                                bottom: 8.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  WText(
                                    'no_account'.tr,
                                    className: 'text-sm text-gray-400 mr-1',
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const RegisterScreen(),
                                        ),
                                      );
                                    },
                                    child: WText(
                                      'register_btn'.tr,
                                      className:
                                          'text-sm font-bold text-red-600',
                                      color: primaryRed,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();

    final phone = _phoneController.text.replaceAll(' ', '');
    final password = _passwordController.text.trim();

    if (phone.length < 9 || password.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('enter_phone_password'.tr),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final response = await _apiService.login(phone, password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response['success'] == true) {
      final profileRes = await _apiService.getProfile();
      if (!mounted) return;

      if (profileRes['success'] == true &&
          profileRes['data'] != null &&
          profileRes['data']['status'] == 'PENDING') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const PendingApprovalScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      }
    } else {
      if (!mounted) return;
      final rawMsg = response['message']?.toString() ?? '';
      final displayMsg = rawMsg.toLowerCase().contains('bad credentials')
          ? 'invalid_credentials'.tr
          : (rawMsg.isNotEmpty ? rawMsg : 'invalid_credentials'.tr);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(displayMsg),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}
