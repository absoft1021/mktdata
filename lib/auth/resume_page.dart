import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:mktdata/main_page.dart';
import 'package:mktdata/utils/app_colors.dart';
import 'package:mktdata/utils/local_auth_api.dart';
import 'package:mktdata/auth/login_page.dart';

class ResumePage extends StatefulWidget {
  const ResumePage({super.key});

  @override
  State<ResumePage> createState() => _ResumePageState();
}

class _ResumePageState extends State<ResumePage> {
  final box = GetStorage();
  final LocalAuthentication auth = LocalAuthentication();
  String _inputPin = "";
  final int _pinLength = 4;
  bool _isLoggingIn = false;

  late String username;
  late String savedPin;

  static const String baseUrl = 'https://mktdata.com.ng/user/api/';

  @override
  void initState() {
    super.initState();
    username = box.read("profile")?['username'] ?? "User";
    savedPin = box.read('pin') ?? "";

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _authenticateBiometric(),
    );
  }

  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is String) {
      if (raw.trim().isEmpty) {
        throw FormatException('Empty string instead of JSON object');
      }
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      throw FormatException('Expected a JSON object but got ${decoded.runtimeType}');
    }
    throw FormatException('Expected a JSON object but got ${raw.runtimeType}');
  }

  Future<bool> _silentLogin() async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}loginPHP.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': box.read("username") ?? '',
          'password': box.read("password") ?? '',
          'submit': 'true',
        },
      );

      if (response.statusCode == 200) {
        final data = _asMap(response.body);
        if (data['success'] == 1 || data['success'] == "1") {
          final profileRaw = data['profile'];
          if (profileRaw != null && profileRaw != '') {
            final profile = _asMap(profileRaw);
            await box.write("profile", profile);
            await box.write("telegram", profile['telegram_link'] ?? '');
            await box.write("contact", profile['contact_phone'] ?? '');
            await box.write("token", data['token'] ?? '');
          }
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _authenticateBiometric() async {
    final isAuthenticated = await LocalAuthApi.authenticate();
    if (isAuthenticated) {
      await _unlockApp();
    }
  }

  void _onKeyTap(String value) {
    if (_isLoggingIn) return;
    if (_inputPin.length < _pinLength) {
      setState(() => _inputPin += value);
    }
    if (_inputPin.length == _pinLength) {
      _verifyPin();
    }
  }

  void _onBackspace() {
    if (_inputPin.isNotEmpty) {
      setState(() => _inputPin = _inputPin.substring(0, _inputPin.length - 1));
    }
  }

  void _verifyPin() {
    if (_inputPin == savedPin) {
      _unlockApp();
    } else {
      Get.snackbar(
        "Wrong PIN",
        "The PIN you entered is incorrect",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      setState(() => _inputPin = "");
    }
  }

  Future<void> _unlockApp() async {
    if (_isLoggingIn) return;
    setState(() => _isLoggingIn = true);

    final success = await _silentLogin();

    setState(() => _isLoggingIn = false);

    if (success) {
      Get.offAll(() => const MainPage());
    } else {
      Get.snackbar(
        "Session Expired",
        "Please login again",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      Get.offAll(() => LoginPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Center(
              child: CircleAvatar(
                radius: 35,
                backgroundColor: AppColors.accentPrimary.withValues(alpha: 0.1),
                child: const Icon(
                  Icons.person_outline,
                  size: 40,
                  color: AppColors.accentPrimary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Welcome back,",
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            Text(
              username,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 40),

            // PIN Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pinLength, (index) {
                bool isFilled = index < _inputPin.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 16,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled
                        ? AppColors.accentPrimary
                        : Colors.transparent,
                    border: Border.all(
                      color: isFilled
                          ? AppColors.accentPrimary
                          : Colors.grey.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                );
              }),
            ),

            if (_isLoggingIn) ...[
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
            ],

            const Spacer(),

            // Number Pad
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                children: [
                  _buildRow(["1", "2", "3"], isDark),
                  _buildRow(["4", "5", "6"], isDark),
                  _buildRow(["7", "8", "9"], isDark),
                  _buildBottomRow(isDark),
                ],
              ),
            ),
            const SizedBox(height: 10),

            TextButton(
              onPressed: () {
                Get.offAll(() => LoginPage());
              },
              child: const Text(
                "Not you? Switch Account",
                style: TextStyle(color: AppColors.accentPrimary),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<String> labels, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: labels.map((label) => _numberButton(label, isDark)).toList(),
      ),
    );
  }

  Widget _buildBottomRow(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _iconButton(Icons.fingerprint, isDark, _authenticateBiometric),
        _numberButton("0", isDark),
        _iconButton(Icons.backspace_outlined, isDark, _onBackspace),
      ],
    );
  }

  Widget _numberButton(String text, bool isDark) {
    return InkWell(
      onTap: () => _onKeyTap(text),
      borderRadius: BorderRadius.circular(50),
      child: Container(
        height: 75,
        width: 75,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark
              ? AppColors.cardDark
              : Colors.grey.withValues(alpha: 0.1),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, bool isDark, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: SizedBox(
        height: 75,
        width: 75,
        child: Center(
          child: Icon(
            icon,
            size: 28,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}