import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/api_service.dart';
import 'pending_approval_screen.dart';
import '../../../main.dart'; 

class VerifyOtpScreen extends StatefulWidget {
  final String phone;
  final String? password;
  final bool isRegistration; // if false, it's password reset
  final String? firstName;
  final String? lastName;
  final int? age;
  final String? region;
  final String? district;

  const VerifyOtpScreen({
    super.key,
    required this.phone,
    this.password,
    this.isRegistration = true,
    this.firstName,
    this.lastName,
    this.age,
    this.region,
    this.district,
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _codeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;
  final ApiService _apiService = ApiService();
  Timer? _timer;
  int _secondsRemaining = 60;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() => _secondsRemaining = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("6 xonali kodni kiriting"), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    setState(() => _isLoading = true);
    
    if (widget.isRegistration) {
      // 1. Verify SMS code
      final verifyResponse = await _apiService.verifySms(widget.phone, code);
      
      if (verifyResponse['success'] != true) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(verifyResponse['message'] ?? "Kod noto'g'ri"),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      // 2. Register
      if (widget.password != null && widget.password!.isNotEmpty) {
        final registerResponse = await _apiService.register(
          widget.phone,
          widget.password!,
          widget.firstName!,
          widget.lastName!,
          widget.age!,
          widget.region!,
          widget.district!
        );
        
        if (registerResponse['success'] != true) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(registerResponse['message'] ?? "Ro'yxatdan o'tishda xatolik"),
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }
        
        await _apiService.login(widget.phone, widget.password!);
      }
    } else {
      // Forgot Password Flow
      if (widget.password != null && widget.password!.isNotEmpty) {
        final resetResponse = await _apiService.forgotPasswordReset(widget.phone, code, widget.password!);
        
        if (resetResponse['success'] != true) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(resetResponse['message'] ?? "Kod noto'g'ri yoki xatolik yuz berdi"),
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }
        
        // Auto login after reset
        await _apiService.login(widget.phone, widget.password!);
      }
    }

    // Logic handled above

    if (!mounted) return;
    setState(() => _isLoading = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.isRegistration ? "Muvaffaqiyatli ro'yxatdan o'tdingiz!" : "Parol o'zgartirildi!"),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => widget.isRegistration 
          ? const PendingApprovalScreen() 
          : const MainNavigation()
      ),
      (route) => false,
    );
  }

  Widget _buildOtpBox(int index) {
    bool isFocused = _codeController.text.length == index || (_codeController.text.length == 6 && index == 5);
    bool hasValue = _codeController.text.length > index;
    String char = hasValue ? _codeController.text[index] : '';
    final theme = Theme.of(context);
    
    return Container(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused ? theme.colorScheme.primary : (hasValue ? theme.colorScheme.primary.withValues(alpha: 0.5) : theme.colorScheme.onSurface.withValues(alpha: 0.2)),
          width: isFocused ? 2 : 1,
        ),
        boxShadow: isFocused ? [
          BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.2), blurRadius: 8, spreadRadius: 1)
        ] : null,
      ),
      alignment: Alignment.center,
      child: Text(
        char,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kodni tasdiqlash"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'SMS orqali yuborilgan kodni kiriting',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Raqam: ${widget.phone}',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Custom 6-digit OTP Input
              GestureDetector(
                onTap: () {
                  _focusNode.requestFocus();
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Invisible text field that takes the input
                    Opacity(
                      opacity: 0.0,
                      child: TextField(
                        controller: _codeController,
                        focusNode: _focusNode,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        autofocus: true,
                        onChanged: (val) {
                          setState(() {});
                          if (val.length == 6) {
                            _verify();
                          }
                        },
                        decoration: const InputDecoration(counterText: ""),
                      ),
                    ),
                    // Visual boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: _buildOtpBox(index),
                      )),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _verify,
                child: _isLoading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
                    : const Text('Tasdiqlash'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _secondsRemaining == 0 
                  ? () async {
                      setState(() => _isLoading = true);
                      final response = widget.isRegistration 
                        ? await _apiService.sendSms(widget.phone)
                        : await _apiService.forgotPasswordSendSms(widget.phone);
                        
                      if (!mounted) return;
                      setState(() => _isLoading = false);
                      if (response['success'] == true) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kod qayta yuborildi"), backgroundColor: Colors.green));
                        _startTimer();
                      } else {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'] ?? "Xatolik"), backgroundColor: Colors.redAccent));
                      }
                    } 
                  : null,
                child: Text(_secondsRemaining > 0 ? "Kodni qayta yuborish ($_secondsRemaining s)" : "Kodni qayta yuborish"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
