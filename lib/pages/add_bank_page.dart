import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mktdata/controllers/add_bank_controller.dart';

class AddBankPage extends StatefulWidget {
  const AddBankPage({super.key});

  @override
  State<AddBankPage> createState() => _AddBankPageState();
}

class _AddBankPageState extends State<AddBankPage> {
  final c = Get.put(AddBankController());
  final acctNumController = TextEditingController();

  @override
  void initState() {
    super.initState();
    acctNumController.addListener(() {
      if (acctNumController.text.length == 10) {
        c.verifyAccount(acctNumController.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF667EEA);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Link Bank Account",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIllustration(primaryColor),
            const SizedBox(height: 30),

            _label("SELECT BANK"),
            _buildBankDropdown(isDark),

            const SizedBox(height: 20),
            _label("ACCOUNT NUMBER"),
            _buildTextField(
              controller: acctNumController,
              hint: "e.g. 0123456789",
              icon: Icons.numbers,
              isDark: isDark,
              type: TextInputType.number,
            ),

            // Account Name Preview
            Obx(
              () => Padding(
                padding: const EdgeInsets.only(top: 10, left: 4),
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
                                c.verifiedName.value.contains("not found")
                                    ? Colors.red
                                    : Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
              ),
            ),

            const SizedBox(height: 40),
            _buildSubmitButton(primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration(Color primary) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.account_balance_rounded, size: 60, color: primary),
      ),
    );
  }

  Widget _buildBankDropdown(bool isDark) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            hint: const Text("Choose your bank"),
            value:
                c.selectedBankCode.value.isEmpty
                    ? null
                    : c.selectedBankCode.value,
            items:
                c.banks
                    .map(
                      (bank) => DropdownMenuItem(
                        value: bank['bank_code'].toString(),
                        child: Text(bank['bank_name']),
                      ),
                    )
                    .toList(),
            onChanged: (val) {
              final bank = c.banks.firstWhere(
                (b) => b['bank_code'].toString() == val,
              );
              c.selectedBankCode.value = val!;
              c.selectedBankName.value = bank['bank_name'];
              if (acctNumController.text.length == 10)
                c.verifyAccount(acctNumController.text);
            },
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
    required TextInputType type,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 20),
        hintText: hint,
        filled: true,
        fillColor: isDark ? Colors.white10 : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
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
                  : () => c.submitBank(acctNum: acctNumController.text),
          child:
              c.isSubmitting.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                    "SAVE BANK ACCOUNT",
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
