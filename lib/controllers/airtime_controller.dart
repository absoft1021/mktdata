import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mktdata/components/abdialog.dart';

class AirtimeController extends GetxController {
  final box = GetStorage();
  RxBool isLoading = false.obs;

  // State variables
  RxString selectedNetwork = "mtn".obs;
  final List networks = [
    {"title": "MTN", "logo": "assets/mtn.png"},
    {"title": "Airtel", "logo": "assets/airtel.png"},
    {"title": "Glo", "logo": "assets/glo.png"},
    {"title": "9mobile", "logo": "assets/mobile.png"},
  ];

  Future<void> buyAirtime({
    required String amount,
    required String phone,
    required String pin,
    required String network,
  }) async {
    try {
      isLoading.value = true;
      String? token = box.read("token");

      final response = await http.post(
        Uri.parse("https://mktdata.com.ng/user/api/buy_airtimePHP.php"),
        headers: {"Authorization": token ?? ""},
        body: {
          "amount": amount,
          "mobileNumber": phone,
          "mNetwork": network,
          "trans_pin": box.read("profile")['trans_pin'] ?? "1111",
          "submit": "Buy",
        },
      );

      final data = jsonDecode(response.body);

      if (data['sWrong'].toString().isEmpty) {
        Abdialog().showDialog("Airtime purchase successful", true);
        // Get.snackbar(
        //   "Success",
        //   "Airtime purchase successful!",
        //   backgroundColor: Colors.green,
        //   colorText: Colors.white,
        // );
      } else {
        Abdialog().showDialog(data['sWrong'] ?? "Error occurred", false);
        // Get.snackbar(
        //   "Failed",
        //   data['sWrong'] ?? "Transaction failed",
        //   backgroundColor: Colors.redAccent,
        //   colorText: Colors.white,
        // );
      }
    } catch (e) {
      Abdialog().showDialog("Check your connection", false);
      // Get.snackbar(
      //   "Error",
      //   "Check your connection",
      //   backgroundColor: Colors.redAccent,
      //   colorText: Colors.white,
      // );
    } finally {
      isLoading.value = false;
    }
  }
}
