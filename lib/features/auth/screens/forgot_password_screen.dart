import 'package:flutter/material.dart';
import 'package:flutter_twind/flutter_twind.dart';
import '../../../core/api_service.dart';
import 'verify_otp_screen.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/twind/twind_ui.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneController = TextEditingController(text: '+998');
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final ApiService _apiService = ApiService();

  Future<void> _submit() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();

    final phone = _phoneController.text.replaceAll(' ', '');
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    final phoneDigits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (phoneDigits.length < 9 ||
        (phone.startsWith('+998') && phoneDigits.length < 12)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('enter_valid_phone'.tr),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('fill_all_fields'.tr),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('passwords_do_not_match'.tr),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('password_min_6'.tr),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 1. Send forgot password SMS
    final response = await _apiService.forgotPasswordSendSms(phone);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response['success'] == true) {
      // 2. Navigate to OTP screen for reset
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyOtpScreen(
            phone: phone,
            password: password,
            isRegistration: false, // Indicates forgot password flow
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'error'.tr),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: WText(
          'forgot_password_title'.tr,
          className: 'text-lg font-semibold',
        ),
      ),
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
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 20.0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 12),
                            Center(
                              child: WContainer(
                                className:
                                    'p-4 rounded-full bg-red-600/10 mb-2',
                                child: AppIcon(
                                  AppIcons.lock,
                                  size: 56,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            WText(
                              'enter_new_password'.tr,
                              className: 'text-xl font-bold text-center',
                              color: theme.colorScheme.onSurface,
                            ),
                            const SizedBox(height: 8),
                            WText(
                              'forgot_password_desc'.tr,
                              className:
                                  'text-sm text-center text-gray-400 leading-relaxed',
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                            const SizedBox(height: 28),

                            TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'phone'.tr,
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: AppIcon(AppIcons.phone, size: 20),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'new_password'.tr,
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
                                    color: theme
                                        .inputDecorationTheme
                                        .prefixIconColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            TextField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              decoration: InputDecoration(
                                labelText: 'confirm_new_password'.tr,
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: AppIcon(AppIcons.lock, size: 20),
                                ),
                                suffixIcon: IconButton(
                                  icon: AppIcon(
                                    _obscureConfirmPassword
                                        ? AppIcons.eyeOff
                                        : AppIcons.eye,
                                    size: 20,
                                    color: theme
                                        .inputDecorationTheme
                                        .prefixIconColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 28),
                            TwButton(
                              text: 'send_code'.tr,
                              onPressed: _isLoading ? null : _submit,
                              isLoading: _isLoading,
                            ),
                            const SizedBox(height: 16),
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
}
