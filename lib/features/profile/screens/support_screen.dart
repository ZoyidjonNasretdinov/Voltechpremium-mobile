import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/api_service.dart';
import 'package:flutter/cupertino.dart';

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

  Future<void> _loadNumbers() async {
    setState(() => _isLoading = true);
    final response = await _apiService.getAdminPhoneNumbers();
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
          const SnackBar(content: Text("Telefon raqamni ochib bo'lmadi"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.scaffoldBackgroundColor;
    final cardColor = theme.colorScheme.surface;
    final textColor = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Biz bilan bog'lanish", style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _phoneNumbers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.phone_circle, size: 64, color: textColor.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text("Hozircha bog'lanish uchun raqamlar yo'q", style: TextStyle(color: textColor.withValues(alpha: 0.6))),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _phoneNumbers.length,
                  itemBuilder: (context, index) {
                    final phoneObj = _phoneNumbers[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.support_agent, color: theme.colorScheme.primary),
                        ),
                        title: Text(phoneObj['name'] ?? 'Admin', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                        subtitle: Text(phoneObj['phoneNumber'] ?? '', style: TextStyle(color: textColor.withValues(alpha: 0.7), fontSize: 15)),
                        trailing: IconButton(
                          icon: const Icon(Icons.phone, color: Colors.green),
                          onPressed: () => _launchPhone(phoneObj['phoneNumber'] ?? ''),
                        ),
                        onTap: () => _launchPhone(phoneObj['phoneNumber'] ?? ''),
                      ),
                    );
                  },
                ),
    );
  }
}
