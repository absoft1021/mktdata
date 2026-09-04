import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mktdata/controllers/register_controller.dart';
import 'package:mktdata/utils/app_colors.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _registerController = Get.put(RegisterController());

  // Text Controllers
  final _fnameController = TextEditingController();
  final _lnameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _pinController = TextEditingController();
  final _refererController = TextEditingController();

  bool _isLoading = false;
  final bool _isObscured = true;

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final result = await _registerController.register(
        fname: _fnameController.text.trim(),
        lname: _lnameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
        transPin: _pinController.text.trim(),
        referer: _refererController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Account Created Successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Go back to Login
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField(_fnameController, "First Name", isDark, Icons.person),
              _buildField(
                _lnameController,
                "Last Name",
                isDark,
                Icons.person_outline,
              ),
              _buildField(
                _usernameController,
                "Username",
                isDark,
                Icons.person,
              ),
              _buildField(
                _emailController,
                "Email Address",
                isDark,
                Icons.email,
                isEmail: true,
              ),
              _buildField(
                _phoneController,
                "Phone Number",
                isDark,
                Icons.phone,
                isPhone: true,
              ),
              _buildField(
                _passwordController,
                "Password",
                isDark,
                Icons.lock,
                isPassword: true,
              ),

              const SizedBox(height: 16),

              _buildField(
                _pinController,
                "Transaction PIN (4 digits)",
                isDark,
                Icons.dialpad,
                isPin: true,
              ),
              _buildField(
                _refererController,
                "Referrer (Optional)",
                isDark,
                Icons.group,
                isRequired: false,
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            "REGISTER",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),

              const SizedBox(height: 20),

              // --- LOGIN LINK SECTION ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentPrimary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    bool isDark,
    IconData icon, {
    bool isEmail = false,
    bool isPhone = false,
    bool isPin = false,
    bool isRequired = true,
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType:
            isEmail
                ? TextInputType.emailAddress
                : (isPhone || isPin
                    ? TextInputType.number
                    : TextInputType.text),
        maxLength: isPin ? 4 : null,
        decoration: _inputDecoration(icon, label, isDark),
        validator: (val) {
          if (isRequired && (val == null || val.isEmpty)) {
            return "$label is required";
          }
          if (isEmail && !(val?.contains('@') ?? false)) return "Enter valid email";
          if (isPin && (val?.length ?? 0) != 4) return "PIN must be 4 digits";
          return null;
        },
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
