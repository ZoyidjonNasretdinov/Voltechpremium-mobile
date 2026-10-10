import 'package:flutter/material.dart';
import 'package:flutter_twind/flutter_twind.dart';
import 'package:intl/intl.dart';
import '../../../core/api_service.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/twind/twind_ui.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _transactions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await _apiService.getTransactionHistory(
      page: 0,
      size: 100,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response['success'] == true) {
          _transactions = response['data']?['content'] ?? [];
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
          'points_history'.tr,
          className: 'text-lg font-semibold',
          color: textColor,
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: WText(_error!, className: 'text-red-500 font-medium'))
          : _transactions.isEmpty
          ? Center(
              child: WText(
                'no_transactions'.tr,
                className: 'text-base text-gray-500',
                color: textColor.withValues(alpha: 0.6),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadTransactions,
              child: Center(
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
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final tx = _transactions[index];
                      final isEarned = tx['type'] == 'EARNED';
                      final dateStr = tx['date'] ?? '';
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

                      return TwCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            WContainer(
                              className: isEarned
                                  ? 'p-2.5 rounded-full bg-green-500/10'
                                  : 'p-2.5 rounded-full bg-red-500/10',
                              child: AppIcon(
                                isEarned
                                    ? AppIcons.plusCircle
                                    : AppIcons.minusCircle,
                                color: isEarned
                                    ? Colors.green
                                    : Colors.redAccent,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  WText(
                                    tx['description'] ??
                                        (isEarned
                                            ? 'points_earned'.tr
                                            : 'points_spent'.tr),
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
                            WText(
                              '${isEarned ? '+' : '-'}${tx['points'] ?? 0}',
                              className: 'text-base font-bold',
                              color: isEarned ? Colors.green : Colors.redAccent,
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
