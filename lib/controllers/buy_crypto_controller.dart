import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class BuyCryptoController extends GetxController {
  final box = GetStorage();

  RxBool isLoading = false.obs;
  // Reactive map to hold the API response
  RxMap<String, dynamic> calcResult = <String, dynamic>{}.obs;

  Future<void> getCoinPrice(
    String amount,
    String valType,
    String symbol,
  ) async {
    // Basic validation to avoid unnecessary API calls
    if (amount.isEmpty || double.tryParse(amount) == 0) {
      calcResult.clear();
      return;
    }

    try {
      isLoading.value = true;
      String? token = box.read("token");

      final response = await http.post(
        Uri.parse("https://mktdata.com.ng/api/v1/calculate-prices"),
        body: jsonEncode({
          "amount": amount,
          "value_type": valType.toLowerCase(),
          "coin_symbol": symbol,
        }),
        headers: {
          "Content-Type": "application/json",
          "Authorization": token ?? "",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          calcResult.value = data;
        } else {
          calcResult.clear();
        }
      }
    } catch (e) {
      print("Calculation API Error: $e");
      calcResult.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> buyGasFee({
    required String coinAmount,
    required String walletAddress,
    required String coinType,
    required String pin,
  }) async {
    try {
      isLoading.value = true;
      String? token = box.read("token");

      final response = await http.post(
        Uri.parse("https://mktdata.com.ng/api/v1/buy_gasfee"),
        body: {
          "coin_amount": coinAmount,
          "wallet_address": walletAddress,
          "coin_type": coinType,
          "trans_pin": box.read("profile")['trans_pin'] ?? "",
        },
        headers: {"Accepts": "application/json", "Authorization": token ?? ""},
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        _showSuccessDialog(data['message'] ?? "Transaction Successful");
      } else {
        Get.snackbar(
          "Transaction Failed",
          data['response'] ?? "Could not process purchase",
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFFF3D71),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar("Error", "A connection error occurred: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _showSuccessDialog(String message) {
    Get.defaultDialog(
      title: "Success!",
      middleText: message,
      backgroundColor: Get.isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
      confirm: TextButton(
        onPressed: () {
          Get.back(); // Close dialog
          Get.back(); // Go back to Home
        },
        child: const Text(
          "Continue",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void executePurchase(String address, String amount, String symbol) {
    // Implement final purchase logic here
    Get.snackbar(
      "Success",
      "Purchase request submitted",
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
