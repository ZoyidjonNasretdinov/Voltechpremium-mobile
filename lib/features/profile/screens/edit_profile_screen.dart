import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_twind/flutter_twind.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/api_service.dart';
import '../../../core/twind/twind_ui.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? profileData;
  const EditProfileScreen({super.key, this.profileData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;

  bool _isLoading = false;
  bool _isUploadingImage = false;
  String? _currentImageUrl;
  Uint8List? _localAvatarBytes;
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.profileData?['firstName'] ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.profileData?['lastName'] ?? '',
    );
    _currentImageUrl = widget.profileData?['imageUrl'];
    if (widget.profileData == null || widget.profileData!.isEmpty) {
      _loadProfileData();
    }
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    final response = await _apiService.getProfile();
    if (response['success'] == true && mounted) {
      final data = response['data'] ?? {};
      setState(() {
        _firstNameController.text = data['firstName'] ?? '';
        _lastNameController.text = data['lastName'] ?? '';
        _currentImageUrl = data['imageUrl'];
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceDialog() async {
    if (_isUploadingImage) return;

    if (kIsWeb) {
      _pickAndUploadImage(ImageSource.gallery);
      return;
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1F25) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: WText(
                  'choose_photo'.tr,
                  className: 'text-sm font-semibold',
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_rounded,
                  color: Color(0xFFE52D27),
                ),
                title: Text(
                  'gallery'.tr,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_rounded,
                  color: Color(0xFFE52D27),
                ),
                title: Text(
                  'camera'.tr,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );

    if (source != null) {
      _pickAndUploadImage(source);
    }
  }

  Future<void> _pickAndUploadImage([
    ImageSource source = ImageSource.gallery,
  ]) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image == null) return;

      final bytes = await image.readAsBytes();
      if (bytes.isEmpty) return;

      var filename = image.name.isNotEmpty ? image.name : 'avatar.jpg';
      final lower = filename.toLowerCase();
      if (!lower.endsWith('.png') &&
          !lower.endsWith('.webp') &&
          !lower.endsWith('.jpg') &&
          !lower.endsWith('.jpeg')) {
        filename = 'avatar.jpg';
      }

      setState(() {
        _localAvatarBytes = bytes;
        _isUploadingImage = true;
      });

      final response = await _apiService.uploadProfileImageBytes(
        bytes,
        filename,
      );

      if (!mounted) return;
      setState(() => _isUploadingImage = false);

      if (response['success'] == true) {
        setState(() {
          _currentImageUrl = response['data']?['imageUrl'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('image_uploaded'.tr),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'error'.tr),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingImage = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('error'.tr),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (_isUploadingImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('uploading_image'.tr),
          backgroundColor: Colors.orangeAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('fill_all_fields'.tr),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final response = await _apiService.updateProfile(firstName, lastName);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('profile_updated'.tr),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
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
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: localeNotifier,
      builder: (context, locale, child) {
        final theme = Theme.of(context);
        final bgColor = theme.scaffoldBackgroundColor;
        final accentColor = theme.colorScheme.primary;

        final isDark = theme.brightness == Brightness.dark;
        final avatarBg =
            isDark ? const Color(0xFF26282E) : const Color(0xFFE2E8F0);
        final avatarIconColor =
            isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B);

        return Scaffold(
          backgroundColor: bgColor,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const AppIcon(AppIcons.arrowLeft, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: WText(
              'edit_profile'.tr,
              className: 'text-lg font-semibold text-white',
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      height: 220,
                      margin: const EdgeInsets.only(bottom: 60),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accentColor,
                            accentColor.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: _isUploadingImage
                                ? null
                                : _showImageSourceDialog,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: bgColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: ClipOval(
                                  child: Container(
                                    color: avatarBg,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      fit: StackFit.expand,
                                      children: [
                                        if (_localAvatarBytes != null)
                                          Image.memory(
                                            _localAvatarBytes!,
                                            fit: BoxFit.cover,
                                            width: 112,
                                            height: 112,
                                          )
                                        else if (_currentImageUrl != null &&
                                            _currentImageUrl!.isNotEmpty &&
                                            ApiService.resolveImageUrl(
                                                  _currentImageUrl,
                                                ) !=
                                                null)
                                          (kIsWeb
                                              ? Image.network(
                                                  ApiService.resolveImageUrl(
                                                    _currentImageUrl,
                                                  )!,
                                                  fit: BoxFit.cover,
                                                  width: 112,
                                                  height: 112,
                                                  loadingBuilder: (ctx, child, progress) =>
                                                      progress == null
                                                          ? child
                                                          : const Center(
                                                              child: SizedBox(
                                                                width: 24,
                                                                height: 24,
                                                                child: CircularProgressIndicator(
                                                                  strokeWidth: 2,
                                                                  color: Colors.redAccent,
                                                                ),
                                                              ),
                                                            ),
                                                  errorBuilder: (ctx, err, st) =>
                                                      Center(
                                                    child: AppIcon(
                                                      AppIcons.userSolid,
                                                      color: avatarIconColor,
                                                      size: 64,
                                                    ),
                                                  ),
                                                )
                                              : CachedNetworkImage(
                                                  imageUrl:
                                                      ApiService.resolveImageUrl(
                                                    _currentImageUrl,
                                                  )!,
                                                  fit: BoxFit.cover,
                                                  width: 112,
                                                  height: 112,
                                                  memCacheWidth: 300,
                                                  memCacheHeight: 300,
                                                  placeholder: (context, url) =>
                                                      const Center(
                                                    child: SizedBox(
                                                      width: 24,
                                                      height: 24,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.redAccent,
                                                      ),
                                                    ),
                                                  ),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      Center(
                                                    child: AppIcon(
                                                      AppIcons.userSolid,
                                                      color: avatarIconColor,
                                                      size: 64,
                                                    ),
                                                  ),
                                                ))
                                        else
                                          Center(
                                            child: AppIcon(
                                              AppIcons.userSolid,
                                              color: avatarIconColor,
                                              size: 64,
                                            ),
                                          ),
                                        if (_isUploadingImage)
                                          Container(
                                            color: Colors.black.withValues(
                                              alpha: 0.45,
                                            ),
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _isUploadingImage
                                  ? null
                                  : _showImageSourceDialog,
                              child: Container(
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: bgColor, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.25,
                                      ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: _isUploadingImage
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const AppIcon(
                                        AppIcons.camera,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 540),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              _buildTextField(
                                'first_name'.tr,
                                _firstNameController,
                                AppIcons.user,
                                theme,
                              ),
                              _buildTextField(
                                'last_name'.tr,
                                _lastNameController,
                                AppIcons.user,
                                theme,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: TwButton(
                            text: 'save_changes'.tr,
                            onPressed: _isLoading ? null : _saveProfile,
                            isLoading: _isLoading,
                            width: double.infinity,
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    dynamic icon,
    ThemeData theme, {
    TextInputType? keyboardType,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    final fillColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.grey.withValues(alpha: 0.05);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: icon is String
                ? AppIcon(
                    icon,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF64748B),
                    size: 20,
                  )
                : Icon(
                    icon as IconData,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF64748B),
                  ),
          ),
          filled: true,
          fillColor: fillColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }
}
