import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
 import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gold_dent/views/home/main_screen.dart';
import 'package:permission_handler/permission_handler.dart'; // Import qilingan
import 'package:gold_dent/views/home/home_screen.dart';
import 'package:gold_dent/views/initial_screen/intro_screen.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('uz_UZ', null);
  // Storage va Firebaseawait
   await GetStorage.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);

  // SMS ruxsatnomasini ilova boshlanishida tekshirish
  await _checkSmsPermission();

  runApp(const MyApp());
}

// SMS ruxsatnomasini so'rash funksiyasi
Future<void> _checkSmsPermission() async {
  var status = await Permission.sms.status;
  if (status.isDenied) {
    // Agar ruxsat berilmagan bo'lsa, so'raymiz
    await Permission.sms.request();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    bool isFirstTime = box.read('isFirstTime') ?? true;

    return GetMaterialApp(
      title: 'Gold Dent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),

      // InitRoute mantiqi
      initialRoute: isFirstTime ? '/init' : '/home',

      getPages: [
        GetPage(name: '/init', page: () => const IntroScreen()),
        GetPage(name: '/home', page: () => const MainScreen()),
      ],
    );
  }
}