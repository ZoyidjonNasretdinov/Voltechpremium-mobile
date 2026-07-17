import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../../../core/localization/app_localizations.dart';
import 'purchases_screen.dart';
import '../../../core/api_service.dart';

class GiftScreen extends StatefulWidget {
  const GiftScreen({super.key});

  @override
  State<GiftScreen> createState() => _GiftScreenState();
}

class _GiftScreenState extends State<GiftScreen> {
  bool _isLoading = true;
  List<dynamic> _realGifts = [];
  int _userPoints = 0;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final profileRes = await _apiService.getProfile();
      if (profileRes['success'] == true) {
        _userPoints = (profileRes['data']['totalBonusPoints'] ?? 0).toInt();
      }

      final giftsRes = await _apiService.getAllGifts();
      if (giftsRes['success'] == true) {
        // the API returns a PageGift, so the list is in data['content']
        _realGifts = giftsRes['data']['content'] ?? [];
      }
    } catch (e) {
      debugPrint("Gifts load error: $e");
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _purchaseGift(int giftId, int price) async {
    if (_userPoints < price) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Balansingizda yetarli ball yo'q!"), backgroundColor: Colors.redAccent));
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xaridni tasdiqlash"),
        content: Text("Ushbu sovg'ani $price ballga xarid qilasizmi?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Bekor qilish")),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Sotib olish")),
        ],
      ),
    );

    if (confirm != true) return;

    if (!mounted) return;
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    final res = await _apiService.purchaseGift(giftId);
    if (!mounted) return;
    
    Navigator.pop(context); // pop loading

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("So'rov adminga yuborildi!"), backgroundColor: Colors.green));
      _loadData(); // reload balance
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? "Xatolik yuz berdi"), backgroundColor: Colors.redAccent));
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
        final hintColor = textColor.withValues(alpha: 0.5);

        return Scaffold(
          backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('gifts'.tr, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: textColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PurchasesScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Current Balance Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            margin: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${'your_points'.tr}:',
                  style: TextStyle(color: theme.colorScheme.onPrimary.withValues(alpha: 0.8), fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Icon(Icons.bolt, color: theme.colorScheme.onPrimary, size: 24),
                    const SizedBox(width: 4),
                    Text(
                      NumberFormat('#,###').format(_userPoints).replaceAll(',', ' '),
                      style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'search_gifts'.tr,
                hintStyle: TextStyle(color: hintColor),
                prefixIcon: Icon(CupertinoIcons.search, color: hintColor),
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          

          
          // Grid
          Expanded(
            child: _isLoading ? const Center(child: CircularProgressIndicator()) 
            : _realGifts.isEmpty ? const Center(child: Text("Hozircha sovg'alar mavjud emas"))
            : GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75, // taller than wide
              ),
              itemCount: _realGifts.length,
              itemBuilder: (context, index) {
                final gift = _realGifts[index];
                final giftId = gift['id'] as int;
                final giftName = gift['name'] ?? "Noma'lum";
                final giftPoints = gift['points'] ?? 0;
                
                // Fallbacks for now since backend doesn't seem to have icon/color
                final icon = CupertinoIcons.gift;
                final color = Colors.orangeAccent;

                return GestureDetector(
                  onTap: () => _purchaseGift(giftId, giftPoints),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Image / Icon
                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            child: Icon(icon, size: 50, color: color),
                          ),
                        ),
                        // Details
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  giftName,
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.bolt, color: accentColor, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        NumberFormat('#,###').format(giftPoints).replaceAll(',', ' '),
                                        style: TextStyle(
                                          color: accentColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
    },
    );
  }
}
