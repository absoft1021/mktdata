import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mktdata/pages/transaction_detailScreen.dart';

class WithdrawalController extends GetxController {
  final box = GetStorage();

  RxBool isLoading = false.obs;
  RxBool isVerifying = false.obs;
  RxDouble walletBalance = 0.00.obs;

  var banks = [].obs;
  var selectedBankCode = "".obs;
  var verifiedName = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchBanks();
  }

  // 1. Fetch Banks (Added Authorization)
  Future<void> fetchBanks() async {
    try {
      final response = await http.get(
        Uri.parse("https://mktdata.com.ng/api/v1/banks_code"),
        headers: {
          "Authorization": box.read("token") ?? "",
          "Accept": "application/json",
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        banks.assignAll(data['accts'] ?? []);
      }
    } catch (e) {
      debugPrint("Bank Fetch Error: $e");
    }
  }

  // 2. Verify Account (Added Authorization)
  Future<void> verifyAccount(String accountNumber) async {
    if (accountNumber.length < 10 || selectedBankCode.isEmpty) return;

    try {
      isVerifying.value = true;
      verifiedName.value = "Verifying...";

      final response = await http.post(
        Uri.parse("https://mktdata.com.ng/api/v1/verify-account"),
        headers: {
          "Authorization": box.read("token") ?? "",
          "Accept": "application/json",
        },
        body: {
          "bank_code": selectedBankCode.value,
          "account_number": accountNumber,
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // Accessing data nested under 'data' key based on your sample response
        verifiedName.value = data['data']?['account_name'] ?? "Unknown Account";
      } else {
        verifiedName.value = data['response'] ?? "Account not found";
      }
    } catch (e) {
      verifiedName.value = "Verification failed";
    } finally {
      isVerifying.value = false;
    }
  }

  // 3. Request Withdrawal (Authorization already included)
  Future<void> requestWithdrawal({
    required String amount,
    required String narration,
    required String pin,
    required String accountNumber,
  }) async {
    try {
      isLoading.value = true;

      final response = await http.post(
        Uri.parse("https://mktdata.com.ng/api/v1/withdraw"),
        headers: {
          "Authorization": box.read("token") ?? "",
          "Accept": "application/json",
        },
        body: {
          "amount": amount,
          "narration": narration,
          "trans_pin": pin,
          "bank_code": selectedBankCode.value,
          "account_number": accountNumber,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          "Success",
          "Withdrawal successful",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.off(() => TransactionDetailScreen(), arguments: data);
      } else {
        Get.snackbar(
          "Error",
          data['response'] ?? "Withdrawal failed",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Connection failed", backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
}
