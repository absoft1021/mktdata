import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mktdata/auth/login_page.dart';
import 'package:mktdata/auth/set_pin_page.dart';
import 'package:mktdata/controllers/main_controller.dart';
import 'package:mktdata/pages/add_bank_page.dart';
import 'package:mktdata/pages/change_password_page.dart';
import 'package:mktdata/pages/kyc_page.dart';
import 'package:mktdata/pages/profile_page.dart';
import 'package:url_launcher/url_launcher.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  final c = Get.find<MainController>();
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    c.kycStatus.value = box.read('profile')?['kyc'] ?? '11';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF2E3A59);
    final primaryColor = const Color(0xFF667EEA);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: titleColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- PROFILE HEADER SECTION ---
            _buildProfileHeader(c, isDark, titleColor, primaryColor),

            const SizedBox(height: 32),

            // --- SECURITY SECTION ---
            _sectionTitle("Security", titleColor),
            _buildMenuCard([
              _settingsTile(
                Icons.person,
                "Profile",
                () => Get.to(() => const ProfilePage()),
                primaryColor,
              ),
              _settingsTile(
                Icons.lock_outline,
                "Change PIN",
                () => Get.to(() => const SetPinPage()),
                primaryColor,
              ),
              _settingsTile(
                Icons.password_outlined,
                "Change Password",
                () => Get.to(() => ChangePasswordPage()),
                primaryColor,
              ),
              // _settingsTile(
              //   Icons.verified_user_outlined,
              //   "KYC Verification",
              //   () => Get.to(() => KycPage()),
              //   primaryColor,
              // ),
            ], isDark),

            const SizedBox(height: 24),

            // --- SUPPORT SECTION ---
            _sectionTitle("Support & Community", titleColor),
            _buildMenuCard([
              // _settingsTile(
              //   Icons.add,
              //   "Add Account",
              //   () => Get.to(() => AddBankPage()),
              //   primaryColor,
              // ),
              _settingsTile(
                Icons.support_agent_outlined,
                "Contact Us",
                () => _launchURL("https://wa.me/${box.read('contact')}"),
                primaryColor,
              ),
              _settingsTile(
                Icons.send_rounded,
                "Join Our Telegram Group",
                () => _launchURL(box.read('telegram') ?? ""),
                primaryColor,
              ),
              _settingsTile(
                Icons.language_outlined,
                "Visit Our Website",
                () => _launchURL("https://mktdata.ng"),
                primaryColor,
              ),
            ], isDark),

            const SizedBox(height: 32),
            _buildLogoutButton(isDark),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    MainController c,
    bool isDark,
    Color titleColor,
    Color primaryColor,
  ) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: primaryColor.withOpacity(0.1),
              child: Text(
                c.userProfile['username']?[0].toUpperCase() ?? "U",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),

            // FIXED: Using Obx to listen to c.kycStatus.value
            Obx(() {
              final String status = c.kycStatus.value.toString().padLeft(
                2,
                '0',
              );

              Color badgeColor;
              IconData badgeIcon;

              switch (status) {
                case '02':
                  badgeColor = Colors.green;
                  badgeIcon = Icons.verified;
                  break;
                case '01':
                  badgeColor = Colors.orange;
                  badgeIcon = Icons.pending;
                  break;
                default:
                  badgeColor = Colors.blueGrey;
                  badgeIcon = Icons.help_outline;
              }

              return Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    width: 2,
                  ),
                ),
                child: Icon(badgeIcon, color: Colors.white, size: 16),
              );
            }),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          c.box.read("userData")?['full_name'] ?? '',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          c.userProfile['email'] ?? "No email provided",
          style: TextStyle(fontSize: 14, color: titleColor.withOpacity(0.6)),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 12),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color.withOpacity(0.5),
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
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
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: children.length,
        separatorBuilder:
            (context, index) => Divider(
              height: 1,
              indent: 55,
              endIndent: 20,
              color: isDark ? Colors.white10 : Colors.grey[100],
            ),
        itemBuilder: (context, index) => children[index],
      ),
    );
  }

  Widget _settingsTile(
    IconData icon,
    String title,
    VoidCallback onTap,
    Color primaryColor,
  ) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildLogoutButton(bool isDark) {
    const logoutColor = Color(0xFFFF3D71);
    return InkWell(
      onTap: () => _confirmLogout(),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: logoutColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: logoutColor, size: 20),
            SizedBox(width: 10),
            Text(
              "Logout Account",
              style: TextStyle(
                color: logoutColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _confirmLogout() {
    Get.defaultDialog(
      title: "Logout",
      middleText: "Are you sure you want to exit?",
      textConfirm: "Yes, Logout",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFFF3D71),
      onConfirm: () {
        GetStorage().erase();
        Get.offAll(() => LoginPage());
      },
    );
  }
}
