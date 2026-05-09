import 'package:dio/dio.dart' as d;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class CableController extends GetxController {
  final box = GetStorage();
  final dio = d.Dio();

  RxBool isLoading = false.obs;
  RxBool isVerifying = false.obs;
  RxBool isVerified = false.obs;

  var providers = [].obs;
  RxString selectedProviderName = "".obs; // For Display
  RxString selectedProviderId = "".obs;   // For API
  RxString customerName = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchProviders();
  }

  Future<void> fetchProviders() async {
    try {
      final response = await dio.get(
        "https://misbundle.ng/api/v1/cable_providers",
        options: d.Options(headers: {
          "Authorization": box.read("token") ?? "",
          "Accept": "application/json"
        }),
      );
      if (response.statusCode == 200) {
        // Assuming API returns {"providers": [{"name": "DSTV", "id": "1"}, ...]}
        providers.assignAll(response.data['providers'] ?? []);
      }
    } catch (e) {
      debugPrint("Provider Fetch Error: $e");
    }
  }

  Future<void> verifyMeter(String meterNum) async {
    if (selectedProviderName.isEmpty || meterNum.isEmpty) {
      Get.snackbar("Required", "Select a provider and enter meter number", 
        backgroundColor: Colors.orange);
      return;
    }

    try {
      isVerifying.value = true;
      isVerified.value = false;

      final response = await dio.post(
        "https://misbundle.ng/api/v1/verify_cable",
        data: {
          "cablename": selectedProviderName.value,
          "smartcard_number": meterNum,
        },
        options: d.Options(headers: {
          "Authorization": box.read("token") ?? "",
          "Accept": "application/json"
        }),
      );

      if (response.statusCode == 200) {
        customerName.value = response.data['customer_name'] ?? "Unknown Customer";
        isVerified.value = true;
      } else {
        Get.snackbar("Error", response.data['response'] ?? "Verification failed", 
          backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Could not verify meter number", backgroundColor: Colors.red);
    } finally {
      isVerifying.value = false;
    }
  }
}