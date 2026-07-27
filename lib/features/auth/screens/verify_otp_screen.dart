import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../../../core/api_service.dart';
import 'pending_approval_screen.dart';
import '../../../main.dart'; 
import '../../../core/localization/app_localizations.dart';

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
    FocusScope.of(context).unfocus();
    final code = _codeController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('enter_6_digit'.tr), backgroundColor: Colors.redAccent),
      );
      return;
    }

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
        content: Text(widget.isRegistration ? 'registration'.tr : 'reset_password'.tr),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('verify_code'.tr),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'enter_6_digit'.tr,
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
              
              // Pinput 6-digit OTP Input
              Pinput(
                length: 6,
                controller: _codeController,
                focusNode: _focusNode,
                autofocus: true,
                onCompleted: (pin) => _verify(),
                defaultPinTheme: PinTheme(
                  width: 45,
                  height: 55,
                  textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                  ),
                ),
                focusedPinTheme: PinTheme(
                  width: 45,
                  height: 55,
                  textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.primary, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                ),
                submittedPinTheme: PinTheme(
                  width: 45,
                  height: 55,
                  textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _verify,
                child: _isLoading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
                    : Text('confirm'.tr),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _secondsRemaining == 0 
                  ? () async {
                      FocusScope.of(context).unfocus();
                      setState(() => _isLoading = true);
                      final response = widget.isRegistration 
                        ? await _apiService.sendSms(widget.phone)
                        : await _apiService.forgotPasswordSendSms(widget.phone);
                        
                      if (!mounted) return;
                      setState(() => _isLoading = false);
                      if (response['success'] == true) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('code_resent'.tr), backgroundColor: Colors.green));
                        _startTimer();
                      } else {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'] ?? "Xatolik"), backgroundColor: Colors.redAccent));
                      }
                    } 
                  : null,
                child: Text(_secondsRemaining > 0 ? "${'send_code'.tr} ($_secondsRemaining s)" : 'send_code'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
