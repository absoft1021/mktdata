import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mktdata/components/pin_bottom_sheet.dart';
import 'package:mktdata/controllers/data_controller.dart';

class BuyDataPage extends StatefulWidget {
  const BuyDataPage({super.key});

  @override
  State<BuyDataPage> createState() => _BuyDataPageState();
}

class _BuyDataPageState extends State<BuyDataPage> {
  final c = Get.put(DataController());
  final _phoneController = TextEditingController();
  final RxBool _isFormValid = false.obs;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validate);
    ever(c.selectedPlan, (_) => _validate());
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
      onConfirm: (enteredPin) {
        c.buyData(phone: _phoneController.text, pin: enteredPin);
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
          "Buy Data",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      bottomNavigationBar: Obx(
        () => Visibility(
          visible: _isFormValid.value,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            margin: EdgeInsets.only(bottom: 20),
            child: SizedBox(
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
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label("SELECT NETWORK"),
            _buildNetworkGrid(isDark),
            const SizedBox(height: 25),
            _label("DATA TYPE"),
            _buildTypeSelector(),
            const SizedBox(height: 25),
            _label("PHONE NUMBER"),
            _buildPhoneInput(isDark),
            const SizedBox(height: 25),
            _label("SELECT PLAN"),
            _buildPlanGrid(isDark),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  // --- UI Helpers ---

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
  Widget _buildNetworkGrid(bool isDark) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:
            c.networks.map((net) {
              // Since 'net' is a Map, access fields using ['key']
              // We compare the title to the selectedNetwork value
              bool isSelected = c.selectedNetwork.value == net['title'];

              return GestureDetector(
                onTap: () {
                  c.selectedNetwork.value =
                      net['title'].toString().toLowerCase();
                  c.selectedNetwork.value = net['title']!;
                  c.fetchDataTypes();
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
                        // Use the logo path from the Map
                        child: Padding(
                          padding: const EdgeInsets.all(
                            8.0,
                          ), // Optional: padding for the logo
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

  Widget _buildTypeSelector() => Obx(
    () => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            c.dataTypes
                .map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(t[1]),
                      selected: c.selectedType.value == t[2],
                      onSelected: (s) {
                        c.selectedType.value = t[2];
                        c.fetchDataPlans();
                      },
                    ),
                  ),
                )
                .toList(),
      ),
    ),
  );

  Widget _buildPhoneInput(bool isDark) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: isDark ? Colors.white10 : Colors.grey[100],
      borderRadius: BorderRadius.circular(16),
    ),
    child: TextField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      onChanged: (v) => _validate(),
      decoration: const InputDecoration(
        hintText: "Enter number",
        border: InputBorder.none,
        prefixIcon: Icon(Icons.phone_android, color: Color(0xFF014492)),
      ),
    ),
  );
  Widget _buildPlanGrid(bool isDark) => Obx(() {
    if (c.isFetchingPlans.value) {
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemCount: c.dataPlans.length,
      itemBuilder: (context, index) {
        var plan = c.dataPlans[index];

        // Wrap the return in Obx so each item independently listens for selection changes
        return Obx(() {
          // Now GetX tracks this specific comparison for every item
          final bool isSel =
              c.selectedPlan['id'].toString() == plan[2].toString();

          return GestureDetector(
            onTap: () {
              c.selectedAmount = plan[2].toString();
              c.selectPlan(plan);
              _validate();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                // This color will now update INSTANTLY
                color:
                    isSel
                        ? const Color(0xFF014492).withValues(alpha: 0.1)
                        : (isDark ? Colors.white10 : Colors.grey[50]),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  // This border will now update INSTANTLY
                  color: isSel ? const Color(0xFF014492) : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      plan[0].split('(')[0].trim(),
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Text(
                    "₦${plan[1]}",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF014492),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  });
}
