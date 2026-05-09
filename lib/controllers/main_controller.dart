import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class MainController extends GetxController {
  final box = GetStorage();

  final String profileUrl =
      "https://mktdata.com.ng/user/api/current_user_state.php";

  var userProfile = {}.obs;
  var bankAccounts = [].obs;
  var coinsList = [].obs;
  var isLoading = false.obs;
  var isAssetsExpanded = false.obs;

  var transactions = [].obs; // Changed from coinsList to transactions

  // FIX: This must stay reactive for your KycPage to work
  var kycStatus = '00'.obs;
  var walletBal = 'Loading..'.obs;

  @override
  void onInit() {
    super.onInit();
    // Load local cache immediately so the UI isn't empty on launch
    userProfile.value = box.read("profile") ?? {};
    bankAccounts.value = box.read("profile")["bank_accts"] ?? [];
    walletBal.value = box.read('balance');
    print(walletBal);
    // Load saved KYC status
    kycStatus.value = box.read("kyc_status") ?? '00';

    getUserProfile();
  }

  Future<void> getTransactions() async {
    try {
      isLoading.value = true;
      String? token = box.read("token");
      final response = await http.get(
        Uri.parse("https://mktdata.com.ng/user/api/airtime_historyPHP.php"),
        headers: {"Authorization": token ?? ""},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        transactions.value = data;
      }
    } catch (e) {
      print("History Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

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
      if (response.statusCode == 200) {
        Map<String, dynamic> profileData = jsonDecode(response.body);
        await box.write("userData", profileData);
        getTransactions();
        // Safely update balance
        if (profileData.containsKey('balance')) {
          await box.write("balance", profileData['balance'].toString());
        }
      } else if (response.statusCode == 401) {
        // Handle expired token if necessary
        print("Token expired or unauthorized");
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }
}
