import 'package:flutter/material.dart';
import 'package:flutter_twind/flutter_twind.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/api_service.dart';
import '../../auth/screens/login_screen.dart';
import '../../../main.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/twind/twind_ui.dart';

class PendingApprovalScreen extends StatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen> {
  bool _isLoading = false;
  final ApiService _apiService = ApiService();
  List<dynamic> _phoneNumbers = [];
  bool _isLoadingPhones = true;

  @override
  void initState() {
    super.initState();
    _loadNumbers();
  }

  Future<void> _loadNumbers() async {
    final response = await _apiService.getAdminPhoneNumbers();
    if (response['success'] == true && mounted) {
      final List<dynamic> allNumbers = response['data'] ?? [];
      setState(() {
        _phoneNumbers = allNumbers.where((n) => n['active'] == true).toList();
        _isLoadingPhones = false;
      });
    } else if (mounted) {
      setState(() => _isLoadingPhones = false);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri url = Uri.parse('tel:$phone');
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('cant_open_phone'.tr),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _checkStatus() async {
    setState(() => _isLoading = true);
    final response = await _apiService.getProfile();
    setState(() => _isLoading = false);

    if (response['success'] == true) {
      final status = response['data']?['status'];
      if (status == 'APPROVED' || status == 'ACTIVE') {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainNavigation()),
          (route) => false,
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('application_under_review'.tr),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      if (!mounted) return;
      if (response['message'] == 'Token topilmadi' ||
          response['message'] == 'Sessiya tugadi') {
        await _logout();
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'error'.tr),
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: WContainer(
                      className: 'p-5 rounded-full bg-red-600/10 mb-4',
                      child: AppIcon(
                        AppIcons.hourglass,
                        size: 60,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  WText(
                    'pending_approval_title'.tr,
                    className: 'text-2xl font-bold text-center',
                    color: theme.colorScheme.onSurface,
                  ),
                  const SizedBox(height: 12),
                  WText(
                    'pending_approval_desc'.tr,
                    className: 'text-sm text-center leading-relaxed',
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 28),

                  // Admin contact card
                  TwCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        WText(
                          'contact_admin_desc'.tr,
                          className: 'text-xs text-center mb-3',
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.8,
                          ),
                        ),
                        if (_isLoadingPhones)
                          const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else if (_phoneNumbers.isEmpty)
                          WText(
                            'no_admin_phones'.tr,
                            className: 'text-xs text-gray-500',
                          )
                        else
                          ..._phoneNumbers.map(
                            (phoneObj) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _launchPhone(phoneObj['phoneNumber'] ?? ''),
                                icon: const AppIcon(
                                  AppIcons.phoneCall,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  "${phoneObj['name'] ?? 'Admin'} - ${phoneObj['phoneNumber'] ?? ''}",
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  minimumSize: const Size(double.infinity, 44),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Check status button
                  TwButton(
                    text: 'check_status_btn'.tr,
                    onPressed: _isLoading ? null : _checkStatus,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 12),

                  // Logout action
                  TextButton(
                    onPressed: _logout,
                    child: WText(
                      'logout'.tr,
                      className: 'text-sm text-gray-400 font-semibold',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
