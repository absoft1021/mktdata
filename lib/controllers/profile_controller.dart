import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ProfileController extends GetxController {
  final box = GetStorage();

  // Observables for user data
  RxString name = "User".obs;
  RxString email = "user@example.com".obs;
  RxString phone = "08012345678".obs;
  RxString tier = "Tier 1".obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  void loadUserData() {
    name.value = box.read("full_name") ?? "John Doe";
    email.value = box.read("email") ?? "john.doe@gmail.com";
    phone.value = box.read("phone") ?? "Not Available";
  }

  void logout() {
    box.erase();
    Get.offAllNamed('/login'); // Redirect to login
  }
}
