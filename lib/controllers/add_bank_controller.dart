import 'package:dio/dio.dart' as d;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AddBankController extends GetxController {
  final box = GetStorage();
  final dio = d.Dio();

  RxBool isSubmitting = false.obs;
  RxBool isVerifying = false.obs;

  var banks = [].obs;
  RxString selectedBankCode = "".obs;
  RxString selectedBankName = "".obs;
  RxString verifiedName = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchBanks();
  }

  // 1. Fetch Banks (Added Authorization)
  Future<void> fetchBanks() async {
    try {
      String? token = box.read("token");
      final response = await dio.get(
        "https://mktdata.com.ng/api/v1/banks_code",
        options: d.Options(
          headers: {"Authorization": token ?? "", "Accept": "application/json"},
        ),
      );
      if (response.statusCode == 200) {
        banks.assignAll(response.data['accts'] ?? []);
      }
    } catch (e) {
      debugPrint("Error fetching banks: $e");
    }
  }

  // 2. Verify Account (Added Authorization)
  Future<void> verifyAccount(String acctNum) async {
    if (acctNum.length < 10 || selectedBankCode.isEmpty) return;

    try {
      isVerifying.value = true;
      verifiedName.value = "Verifying...";
      String? token = box.read("token");

      final response = await dio.post(
        "https://mktdata.com.ng/api/v1/verify-account",
        data: {"bank_code": selectedBankCode.value, "account_number": acctNum},
        options: d.Options(
          headers: {"Authorization": token ?? "", "Accept": "application/json"},
        ),
      );

      if (response.statusCode == 200) {
        verifiedName.value = response.data['data']?['account_name'] ?? "";
      } else {
        verifiedName.value = "Account not found";
      }
    } catch (e) {
      verifiedName.value = "Could not verify";
    } finally {
      isVerifying.value = false;
    }
  }

  // 3. Submit Bank (Already had Authorization, kept for consistency)
  Future<void> submitBank({required String acctNum}) async {
    if (selectedBankCode.isEmpty ||
        acctNum.length < 10 ||
        verifiedName.value.isEmpty ||
        verifiedName.value.contains("not found")) {
      Get.snackbar(
        "Error",
        "Please verify bank details first",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSubmitting.value = true;
      String? token = box.read("token");

      final response = await dio.post(
        "https://mktdata.com.ng/api/v1/submit_bank",
        data: {
          "bank_name": selectedBankName.value,
          "acct_num": acctNum,
          "acct_name": verifiedName.value,
          "bank_code": selectedBankCode.value,
        },
        options: d.Options(
          headers: {"Authorization": token ?? "", "Accept": "application/json"},
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var profile = box.read('profile') ?? {};
        profile['bank_name'] = selectedBankName.value;
        profile['account_number'] = acctNum;
        profile['account_name'] = verifiedName.value;
        box.write('profile', profile);

        Get.back();
        Get.snackbar(
          "Success",
          "Bank linked successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } on d.DioException catch (e) {
      String msg = (e.response?.data is Map) ? (e.response?.data['response'] ?? "Failed to link bank") : "Failed to link bank";
      Get.snackbar(
        "Error",
        msg,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
