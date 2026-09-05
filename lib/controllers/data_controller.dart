import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mktdata/components/abdialog.dart';

class DataController extends GetxController {
  final box = GetStorage();
  static const String baseUrl = 'https://mktdata.com.ng/user/api/';

  RxBool isLoading = false.obs;
  RxBool isFetchingPlans = false.obs;

  RxString selectedNetwork = "".obs;
  RxString selectedType = "".obs;
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
  }

  void selectPlan(List plan) {
    selectedPlan.value = {
      "name": plan[0].toString(),
      "price": plan[1].toString(),
      "id": plan[2].toString(),
    };
  }

  Future<void> fetchDataTypes() async {
    try {
      dataTypes.clear();
      dataPlans.clear();
      selectedPlan.clear();
      final token = box.read('token') ?? '';

      final response = await http.post(
        Uri.parse('${baseUrl}fetch_data_type.php'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
          if (token.isNotEmpty) 'Authorization': token,
        },
        body: {"mNetwork": selectedNetwork.value.toLowerCase()},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        dataTypes.value = data is List ? data : [];
        if (dataTypes.isNotEmpty) {
          selectedType.value = dataTypes[0][2].toString();
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
      final token = box.read('token') ?? '';

      final response = await http.post(
        Uri.parse('${baseUrl}dataPrice.php'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
          if (token.isNotEmpty) 'Authorization': token,
        },
        body: {
          "mNetwork": selectedNetwork.value.toLowerCase(),
          "mType": selectedType.value,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        dataPlans.value = data is List ? data : [];
      }
    } catch (e) {
      debugPrint("Plans Error: $e");
    } finally {
      isFetchingPlans.value = false;
    }
  }

  Future<void> buyData({required String phone, required String pin}) async {
    try {
      isLoading.value = true;
      final token = box.read('token') ?? '';

      final response = await http.post(
        Uri.parse('${baseUrl}buy_dataPHP.php'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
          if (token.isNotEmpty) 'Authorization': token,
        },
        body: {
          "mobileNumber": phone,
          "mNetwork": selectedNetwork.value.toLowerCase(),
          "plan_id": selectedPlan['id'] ?? '',
          "trans_pin": box.read("profile")?['trans_pin'] ?? pin,
          "amount": selectedPlan['price'] ?? '',
          "submit": "Buy",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if ((data['sWrong'] ?? '').toString().isEmpty) {
          Abdialog().showDialog("Data purchase successful", true);
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