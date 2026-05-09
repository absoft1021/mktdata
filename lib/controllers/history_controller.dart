import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class HistoryController extends GetxController {
  final box = GetStorage();

  var transactions = [].obs; // Changed from coinsList to transactions
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getTransactions();
  }

  Future<void> getTransactions() async {
    try {
      isLoading.value = true;
      String? token = box.read("token");
      final response = await http.get(
        Uri.parse("https://mktdata.com.ng/user/api/airtime_historyPHP.php"),
        headers: {"Authorization": token ?? ""},
      );

      print(response.body);

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
}
