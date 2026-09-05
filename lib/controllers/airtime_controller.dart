import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mktdata/components/abdialog.dart';

class AirtimeController extends GetxController {
  final box = GetStorage();
  static const String baseUrl = 'https://mktdata.com.ng/user/api/';

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

      final token = box.read('token') ?? '';
      final response = await http.post(
        Uri.parse('${baseUrl}buy_airtimePHP.php'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
          if (token.isNotEmpty) 'Authorization': token,
        },
        body: {
          "amount": amount,
          "mobileNumber": phone,
          "mNetwork": network,
          "trans_pin": box.read("profile")?['trans_pin'] ?? pin,
          "submit": "Buy",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if ((data['sWrong'] ?? '').toString().isEmpty) {
          Abdialog().showDialog("Airtime purchase successful", true);
        } else {
          Abdialog().showDialog(data['sWrong'] ?? "Error occurred", false);
        }
      } else {
        Abdialog().showDialog("Server error: ${response.statusCode}", false);
      }
    } catch (e) {
      Abdialog().showDialog("Check your connection", false);
    } finally {
      isLoading.value = false;
    }
  }
}