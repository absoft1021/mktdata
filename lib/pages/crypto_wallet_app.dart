import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mktdata/models/crypto_model.dart';
import 'package:mktdata/pages/buy_crypto_page.dart';
import 'package:mktdata/pages/sell_crypto_page.dart';

class CryptoWalletApp extends StatefulWidget {
  const CryptoWalletApp({super.key});

  @override
  State<CryptoWalletApp> createState() => _CryptoWalletAppState();
}

class _CryptoWalletAppState extends State<CryptoWalletApp>
    with SingleTickerProviderStateMixin {
  bool _balanceVisible = true;

  final List<CryptoAsset> _assets = [
    CryptoAsset(
      name: 'Toncoin',
      symbol: 'TON',
      price: 1.51,
      change: -0.01,
      color: const Color(0xFF0088CC),
      icon: Icons.diamond,
    ),
    CryptoAsset(
      name: 'Ethereum',
      symbol: 'ETH',
      price: 2956.78,
      change: 0.06,
      color: const Color(0xFF627EEA),
      icon: Icons.currency_exchange,
    ),
    CryptoAsset(
      name: 'Tron',
      symbol: 'TRX',
      price: 0.294404,
      change: -0.04,
      color: const Color(0xFFEB0029),
      icon: Icons.album,
    ),
    CryptoAsset(
      name: 'Linea',
      symbol: 'LINEA_ETH',
      price: 2956.78,
      change: 0.06,
      color: Colors.grey,
      icon: Icons.link,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(theme, isDark),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildBalanceCard(),
                    const SizedBox(height: 24),
                    _buildActionButtons(theme, isDark),
                    const SizedBox(height: 32),
                    _buildAssetsList(theme, isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme, bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF2E3A59);
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back',
                  style: TextStyle(fontSize: 12, color: theme.hintColor),
                ),
                Text(
                  'Zubairu Saidu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          // Added a Theme Toggle for testing
          IconButton(
            onPressed:
                () => Get.changeThemeMode(
                  Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
                ),
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: textColor,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.qr_code_scanner, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    // We keep the original colors for the card itself,
    // but we ensure the text contrast is handled correctly.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
          borderRadius: BorderRadius.circular(16),
          // Added a subtle shadow that works in both modes
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667EEA).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Balance',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                GestureDetector(
                  onTap:
                      () => setState(() => _balanceVisible = !_balanceVisible),
                  child: Icon(
                    _balanceVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.white70,
                    size: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _balanceVisible ? '₦50.49' : '••••••',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '9PSB • 5931161222',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.card_giftcard,
                  color: Color(0xFFFFD700),
                  size: 12,
                ),
                const SizedBox(width: 4),
                const Text(
                  'Bonus: ₦0.00',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton(
            'Buy',
            Icons.add,
            const Color(0xFF00E096),
            theme,
            isDark,
            () => Get.to(() => BuyCryptoPage()),
          ),
          _buildActionButton(
            'Sell',
            Icons.remove,
            const Color(0xFFFF3D71),
            theme,
            isDark,
            () => Get.to(() => SellCryptoPage()),
          ),
          _buildActionButton(
            'Data',
            Icons.wifi,
            const Color(0xFF667EEA),
            theme,
            isDark,
            () {},
          ),
          _buildActionButton(
            'Airtime',
            Icons.call,
            const Color(0xFFFFAA00),
            theme,
            isDark,
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    ThemeData theme,
    bool isDark,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color:
                  isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              // RESTORED: Border style from buildAssetsList
              border:
                  isDark
                      ? Border.all(color: Colors.white.withValues(alpha: 0.1))
                      : null,
              boxShadow:
                  isDark
                      ? []
                      : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
            ),
            child: Center(child: Icon(icon, color: color, size: 24)),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              // Dynamic text color for mode switching
              color: isDark ? Colors.white : const Color(0xFF2E3A59),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetsList(ThemeData theme, bool isDark) {
    // Define text and card colors based on theme
    final titleColor = isDark ? Colors.white : const Color(0xFF2E3A59);
    final cardColor =
        isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white;
    final subtitleColor = isDark ? Colors.white54 : const Color(0xFF8F9BB3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Assets',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.tune, size: 18),
                label: const Text('Filter'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF667EEA),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _assets.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final asset = _assets[index];
            final isPositive = asset.change >= 0;

            return Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border:
                    isDark
                        ? Border.all(color: Colors.white.withValues(alpha: 0.1))
                        : null,
                boxShadow:
                    isDark
                        ? []
                        : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: asset.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(asset.icon, color: asset.color, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                asset.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: titleColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                asset.symbol,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: subtitleColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${asset.price.toStringAsFixed(asset.price < 1 ? 6 : 2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: titleColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isPositive
                                        ? const Color(
                                          0xFF00E096,
                                        ).withValues(alpha: 0.1)
                                        : const Color(
                                          0xFFFF3D71,
                                        ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isPositive
                                        ? Icons.trending_up
                                        : Icons.trending_down,
                                    size: 12,
                                    color:
                                        isPositive
                                            ? const Color(0xFF00E096)
                                            : const Color(0xFFFF3D71),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${asset.change.abs().toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color:
                                          isPositive
                                              ? const Color(0xFF00E096)
                                              : const Color(0xFFFF3D71),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
