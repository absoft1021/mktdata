import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mktdata/components/abdialog.dart';
import 'package:mktdata/utils/api_client.dart';

class AirtimeController extends GetxController {
  final box = GetStorage();
  final api = ApiClient.to;
  RxBool isLoading = false.obs;

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

      final response = await api.post(
        'buy_airtimePHP.php',
        data: {
          "amount": amount,
          "mobileNumber": phone,
          "mNetwork": network,
          "trans_pin": box.read("profile")?['trans_pin'] ?? "",
          "submit": "Buy",
        },
      );

      final data = response.data;

      if (data['sWrong'].toString().isEmpty) {
        Abdialog().showDialog("Airtime purchase successful", true);
      } else {
        Abdialog().showDialog(data['sWrong'] ?? "Error occurred", false);
      }
    } catch (e) {
      Abdialog().showDialog("Check your connection", false);
    } finally {
      isLoading.value = false;
    }
  }
}
