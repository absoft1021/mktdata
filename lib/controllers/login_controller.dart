import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mktdata/auth/resume_page.dart';
import 'package:mktdata/main_page.dart';
import 'package:mktdata/utils/api_client.dart';
import 'package:dio/dio.dart';

class LoginController extends GetxController {
  final box = GetStorage();
  final api = ApiClient.to;

  var isLoading = false.obs;

  void launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void login(String username, String password) async {
    try {
      isLoading.value = true;
      final response = await api.dio.post(
        'loginPHP.php',
        data: {'username': username, 'password': password, 'submit': 'true'},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      isLoading.value = false;

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data;

        if (data['success'] == 1 || data['success'] == "1") {
          var profile = data['profile'];
          if (profile != null) {
            await box.write("profile", profile);
            await box.write("telegram", profile['telegram_link'] ?? '');
            await box.write("contact", profile['contact_phone'] ?? '');
            await box.write("token", data['token'] ?? '');
          }

          getUserProfile();
        } else {
          _showErrorSnackbar(
            "Login Failed",
            data['incorrectData'] ?? 'Invalid credentials',
          );
        }
      } else {
        _showErrorSnackbar(
          "Server Error",
          "Status code: ${response.statusCode}",
        );
      }
    } catch (e) {
      isLoading.value = false;
      _showErrorSnackbar("Connection Error", e.toString());
    }
  }

  void getUserProfile() async {
    try {
      final response = await api.get('current_user_state.php');
      if (response.statusCode == 200) {
        Map<String, dynamic> profileData = response.data;
        await box.write("userData", profileData);

        if (profileData.containsKey('balance')) {
          await box.write("balance", profileData['balance'].toString());
        }
        Get.offAll(() => MainPage());
      } else {
        _showErrorSnackbar("Error", "Failed to load profile");
        isLoading.value = false;
      }
    } catch (e) {
      _showErrorSnackbar("Error", "Failed to load profile");
      isLoading.value = false;
    }
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
      duration: const Duration(seconds: 3),
    );
  }
}
