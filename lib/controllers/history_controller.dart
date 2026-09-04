import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class HistoryController extends GetxController {
  final box = GetStorage();

  var transactions = [].obs;
  var filteredTransactions = [].obs;
  var isLoading = false.obs;
  var selectedFilter = 'All'.obs;

  final List<String> filterOptions = [
    'All',
    'Airtime',
    'Data',
    'Wallet Topup',
    'Electricity',
    'Cable',
    'Datacard',
  ];

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
        Uri.parse("https://mktdata.com.ng/user/api/data_historyPHP2.php"),
        headers: {"Authorization": token ?? ""},
      ).timeout(const Duration(seconds: 15));



      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);

        if (jsonData['status'] == 'success' && jsonData['data'] != null) {
          List<dynamic> allTransactions = [];

          // Extract transactions from all categories
          final data = jsonData['data'] as Map<String, dynamic>;

          // Add airtime transactions
          if (data['airtime'] is List) {
            allTransactions.addAll(data['airtime']);
          }

          // Add data transactions
          if (data['data'] is List) {
            allTransactions.addAll(data['data']);
          }

          // Add wallet/funding transactions
          if (data['wallet'] is List) {
            allTransactions.addAll(data['wallet']);
          }

          // Add datacard transactions
          if (data['datacard'] is List) {
            allTransactions.addAll(data['datacard']);
          }

          // Add exampin transactions
          if (data['exampin'] is List) {
            allTransactions.addAll(data['exampin']);
          }

          // Add electricity transactions
          if (data['electricity'] is List) {
            allTransactions.addAll(data['electricity']);
          }

          // Add cable transactions
          if (data['cable'] is List) {
            allTransactions.addAll(data['cable']);
          }

          // Sort transactions by date (newest first)
          allTransactions.sort((a, b) {
            try {
              String dateA = _parseDate(a['date'].toString());
              String dateB = _parseDate(b['date'].toString());
              return dateB.compareTo(dateA);
            } catch (e) {
              return 0;
            }
          });

          transactions.value = allTransactions;
          applyFilter('All'); // Apply default filter

        }
      }
    } catch (e) {

    } finally {
      isLoading.value = false;
    }
  }

  void applyFilter(String filter) {
    selectedFilter.value = filter;

    if (filter == 'All') {
      filteredTransactions.value = List.from(transactions);
    } else {
      filteredTransactions.value = transactions
          .where((tx) =>
              (tx['type'] ?? '').toString().toLowerCase() ==
              filter.toLowerCase())
          .toList();
    }
  }

  // Helper function to standardize date format for comparison
  String _parseDate(String dateStr) {
    try {
      // Handle format: "17-08-2026 / 05:08pm" or "2026-08-17 05:13pm"
      if (dateStr.contains('/')) {
        // Format: "17-08-2026 / 05:08pm"
        final parts = dateStr.split('/')[0].trim().split('-');
        return "${parts[2]}-${parts[1]}-${parts[0]}"; // Convert to YYYY-MM-DD
      } else {
        // Format: "2026-08-17 05:13pm" - already in good format
        return dateStr.split(' ')[0];
      }
    } catch (e) {
      return dateStr;
    }
  }
}
