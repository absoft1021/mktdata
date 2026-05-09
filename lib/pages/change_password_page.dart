import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mktdata/controllers/change_password_controller.dart';

class ChangePasswordPage extends StatelessWidget {
  ChangePasswordPage({super.key});

  final c = Get.put(ChangePasswordController());
  final currentPassController = TextEditingController();
  final newPassController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF667EEA);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Change Password",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Update your login credentials to keep your account secure.",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),

            _label("CURRENT PASSWORD"),
            _buildPasswordField(
              controller: currentPassController,
              hint: "Enter current password",
              isDark: isDark,
              obscureObs: c.obscureCurrent,
            ),

            const SizedBox(height: 24),

            _label("NEW PASSWORD"),
            _buildPasswordField(
              controller: newPassController,
              hint: "Enter new password",
              isDark: isDark,
              obscureObs: c.obscureNew,
            ),

            const SizedBox(height: 40),

            _buildSubmitButton(primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    required RxBool obscureObs,
  }) {
    return Obx(
      () => TextField(
        controller: controller,
        obscureText: obscureObs.value,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: isDark ? Colors.white10 : Colors.grey[100],
          prefixIcon: const Icon(Icons.lock_outline, size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              obscureObs.value
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 20,
            ),
            onPressed: () => obscureObs.toggle(),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(Color primary) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          onPressed:
              c.isSubmitting.value
                  ? null
                  : () => c.updatePassword(
                    currentPassword: currentPassController.text,
                    newPassword: newPassController.text,
                  ),
          child:
              c.isSubmitting.value
                  ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : const Text(
                    "UPDATE PASSWORD",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _label(String t) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        t,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}
