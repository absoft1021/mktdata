import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mktdata/components/pin_bottom_sheet.dart';
import 'package:mktdata/controllers/airtime_controller.dart';

class AirtimePage extends StatefulWidget {
  const AirtimePage({super.key});

  @override
  State<AirtimePage> createState() => _AirtimePageState();
}

class _AirtimePageState extends State<AirtimePage> {
  final c = Get.put(AirtimeController());
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  String selectedNet = "";

  // Trigger the reusable PIN sheet
  void _handleProceed() {
    if (_phoneController.text.length < 10 || _amountController.text.isEmpty) {
      Get.snackbar(
        "Invalid Input",
        "Please check phone number and amount",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    PinSheet.show(
      title: "Confirm Airtime",
      subtitle:
          "Sending ₦${_amountController.text} to ${_phoneController.text}",
      onConfirm: (enteredPin) {
        // This runs once the 4th digit is tapped in the sheet
        c.buyAirtime(
          amount: _amountController.text,
          phone: _phoneController.text,
          pin: enteredPin,
          network: selectedNet,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E17) : Colors.white,
      appBar: AppBar(
        title: const Text(
          "Buy Airtime",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label("SELECT NETWORK", isDark),
            _buildNetworkGrid(isDark),
            const SizedBox(height: 30),
            _label("PHONE NUMBER", isDark),
            _buildInput(
              controller: _phoneController,
              hint: "Enter Phone Number",
              icon: Icons.phone_android,
              isDark: isDark,
              type: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            _label("AMOUNT", isDark),
            _buildInput(
              controller: _amountController,
              hint: "0.00",
              icon: Icons.account_balance_wallet_outlined,
              isDark: isDark,
              type: TextInputType.number,
              prefix: "₦ ",
            ),
            const SizedBox(height: 40),
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF014492),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: c.isLoading.value ? null : _handleProceed,
                  child:
                      c.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            "PROCEED",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Network Selection Logic with Obx ---
  Widget _buildNetworkGrid(bool isDark) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:
            c.networks.map((net) {
              bool isSelected = c.selectedNetwork.value == net['title'];

              return GestureDetector(
                onTap: () {
                  c.selectedNetwork.value = net['title']!;
                  selectedNet = net['title'].toString().toLowerCase();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? const Color(0xFF014492).withValues(alpha: 0.1)
                            : (isDark ? Colors.white10 : Colors.grey[100]),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isSelected
                              ? const Color(0xFF014492)
                              : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(net['logo']!, fit: BoxFit.contain),
                        ),
                      ),
                      // const SizedBox(height: 8),
                      // Text(
                      //   net['title']!,
                      //   style: TextStyle(
                      //     fontSize: 12,
                      //     color: isDark ? Colors.white : Colors.black,
                      //     fontWeight:
                      //         isSelected ? FontWeight.bold : FontWeight.normal,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  // --- Input & Label Helpers ---
  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    required TextInputType type,
    String? prefix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        keyboardType: type,
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF014492)),
          prefixText: prefix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
        ),
      ),
    );
  }

  Widget _label(String text, bool isDark) => Padding(
    padding: const EdgeInsets.only(bottom: 10, left: 4),
    child: Text(
      text,
      style: TextStyle(
        color: isDark ? Colors.white54 : Colors.black54,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
