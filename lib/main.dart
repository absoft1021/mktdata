import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mktdata/auth/login_page.dart';
import 'package:mktdata/auth/resume_page.dart';
import 'package:mktdata/utils/app_colors.dart';
//import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() async {
  await GetStorage.init();

  // OneSignal.initialize("5d81d1f9-35d5-4418-a6e0-dfcc0ff0f7cc");
  // OneSignal.Notifications.requestPermission(true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();

    return GetMaterialApp(
      title: 'MKTdata',
      debugShowCheckedModeBanner: false,

      // Default Light Theme
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.bgColorLight,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
      ),

      // Dark Theme
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bgColorDark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),

      themeMode: ThemeMode.system,

      home:
          box.read('token') == null || box.read('token').isEmpty
              ? LoginPage()
              : ResumePage(),
    );
  }
}
