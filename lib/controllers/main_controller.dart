import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mktdata/utils/api_client.dart';

class MainController extends GetxController {
  final box = GetStorage();
  final api = ApiClient.to;

  var userProfile = {}.obs;
  var bankAccounts = [].obs;
  var coinsList = [].obs;
  var isLoading = false.obs;
  var isAssetsExpanded = false.obs;

  var transactions = [].obs;

  var kycStatus = '00'.obs;
  var walletBal = 'Loading..'.obs;

  @override
  void onInit() {
    super.onInit();
    userProfile.value = box.read("profile") ?? {};
    bankAccounts.value = box.read("profile")?["bank_accts"] ?? [];
    walletBal.value = box.read('balance') ?? '0.00';
    kycStatus.value = box.read("kyc_status") ?? '00';

    getUserProfile();
  }

  Future<void> getTransactions() async {
    try {
      isLoading.value = true;
      final response = await api.get('airtime_historyPHP.php');
      if (response.statusCode == 200) {
        transactions.value = response.data;
      }
    } catch (e) {

    } finally {
      isLoading.value = false;
    }
  }

  void getUserProfile() async {
    try {
      final response = await api.get('current_user_state.php');
      if (response.statusCode == 200) {
        Map<String, dynamic> profileData = response.data;
        await box.write("userData", profileData);
        getTransactions();
        if (profileData.containsKey('balance')) {
          await box.write("balance", profileData['balance'].toString());
          walletBal.value = profileData['balance'].toString();
        }
      }
    } catch (e) {

    }
  }
}
