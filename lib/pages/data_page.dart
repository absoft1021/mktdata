import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mktdata/components/pin_bottom_sheet.dart';
import 'package:mktdata/controllers/data_controller.dart';

class BuyDataPage extends StatefulWidget {
  const BuyDataPage({super.key});

  @override
  State<BuyDataPage> createState() => _BuyDataPageState();
}

class _BuyDataPageState extends State<BuyDataPage>
    with SingleTickerProviderStateMixin {
  final c = Get.put(DataController());
  final _phoneController = TextEditingController();
  final RxBool _isFormValid = false.obs;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  static const _brand = Color(0xFF014492);
  static const _brandLight = Color(0xFFE8F0FC);

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _phoneController.addListener(_validate);
    ever(c.selectedPlan, (_) => _validate());
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _validate() {
    _isFormValid.value =
        _phoneController.text.length >= 10 && c.selectedPlan.isNotEmpty;
  }

  void _handleProceed() {
    PinSheet.show(
      title: "Confirm Purchase",
      subtitle:
          "Paying ₦${c.selectedPlan['price']} for ${c.selectedPlan['name']}",
      onConfirm: (pin) => c.buyData(phone: _phoneController.text, pin: pin),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0A0E17) : const Color(0xFFF5F7FB);
    final cardBg = isDark ? const Color(0xFF141923) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: _buildAppBar(isDark),
      bottomNavigationBar: _buildBottomBar(),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Section(
                label: "NETWORK",
                child: _buildNetworkGrid(isDark, cardBg),
              ),
              _Section(
                label: "DATA TYPE",
                child: _buildTypeSelector(isDark),
              ),
              _Section(
                label: "PHONE NUMBER",
                child: _buildPhoneInput(isDark, cardBg),
              ),
              _Section(
                label: "SELECT PLAN",
                child: _buildPlanGrid(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      title: const Text(
        "Buy Data",
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: isDark ? Colors.white : Colors.black87,
        ),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Obx(
      () => AnimatedSlide(
        offset: _isFormValid.value ? Offset.zero : const Offset(0, 1),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _isFormValid.value ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brand,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: c.isLoading.value ? null : _handleProceed,
                child: c.isLoading.value
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        "PROCEED TO PAYMENT",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: 0.8,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkGrid(bool isDark, Color cardBg) {
    return Obx(
      () => Row(
        children: c.networks.map((net) {
          final isSelected =
              c.selectedNetwork.value.toLowerCase() ==
              net['title']!.toLowerCase();
          return Expanded(
            child: GestureDetector(
              onTap: () {
                c.selectedNetwork.value = net['title']!.toLowerCase();
                c.fetchDataTypes();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _brandLight
                      : (isDark ? Colors.white10 : cardBg),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? _brand : Colors.transparent,
                    width: 1.8,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _brand.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          isDark ? Colors.white12 : Colors.grey[100],
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Image.asset(
                          net['logo']!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      net['title']!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? _brand
                            : (isDark ? Colors.white60 : Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTypeSelector(bool isDark) {
    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: c.dataTypes.map((t) {
            final isSelected = c.selectedType.value == t[2].toString();
            return GestureDetector(
              onTap: () {
                c.selectedType.value = t[2].toString();
                c.fetchDataPlans();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _brand
                      : (isDark ? Colors.white10 : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? _brand : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Text(
                  t[1].toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white60 : Colors.black87),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPhoneInput(bool isDark, Color cardBg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: TextField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: "Phone Number",
          hintStyle: TextStyle(
            color: isDark ? Colors.white30 : Colors.black26,
            fontSize: 14,
          ),
          border: InputBorder.none,
          prefixIcon: Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: isDark ? Colors.white12 : Colors.grey.shade200,
                ),
              ),
            ),
            child: const Icon(
              Icons.phone_android_rounded,
              color: _brand,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanGrid(bool isDark) {
    return Obx(() {
      if (c.isFetchingPlans.value) {
        return _PlanSkeletonGrid(isDark: isDark);
      }

      if (c.dataPlans.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Text(
              "No plans available",
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
                fontSize: 13,
              ),
            ),
          ),
        );
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 2.4,
        ),
        itemCount: c.dataPlans.length,
        itemBuilder: (_, i) {
          final plan = c.dataPlans[i];
          return Obx(() {
            final isSel =
                c.selectedPlan['id'].toString() == plan[2].toString();
            return _PlanCard(
              name: plan[0].toString(),
              price: plan[1].toString(),
              isSelected: isSel,
              isDark: isDark,
              onTap: () {
                c.selectPlan(plan); // sets selectedAmount = price correctly
                _validate();
              },
            );
          });
        },
      );
    });
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 2),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.name,
    required this.price,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final String name;
  final String price;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  static const _brand = Color(0xFF014492);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? _brand.withValues(alpha: 0.08)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _brand : Colors.grey.withValues(alpha: 0.15),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? _brand
                    : (isDark ? Colors.white70 : Colors.black87),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "₦$price",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isSelected ? _brand : const Color(0xFF014492),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanSkeletonGrid extends StatefulWidget {
  const _PlanSkeletonGrid({required this.isDark});
  final bool isDark;

  @override
  State<_PlanSkeletonGrid> createState() => _PlanSkeletonGridState();
}

class _PlanSkeletonGridState extends State<_PlanSkeletonGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final opacity = 0.04 + _anim.value * 0.08;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.4,
          ),
          itemCount: 6,
          itemBuilder: (_, __) => Container(
            decoration: BoxDecoration(
              color: (widget.isDark ? Colors.white : Colors.black)
                  .withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}