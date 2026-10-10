import 'package:flutter/material.dart';
import 'package:flutter_twind/flutter_twind.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/api_service.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/twind/twind_ui.dart';

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
          _error = response['message'] ?? 'error'.tr;
        }
      });
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
          'my_purchases'.tr,
          className: 'text-lg font-semibold',
          color: textColor,
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: WText(_error!, className: 'text-red-500 font-medium'))
          : _purchases.isEmpty
          ? Center(
              child: WText(
                'no_purchases'.tr,
                className: 'text-base text-gray-500',
                color: textColor.withValues(alpha: 0.6),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadPurchases,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _purchases.length,
                    itemBuilder: (context, index) {
                      final purchase = _purchases[index];
                      final gift = purchase['gift'] ?? {};
                      final giftName = gift['name'] ?? 'unknown_gift'.tr;
                      final points = purchase['pointsSpent'] ?? 0;
                      final status = purchase['status'] ?? 'PENDING';
                      final dateStr = purchase['purchaseDate'] ?? '';

                      String formattedDate = '';
                      try {
                        if (dateStr.isNotEmpty) {
                          String dStr = dateStr;
                          if (!dStr.endsWith('Z')) dStr += 'Z';
                          final date = DateTime.parse(
                            dStr,
                          ).toUtc().add(const Duration(hours: 5));
                          formattedDate = DateFormat(
                            'dd.MM.yyyy HH:mm',
                          ).format(date);
                        }
                      } catch (e) {
                        formattedDate = dateStr;
                      }

                      final isApproved =
                          status == 'APPROVED' || status == 'DELIVERED';
                      final statusText = isApproved
                          ? 'status_delivered'.tr
                          : 'status_pending'.tr;
                      final statusColor = isApproved
                          ? Colors.green
                          : Colors.orangeAccent;

                      return TwCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            WContainer(
                              className:
                                  'w-12 h-12 rounded-xl bg-red-600/10 flex items-center justify-center',
                              child:
                                  gift['imageUrl'] != null &&
                                      gift['imageUrl'].toString().isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: CachedNetworkImage(
                                        imageUrl: ApiService.resolveImageUrl(
                                          gift['imageUrl'].toString(),
                                        )!,
                                        fit: BoxFit.cover,
                                        width: 48,
                                        height: 48,
                                        memCacheWidth: 150,
                                        memCacheHeight: 150,
                                        placeholder: (ctx, url) => const Center(
                                          child: SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                        ),
                                        errorWidget: (ctx, err, st) => AppIcon(
                                          AppIcons.gift,
                                          color: theme.colorScheme.primary,
                                          size: 24,
                                        ),
                                      ),
                                    )
                                  : AppIcon(
                                      AppIcons.gift,
                                      color: theme.colorScheme.primary,
                                      size: 24,
                                    ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  WText(
                                    giftName,
                                    className: 'text-sm font-bold',
                                    color: textColor,
                                  ),
                                  const SizedBox(height: 3),
                                  WText(
                                    formattedDate,
                                    className: 'text-xs text-gray-400',
                                    color: textColor.withValues(alpha: 0.5),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                WText(
                                  '-$points ${'points_unit'.tr}',
                                  className: 'text-sm font-bold text-red-600',
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(height: 4),
                                TwBadge(text: statusText, color: statusColor),
                              ],
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
