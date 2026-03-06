import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Sanani formatlash uchun
import '../../controllers/main/main_controller.dart';
import '../../controllers/home_controller/home_controller.dart'; // Navbatlar sonini olish uchun

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF007BFF);
    const Color unselectedColor = Color(0xFF94A3B8);

    final controller = Get.put(MainController());
    // Navbatlar sonini kuzatish uchun HomeController ni topamiz
    final homeController = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade300, width: 0.5)),
        ),
        child: Obx(() => BottomNavigationBar(
          currentIndex: controller.selectedIndex.value,
          onTap: controller.changeIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: primaryColor,
          unselectedItemColor: unselectedColor,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
          items: [
            _buildNavItem(Icons.home_filled, "Asosiy"),

            // --- QAYTA KO'RIK TABI (BADGE BILAN) ---
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.event_note_rounded, size: 24), // Mosroq ikonka
                  Obx(() {
                    // Bugungi sanani olish
                    String today = DateFormat('dd.MM.yyyy').format(DateTime.now());

                    // Bugungi navbatlar sonini hisoblash
                    int count = homeController.todayOrders.where((order) =>
                    order['nextVisit'] == today).length;

                    if (count == 0) return const SizedBox.shrink();

                    return Positioned(
                      right: -6,
                      top: -3,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF3B30), // iOS uslubidagi qizil
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }),
                ],
              ),
              label: "Qayta ko'rik",
            ),

            _buildNavItem(Icons.account_balance_wallet_rounded, "Qarzlar"),
            _buildNavItem(Icons.person_2_rounded, "Profil"),
          ],
        )),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon, size: 24),
      label: label,
    );
  }
}