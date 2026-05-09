import 'package:dio/dio.dart' as d;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ChangePasswordController extends GetxController {
  final box = GetStorage();
  final dio = d.Dio();

  RxBool isSubmitting = false.obs;
  RxBool obscureCurrent = true.obs;
  RxBool obscureNew = true.obs;

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (currentPassword.isEmpty || newPassword.length < 6) {
      Get.snackbar(
        "Error",
        "Passwords must be at least 6 characters",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSubmitting.value = true;
      String? token = box.read("token");

      final response = await dio.post(
        "https://mktdata.com.ng/api/v1/change-password", // Ensure this endpoint is correct
        data: {
          "current_password": currentPassword,
          "new_password": newPassword,
        },
        options: d.Options(
          headers: {"Authorization": token ?? "", "Accept": "application/json"},
        ),
      );

      if (response.statusCode == 200) {
        Get.back();
        Get.snackbar(
          "Success",
          "Password updated successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } on d.DioException catch (e) {
      String msg = e.response?.data['response'] ?? "Failed to update password";
      Get.snackbar(
        "Error",
        msg,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
