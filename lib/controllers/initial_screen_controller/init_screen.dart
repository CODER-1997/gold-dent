import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';

import '../../views/home/main_screen.dart';

class IntroController extends GetxController {
  var currentPage = 0.obs; // Hozirgi sahifa indeksi
  final PageController pageController = PageController();

  // Onboarding ma'lumotlari
  final List<Map<String, String>> introData = [
    {
      "title": "Bemorlarni boshqarish",
      "desc": "Barcha bemorlaringiz ma'lumotlari bir joyda xavfsiz saqlanadi.",
      "icon": "assets/intro_screen/patients.png" // yoki Icons.people
    },
    {
      "title": "Navbatlarni rejalashtirish",
      "desc": "Vaqtingizni unumli taqsimlang va navbatlarni oson boshqaring.",
      "icon": "assets/intro_screen/calendar.png"
    },
    {
      "title": "Moliya va qarzdorlik",
      "desc": "Pulingizni va hisobotlarni oson boshqaring !",
      "icon": "assets/intro_screen/img.png"
    }
  ];

  void next() {
    if (currentPage.value < introData.length - 1) {
      pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      finishIntro();
    }
  }

  void finishIntro() {
    GetStorage().write('isFirstTime', false);
    Get.offAll(() => const MainScreen());
  }
}