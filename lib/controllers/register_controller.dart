import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class RegisterController extends GetxController {
  final String apiUrl = "https://mktdata.com.ng/user/api/signupPHP.php";

  Future<Map<String, dynamic>> register({
    required String fname,
    required String lname,
    required String username,
    required String email,
    required String phone,
    required String password,
    required String transPin,
    String? referer,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          "firstname": fname,
          "lastname": lname,
          "username": username,
          "email": email,
          "phone": phone,
          "password": password,
          "cpassword": password,
          "trans_pin": transPin,
          "submit": "true",
          "ref": referer ?? "",
        },
      );


      final data = jsonDecode(response.body);

      if (data['sWrong'].toString().isEmpty) {
        return {
          "success": false,
          "message": data['sWrong'] ?? "Registration Failed",
        };
      } else {
        return {"success": true, "data": data};
      }
    } catch (e) {
      return {"success": false, "message": "Connection error: $e"};
    }
  }
}
