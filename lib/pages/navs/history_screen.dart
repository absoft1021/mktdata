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

  Widget _buildTransactionTile(dynamic tx, bool isDark, ThemeData theme) {
    bool isSell = false;
    String status = tx[4].toString().toLowerCase();

    // Status Colors
    Color statusColor = status == 'pending' ? Colors.orange : Colors.green;

    return InkWell(
      onTap: () => Get.to(() => TransactionDetailScreen(), arguments: tx),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isDark ? Border.all(color: Colors.white10) : null,
          boxShadow:
              isDark
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
            backgroundColor: (isSell ? Colors.red : Colors.green).withValues(
              alpha: 0.1,
            ),
            child: Icon(
              isSell ? Icons.south_west_rounded : Icons.north_east_rounded,
              color: isSell ? Colors.red : Colors.green,
              size: 20,
            ),
          ),
          title: Row(
            children: [
              Text(
                tx[1],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              // Text(
              //   "₦${double.parse(tx[3]).toStringAsFixed(2)}",
              //   style: const TextStyle(fontWeight: FontWeight.bold),
              // ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx[5].toString().substring(0, tx[5].toString().indexOf("<")),
                  style: const TextStyle(fontSize: 12),
                ),
                const Spacer(),
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
                    status.capitalizeFirst!,
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
