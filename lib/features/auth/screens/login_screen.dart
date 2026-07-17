import 'package:flutter/material.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import 'pending_approval_screen.dart';
import '../../../main.dart';
import '../../../core/api_service.dart';
import '../../scanner/screens/scanner_screen.dart';

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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 60),
                      Image.asset(
                        'assets/images/logo.png',
                        height: 180,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Tizimga kirish',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 40),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Telefon raqam',
                          prefixIcon: const Icon(Icons.phone),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Parol',
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
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : () async {
                          final phone = _phoneController.text.replaceAll(' ', '');
                          final password = _passwordController.text.trim();
                          
                          if (phone.length < 9 || password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Telefon raqam va parolni kiriting"),
                                backgroundColor: Colors.redAccent,
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
                            if (!context.mounted) return;
                            
                            if (profileRes['success'] == true && profileRes['data'] != null && profileRes['data']['status'] == 'PENDING') {
                              if (!context.mounted) return;
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const PendingApprovalScreen()),
                              );
                            } else {
                              if (!context.mounted) return;
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const MainNavigation()),
                              );
                            }
                          } else {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(response['message'] ?? "Xatolik yuz berdi"),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                        child: _isLoading 
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
                          : const Text('Kirish'),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                          );
                        },
                        child: Text(
                          "Parolni unutdingizmi?",
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ScannerScreen()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2A1515) : theme.colorScheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.qr_code_scanner,
                              size: 40,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Center(
                        child: Text(
                          "QR orqali tekshirish",
                          style: TextStyle(
                            fontSize: 14, 
                            color: Colors.grey, 
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0, top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Akkauntingiz yo'qmi? ", 
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 15,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: Text(
                        "Ro'yxatdan o'tish",
                        style: TextStyle(
                          color: theme.colorScheme.primary, 
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

