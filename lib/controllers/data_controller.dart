import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mktdata/components/abdialog.dart';

class DataController extends GetxController {
  final box = GetStorage();
  RxBool isLoading = false.obs;
  RxBool isFetchingPlans = false.obs;

  RxString selectedNetwork = "".obs;
  RxString selectedType = "".obs;
  String selectedAmount = "";

  // We use RxMap to track selection
  RxMap selectedPlan = {}.obs;

  RxList dataTypes = [].obs;
  RxList dataPlans = [].obs;

  final List<Map<String, String>> networks = [
    {"title": "MTN", "logo": "assets/mtn.png"},
    {"title": "Airtel", "logo": "assets/airtel.png"},
    {"title": "Glo", "logo": "assets/glo.png"},
    {"title": "9mobile", "logo": "assets/mobile.png"},
  ];

  @override
  void onInit() {
    super.onInit();
    fetchDataTypes();
  }

  // Method to handle clean selection and UI refresh
  void selectPlan(List plan) {
    selectedPlan.value = {
      "name": plan[0].toString(),
      "price": plan[1].toString(),
      "id": plan[2].toString(), // Forced to string for comparison
    };
  }

  Future<void> fetchDataTypes() async {
    try {
      dataTypes.clear();
      dataPlans.clear();
      selectedPlan.clear();

      final response = await http.post(
        Uri.parse("https://mktdata.com.ng/user/api/fetch_data_type.php"),
        body: {"mNetwork": selectedNetwork.value.toLowerCase()},
        headers: {"Authorization": box.read("token") ?? ""},
      );

      if (response.statusCode == 200) {
        dataTypes.value = jsonDecode(response.body);
        if (dataTypes.isNotEmpty) {
          selectedType.value = dataTypes[0][2];
          fetchDataPlans();
        }
      }
    } catch (e) {
      debugPrint("Type Error: $e");
    }
  }

  Future<void> fetchDataPlans() async {
    try {
      isFetchingPlans.value = true;
      dataPlans.clear();
      selectedPlan.clear();

      final response = await http.post(
        Uri.parse("https://mktdata.com.ng/user/api/dataPrice.php"),
        body: {
          "mNetwork": selectedNetwork.value.toLowerCase(),
          "mType": selectedType.value,
        },
        headers: {"Authorization": box.read("token") ?? ""},
      );

      if (response.statusCode == 200) {
        dataPlans.value = jsonDecode(response.body);
      }
    } finally {
      isFetchingPlans.value = false;
    }
  }

  Future<void> buyData({required String phone, required String pin}) async {
    try {
      isLoading.value = true;
      final response = await http.post(
        Uri.parse("https://mktdata.com.ng/user/api/buy_dataPHP.php"),
        headers: {"Authorization": box.read("token") ?? ""},
        body: {
          "mobileNumber": phone,
          "mNetwork": selectedNetwork.value.toLowerCase(),
          "plan_id": selectedPlan['id'],
          "trans_pin": box.read("profile")['trans_pin'] ?? "",
          "amount": selectedAmount,
          "submit": "Buy",
        },
      );
      final data = jsonDecode(response.body);
      if (data['sWrong'].toString().isEmpty) {
        Abdialog().showDialog("Data purchase successful", true);
        // Get.snackbar(
        //   "Success",
        //   "Data purchase successful!",
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
    } finally {
      isLoading.value = false;
    }
  }
}
