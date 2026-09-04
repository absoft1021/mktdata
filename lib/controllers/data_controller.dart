import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mktdata/components/abdialog.dart';
import 'package:mktdata/utils/api_client.dart';

class DataController extends GetxController {
  final box = GetStorage();
  final api = ApiClient.to;
  RxBool isLoading = false.obs;
  RxBool isFetchingPlans = false.obs;

  RxString selectedNetwork = "".obs;
  RxString selectedType = "".obs;
  String selectedAmount = "";

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

      final response = await api.post(
        'fetch_data_type.php',
        data: {"mNetwork": selectedNetwork.value.toLowerCase()},
      );

      if (response.statusCode == 200) {
        dataTypes.value = response.data;
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

      final response = await api.post(
        'dataPrice.php',
        data: {
          "mNetwork": selectedNetwork.value.toLowerCase(),
          "mType": selectedType.value,
        },
      );

      if (response.statusCode == 200) {
        dataPlans.value = response.data;
      }
    } finally {
      isFetchingPlans.value = false;
    }
  }

  Future<void> buyData({required String phone, required String pin}) async {
    try {
      isLoading.value = true;
      final response = await api.post(
        'buy_dataPHP.php',
        data: {
          "mobileNumber": phone,
          "mNetwork": selectedNetwork.value.toLowerCase(),
          "plan_id": selectedPlan['id'],
          "trans_pin": box.read("profile")?['trans_pin'] ?? "",
          "amount": selectedAmount,
          "submit": "Buy",
        },
      );
      final data = response.data;
      if (data['sWrong'].toString().isEmpty) {
        Abdialog().showDialog("Data purchase successful", true);
      } else {
        Abdialog().showDialog(data['sWrong'] ?? "Error occurred", false);
      }
    } finally {
      isLoading.value = false;
    }
  }
}
