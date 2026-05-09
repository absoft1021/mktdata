import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mktdata/controllers/main_controller.dart';

class KycController extends GetxController {
  final box = GetStorage();
  final mainC = Get.find<MainController>();

  RxBool isSubmitting = false.obs;
  Rx<File?> selectedImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

  // Pick Image from Gallery
  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Compresses image to save data/bandwidth
    );
    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  // Tier 2 Submission (NIN/BVN)
  Future<void> submitTier2({required String nin, required String bvn}) async {
    if (nin.length != 11 || bvn.length != 11) {
      _showSnack(
        "Invalid Input",
        "NIN and BVN must be 11 digits",
        Colors.orange,
      );
      return;
    }

    try {
      isSubmitting.value = true;
      final response = await http.post(
        Uri.parse("https://mktdata.com.ng/api/v1/submit_kyc"),
        headers: {
          "Authorization": box.read("token") ?? "",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"nin": nin, "bvn": bvn}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        //   mainC.updateKyc("02"); // Status 02 = Tier 2 Pending
        _showSnack("Success", "Identity submitted for review", Colors.green);
      } else {
        final error = jsonDecode(response.body);
        _showSnack(
          "Error",
          error['response'] ?? "Submission failed",
          Colors.red,
        );
      }
    } catch (e) {
      _showSnack("Connection Error", "Please check your internet", Colors.red);
    } finally {
      isSubmitting.value = false;
    }
  }

  // Tier 3 Submission (Image + Address + PIN)

  Future<void> submitTier3({
    required String address,
    required String pin,
  }) async {
    if (pin.isEmpty || selectedImage.value == null) {
      _showSnack(
        "Required",
        "Please provide PIN, and proof image",
        Colors.orange,
      );
      return;
    }

    try {
      isSubmitting.value = true;
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("https://mktdata.com.ng/api/v1/submit_kyc_proof"),
      );

      request.headers.addAll({
        "Authorization": box.read("token") ?? "",
        "Accept": "application/json",
      });

      // Use the pin passed from the text controller
      request.fields['trans_pin'] = box.read("profile")['trans_pin'] ?? "";
      // request.fields['proof'] = address;

      request.files.add(
        await http.MultipartFile.fromPath('proof', selectedImage.value!.path),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Decode the response body to get the server's message
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        //   mainC.updateKyc("03"); // Status 03 = Tier 3 Pending

        // Use the server's success message if available
        String successMsg =
            responseData['response'] ?? "Address proof submitted for review";
        _showSnack("Success", successMsg, Colors.green);
      } else {
        // Extract the specific error from the JSON: "Invalid file type..." etc.
        String errorMsg =
            responseData['response'] ??
            "Verification failed. Check your details.";
        _showSnack("Error", errorMsg, Colors.red);
      }
    } catch (e) {
      _showSnack("Error", "Something went wrong. Try again.", Colors.red);
    } finally {
      isSubmitting.value = false;
    }
  }

  void _showSnack(String title, String msg, Color color) {
    Get.snackbar(
      title,
      msg,
      backgroundColor: color,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(15),
    );
  }
}
