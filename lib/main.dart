import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // GetX ni qo'shdik
import 'package:get_storage/get_storage.dart';
import 'package:gold_dent/views/home/main_screen.dart';
import 'package:gold_dent/views/initial_screen/intro_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    // 'isFirstTime' kalitini tekshiramiz, agar bo'sh bo'lsa 'true' deb olamiz
    bool isFirstTime = box.read('isFirstTime') ?? true;

    return GetMaterialApp( // MaterialApp emas, GetMaterialApp!
      debugShowCheckedModeBanner: false,
      title: 'Stomatolog Ilovasi',
      // Mantiq: Agar birinchi marta bo'lsa IntroScreen, bo'lmasa MainScreen
      home: isFirstTime ? const IntroScreen() : const MainScreen(),
    );
  }
}