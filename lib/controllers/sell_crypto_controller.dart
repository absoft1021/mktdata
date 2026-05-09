import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as d;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class SellCryptoController extends GetxController {
  final box = GetStorage();
  final dio = d.Dio();

  RxBool isLoading = false.obs;
  RxBool isSubmitting = false.obs;

  RxList coins = [].obs;
  RxMap selectedCoin = {}.obs;

  // Separate observables for clarity and UI state persistence
  RxMap selectedNetwork = {}.obs;
  RxMap selectedExchanger = {}.obs;

  Rx<File?> imageFile = Rx<File?>(null);
  RxDouble rate = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCoins();
  }

  Future<void> fetchCoins() async {
    try {
      isLoading.value = true;
      final response = await dio.get(
        "https://mktdata.com.ng/api/v1/coins-sell",
        options: d.Options(
          headers: {"Authorization": "${box.read("token") ?? ""}"},
        ),
      );

      if (response.statusCode == 200) {
        // Handle potential different data structures
        var data = response.data['results']?['info'] ?? [];
        coins.assignAll(data);

        if (coins.isNotEmpty) {
          updateSelectedCoin(coins[0]);
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch crypto data");
    } finally {
      isLoading.value = false;
    }
  }

  void updateSelectedCoin(dynamic coin) {
    selectedCoin.value = coin;
    rate.value = double.tryParse(coin['rate']?.toString() ?? '0.0') ?? 0.0;

    // Clear selections when coin changes to prevent wrong network/address combos
    selectedNetwork.clear();
    selectedExchanger.clear();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Optimize image size for upload
      );
      if (pickedFile != null) {
        imageFile.value = File(pickedFile.path);
      }
    } catch (e) {
      Get.snackbar("Image Error", "Could not access gallery");
    }
  }

  Future<void> processSale({
    required String amount,
    required bool isWallet,
  }) async {
    if (imageFile.value == null) {
      Get.snackbar("Missing Proof", "Please upload payment proof");
      return;
    }

    final coin = selectedCoin;
    final source = isWallet ? selectedNetwork : selectedExchanger;
    final profile = box.read("profile") ?? {};

    try {
      isSubmitting.value = true;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse("https://mktdata.com.ng/api/v1/sell_crypto"),
      );
      request.headers.addAll({
        "Authorization": box.read("token") ?? "",
        "Accept": "application/json",
      });

      // Force .jpg (no path package needed)
      String filename = imageFile.value!.path.split('/').last;
      if (filename.contains('.')) {
        filename = filename.substring(0, filename.lastIndexOf('.'));
      }
      filename += '.jpg';

      request.fields.addAll({
        "amount": amount,
        "coin_type": (coin['name'] ?? '').toString(),
        "source_wallet":
            isWallet ? (source['wallet_address'] ?? '') : (source['uid'] ?? ''),
        "trans_pin": profile['trans_pin'] ?? "",
        "comment": "Sale",
        "network": (source['name'] ?? '').toString(),
        "bank_name": (profile['bank_name'] ?? '').toString(),
        "account_number": (profile['account_number'] ?? '').toString(),
        "account_name": (profile['account_name'] ?? '').toString(),
      });

      request.files.add(
        await http.MultipartFile.fromPath(
          'proof',
          imageFile.value!.path,
          filename: filename,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back();
        Get.back();
        Get.snackbar(
          "Success",
          "Transaction Submitted Successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        print("Server Error: ${response.body}");
        final data = jsonDecode(response.body);
        final msg = data['response'] ?? data['message'] ?? "Transaction failed";
        Get.snackbar(
          "Failed",
          msg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Error: $e");
      Get.snackbar(
        "Failed",
        "Something went wrong",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> processSaleX({
    required String amount,
    required bool isWallet,
  }) async {
    if (imageFile.value == null) {
      Get.snackbar("Missing Proof", "Please upload payment proof");
      return;
    }

    final coin = selectedCoin;
    final source = isWallet ? selectedNetwork : selectedExchanger;
    final profile = box.read("profile") ?? {};

    try {
      isSubmitting.value = true;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse("https://mktdata.com.ng/api/v1/sell_crypto"),
      );
      request.headers.addAll({
        "Authorization": box.read("token") ?? "",
        "Accept": "application/json",
      });

      request.fields.addAll({
        "amount": amount,
        "coin_type": (coin['name'] ?? '').toString(),
        "source_wallet":
            isWallet ? (source['wallet_address'] ?? '') : (source['uid'] ?? ''),
        "trans_pin": "1111",
        "comment": "Sale",
        "network": (source['name'] ?? '').toString(),
        "bank_name": (profile['bank_name'] ?? '').toString(),
        "account_number": (profile['account_number'] ?? '').toString(),
        "account_name": (profile['account_name'] ?? '').toString(),
      });

      request.files.add(
        await http.MultipartFile.fromPath(
          'proof',
          imageFile.value!.path,
          filename: basename(imageFile.value!.path),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back();
        Get.back();
        Get.snackbar(
          "Success",
          "Transaction Submitted Successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        print("Server Error: ${response.body}");
        final data = jsonDecode(response.body);
        final msg = data['response'] ?? data['message'] ?? "Transaction failed";
        Get.snackbar(
          "Failed",
          msg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Error: $e");
      Get.snackbar(
        "Failed",
        "Something went wrong",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
