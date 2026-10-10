import 'package:flutter/material.dart';
import 'package:flutter_twind/flutter_twind.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../main.dart';
import '../../auth/screens/login_screen.dart';
import 'edit_profile_screen.dart';
import 'transactions_screen.dart';
import 'faq_screen.dart';
import 'support_screen.dart';
import 'policy_screen.dart';
import 'terms_screen.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/api_service.dart';
import '../../../core/twind/twind_ui.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadNotificationPref();
  }

  Future<void> _loadNotificationPref() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      });
    }
  }

  Future<void> _saveNotificationPref(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() => _notificationsEnabled = value);
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final response = await _apiService.getProfile();
    if (response['success'] == true && mounted) {
      setState(() {
        _profileData = response['data'];
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showDeleteAccountDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (dialogContext) => TwDialogWrapper(
        title: 'delete_account'.tr,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const AppIcon(
                  AppIcons.alert,
                  color: Colors.redAccent,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: WText(
                    'delete_account_confirm'.tr,
                    className: 'text-sm leading-relaxed text-gray-400',
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: WText(
              'cancel'.tr,
              className: 'text-sm text-gray-400 font-semibold',
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              setState(() => _isLoading = true);
              final response = await _apiService.deleteAccount();
              if (!mounted) return;
              setState(() => _isLoading = false);
              if (response['success'] == true) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('account_deleted_success'.tr),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                await _apiService.logout();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              } else {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(response['message'] ?? 'error'.tr),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: WText(
              'delete_account'.tr,
              className: 'text-sm font-bold text-white',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: localeNotifier,
      builder: (context, locale, child) {
        final theme = Theme.of(context);
        final bgColor = theme.scaffoldBackgroundColor;
        final textColor = theme.colorScheme.onSurface;
        final subTextColor = textColor.withValues(alpha: 0.6);
        final accentColor = theme.colorScheme.primary;

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
              'settings'.tr,
              className: 'text-lg font-semibold',
              color: textColor,
            ),
            centerTitle: true,
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadProfile,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 580),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 16),

                              // User Info Card
                              TwCard(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditProfileScreen(
                                        profileData: _profileData,
                                      ),
                                    ),
                                  );
                                  _loadProfile();
                                },
                                child: Row(
                                  children: [
                                    UserAvatar(
                                      imageUrl: _profileData?['imageUrl'],
                                      size: 54,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          WText(
                                            '${_profileData?['firstName'] ?? ''} ${_profileData?['lastName'] ?? ''}',
                                            className: 'text-base font-bold',
                                            color: textColor,
                                          ),
                                          const SizedBox(height: 3),
                                          WText(
                                            _profileData?['phoneNumber'] ?? '',
                                            className: 'text-xs',
                                            color: subTextColor,
                                          ),
                                          const SizedBox(height: 3),
                                          WText(
                                            '${_profileData?['totalBonusPoints'] ?? 0} ${'points_unit'.tr}',
                                            className: 'text-sm font-bold',
                                            color: accentColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                    AppIcon(
                                      AppIcons.chevronRight,
                                      color: subTextColor,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),

                              // General Settings Group
                              TwCard(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Column(
                                  children: [
                                    _buildSettingsTile(
                                      icon: AppIcons.clock,
                                      title: 'pause_notif'.tr,
                                      textColor: textColor,
                                      subTextColor: subTextColor,
                                      trailing: Switch(
                                        value: _notificationsEnabled,
                                        onChanged: _saveNotificationPref,
                                        activeThumbColor:
                                            theme.colorScheme.onPrimary,
                                        activeTrackColor: accentColor,
                                        inactiveTrackColor: Colors.grey
                                            .withValues(alpha: 0.3),
                                        inactiveThumbColor: Colors.grey,
                                      ),
                                    ),
                                    _buildDivider(subTextColor),
                                    _buildSettingsTile(
                                      icon: AppIcons.settings,
                                      title: 'general_settings'.tr,
                                      textColor: textColor,
                                      subTextColor: subTextColor,
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditProfileScreen(
                                                  profileData: _profileData,
                                                ),
                                          ),
                                        );
                                        _loadProfile();
                                      },
                                    ),
                                    _buildDivider(subTextColor),
                                    _buildSettingsTile(
                                      icon: AppIcons.history,
                                      title: 'points_history'.tr,
                                      textColor: textColor,
                                      subTextColor: subTextColor,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const TransactionsScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Theme & Language Group
                              TwCard(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Column(
                                  children: [
                                    ValueListenableBuilder<ThemeMode>(
                                      valueListenable: themeNotifier,
                                      builder: (context, mode, child) {
                                        final isDark =
                                            mode == ThemeMode.dark ||
                                            (mode == ThemeMode.system &&
                                                MediaQuery.of(
                                                      context,
                                                    ).platformBrightness ==
                                                    Brightness.dark);
                                        return _buildSettingsTile(
                                          icon: AppIcons.star,
                                          title: 'dark_mode'.tr,
                                          textColor: textColor,
                                          subTextColor: subTextColor,
                                          trailing: Switch(
                                            value: isDark,
                                            onChanged: (v) {
                                              setThemeMode(
                                                v
                                                    ? ThemeMode.dark
                                                    : ThemeMode.light,
                                              );
                                            },
                                            activeThumbColor:
                                                theme.colorScheme.onPrimary,
                                            activeTrackColor: accentColor,
                                            inactiveTrackColor: Colors.grey
                                                .withValues(alpha: 0.3),
                                            inactiveThumbColor: Colors.grey,
                                          ),
                                        );
                                      },
                                    ),
                                    _buildDivider(subTextColor),
                                    _buildSettingsTile(
                                      icon: AppIcons.language,
                                      title: 'language'.tr,
                                      textColor: textColor,
                                      subTextColor: subTextColor,
                                      trailing: DropdownButton<String>(
                                        value: localeNotifier.value,
                                        underline: const SizedBox(),
                                        icon: AppIcon(
                                          AppIcons.chevronDown,
                                          color: subTextColor,
                                          size: 18,
                                        ),
                                        dropdownColor:
                                            theme.colorScheme.surface,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 14,
                                        ),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            setAppLocale(newValue);
                                          }
                                        },
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'uz',
                                            child: Text('O\'zbekcha'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'ru',
                                            child: Text('Русский'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'en',
                                            child: Text('English'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Information & Legal Group
                              TwCard(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Column(
                                  children: [
                                    _buildSettingsTile(
                                      icon: AppIcons.help,
                                      title: 'faq'.tr,
                                      textColor: textColor,
                                      subTextColor: subTextColor,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const FaqScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                    _buildDivider(subTextColor),
                                    _buildSettingsTile(
                                      icon: AppIcons.phoneCall,
                                      title: 'contact_us'.tr,
                                      textColor: textColor,
                                      subTextColor: subTextColor,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const SupportScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                    _buildDivider(subTextColor),
                                    _buildSettingsTile(
                                      icon: AppIcons.terms,
                                      title: 'terms_title'.tr,
                                      textColor: textColor,
                                      subTextColor: subTextColor,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const TermsScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                    _buildDivider(subTextColor),
                                    _buildSettingsTile(
                                      icon: AppIcons.shield,
                                      title: 'policy_title'.tr,
                                      textColor: textColor,
                                      subTextColor: subTextColor,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const PolicyScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                    _buildDivider(subTextColor),
                                    _buildSettingsTile(
                                      icon: AppIcons.trash,
                                      title: 'delete_account'.tr,
                                      textColor: Colors.redAccent,
                                      subTextColor: subTextColor,
                                      onTap: () => _showDeleteAccountDialog(
                                        context,
                                        theme,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Logout Button
                              TwButton(
                                text: 'logout'.tr,
                                isOutlined: true,
                                textColor: Colors.redAccent,
                                icon: const AppIcon(
                                  AppIcons.logout,
                                  color: Colors.redAccent,
                                  size: 18,
                                ),
                                width: double.infinity,
                                onPressed: () async {
                                  await _apiService.logout();
                                  if (!context.mounted) return;
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                    (route) => false,
                                  );
                                },
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildSettingsTile({
    required dynamic icon,
    required String title,
    required Color textColor,
    required Color subTextColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: icon is String
          ? AppIcon(icon, color: textColor.withValues(alpha: 0.8), size: 22)
          : Icon(
              icon as IconData,
              color: textColor.withValues(alpha: 0.8),
              size: 22,
            ),
      title: WText(title, className: 'text-sm font-medium', color: textColor),
      trailing:
          trailing ??
          AppIcon(AppIcons.chevronRight, color: subTextColor, size: 20),
      onTap: onTap ?? (trailing == null ? () {} : null),
    );
  }

  Widget _buildDivider(Color color) {
    return Divider(color: color.withValues(alpha: 0.1), height: 1, indent: 52);
  }
}
