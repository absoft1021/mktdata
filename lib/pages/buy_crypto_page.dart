import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mktdata/components/pin_bottom_sheet.dart';
import 'package:mktdata/controllers/buy_crypto_controller.dart';

class BuyCryptoPage extends StatefulWidget {
  const BuyCryptoPage({super.key});

  @override
  State<BuyCryptoPage> createState() => _BuyCryptoPageState();
}

class _BuyCryptoPageState extends State<BuyCryptoPage> {
  final BuyCryptoController c = Get.put(BuyCryptoController());
  final TextEditingController _walletController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String _selectedCurrency = 'NGN';
  late Map asset;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    asset = Get.arguments;
  }

  void _onAmountChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      c.getCoinPrice(value, _selectedCurrency, asset['price_symbol']);
    });
  }

  @override
  void dispose() {
    _walletController.dispose();
    _amountController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Buy ${asset['name']}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildCryptoInfoCard(isDark),
            const SizedBox(height: 24),

            _buildInputField(
              label: 'Wallet Address',
              icon: Icons.account_balance_wallet_outlined,
              isDark: isDark,
              child: TextField(
                controller: _walletController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: const InputDecoration(
                  hintText: 'Enter destination address',
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            _buildInputField(
              label: 'I want to spend',
              icon: Icons.payments_outlined,
              isDark: isDark,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      onChanged: _onAmountChanged,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        hintText: '0.00',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  _buildCurrencySelector(isDark),
                ],
              ),
            ),

            // --- REACTIVE CALCULATION BREAKDOWN ---
            Obx(() {
              if (c.isLoading.value) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: LinearProgressIndicator(minHeight: 2),
                );
              }
              if (c.calcResult.isNotEmpty) {
                return _buildPriceBreakdown(isDark);
              }
              return const SizedBox(height: 30);
            }),

            _buildQuickAmounts(isDark),
            const SizedBox(height: 40),
            _buildPurchaseButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBreakdown(bool isDark) {
    final res = c.calcResult;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.blue.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.blue.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          _breakdownRow(
            "You receive",
            "${res['coin_value']} ${asset['display_symbol']}",
            isBold: true,
            color: const Color(0xFF00E096),
          ),
          const Divider(height: 24),
          _breakdownRow("Service Fee", "₦${res['charges']}", isDark: isDark),
          const SizedBox(height: 12),
          _breakdownRow("USDT Value", "\$${res['usdt_price']}", isDark: isDark),
          const SizedBox(height: 12),
          _breakdownRow(
            "Market Rate",
            "\$${res['live_market_price']}",
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _breakdownRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
    bool? isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            fontSize: isBold ? 16 : 13,
            color: color ?? (isDark == true ? Colors.white : Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildCryptoInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow:
            isDark
                ? []
                : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                  ),
                ],
      ),
      child: Row(
        children: [
          Image.network(
            "https://mktdata.ng${asset['image']}",
            width: 40,
            height: 40,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                asset['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                asset['display_symbol'],
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '\$${asset['price_usd'].toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required Widget child,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color:
                isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.grey.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildCurrencySelector(bool isDark) {
    return PopupMenuButton<String>(
      onSelected: (v) {
        setState(() => _selectedCurrency = v);
        c.getCoinPrice(_amountController.text, v, asset['price_symbol']);
      },
      itemBuilder:
          (context) =>
              [
                'NGN',
                'USDT',
              ].map((c) => PopupMenuItem(value: c, child: Text(c))).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(
              _selectedCurrency,
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAmounts(bool isDark) {
    final amounts = {
      '10k': '10000',
      '20k': '20000',
      '50k': '50000',
      '100k': '100000',
    };
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:
          amounts.entries
              .map(
                (e) => ActionChip(
                  label: Text(e.key),
                  onPressed: () {
                    _amountController.text = e.value;
                    c.getCoinPrice(
                      e.value,
                      _selectedCurrency,
                      asset['price_symbol'],
                    );
                  },
                ),
              )
              .toList(),
    );
  }

  Widget _buildPurchaseButton() {
    return Obx(() {
      final bool canPurchase =
          !c.isLoading.value &&
          c.calcResult.isNotEmpty &&
          _walletController.text.isNotEmpty;

      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF014492),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          onPressed:
              canPurchase
                  ? () {
                    // MODIFIED SUBTITLE BELOW
                    PinSheet.show(
                      title: "Confirm Purchase",
                      subtitle:
                          "Buying ${asset['name']} with ₦${_amountController.text}",
                      onConfirm: (enteredPin) {
                        c.buyGasFee(
                          coinAmount: c.calcResult['coin_value'].toString(),
                          walletAddress: _walletController.text,
                          coinType: asset['price_symbol'],
                          pin: enteredPin,
                        );
                      },
                    );
                  }
                  : null,
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
                    'Confirm Purchase',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
        ),
      );
    });
  }
}
