import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:mktdata/main_page.dart';
import 'package:mktdata/auth/set_pin_page.dart';

class LoginController extends GetxController {
  final box = GetStorage();
  static const String baseUrl = 'https://mktdata.com.ng/user/api/';

  var isLoading = false.obs;

  void launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is String) {
      if (raw.trim().isEmpty) {
        throw FormatException('Empty string instead of JSON object');
      }
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      throw FormatException('Expected a JSON object but got ${decoded.runtimeType}');
    }
    throw FormatException('Expected a JSON object but got ${raw.runtimeType}');
  }

  void login(String username, String password) async {
    try {
      isLoading.value = true;
      final response = await http.post(
        Uri.parse('${baseUrl}loginPHP.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': username,
          'password': password,
          'submit': 'true',
        },
      );

      isLoading.value = false;

      if (response.statusCode == 200) {
        final data = _asMap(response.body);

        if (data['success'] == 1 || data['success'] == "1") {
          final profileRaw = data['profile'];
          if (profileRaw != null && profileRaw != '') {
            await box.write("username", username ?? '');
            await box.write("password", password ?? '');
            
            final profile = _asMap(profileRaw);
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
      final token = box.read('token') ?? '';
      final response = await http.get(
        Uri.parse('${baseUrl}current_user_state.php'),
        headers: {
          'Authorization': '$token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final profileData = _asMap(response.body);
        await box.write("userData", profileData);

        if (profileData.containsKey('balance')) {
          await box.write("balance", profileData['balance'].toString());
        }
        String? savedPin = box.read('pin');

        Get.offAll(
          () => savedPin != null && savedPin.isNotEmpty
              ? MainPage()
              : SetPinPage(),
        );
        
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