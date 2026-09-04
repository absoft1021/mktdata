import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mktdata/controllers/login_controller.dart';
import 'package:mktdata/utils/app_colors.dart';

import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final LoginController c = Get.put(LoginController());
  final box = GetStorage();

  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    _checkSessionExpired();
  }

  void _checkSessionExpired() {
    final args = Get.arguments;
    if (args != null && args['sessionExpired'] == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Session Expired',
          'Your session has expired. Please login again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          margin: const EdgeInsets.all(15),
          duration: const Duration(seconds: 4),
        );
      });
    }
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      c.login(_emailController.text.trim(), _passwordController.text.trim());
    }
  }

  void _showForgotPassword() {
    // Logic for forgot password dialog or page
    Get.defaultDialog(
      title: "Reset Password",
      middleText: "Enter your email to receive a reset link.",
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextField(
          decoration: InputDecoration(
            hintText: "Email address",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
      textConfirm: "Send Link",
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        Get.snackbar("Sent", "Check your inbox for instructions.");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header Section ---
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Image.asset(
                        'assets/app_icon.png',
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  // const SizedBox(height: 10),
                  Text(
                    "Login Account",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const Text(
                    "Enter your credentials to continue",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 40),

                  // --- Email Field ---
                  _inputLabel("Username", isDark),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: _inputDecoration(
                      Icons.email_outlined,
                      "Enter username",
                      isDark,
                    ),
                    validator:
                        (value) =>
                            (value == null) ? "Enter a valid username" : null,
                  ),
                  const SizedBox(height: 20),

                  // --- Password Field ---
                  _inputLabel("Password", isDark),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _isObscured,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: _inputDecoration(
                      Icons.lock_outline,
                      "Enter password",
                      isDark,
                      suffix: IconButton(
                        icon: Icon(
                          _isObscured
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                          color: Colors.grey,
                        ),
                        onPressed:
                            () => setState(() => _isObscured = !_isObscured),
                      ),
                    ),
                    validator:
                        (value) =>
                            (value == null || value.length < 6)
                                ? "Password too short"
                                : null,
                  ),

                  // --- Forgot Password ---
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed:
                          () => c.launchURL(
                            'https://mktdata.com.ng/forgot_pass.html',
                          ),
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: AppColors.accentPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- Login Button ---
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: c.isLoading.value ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child:
                            c.isLoading.value
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  "SIGN IN",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- Footer ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "New to mktdata?",
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.to(() => const RegisterPage()),
                        child: const Text(
                          "Create Account",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentPrimary,
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
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _inputLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    IconData icon,
    String hint,
    bool isDark, {
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.accentPrimary, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor:
          isDark ? AppColors.cardDark : Colors.grey.withValues(alpha: 0.05),
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? Colors.white10 : Colors.transparent,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.accentPrimary,
          width: 1.5,
        ),
      ),
    );
  }
}
