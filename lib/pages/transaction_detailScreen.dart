import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key});

  // Helper to handle String or num types safely
  String _formatAmount(dynamic amount) {
    if (amount == null || amount.toString().isEmpty) return "0";
    // Remove currency symbols if present in the string before parsing
    String cleanAmount = amount.toString().replaceAll(RegExp(r'[^0-9.]'), '');
    double value = double.tryParse(cleanAmount) ?? 0.0;
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final dynamic tx = Get.arguments;

    // Basic validation to ensure tx is a list and has enough elements
    if (tx == null || tx is! List || tx.length < 5) {
      return const Scaffold(
        body: Center(child: Text("Invalid transaction data")),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine if it's a sell/debit based on logic (Assumed logic: index 1 or narration)
    // Adjust this boolean based on your actual data structure
    final bool isSell =
        tx[1].toString().toLowerCase().contains('sell') ||
        tx[1].toString().toLowerCase().contains('debit');

    final String status = tx[4]?.toString().toLowerCase() ?? 'unknown';

    // Status color logic
    final Color statusColor = switch (status) {
      'pending' => Colors.orange,
      'failed' => Colors.red,
      'success' => Colors.green,
      _ => Colors.amber,
    };

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Details',
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
            _buildHeader(tx, isSell, isDark),
            const SizedBox(height: 12),
            _buildInfoCard(isDark, [
              _detailRow(
                "Status",
                status.capitalizeFirst ?? "N/A",
                valueColor: statusColor,
              ),
              _detailRow("Amount", "₦${_formatAmount(tx[3])}"),
              _detailRow("Type", tx[1]?.toString() ?? "N/A"),
              _detailRow(
                "Date",
                tx[5]?.toString().substring(
                      0,
                      tx[5]?.toString().indexOf("<"),
                    ) ??
                    "N/A",
              ),
            ]),
            const SizedBox(height: 10),
            _buildInfoCard(isDark, [
              _detailRow(
                "Reference",
                tx[0]?.toString() ?? "N/A",
                canCopy: true,
              ),
              // If tx is a List, hash might be at a specific index, e.g., tx[6]
              // Adjust the index below to match your actual list index for Hash
              if (tx.length > 6 && tx[6] != null)
                _detailRow("Tx Hash", tx[6].toString(), canCopy: true),
            ]),
            const SizedBox(height: 10),
            // Narration index usually 7 or similar in these list-based structures
            _buildInfoCard(isDark, [
              _narrationBlock(
                tx.length > 7 ? tx[7]?.toString() : "No narration available",
              ),
            ]),
            const SizedBox(height: 20),
            _buildDoneButton(isSell),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic tx, bool isSell, bool isDark) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 24),
    decoration: BoxDecoration(
      color:
          isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.grey.withOpacity(0.05),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
      ),
    ),
    child: Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor:
              isSell
                  ? const Color(0xFFFF3D71).withOpacity(0.1)
                  : const Color(0xFF00E096).withOpacity(0.1),
          child: Icon(
            isSell ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            size: 32,
            color: isSell ? const Color(0xFFFF3D71) : const Color(0xFF00E096),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          isSell ? "Sent" : "Received",
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          "₦${_formatAmount(tx[3])}",
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );

  Widget _buildInfoCard(bool isDark, List<Widget> children) => Container(
    padding: const EdgeInsets.all(16),
    width: double.infinity,
    decoration: BoxDecoration(
      color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow:
          isDark
              ? []
              : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
    ),
    child: Column(
      children:
          children
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
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
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

  Widget _narrationBlock(String? text) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Narration",
        style: TextStyle(color: Colors.grey, fontSize: 12),
      ),
      const SizedBox(height: 6),
      Text(
        text ?? "No narration provided",
        style: const TextStyle(fontSize: 14, height: 1.4),
      ),
    ],
  );

  Widget _buildDoneButton(bool isSell) => SizedBox(
    width: double.infinity,
    height: 54,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSell ? const Color(0xFFFF3D71) : const Color(0xFF00E096),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
