import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class ExamController extends GetxController {
  // Observables
  var isLoading = false.obs;
  var selectedExam = 'WAEC'.obs;
  var price = '₦0.00'.obs;
  
  // Data list
  final List<Map<String, String>> examList = [
    {'title': 'WAEC', 'image': 'assets/waec.png'},
    {'title': 'NECO', 'image': 'assets/neco.png'},
    {'title': 'NABTEB', 'image': 'assets/nabteb.png'},
    {'title': 'NBAIS', 'image': 'assets/nbais.png'},
  ];

  @override
  void onInit() {
    super.onInit();
    // Fetch initial price for default selection
    fetchPrice('waec');
  }

  void fetchPrice(String examTitle) async {
    isLoading.value = true;
    try {
      // Logic mimicking your RequestNetwork call
      // Replace with your actual API endpoint
      // var response = await api.post('/checkExam', body: {'exam': examTitle});
      
      await Future.delayed(Duration(milliseconds: 800)); // Simulate network
      price.value = "₦2,500"; // Update with response data
    } catch (e) {
      Get.snackbar("Error", "Service temporarily unavailable");
    } finally {
      isLoading.value = false;
    }
  }

  void processPurchase() async {
    isLoading.value = true;
    // Simulate your TimerTask logic
    Timer(Duration(milliseconds: 1200), () {
      isLoading.value = false;
      Get.defaultDialog(
        title: "",
        middleText: "Service temporarily unavailable",
        textConfirm: "OK",
        confirmTextColor: Colors.white,
        onConfirm: () => Get.back(),
      );
    });
  }
}