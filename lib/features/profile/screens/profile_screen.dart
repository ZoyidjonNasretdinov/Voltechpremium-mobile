import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../main.dart';
import '../../auth/screens/login_screen.dart';
import 'edit_profile_screen.dart';
import 'transactions_screen.dart';
import 'faq_screen.dart';
import 'support_screen.dart';
import 'policy_screen.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/api_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: localeNotifier,
      builder: (context, locale, child) {
        final theme = Theme.of(context);
        final bgColor = theme.scaffoldBackgroundColor;
        final cardColor = theme.colorScheme.surface;
        final accentColor = theme.colorScheme.primary;
        final textColor = theme.colorScheme.onSurface;
        final subTextColor = textColor.withValues(alpha: 0.6);

        return Scaffold(
          backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('settings'.tr, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : RefreshIndicator(
            onRefresh: _loadProfile,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen(profileData: _profileData)));
                        _loadProfile();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                                image: _profileData != null && _profileData!['imageUrl'] != null && _profileData!['imageUrl'].toString().isNotEmpty
                                    ? DecorationImage(
                                        image: CachedNetworkImageProvider("https://voltechpremiumbackend-api-production.up.railway.app/api/files/download/${_profileData!['imageUrl']}"),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: _profileData == null || _profileData!['imageUrl'] == null || _profileData!['imageUrl'].toString().isEmpty
                                  ? Icon(Icons.person, color: textColor, size: 30)
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${_profileData?['firstName'] ?? ''} ${_profileData?['lastName'] ?? ''}', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(_profileData?['phoneNumber'] ?? '', style: TextStyle(color: subTextColor, fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text('${_profileData?['totalBonusPoints'] ?? 0} ball', style: TextStyle(color: accentColor, fontSize: 14, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: subTextColor),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: CupertinoIcons.bell,
                      title: 'pause_notif'.tr,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      trailing: Switch(
                        value: _notificationsEnabled,
                        onChanged: _saveNotificationPref,
                        activeThumbColor: theme.colorScheme.onPrimary,
                        activeTrackColor: accentColor,
                        inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
                        inactiveThumbColor: Colors.grey,
                      ),
                    ),
                    _buildDivider(subTextColor),
                    _buildSettingsTile(
                      icon: CupertinoIcons.slider_horizontal_3,
                      title: 'general_settings'.tr,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(profileData: _profileData),
                          ),
                        );
                        _loadProfile();
                      },
                    ),
                    _buildDivider(subTextColor),
                    _buildSettingsTile(
                      icon: CupertinoIcons.list_bullet,
                      title: 'Ballar tarixi',
                      textColor: textColor,
                      subTextColor: subTextColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TransactionsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    ValueListenableBuilder<ThemeMode>(
                      valueListenable: themeNotifier,
                      builder: (context, mode, child) {
                        final isDark = mode == ThemeMode.dark || (mode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);
                        return _buildSettingsTile(
                          icon: CupertinoIcons.moon,
                          title: 'dark_mode'.tr,
                          textColor: textColor,
                          subTextColor: subTextColor,
                          trailing: Switch(
                            value: isDark,
                            onChanged: (v) {
                              themeNotifier.value = v ? ThemeMode.dark : ThemeMode.light;
                            },
                            activeThumbColor: theme.colorScheme.onPrimary,
                            activeTrackColor: accentColor,
                            inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
                            inactiveThumbColor: Colors.grey,
                          ),
                        );
                      }
                    ),
                    _buildDivider(subTextColor),
                    _buildSettingsTile(
                      icon: CupertinoIcons.globe,
                      title: 'language'.tr,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      trailing: DropdownButton<String>(
                        value: localeNotifier.value,
                        underline: const SizedBox(),
                        icon: Icon(Icons.arrow_drop_down, color: subTextColor),
                        dropdownColor: cardColor,
                        style: TextStyle(color: textColor, fontSize: 14),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              localeNotifier.value = newValue;
                            });
                          }
                        },
                        items: const [
                          DropdownMenuItem(value: 'uz', child: Text('O\'zbekcha')),
                          DropdownMenuItem(value: 'ru', child: Text('Русский')),
                          DropdownMenuItem(value: 'en', child: Text('English')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: CupertinoIcons.question_circle,
                      title: 'faq'.tr,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const FaqScreen()));
                      },
                    ),
                    _buildDivider(subTextColor),
                    _buildSettingsTile(
                      icon: CupertinoIcons.phone_circle,
                      title: "Biz bilan bog'lanish",
                      textColor: textColor,
                      subTextColor: subTextColor,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SupportScreen()));
                      },
                    ),
                    _buildDivider(subTextColor),
                    _buildSettingsTile(
                      icon: CupertinoIcons.info_circle,
                      title: 'terms'.tr,
                      textColor: textColor,
                      subTextColor: subTextColor,
                    ),
                    _buildDivider(subTextColor),
                    _buildSettingsTile(
                      icon: CupertinoIcons.person_crop_circle,
                      title: 'policy_title'.tr,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const PolicyScreen()));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  await _apiService.logout();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.brightness == Brightness.dark ? Colors.white : Colors.redAccent.withValues(alpha: 0.1),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 8),
                    Text('logout'.tr, style: const TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    ));
    },
    );
  }

  Widget _buildSettingsTile({required IconData icon, required String title, required Color textColor, required Color subTextColor, Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: textColor.withValues(alpha: 0.8), size: 22),
      title: Text(title, style: TextStyle(color: textColor, fontSize: 15)),
      trailing: trailing ?? Icon(Icons.chevron_right, color: subTextColor, size: 20),
      onTap: onTap ?? (trailing == null ? () {} : null),
    );
  }

  Widget _buildDivider(Color color) {
    return Divider(color: color.withValues(alpha: 0.1), height: 1, indent: 52);
  }
}
