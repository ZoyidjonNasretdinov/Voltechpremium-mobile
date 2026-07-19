import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/api_service.dart';
import '../../auth/screens/login_screen.dart';
import '../../../main.dart';

class PendingApprovalScreen extends StatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen> {
  bool _isLoading = false;
  final ApiService _apiService = ApiService();
  final String _adminPhone = "+998901234567"; // O'zgartirishingiz mumkin

  Future<void> _launchPhone() async {
    final Uri url = Uri.parse('tel:$_adminPhone');
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Telefon raqamni ochib bo'lmadi"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _checkStatus() async {
    setState(() => _isLoading = true);
    final response = await _apiService.getProfile();
    setState(() => _isLoading = false);

    if (response['success'] == true) {
      final status = response['data']['status'];
      if (status == 'ACTIVE') {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainNavigation()),
          (route) => false,
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Arizangiz hali ko'rib chiqilmoqda"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? "Xatolik yuz berdi. Iltimos, qayta urinib ko'ring."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _logout() async {
    await _apiService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                Icons.hourglass_empty,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Arizangiz ko\'rib chiqilmoqda',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Ro\'yxatdan o\'tganingiz uchun rahmat! Ma\'muriyat profilingizni tasdiqlaganidan so\'ng tizimdan foydalanishingiz mumkin bo\'ladi.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      "Tasdiqlashni tezlashtirish uchun Admin bilan bog'lanishingiz mumkin:",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _launchPhone,
                      icon: const Icon(Icons.phone),
                      label: Text(_adminPhone),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _checkStatus,
                child: _isLoading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
                    : const Text('Holatni tekshirish'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _logout,
                child: const Text('Hisobdan chiqish'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
