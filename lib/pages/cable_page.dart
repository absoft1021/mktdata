import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mktdata/controllers/cable_controller.dart';
import 'package:mktdata/components/pin_bottom_sheet.dart';

class CablePage extends StatefulWidget {
  CablePage({super.key});

  @override
  State<CablePage> createState() => _CablePageState();
}

class _CablePageState extends State<CablePage> {
  final c = Get.put(CableController());
  final meterController = TextEditingController();
  final amountController = TextEditingController();

  @override
  void dispose() {
    meterController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF667EEA);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E17) : Colors.white,
      appBar: AppBar(
        title: const Text(
          "Cable TV",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label("SELECT PROVIDER"),
            _buildProviderDropdown(isDark),
            const SizedBox(height: 25),

            _label("SMARTCARD / IUC NUMBER"),
            _buildTextField(
              controller: meterController,
              hint: "Enter SmartCard Number",
              icon: Icons.vignette_outlined,
              isDark: isDark,
              isNumber: true,
              suffix: _verifyButton(primaryColor),
            ),

            // This section only appears after successful verification
            Obx(
              () => AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child:
                    c.isVerified.value
                        ? Column(
                          key: const ValueKey(1),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 25),
                            _buildCustomerBox(primaryColor),
                            const SizedBox(height: 25),
                            _label("AMOUNT"),
                            _buildTextField(
                              controller: amountController,
                              hint: "Enter Amount",
                              icon: Icons.account_balance_wallet_outlined,
                              isDark: isDark,
                              isNumber: true,
                            ),
                            const SizedBox(height: 40),
                            _buildPayButton(primaryColor),
                          ],
                        )
                        : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderDropdown(bool isDark) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            hint: const Text("Select Package (e.g GOTV)"),
            dropdownColor: isDark ? const Color(0xFF1A1F2E) : Colors.white,
            // Fixed: Ensure value matches one of the items exactly or is null
            value:
                c.selectedProviderName.value.isEmpty
                    ? null
                    : c.selectedProviderName.value,
            items:
                c.providers.map((p) {
                  return DropdownMenuItem<String>(
                    value: p['name'].toString(),
                    child: Text(
                      p['name'].toString(),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
            onChanged: (val) {
              c.selectedProviderName.value = val!;
              c.isVerified.value = false; // Reset verification on change
            },
          ),
        ),
      ),
    );
  }

  Widget _verifyButton(Color primary) {
    return Obx(
      () => TextButton(
        onPressed:
            c.isVerifying.value
                ? null
                : () => c.verifyMeter(meterController.text),
        child:
            c.isVerifying.value
                ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : Text(
                  "VERIFY",
                  style: TextStyle(color: primary, fontWeight: FontWeight.bold),
                ),
      ),
    );
  }

  Widget _buildCustomerBox(Color primary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.person_pin, color: primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "CUSTOMER NAME",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  c.customerName.value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
        ],
      ),
    );
  }

  Widget _buildPayButton(Color primary) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        onPressed: () {
          PinSheet.show(
            title: "Cable Payment",
            subtitle:
                "Pay ₦${amountController.text} for ${c.selectedProviderName.value}",
            onConfirm: (pin) {
              // Call your purchase logic here
            },
          );
        },
        child: const Text(
          "PROCEED TO PAYMENT",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool isNumber = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF667EEA)),
        suffixIcon: suffix,
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
        filled: true,
        fillColor: isDark ? Colors.white10 : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }

  Widget _label(String t) => Padding(
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
