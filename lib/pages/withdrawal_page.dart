import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mktdata/components/pin_bottom_sheet.dart';
import 'package:mktdata/controllers/withdrawal_controller.dart';

class WithdrawalPage extends StatefulWidget {
  const WithdrawalPage({super.key});

  @override
  State<WithdrawalPage> createState() => _WithdrawalPageState();
}

class _WithdrawalPageState extends State<WithdrawalPage> {
  final c = Get.put(WithdrawalController());
  final _amountController = TextEditingController();
  final _narrationController = TextEditingController();
  final _accountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load balance from arguments passed during navigation
    c.walletBalance.value = double.tryParse(Get.arguments.toString()) ?? 0.0;

    // Listen for account number changes to trigger auto-verify
    _accountController.addListener(() {
      if (_accountController.text.length == 10) {
        c.verifyAccount(_accountController.text);
      } else if (_accountController.text.length < 10) {
        c.verifiedName.value = "";
      }
    });
  }

  void _handleWithdrawal() {
    if (c.selectedBankCode.isEmpty) {
      Get.snackbar(
        "Error",
        "Please select a bank",
        backgroundColor: Colors.orange,
      );
      return;
    }
    if (c.verifiedName.value.isEmpty ||
        c.verifiedName.value.contains("not found")) {
      Get.snackbar(
        "Error",
        "Valid account name required",
        backgroundColor: Colors.orange,
      );
      return;
    }

    PinSheet.show(
      title: "Confirm Withdrawal",
      subtitle:
          "Withdrawing ₦${_amountController.text} to ${c.verifiedName.value}",
      onConfirm: (enteredPin) {
        c.requestWithdrawal(
          amount: _amountController.text,
          narration: _narrationController.text,
          pin: enteredPin,
          accountNumber: _accountController.text,
        );
      },
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _narrationController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E17) : Colors.white,
      appBar: AppBar(
        title: const Text(
          "Withdraw Funds",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            _buildBalanceCard(),
            const SizedBox(height: 30),

            _label("SELECT BANK"),
            _buildBankDropdown(isDark),
            const SizedBox(height: 20),

            _label("ACCOUNT NUMBER"),
            _buildInput(
              controller: _accountController,
              hint: "0000000000",
              icon: Icons.account_balance_outlined,
              isDark: isDark,
              isNumber: true,
            ),

            // Verification status display
            Obx(
              () => Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child:
                    c.isVerifying.value
                        ? const SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : Text(
                          c.verifiedName.value,
                          style: TextStyle(
                            color:
                                c.verifiedName.value.contains("failed") ||
                                        c.verifiedName.value.contains(
                                          "not found",
                                        )
                                    ? Colors.red
                                    : Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 15),

            _label("AMOUNT"),
            _buildInput(
              controller: _amountController,
              hint: "0.00",
              icon: Icons.payments_outlined,
              isDark: isDark,
              isNumber: true,
              suffix: TextButton(
                onPressed:
                    () =>
                        _amountController.text =
                            c.walletBalance.value.toString(),
                child: const Text(
                  "MAX",
                  style: TextStyle(
                    color: Color(0xFF014492),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            _label("NARRATION"),
            _buildInput(
              controller: _narrationController,
              hint: "e.g Savings for business",
              icon: Icons.notes_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 40),

            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  // --- UI Helpers ---

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF014492), Color(0xFF1565C0)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Available Balance",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 5),
          Obx(
            () => Text(
              "₦${c.walletBalance.value.toStringAsFixed(2)}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankDropdown(bool isDark) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            hint: const Text("Choose Destination Bank"),
            value:
                c.selectedBankCode.value.isEmpty
                    ? null
                    : c.selectedBankCode.value,
            dropdownColor: isDark ? const Color(0xFF1A1F2E) : Colors.white,
            items:
                c.banks.map((bank) {
                  return DropdownMenuItem<String>(
                    value: bank['bank_code'].toString(),
                    child: Text(
                      bank['bank_name'],
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
            onChanged: (val) {
              c.selectedBankCode.value = val!;
              if (_accountController.text.length == 10)
                c.verifyAccount(_accountController.text);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool isNumber = false,
    Widget? suffix,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF014492), size: 20),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(
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
          onPressed: c.isLoading.value ? null : _handleWithdrawal,
          child:
              c.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                    "WITHDRAW NOW",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 10, left: 4),
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
