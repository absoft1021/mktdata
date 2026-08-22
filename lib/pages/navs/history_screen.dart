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

        if (c.transactions.isEmpty) {
          return _buildEmptyState(theme);
        }

        return RefreshIndicator(
          onRefresh: () => c.getTransactions(),
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: c.transactions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final tx = c.transactions[index];
              return _buildTransactionTile(tx, isDark, theme);
            },
          ),
        );
      }),
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
    String description = tx['desc'] ?? tx['description'] ?? '';
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
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor: iconBgColor.withValues(alpha: 0.1),
            child: Icon(
              iconData,
              color: iconBgColor,
              size: 22,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  type.capitalizeFirst ?? 'Transaction',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                amount,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        date,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.hintColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        status.capitalizeFirst ?? 'Unknown',
                        overflow: TextOverflow.ellipsis,
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
          ),
        ),
      ),
    );
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
