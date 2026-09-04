import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mktdata/controllers/kyc_controller.dart';
import 'package:mktdata/controllers/main_controller.dart';

class KycPage extends StatefulWidget {
  KycPage({super.key});

  @override
  State<KycPage> createState() => _KycPageState();
}

class _KycPageState extends State<KycPage> {
  // Injecting/Finding Controllers
  final c = Get.put(KycController());
  final mainC = Get.find<MainController>();

  // Text Controllers for Inputs
  final ninController = TextEditingController();
  final bvnController = TextEditingController();
  final addressController = TextEditingController();
  final pinController = TextEditingController();

  @override
  void dispose() {
    ninController.dispose();
    bvnController.dispose();
    addressController.dispose();
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF667EEA);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "KYC Verification",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: Obx(() {
        String status = mainC.kycStatus.value;
        int activeStep = _getStatusStep(status);

        return Column(
          children: [
            // Fixed Header showing progress
            _buildStepperHeader(activeStep, primaryColor),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? Colors.black : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: _buildBody(status, isDark, primaryColor),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // Logic to determine which step is active in the header
  int _getStatusStep(String status) {
    if (status == "00" || status == "01") return 0; // Tier 1
    if (status == "11" || status == "02") return 1; // Tier 2
    return 2; // Tier 3 (Includes 22, 03, 33)
  }

  Widget _buildBody(String status, bool isDark, Color primary) {
    // --- TIER 1 SECTION ---
    if (status == "00" || status == "01") {
      return _infoWrapper(
        icon: Icons.mark_email_read_rounded,
        color: Colors.green,
        title: "Tier 1 Verified",
        desc: "Your email and phone number have been automatically verified.",
        child: _actionButton(
          "PROCEED TO TIER 2",
          primary,
          () {},
        ),
      );
    }

    // --- TIER 2 SECTION (Input Form) ---
    if (status == "11") {
      return Column(
        children: [
          _titleSection(
            "Tier 2: Identity",
            "Please provide your government issued ID details",
          ),
          const SizedBox(height: 25),
          _textField(
            ninController,
            "11-Digit NIN",
            isDark,
            Icons.fingerprint,
            isNum: true,
          ),
          const SizedBox(height: 15),
          _textField(
            bvnController,
            "11-Digit BVN",
            isDark,
            Icons.account_balance_wallet_outlined,
            isNum: true,
          ),
          const SizedBox(height: 40),
          _actionButton(
            "SUBMIT IDENTITY",
            primary,
            () =>
                c.submitTier2(nin: ninController.text, bvn: bvnController.text),
          ),
        ],
      );
    }

    // Tier 2 Pending
    if (status == "02") {
      return _statusOverlay(
        Icons.hourglass_empty_rounded,
        Colors.orange,
        "Tier 2 Reviewing...",
      );
    }

    // --- TIER 3 SECTION (Input Form) ---
    if (status == "22") {
      return Column(
        children: [
          _titleSection(
            "Tier 3: Address Proof",
            "Upload a utility bill or bank statement (Max 2MB)",
          ),
          const SizedBox(height: 20),

          // Image Picker Widget
          GestureDetector(
            onTap: () => c.pickImage(),
            child: Obx(
              () => Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: primary.withOpacity(0.2),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child:
                    c.selectedImage.value == null
                        ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              size: 40,
                              color: primary,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Tap to upload document",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        )
                        : ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            c.selectedImage.value!,
                            fit: BoxFit.cover,
                          ),
                        ),
              ),
            ),
          ),

          //    const SizedBox(height: 20),
          //  _textField(addressController, "Full Residential Address", isDark, Icons.home_work_outlined, lines: 2),
          const SizedBox(height: 15),
          _textField(
            pinController,
            "Transaction PIN",
            isDark,
            Icons.lock_outline,
            isPin: true,
          ),
          const SizedBox(height: 40),
          _actionButton(
            "COMPLETE VERIFICATION",
            primary,
            () => c.submitTier3(
              address: addressController.text,
              pin: pinController.text,
            ),
          ),
        ],
      );
    }

    // Tier 3 Pending
    if (status == "03") {
      return _statusOverlay(
        Icons.history_edu_rounded,
        Colors.blue,
        "Tier 3 Reviewing...",
      );
    }

    // Tier 3 Approved (Final Success)
    return _statusOverlay(
      Icons.verified_rounded,
      Colors.green,
      "Full KYC Verified",
      isDone: true,
    );
  }

  // --- UI Components ---

  Widget _buildStepperHeader(int current, Color primary) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _stepCircle("1", "Basic", current >= 0, current > 0, primary),
          _stepLine(current > 0, primary),
          _stepCircle("2", "Identity", current >= 1, current > 1, primary),
          _stepLine(current > 1, primary),
          _stepCircle("3", "Address", current >= 2, false, primary),
        ],
      ),
    );
  }

  Widget _stepCircle(
    String n,
    String label,
    bool active,
    bool done,
    Color primary,
  ) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            color: done ? Colors.green : (active ? primary : Colors.grey[300]),
            shape: BoxShape.circle,
            boxShadow:
                active
                    ? [
                      BoxShadow(
                        color: primary.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : [],
          ),
          child: Center(
            child:
                done
                    ? const Icon(Icons.check, size: 20, color: Colors.white)
                    : Text(
                      n,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? primary : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _stepLine(bool active, Color primary) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      width: 40,
      height: 2,
      color: active ? Colors.green : Colors.grey[300],
    );
  }

  Widget _titleSection(String t, String s) => Column(
    children: [
      Text(
        t,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 6),
      Text(
        s,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
      ),
    ],
  );

  Widget _infoWrapper({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
    required Widget child,
  }) {
    return Column(
      children: [
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 70, color: color),
        ),
        const SizedBox(height: 30),
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          desc,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 15),
        ),
        const SizedBox(height: 60),
        child,
      ],
    );
  }

  Widget _statusOverlay(
    IconData icon,
    Color color,
    String msg, {
    bool isDone = false,
  }) => Center(
    child: Column(
      children: [
        const SizedBox(height: 50),
        Icon(icon, size: 110, color: color),
        const SizedBox(height: 25),
        Text(
          msg,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            isDone
                ? "Your account is now fully verified. You can enjoy all features without restrictions."
                : "Our compliance team is currently verifying your details. You will receive a notification once approved.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, height: 1.5),
          ),
        ),
      ],
    ),
  );

  Widget _textField(
    TextEditingController ctrl,
    String hint,
    bool isDark,
    IconData icon, {
    int lines = 1,
    bool isPin = false,
    bool isNum = false,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: lines,
      obscureText: isPin,
      maxLength: isPin ? 4 : 20,
      keyboardType: isPin || isNum ? TextInputType.number : TextInputType.text,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        prefixIcon: Icon(icon, size: 20, color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _actionButton(String label, Color primary, VoidCallback onTap) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          onPressed: c.isSubmitting.value ? null : onTap,
          child:
              c.isSubmitting.value
                  ? const SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                  : Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.1,
                    ),
                  ),
        ),
      ),
    );
  }
}
