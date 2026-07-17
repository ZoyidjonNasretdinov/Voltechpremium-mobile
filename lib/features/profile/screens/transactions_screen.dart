import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/api_service.dart';


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

    final response = await _apiService.getTransactionHistory(page: 0, size: 100);
    
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
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Ballar tarixi', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent)))
              : _transactions.isEmpty
                  ? Center(
                      child: Text(
                        "Hozircha ballar tarixi yo'q",
                        style: TextStyle(color: textColor.withValues(alpha: 0.6), fontSize: 16),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadTransactions,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _transactions.length,
                        itemBuilder: (context, index) {
                          final tx = _transactions[index];
                          final isEarned = tx['type'] == 'EARNED';
                          final dateStr = tx['date'] ?? '';
                          String formattedDate = '';
                          try {
                            if (dateStr.isNotEmpty) {
                              final date = DateTime.parse(dateStr).toLocal();
                              formattedDate = DateFormat('dd.MM.yyyy HH:mm').format(date);
                            }
                          } catch (e) {
                            formattedDate = dateStr;
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isEarned 
                                        ? Colors.green.withValues(alpha: 0.1) 
                                        : Colors.redAccent.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isEarned ? Icons.add_circle_outline : Icons.remove_circle_outline,
                                    color: isEarned ? Colors.green : Colors.redAccent,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tx['description'] ?? (isEarned ? 'Ball qo\'shildi' : 'Ball sarflandi'),
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        formattedDate,
                                        style: TextStyle(
                                          color: textColor.withValues(alpha: 0.5),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${isEarned ? '+' : '-'}${tx['points'] ?? 0}',
                                  style: TextStyle(
                                    color: isEarned ? Colors.green : Colors.redAccent,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
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
