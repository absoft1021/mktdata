import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:mktdata/auth/resume_page.dart';
import 'package:mktdata/main_page.dart';

class LoginController extends GetxController {
  final box = GetStorage();
  final String loginUrl = "https://mktdata.com.ng/user/api/loginPHP.php";
  final String profileUrl =
      "https://mktdata.com.ng/user/api/current_user_state.php";

  var isLoading = false.obs;

  void launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // --- Login Request ---
  void login(String username, String password) async {
    try {
      isLoading.value = true;
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"username": username, "password": password, "submit": "true"},
      );

      isLoading.value = false;

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        if (data['success'] == 1 || data['success'] == "1") {
          // Robust Null Checks for Profile
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

  // --- Get User Profile Request ---
  void getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse("https://mktdata.com.ng/user/api/current_user_state.php"),
        headers: {
          "Content-Type": "application/json",
          "Accept":
              "application/json", // Added to ensure server knows we want JSON back
          "Authorization": box.read('token'),
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> profileData = jsonDecode(response.body);
        await box.write("userData", profileData);

        // Safely update balance
        if (profileData.containsKey('balance')) {
          await box.write("balance", profileData['balance'].toString());

          Get.offAll(() => MainPage());
        }
      } else if (response.statusCode == 401) {
        // Handle expired token if necessary
        print("Token expired or unauthorized");
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  // Helper for cleaner code
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
