import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mktdata/controllers/exam_controller.dart';
import 'package:mktdata/utils/app_colors.dart';
import 'package:mktdata/components/pin_bottom_sheet.dart'; // Ensure path is correct

class ExamPage extends StatelessWidget {
  final ExamController controller = Get.put(ExamController());

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.accentPrimary;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0E17) : const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text(
          "Exam PIN",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIllustration(primaryColor),
                const SizedBox(height: 30),

                _label("SELECT EXAM TYPE"),
                _buildExamDropdown(isDark),

                const SizedBox(height: 20),
                _label("PRICE"),
                _buildPriceField(isDark),

                const SizedBox(height: 40),
                _buildPurchaseButton(context, primaryColor),

                const SizedBox(height: 20),
                _buildInfoNote(isDark),
              ],
            ),
          ),

          // Progress Loader
          Obx(
            () =>
                controller.isLoading.value
                    ? Container(
                      color: Colors.black45,
                      child: const Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink(),
          ),
        ],
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
        child: Icon(Icons.school_outlined, size: 60, color: primary),
      ),
    );
  }

  Widget _buildExamDropdown(bool isDark) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value:
                controller.selectedExam.value.isEmpty
                    ? null
                    : controller.selectedExam.value,
            dropdownColor: isDark ? const Color(0xFF1A1F2E) : Colors.white,
            hint: const Text("Choose Examination"),
            items:
                controller.examList.map((item) {
                  return DropdownMenuItem<String>(
                    value: item['title'],
                    child: Row(
                      children: [
                        const Icon(
                          Icons.description_outlined,
                          size: 20,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          item['title']!,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
            onChanged: (val) {
              controller.selectedExam.value = val!;
              controller.fetchPrice(val.toLowerCase());
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPriceField(bool isDark) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.payments_outlined, color: Colors.grey, size: 20),
            const SizedBox(width: 12),
            Text(
              controller.price.value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseButton(BuildContext context, Color primary) {
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
          if (controller.selectedExam.value.isEmpty) {
            Get.snackbar(
              "Error",
              "Please select an exam type",
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return;
          }
          _handlePayment();
        },
        child: const Text(
          "PURCHASE PIN",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  void _handlePayment() {
    PinSheet.show(
      title: "Confirm Purchase",
      subtitle: "Buying ${controller.selectedExam.value} PIN",
      onConfirm: (pin) {
        controller
            .processPurchase(); // Ensure your controller accepts/handles the PIN
      },
    );
  }

  Widget _buildInfoNote(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.amber, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Your PIN will be displayed immediately after purchase.",
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
        ],
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
