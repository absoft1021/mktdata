import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mktdata/components/pin_bottom_sheet.dart';
import 'package:mktdata/controllers/sell_crypto_controller.dart';
import 'package:mktdata/utils/app_colors.dart';

enum PayoutMethod { fromWallet, fromExchanger }

class SellCryptoPage extends StatefulWidget {
  const SellCryptoPage({super.key});

  @override
  State<SellCryptoPage> createState() => _SellCryptoPageState();
}

class _SellCryptoPageState extends State<SellCryptoPage> {
  final c = Get.put(SellCryptoController());
  final TextEditingController _amountController = TextEditingController();

  // Using Rx for local state to keep everything reactive within Obx
  final Rx<PayoutMethod> selectedPayoutMethod = PayoutMethod.fromWallet.obs;
  final RxDouble payout = 0.0.obs;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);

    // Auto-validate/update when controller variables change
    ever(c.imageFile, (_) => setState(() {}));
    ever(c.selectedNetwork, (_) => setState(() {}));
    ever(c.selectedExchanger, (_) => setState(() {}));
  }

  void _onAmountChanged() {
    _calculatePayout();
  }

  void _calculatePayout() {
    if (c.selectedCoin.isEmpty) return;
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    double rate =
        double.tryParse(c.selectedCoin['rate']?.toString() ?? '0') ?? 0.0;
    payout.value = amount * rate;
  }

  // Logic to determine if button should be enabled
  bool get _isFormValid {
    bool isWallet = selectedPayoutMethod.value == PayoutMethod.fromWallet;
    bool hasMethodSelected =
        isWallet
            ? c.selectedNetwork.isNotEmpty
            : c.selectedExchanger.isNotEmpty;

    return _amountController.text.isNotEmpty &&
        hasMethodSelected &&
        c.imageFile.value != null &&
        (double.tryParse(_amountController.text) ?? 0) > 0;
  }

  void _handleProceed() {
    PinSheet.show(
      title: "Confirm Sale",
      subtitle:
          "Selling ${_amountController.text} ${c.selectedCoin['abbreviation']} for ₦${payout.value.toStringAsFixed(2)}",
      onConfirm: (pin) {
        c.processSale(
          amount: _amountController.text,
          isWallet: selectedPayoutMethod.value == PayoutMethod.fromWallet,
        );
      },
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        title: Text(
          'Sell Crypto',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: Obx(() {
        if (c.isLoading.value && c.coins.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accentPrimary),
          );
        }
        if (c.coins.isEmpty) {
          return const Center(child: Text("No assets available"));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _label("PAYOUT METHOD", isDark),
              _buildPayoutToggle(isDark),
              const SizedBox(height: 12),
              _buildCompactInput(isDark),
              const SizedBox(height: 12),
              _buildPayoutBanner(),
              const SizedBox(height: 12),
              _label("NETWORK & ADDRESS", isDark),
              _buildDynamicNetworkCard(isDark),
              const SizedBox(height: 12),
              _label("PAYMENT PROOF", isDark),
              _buildCompactUpload(isDark),
              const SizedBox(height: 10),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() => _buildBottomButton(isDark)),
    );
  }

  Widget _buildBottomButton(bool isDark) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _isFormValid ? 1.0 : 0.5,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        margin: EdgeInsets.only(bottom: 30),
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgDark : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentPrimary,
              disabledBackgroundColor: AppColors.accentPrimary.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed:
                (_isFormValid && !c.isSubmitting.value) ? _handleProceed : null,
            child:
                c.isSubmitting.value
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : const Text(
                      "PROCEED",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
          ),
        ),
      ),
    );
  }

  // --- UI HELPERS (Extracted for brevity) ---

  Widget _label(String text, bool isDark) => Padding(
    padding: const EdgeInsets.only(bottom: 10, left: 4),
    child: Text(
      text,
      style: TextStyle(
        color: isDark ? Colors.white54 : Colors.black54,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    ),
  );

  Widget _buildCompactInput(bool isDark) {
    return InkWell(
      onTap: _showCoinPicker,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Text(
              c.selectedCoin['abbreviation'] ?? 'Select',
              style: const TextStyle(
                color: AppColors.accentPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: AppColors.accentPrimary),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _amountController,
                textAlign: TextAlign.right,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
                decoration: const InputDecoration(
                  hintText: '0.00',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayoutBanner() {
    return Obx(
      () => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.accentPrimary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Receive:",
              style: TextStyle(color: AppColors.accentPrimary, fontSize: 13),
            ),
            Text(
              "₦${payout.value.toStringAsFixed(2)}",
              style: const TextStyle(
                color: AppColors.accentPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayoutToggle(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _toggleBtn(PayoutMethod.fromWallet, "From Wallet", isDark),
          _toggleBtn(PayoutMethod.fromExchanger, "From Exchange", isDark),
        ],
      ),
    );
  }

  Widget _toggleBtn(PayoutMethod method, String text, bool isDark) {
    return Obx(() {
      bool isSel = selectedPayoutMethod.value == method;
      return Expanded(
        child: GestureDetector(
          onTap: () => selectedPayoutMethod.value = method,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSel ? AppColors.accentPrimary : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  color:
                      isSel
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black54),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDynamicNetworkCard(bool isDark) {
    return Obx(() {
      bool isWallet = selectedPayoutMethod.value == PayoutMethod.fromWallet;
      final current = isWallet ? c.selectedNetwork : c.selectedExchanger;
      final String addressValue =
          isWallet
              ? (current['wallet_address'] ?? "Select Network")
              : (current['uid'] ?? "Select Exchange");

      return InkWell(
        onTap: _showSubPicker,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.accentPrimary.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isWallet ? "Network" : "Exchange",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  Row(
                    children: [
                      Text(
                        current['name'] ?? "Choose...",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Icon(Icons.arrow_drop_down, size: 20),
                    ],
                  ),
                ],
              ),
              const Divider(color: Colors.white10, height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      addressValue,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (current.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: addressValue));
                        Get.snackbar(
                          "Copied",
                          "Address copied to clipboard",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      },
                      icon: const Icon(
                        Icons.copy,
                        size: 18,
                        color: AppColors.accentPrimary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCompactUpload(bool isDark) {
    return Obx(
      () => InkWell(
        onTap: () => c.pickImage(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isDark ? AppColors.cardDark : Colors.grey.withOpacity(0.05),
            border: Border.all(
              color:
                  c.imageFile.value != null ? Colors.green : Colors.transparent,
            ),
          ),
          child:
              c.imageFile.value != null
                  ? Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          c.imageFile.value!,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Change Receipt",
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      ),
                    ],
                  )
                  : const Column(
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        color: AppColors.accentPrimary,
                      ),
                      SizedBox(height: 8),
                      Text("Upload Payment Proof"),
                    ],
                  ),
        ),
      ),
    );
  }

  void _showCoinPicker() {
    Get.bottomSheet(
      _bottomSheetWrapper(
        title: "Select Cryptocurrency",
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: c.coins.length,
          itemBuilder: (context, index) {
            final coin = c.coins[index];
            return ListTile(
              leading: Image.network(
                "https://mktdata.ng${coin['image']}",
                width: 30,
                errorBuilder: (c, e, s) => const Icon(Icons.token),
              ),
              title: Text(
                coin['name'] ?? "",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Text(
                "₦${coin['rate']}",
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                c.updateSelectedCoin(coin);
                _calculatePayout();
                Get.back();
              },
            );
          },
        ),
      ),
    );
  }

  void _showSubPicker() {
    if (c.selectedCoin.isEmpty) {
      Get.snackbar("Notice", "Please select a coin first");
      return;
    }

    try {
      Map<String, dynamic> netData = jsonDecode(
        c.selectedCoin['networks'] ?? "{}",
      );
      bool isWallet = selectedPayoutMethod.value == PayoutMethod.fromWallet;
      List items =
          isWallet ? (netData['wallets'] ?? []) : (netData['exchangers'] ?? []);

      Get.bottomSheet(
        _bottomSheetWrapper(
          title: isWallet ? "Select Network" : "Select Exchange",
          child:
              items.isEmpty
                  ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("No options available for this coin"),
                  )
                  : ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        title: Text(
                          item['name'] ?? "",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          isWallet
                              ? (item['wallet_address'] ?? "")
                              : "UID: ${item['uid']}",
                        ),
                        onTap: () {
                          if (isWallet) {
                            c.selectedNetwork.value = Map<String, dynamic>.from(
                              item,
                            );
                          } else {
                            c
                                .selectedExchanger
                                .value = Map<String, dynamic>.from(item);
                          }
                          Get.back();
                        },
                      );
                    },
                  ),
        ),
      );
    } catch (e) {
      Get.snackbar("Error", "Could not load networks");
    }
  }

  Widget _bottomSheetWrapper({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 15),
          Flexible(child: child),
        ],
      ),
    );
  }
}
