import 'package:flutter/material.dart';
import '../../../core/api_service.dart';
import 'verify_otp_screen.dart';
import '../../profile/screens/policy_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController(text: '+998 ');
  final _districtController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedRegion;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _acceptedPrivacyPolicy = false;
  final ApiService _apiService = ApiService();

  final List<String> _regions = [
    'Toshkent sh.',
    'Toshkent viloyati',
    'Andijon',
    'Buxoro',
    "Farg'ona",
    'Jizzax',
    'Xorazm',
    'Namangan',
    'Navoiy',
    'Qashqadaryo',
    'Samarqand',
    'Sirdaryo',
    'Surxondaryo',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ro'yxatdan o'tish"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Yangi Usta profili',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Barcha ma'lumotlarni to'g'ri kiriting",
              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 32),
            
            // Ism
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'Ism', prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(height: 16),
            
            // Familiya
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Familiya', prefixIcon: Icon(Icons.person_outline)),
            ),
            const SizedBox(height: 16),
            
            // Yosh
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Yoshingiz', prefixIcon: Icon(Icons.calendar_today)),
            ),
            const SizedBox(height: 16),
            
            // Telefon
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Telefon raqam', prefixIcon: Icon(Icons.phone)),
            ),
            const SizedBox(height: 16),
            
            // Viloyat (Dropdown)
            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Viloyatni tanlang', prefixIcon: Icon(Icons.location_on)),
              dropdownColor: theme.colorScheme.surface,
              initialValue: _selectedRegion,
              items: _regions.map((String region) {
                return DropdownMenuItem<String>(
                  value: region,
                  child: Text(region),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRegion = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Tuman (District)
            TextField(
              controller: _districtController,
              decoration: const InputDecoration(labelText: 'Tuman (Yashash manzili)', prefixIcon: Icon(Icons.map)),
            ),
            const SizedBox(height: 16),
            
            // Parol
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: "Parol o'ylab toping",
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
            
            // Maxfiylik Siyosati
            Row(
              children: [
                Checkbox(
                  value: _acceptedPrivacyPolicy,
                  onChanged: (val) {
                    setState(() {
                      _acceptedPrivacyPolicy = val ?? false;
                    });
                  },
                  activeColor: theme.colorScheme.primary,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PolicyScreen()));
                    },
                    child: Text.rich(
                      TextSpan(
                        text: "Men ",
                        children: [
                          TextSpan(
                            text: "Maxfiylik siyosati",
                            style: TextStyle(color: theme.colorScheme.primary, decoration: TextDecoration.underline, fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: " va Foydalanish shartlariga roziman"),
                        ],
                      ),
                      style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Saqlash / Tasdiqlash
            ElevatedButton(
              onPressed: _isLoading ? null : () async {
                final phone = _phoneController.text.replaceAll(' ', '');
                final firstName = _firstNameController.text.trim();
                final lastName = _lastNameController.text.trim();
                final password = _passwordController.text.trim();
                final ageText = _ageController.text.trim();
                final district = _districtController.text.trim();
                final region = _selectedRegion;
                
                if (phone.isEmpty || firstName.isEmpty || lastName.isEmpty || password.isEmpty || ageText.isEmpty || district.isEmpty || region == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Barcha maydonlarni to'ldiring!"),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }

                if (!_acceptedPrivacyPolicy) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Iltimos, Maxfiylik siyosatiga rozi bo'ling!"),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }

                int? age = int.tryParse(ageText);
                if (age == null || age < 15) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Yoshingiz kamida 15 bo'lishi kerak"),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }

                setState(() => _isLoading = true);
                
                final response = await _apiService.sendSms(phone);
                
                if (!mounted) return;
                setState(() => _isLoading = false);
                
                if (response['success'] != true) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response['message'] ?? "SMS yuborishda xatolik"),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }

                if (!context.mounted) return;
                // Navigate to VerifyOtpScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VerifyOtpScreen(
                      phone: phone,
                      password: password,
                      isRegistration: true,
                      firstName: firstName,
                      lastName: lastName,
                      age: age,
                      region: region,
                      district: district,
                    ),
                  ),
                );
              },
              child: _isLoading
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
                : const Text('Ro\'yxatdan o\'tish'),
            ),
          ],
        ),
      ),
    );
  }
}

