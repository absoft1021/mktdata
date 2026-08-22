import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dynamic tx = Get.arguments;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Validate transaction data
    if (tx == null || tx is! Map) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Details'),
          centerTitle: true,
        ),
        body: const Center(child: Text("Invalid transaction data")),
      );
    }

    final String type = (tx['type'] ?? 'Unknown').toString().toLowerCase();
    final String status = (tx['status'] ?? 'Pending').toString().toLowerCase();
    final String description = tx['desc'] ?? tx['description'] ?? 'No description';
    final String amount = tx['amount'].toString();
    final String date = tx['date'] ?? 'N/A';
    final String ref = tx['ref'] ?? 'N/A';

    // Determine if it's an outgoing transaction
    bool isOutgoing = !type.contains('topup') && !type.contains('funding');

    // Status color logic
    final Color statusColor = status == 'pending'
        ? Colors.orange
        : status == 'failed'
            ? Colors.red
            : Colors.green;

    // Transaction type icon and color
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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Transaction Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            _buildHeader(
              type,
              amount,
              isOutgoing,
              isDark,
              iconBgColor,
              iconData,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(isDark, [
              _detailRow(
                "Type",
                type.capitalizeFirst ?? "N/A",
              ),
              _detailRow(
                "Status",
                status.capitalizeFirst ?? "N/A",
                valueColor: statusColor,
              ),
              _detailRow("Amount", amount),
              _detailRow("Date", date),
            ]),
            const SizedBox(height: 12),
            _buildInfoCard(isDark, [
              _detailRow(
                "Reference ID",
                ref,
                canCopy: true,
              ),
              if (tx['oldbal'] != null)
                _detailRow("Old Balance", tx['oldbal'].toString()),
              if (tx['newbal'] != null)
                _detailRow("New Balance", tx['newbal'].toString()),
            ]),
            const SizedBox(height: 12),
            _buildInfoCard(isDark, [
              _narrationBlock(description),
            ]),
            const SizedBox(height: 24),
            _buildDoneButton(isOutgoing),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    String type,
    String amount,
    bool isOutgoing,
    bool isDark,
    Color iconBgColor,
    IconData iconData,
  ) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isDark
                    ? Colors.white10
                    : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: iconBgColor.withValues(alpha: 0.15),
              child: Icon(
                iconData,
                size: 40,
                color: iconBgColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              type.capitalizeFirst ?? 'Transaction',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              amount,
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );

  Widget _buildInfoCard(bool isDark, List<Widget> children) => Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
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
        child: Column(
          children: children
              .expand(
                (w) => [
                  w,
                  const Divider(height: 12, color: Colors.transparent),
                ],
              )
              .toList()
            ..removeLast(),
        ),
      );

  Widget _detailRow(
    String label,
    String value, {
    Color? valueColor,
    bool canCopy = false,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: valueColor,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  if (canCopy && value != "N/A")
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: value));
                        Get.rawSnackbar(
                          message: "$label copied to clipboard",
                          snackPosition: SnackPosition.BOTTOM,
                          duration: const Duration(seconds: 2),
                          margin: const EdgeInsets.all(12),
                          borderRadius: 8,
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.copy_all_rounded,
                          size: 18,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _narrationBlock(String text) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Description",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      );

  Widget _buildDoneButton(bool isOutgoing) => SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isOutgoing ? Colors.blue : Colors.green,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          onPressed: () => Get.back(),
          child: const Text(
            "Done",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
}
