import 'package:flutter/material.dart';
import '../../../core/api_service.dart';
import '../../../core/localization/app_localizations.dart';
import 'verify_otp_screen.dart';
import 'forgot_password_screen.dart';
import '../../profile/screens/policy_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController(text: '+998 ');
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _acceptedPrivacyPolicy = false;
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
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
        title: Text('registration'.tr),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'new_master_profile'.tr,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'enter_correct_data'.tr,
              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 32),
            
            // Ism
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: 'first_name'.tr, prefixIcon: const Icon(Icons.person)),
            ),
            const SizedBox(height: 16),
            
            // Familiya
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'last_name'.tr, prefixIcon: const Icon(Icons.person_outline)),
            ),
            const SizedBox(height: 16),
            
            // Telefon
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: 'phone'.tr, prefixIcon: const Icon(Icons.phone)),
            ),
            const SizedBox(height: 16),
            
            // Parol
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'create_password'.tr,
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: theme.inputDecorationTheme.prefixIconColor,
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

            // Parolni tasdiqlash
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'confirm_password'.tr,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    color: theme.inputDecorationTheme.prefixIconColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Maxfiylik Siyosati
            Row(
              children: [
                Checkbox(
                  value: _acceptedPrivacyPolicy,
                  onChanged: (val) {
                    setState(() {
                      _acceptedPrivacyPolicy = val ?? false;
                    });
                  },
                  activeColor: theme.colorScheme.primary,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PolicyScreen()));
                    },
                    child: Text.rich(
                      TextSpan(
                        text: "${'i_agree'.tr} ",
                        children: [
                          TextSpan(
                            text: 'privacy_policy'.tr,
                            style: TextStyle(color: theme.colorScheme.primary, decoration: TextDecoration.underline, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Saqlash / Tasdiqlash
            ElevatedButton(
              onPressed: _isLoading ? null : () async {
                if (_isLoading) return;
                FocusScope.of(context).unfocus();

                final phone = _phoneController.text.replaceAll(' ', '');
                final firstName = _firstNameController.text.trim();
                final lastName = _lastNameController.text.trim();
                final password = _passwordController.text.trim();
                final confirmPassword = _confirmPasswordController.text.trim();
                
                if (phone.isEmpty || firstName.isEmpty || lastName.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('fill_all_fields'.tr),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }

                final phoneDigits = phone.replaceAll(RegExp(r'[^0-9]'), '');
                if (phoneDigits.length < 9 || (phone.startsWith('+998') && phoneDigits.length < 12)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('enter_valid_phone'.tr),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }

                if (firstName.length < 2 || lastName.length < 2) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('enter_valid_name'.tr),
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

                if (password != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('passwords_mismatch'.tr),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }

                if (!_acceptedPrivacyPolicy) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('agree_policy'.tr),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }

                setState(() => _isLoading = true);
                
                final response = await _apiService.sendSms(phone);
                
                if (!mounted) return;
                setState(() => _isLoading = false);
                
                if (response['success'] != true) {
                  if (!context.mounted) return;
                  final msg = response['message']?.toString() ?? 'error'.tr;
                  final isDuplicate = msg.toLowerCase().contains('allaqachon') || 
                                      msg.toLowerCase().contains('уже') || 
                                      msg.toLowerCase().contains('already') ||
                                      msg.toLowerCase().contains('exists');
                  
                  if (isDuplicate) {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.orange),
                            const SizedBox(width: 8),
                            Expanded(child: Text('account_exists_title'.tr, style: const TextStyle(fontSize: 18))),
                          ],
                        ),
                        content: Text('account_exists_desc'.tr),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              Navigator.push(context, MaterialPageRoute(builder: (c) => const ForgotPasswordScreen()));
                            },
                            child: Text('forgot_password'.tr),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              Navigator.pop(context);
                            },
                            child: Text('login_btn'.tr),
                          ),
                        ],
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(msg),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                  return;
                }

                if (!context.mounted) return;
                // Navigate to VerifyOtpScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VerifyOtpScreen(
                      phone: phone,
                      password: password,
                      isRegistration: true,
                      firstName: firstName,
                      lastName: lastName,
                    ),
                  ),
                );
              },
              child: _isLoading
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
                : Text('registration'.tr),
            ),
          ],
        ),
      ),
    ),
    ),
    );
  }
}

