import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/api_service.dart';


class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _purchases = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPurchases();
  }

  Future<void> _loadPurchases() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await _apiService.getPurchaseHistory();
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response['success'] == true) {
          _purchases = response['data'] ?? [];
        } else {
          _error = response['message'] ?? 'Xatolik yuz berdi';
        }
      });
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
        title: Text('Mening xaridlarim', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent)))
              : _purchases.isEmpty
                  ? Center(
                      child: Text(
                        "Hozircha xaridlar yo'q",
                        style: TextStyle(color: textColor.withValues(alpha: 0.6), fontSize: 16),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPurchases,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _purchases.length,
                        itemBuilder: (context, index) {
                          final purchase = _purchases[index];
                          final gift = purchase['gift'] ?? {};
                          final giftName = gift['name'] ?? 'Sovg\'a';
                          final points = purchase['pointsSpent'] ?? 0;
                          final status = purchase['status'] ?? 'PENDING';
                          final dateStr = purchase['purchaseDate'] ?? '';
                          
                          String formattedDate = '';
                          try {
                            if (dateStr.isNotEmpty) {
                              String dStr = dateStr;
                              if (!dStr.endsWith('Z')) dStr += 'Z';
                              final date = DateTime.parse(dStr).toLocal();
                              formattedDate = DateFormat('dd.MM.yyyy HH:mm').format(date);
                            }
                          } catch (e) {
                            formattedDate = dateStr;
                          }

                          final isApproved = status == 'APPROVED';
                          final statusText = isApproved ? 'Topshirildi' : 'Kutmoqda';
                          final statusColor = isApproved ? Colors.green : Colors.orangeAccent;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    image: gift['imageUrl'] != null && gift['imageUrl'].toString().isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage("https://voltechpremiumbackend-api-production.up.railway.app/api/files/download/${gift['imageUrl']}"),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: gift['imageUrl'] == null || gift['imageUrl'].toString().isEmpty
                                      ? Icon(Icons.card_giftcard, color: theme.colorScheme.primary)
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        giftName,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        formattedDate,
                                        style: TextStyle(
                                          color: textColor.withValues(alpha: 0.5),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '-$points ball',
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        statusText,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
