import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? profileData;
  const EditProfileScreen({super.key, this.profileData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _ageController;
  late TextEditingController _regionController;
  late TextEditingController _districtController;
  
  bool _isLoading = false;
  bool _isUploadingImage = false;
  String? _currentImageUrl;
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.profileData?['firstName'] ?? '');
    _lastNameController = TextEditingController(text: widget.profileData?['lastName'] ?? '');
    _ageController = TextEditingController(text: widget.profileData?['age']?.toString() ?? '');
    _regionController = TextEditingController(text: widget.profileData?['region'] ?? '');
    _districtController = TextEditingController(text: widget.profileData?['district'] ?? '');
    _currentImageUrl = widget.profileData?['imageUrl'];
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _regionController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (image == null) return;

      setState(() => _isUploadingImage = true);

      final response = await _apiService.uploadProfileImage(image.path);

      if (!mounted) return;
      setState(() => _isUploadingImage = false);

      if (response['success'] == true) {
        setState(() {
          _currentImageUrl = response['data']['imageUrl'];
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Rasm yuklandi"), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'] ?? "Rasm yuklashda xatolik"), backgroundColor: Colors.redAccent));
      }
    } catch (e) {
      setState(() => _isUploadingImage = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Xatolik yuz berdi"), backgroundColor: Colors.redAccent));
    }
  }

  Future<void> _saveProfile() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final ageText = _ageController.text.trim();
    final region = _regionController.text.trim();
    final district = _districtController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || ageText.isEmpty || region.isEmpty || district.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Barcha maydonlarni to'ldiring"), backgroundColor: Colors.redAccent));
      return;
    }

    final age = int.tryParse(ageText);
    if (age == null || age < 15) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Yosh kamida 15 bo'lishi kerak"), backgroundColor: Colors.redAccent));
      return;
    }

    setState(() => _isLoading = true);

    final response = await _apiService.updateProfile(firstName, lastName, age, region, district);
    
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil yangilandi"), backgroundColor: Colors.green));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'] ?? "Xatolik yuz berdi"), backgroundColor: Colors.redAccent));
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

        return Scaffold(
          backgroundColor: bgColor,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('edit_profile'.tr, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
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
                          colors: [accentColor, accentColor.withValues(alpha: 0.8)],
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
                          Container(
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
                                )
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                  image: _currentImageUrl != null && _currentImageUrl!.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage("https://voltechpremiumbackend-api-production.up.railway.app/api/files/download/$_currentImageUrl"),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: _currentImageUrl == null || _currentImageUrl!.isEmpty
                                    ? Icon(Icons.person, color: accentColor.withValues(alpha: 0.7), size: 70)
                                    : null,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _isUploadingImage ? null : _pickAndUploadImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: bgColor, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: _isUploadingImage
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : Icon(Icons.camera_alt, size: 20, color: theme.colorScheme.onPrimary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _buildTextField('Ism', _firstNameController, Icons.person_outline, theme),
                        _buildTextField('Familiya', _lastNameController, Icons.person_outline, theme),
                        _buildTextField('Yosh', _ageController, Icons.cake_outlined, theme, keyboardType: TextInputType.number),
                        _buildTextField('Viloyat', _regionController, Icons.map_outlined, theme),
                        _buildTextField('Tuman', _districtController, Icons.location_city_outlined, theme),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: theme.colorScheme.onPrimary,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: accentColor.withValues(alpha: 0.5),
                      ),
                      child: _isLoading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                        : Text('save_changes'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    ),
                    child: Text('delete_account'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, ThemeData theme, {TextInputType? keyboardType}) {
    final isDark = theme.brightness == Brightness.dark;
    final fillColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.05);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          prefixIcon: Icon(icon, color: theme.colorScheme.primary),
          filled: true,
          fillColor: fillColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
