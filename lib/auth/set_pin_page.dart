import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mktdata/main_page.dart';
import 'package:mktdata/utils/app_colors.dart';

class SetPinPage extends StatefulWidget {
  const SetPinPage({super.key});

  @override
  State<SetPinPage> createState() => _SetPinPageState();
}

class _SetPinPageState extends State<SetPinPage> {
  final box = GetStorage();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  bool _obscurePin = true;
  bool _obscureConfirm = true;

  void _verifyAndSave() {
    if (_formKey.currentState!.validate()) {
      // SUCCESS: Save to Storage
      box.write('pin', _confirmPinController.text);

      Get.snackbar(
        "PIN Secured",
        "Your transaction PIN has been set.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(15),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );

      Future.delayed(const Duration(seconds: 1), () {
        Get.offAll(() => const MainPage());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.accentPrimary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_reset_rounded,
                        size: 40,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Transaction PIN",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Create a 4-digit PIN for secure transactions",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // --- New PIN Field ---
              _label("NEW PIN"),
              TextFormField(
                controller: _pinController,
                obscureText: _obscurePin,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  letterSpacing: 20,
                  fontWeight: FontWeight.bold,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _inputDecoration(
                  "0 0 0 0",
                  isDark,
                  _obscurePin,
                  () => setState(() => _obscurePin = !_obscurePin),
                ),
                validator: (val) {
                  if (val == null || val.length < 4) return "Enter 4 digits";
                  return null;
                },
              ),

              const SizedBox(height: 25),

              // --- Confirm PIN Field ---
              _label("CONFIRM PIN"),
              TextFormField(
                controller: _confirmPinController,
                obscureText: _obscureConfirm,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  letterSpacing: 20,
                  fontWeight: FontWeight.bold,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _inputDecoration(
                  "0 0 0 0",
                  isDark,
                  _obscureConfirm,
                  () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                validator: (val) {
                  if (val != _pinController.text) return "PINs do not match";
                  return null;
                },
              ),

              const SizedBox(height: 50),

              // --- Submit Button ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _verifyAndSave,
                  child: const Text(
                    "SAVE TRANSACTION PIN",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hint,
    bool isDark,
    bool obscured,
    VoidCallback toggle,
  ) {
    return InputDecoration(
      hintText: hint,
      counterText: "",
      filled: true,
      fillColor: isDark ? AppColors.cardDark : Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      suffixIcon: IconButton(
        icon: Icon(
          obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
        ),
        onPressed: toggle,
        color: Colors.grey,
      ),
    );
  }
}
