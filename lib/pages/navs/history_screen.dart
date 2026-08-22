import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mktdata/controllers/history_controller.dart';
import 'package:mktdata/pages/transaction_detailScreen.dart';

class HistoryScreen extends StatelessWidget {
  HistoryScreen({super.key});

  final HistoryController c = Get.put(HistoryController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Transaction History',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: Obx(() {
        if (c.isLoading.value && c.transactions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Filter Chips Section
            _buildFilterChips(isDark),
            
            // Transactions List
            Expanded(
              child: c.filteredTransactions.isEmpty
                  ? _buildEmptyState(theme)
                  : RefreshIndicator(
                      onRefresh: () => c.getTransactions(),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: c.filteredTransactions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final tx = c.filteredTransactions[index];
                          return _buildTransactionTile(tx, isDark, theme);
                        },
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            ...c.filterOptions.map((filter) {
              final isSelected = c.selectedFilter.value == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (_) => c.applyFilter(filter),
                  backgroundColor:
                      isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.grey.withValues(alpha: 0.1),
                  selectedColor:
                      _getFilterColor(filter).withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                    color:
                        isSelected
                            ? _getFilterColor(filter)
                            : (isDark ? Colors.white70 : Colors.black54),
                    fontSize: 12,
                  ),
                  side: BorderSide(
                    color:
                        isSelected
                            ? _getFilterColor(filter)
                            : (isDark
                                ? Colors.white10
                                : Colors.grey.withValues(alpha: 0.2)),
                    width: isSelected ? 1.5 : 0.5,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(
    dynamic tx,
    bool isDark,
    ThemeData theme,
  ) {
    // Get transaction properties
    String type = (tx['type'] ?? 'Unknown').toString().toLowerCase();
    String status = (tx['status'] ?? 'Pending').toString().toLowerCase();
    String description = tx['desc'] ?? tx['description'] ?? 'No description';
    String amount = tx['amount'].toString();
    String date = tx['date'] ?? '';
    String ref = tx['ref'] ?? '';

    // Determine if it's an outgoing transaction
    bool isOutgoing = !type.contains('topup') && !type.contains('funding');

    // Status colors
    Color statusColor = status == 'pending'
        ? Colors.orange
        : status == 'failed'
            ? Colors.red
            : Colors.green;

    // Transaction type colors and icons
    Color iconBgColor;
    IconData iconData;

    switch (type) {
      case 'airtime':
        iconBgColor = Colors.blue;
        iconData = Icons.phone_iphone_rounded;
        break;
      case 'data':
        iconBgColor = Colors.purple;
        iconData = Icons.signal_cellular_4_bar_rounded;
        break;
      case 'wallet topup':
      case 'funding':
        iconBgColor = Colors.green;
        iconData = Icons.account_balance_wallet_rounded;
        isOutgoing = false;
        break;
      case 'electricity':
        iconBgColor = Colors.amber;
        iconData = Icons.flash_on_rounded;
        break;
      case 'cable':
        iconBgColor = Colors.indigo;
        iconData = Icons.tv_rounded;
        break;
      case 'datacard':
        iconBgColor = Colors.cyan;
        iconData = Icons.credit_card_rounded;
        break;
      default:
        iconBgColor = Colors.grey;
        iconData = Icons.receipt_long_rounded;
    }

    return InkWell(
      onTap: () => Get.to(() => TransactionDetailScreen(), arguments: tx),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isDark ? Border.all(color: Colors.white10) : null,
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Leading Icon
              CircleAvatar(
                radius: 28,
                backgroundColor: iconBgColor.withValues(alpha: 0.1),
                child: Icon(
                  iconData,
                  color: iconBgColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              
              // Middle Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type and Amount Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            type.capitalizeFirst ?? 'Transaction',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          amount,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Description
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.hintColor,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Date and Status Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            date,
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.hintColor.withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            status.capitalizeFirst ?? 'Unknown',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getFilterColor(String filter) {
    switch (filter.toLowerCase()) {
      case 'airtime':
        return Colors.blue;
      case 'data':
        return Colors.purple;
      case 'wallet topup':
        return Colors.green;
      case 'electricity':
        return Colors.amber;
      case 'cable':
        return Colors.indigo;
      case 'datacard':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: 80,
            color: theme.hintColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "No transactions found",
            style: TextStyle(color: theme.hintColor, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
