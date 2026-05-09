import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    // Access the 'profile' map from storage
    final Map<String, dynamic> user = box.read('userData') ?? {};

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF667EEA);

    // Combine Names
    String fullName = "${user['full_name'] ?? ''}".trim();
    if (fullName.isEmpty) fullName = "User Account";

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "My Account",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // --- HEADER SECTION ---
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: Text(
                      user['fname']?[0].toUpperCase() ?? "U",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user['email'] ?? "",
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  _buildBadge(
                    user['level']?.toUpperCase() ?? "LEVEL 1",
                    primaryColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- INFO CARDS ---
            Row(
              children: [
                _buildStatCard(
                  "Balance",
                  "₦${user['balance'] ?? '0.00'}",
                  isDark,
                ),
                const SizedBox(width: 15),
                _buildStatCard(
                  "Referrals",
                  "${user['ref_count'] ?? 0}",
                  isDark,
                ),
              ],
            ),

            const SizedBox(height: 25),

            // --- BANKING SECTION ---
            _sectionHeader("LINKED BANK ACCOUNT"),
            _buildInfoTile(
              Icons.account_balance_rounded,
              user['bank_name'] ?? "Not Set",
              "${user['account_number'] ?? 'No Account'} • ${user['account_name'] ?? ''}",
              isDark,
            ),

            const SizedBox(height: 20),

            // --- REFERRAL SECTION ---
            _sectionHeader("REFERRAL CODE"),
            _buildReferralTile(user['username'] ?? "N/A", primaryColor, isDark),

            const SizedBox(height: 40),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text(
                  "Back",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.redAccent.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow:
              isDark
                  ? []
                  : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String title,
    String subtitle,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralTile(String code, Color primary, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            code,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              Get.snackbar(
                "Copied",
                "Referral code copied!",
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            icon: Icon(Icons.copy_rounded, color: primary),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
