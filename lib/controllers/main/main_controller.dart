import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:gold_dent/views/home/debtors.dart';

import '../../views/home/home_screen.dart';
import '../../views/home/in_progress_screen.dart';
import '../../views/profil/profile_screen.dart';

class MainController extends GetxController {
  // Tanlangan sahifa indeksi
  var selectedIndex = 0.obs;

  // Sahifalar ro'yxati
  final screens = [
    HomeScreen(),
    const InProgressScreen(),
    const DebtorScreen(),
    const ProfileScreen(),
  ];

  void changeIndex(int index) {
    selectedIndex.value = index;
  }
}