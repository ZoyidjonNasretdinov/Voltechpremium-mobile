import 'package:flutter/material.dart';
import 'package:flutter_twind/flutter_twind.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/api_service.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/twind/twind_ui.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _phoneNumbers = [];

  @override
  void initState() {
    super.initState();
    _loadNumbers();
  }

  Future<void> _loadNumbers({bool forceRefresh = false}) async {
    setState(() => _isLoading = true);
    final response = await _apiService.getAdminPhoneNumbers(
      forceRefresh: forceRefresh,
    );
    if (response['success'] == true && mounted) {
      final List<dynamic> allNumbers = response['data'] ?? [];
      setState(() {
        _phoneNumbers = allNumbers.where((n) => n['active'] == true).toList();
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri url = Uri.parse('tel:$phone');
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('cant_call_phone'.tr),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.scaffoldBackgroundColor;
    final textColor = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: AppIcon(AppIcons.arrowLeft, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: WText(
          'contact_us'.tr,
          className: 'text-lg font-semibold',
          color: textColor,
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadNumbers(forceRefresh: true),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _phoneNumbers.isEmpty
            ? Center(
                child: ListView(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    WColumn(
                      className: 'items-center justify-center p-6',
                      children: [
                        AppIcon(
                          AppIcons.phoneCall,
                          size: 64,
                          color: textColor.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        WText(
                          'no_support_numbers'.tr,
                          className: 'text-sm text-gray-500',
                          color: textColor.withValues(alpha: 0.6),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    itemCount: _phoneNumbers.length,
                    itemBuilder: (context, index) {
                      final phoneObj = _phoneNumbers[index];
                      return TwCard(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        onTap: () => _launchPhone(phoneObj['phoneNumber'] ?? ''),
                        child: Row(
                          children: [
                            WContainer(
                              className: 'p-2.5 rounded-full bg-red-600/10',
                              child: AppIcon(
                                AppIcons.help,
                                color: theme.colorScheme.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  WText(
                                    phoneObj['name'] ?? 'Admin',
                                    className: 'text-sm font-bold',
                                    color: textColor,
                                  ),
                                  const SizedBox(height: 2),
                                  WText(
                                    phoneObj['phoneNumber'] ?? '',
                                    className: 'text-sm',
                                    color: textColor.withValues(alpha: 0.7),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const AppIcon(
                                AppIcons.phoneCall,
                                color: Colors.green,
                                size: 20,
                              ),
                              onPressed: () =>
                                  _launchPhone(phoneObj['phoneNumber'] ?? ''),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
      ),
    );
  }
}
