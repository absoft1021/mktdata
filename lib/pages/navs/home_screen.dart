import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mktdata/controllers/main_controller.dart';
import 'package:mktdata/pages/airtime_page.dart';
import 'package:mktdata/pages/cable_page.dart';
import 'package:mktdata/pages/data_page.dart';
import 'package:mktdata/pages/exam_page.dart';
import 'package:mktdata/pages/fund_page.dart';
import 'package:mktdata/pages/profile_page.dart';
import 'package:mktdata/pages/sell_crypto_page.dart';
import 'package:mktdata/pages/transaction_detailScreen.dart';
import 'package:mktdata/pages/withdrawal_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MainController c = Get.put(MainController());
  bool _balanceVisible = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => c.getUserProfile(),
          child: CustomScrollView(
            // Using CustomScrollView for better scroll performance
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(child: _buildAppBar(theme, isDark)),
              SliverToBoxAdapter(child: Obx(() => _buildBalanceCard())),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(child: _buildActionButtons(theme, isDark)),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // Transactions Header
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    "Recent Transactions",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // Transaction List
              Obx(() {
                if (c.transactions.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(theme),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final tx = c.transactions[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildTransactionTile(tx, isDark, theme),
                        );
                      },
                      childCount:
                          c.transactions.length > 3 ? 3 : c.transactions.length,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme, bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF2E3A59);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          InkWell(
            onTap: () => Get.to(() => const ProfilePage()),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${c.box.read('userData')?['username']?.toString().capitalizeFirst ?? ''}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  c.box
                          .read('userData')?['user_type']
                          ?.toString()
                          .capitalizeFirst ??
                      'Welcome back',
                  style: TextStyle(fontSize: 12, color: theme.hintColor),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed:
                () => Get.changeThemeMode(
                  Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
                ),
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E3C72), Color(0xFF014492)],
          ),
          borderRadius: BorderRadius.circular(20),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.blue.withOpacity(0.3),
          //     blurRadius: 12,
          //     offset: const Offset(0, 6),
          //   ),
          // ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Balance',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                GestureDetector(
                  onTap:
                      () => setState(() => _balanceVisible = !_balanceVisible),
                  child: Icon(
                    _balanceVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Obx(
                  () => Text(
                    _balanceVisible
                        ? '₦${c.walletBal.value ?? '0.00'}'
                        : '₦ ••••••',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Get.to(() => const FundPage()),
                  child: const Text('Fund Wallet'),
                ),
              ],
            ),
            if (c.bankAccounts.isNotEmpty) ...[
              const Divider(color: Colors.white24, height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${c.bankAccounts[0][1].toString().contains(" ") ? c.bankAccounts[0][1].toString().split(" ")[0] : c.bankAccounts[0][1]} • ${c.bankAccounts[0][0]}",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.copy,
                      color: Colors.white70,
                      size: 16,
                    ),
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: c.bankAccounts[0][0]),
                      );
                      Get.snackbar(
                        "Success",
                        "Account number copied",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.white,
                        colorText: Colors.black,
                      );
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(dynamic tx, bool isDark, ThemeData theme) {
    String status = tx[4].toString().toLowerCase();
    Color statusColor = status == 'pending' ? Colors.orange : Colors.green;

    return Container(
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
      child: ListTile(
        onTap: () => Get.to(() => TransactionDetailScreen(), arguments: tx),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(Icons.receipt_long, color: statusColor, size: 20),
        ),
        title: Text(
          tx[1],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          tx[5].toString().split('<')[0], // Cleaner string split logic
          style: const TextStyle(fontSize: 11),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "₦${tx[3]}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status.capitalizeFirst!,
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
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.history_rounded,
          size: 60,
          color: theme.hintColor.withOpacity(0.3),
        ),
        const SizedBox(height: 16),
        Text("No transactions found", style: TextStyle(color: theme.hintColor)),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton(
            'Airtime',
            Icons.call,
            Colors.orange,
            theme,
            isDark,
            () => Get.to(() => const AirtimePage()),
          ),
          _buildActionButton(
            'Data',
            Icons.wifi,
            Colors.blue,
            theme,
            isDark,
            () => Get.to(() => const BuyDataPage()),
          ),
          _buildActionButton(
            'Exam',
            Icons.school,
            Colors.teal,
            theme,
            isDark,
            () => Get.to(() => ExamPage()),
          ),
          _buildActionButton(
            'Cable',
            Icons.tv,
            Colors.red,
            theme,
            isDark,
            () => Get.to(() => CablePage()),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    ThemeData theme,
    bool isDark,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow:
                  isDark
                      ? []
                      : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                        ),
                      ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
