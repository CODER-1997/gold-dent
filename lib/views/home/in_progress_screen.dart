import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../controllers/main/in_progress_controller.dart';

class InProgressScreen extends StatelessWidget {
  const InProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InProgressController());
    const Color accentBlue = Color(0xFF007AFF);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F7),
        elevation: 0,
        title: const Text(
          "Jarayonlar",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 28),
        ),
      ),
      body: Column(
        children: [
          // 1. Premium Segmented Control
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 15),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade300.withOpacity(0.5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Obx(() => Row(
                children: [
                  _buildTab(controller, 0, "Faol"),
                  _buildTab(controller, 1, "Navbat"),
                  _buildTab(controller, 2, "Tugallangan"),
                ],
              )),
            ),
          ),

          // 2. PageView (Swipe qilinadigan qism)
          Expanded(
            child: PageView(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              children: [
                _buildListPage("BUGUNGI NAVBATLAR", [
                  _buildRoadCard("Sardor Erkinov", "Braket o'rnatish", "14:00", "Qabulda", Colors.green, Icons.play_circle_fill),
                  _buildRoadCard("Lola Ahmedova", "Implantatsiya", "15:30", "Kutilmoqda", accentBlue, Icons.pause_circle_filled),
                ]),
                _buildListPage("NAVBBATDAGILAR", [
                  _buildRoadCard("Jasur Olimov", "Konsultatsiya", "09:00", "Ertaga", Colors.orange, Icons.event),
                ]),
                _buildListPage("YAKUNLANGANLAR", [
                  _buildRoadCard("Akmal Shokirov", "Plomba", "12:00", "Tugallandi", Colors.grey, Icons.check_circle),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Sahifa ro'yxati (Swipe uchun)
  Widget _buildListPage(String header, List<Widget> cards) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _buildSectionHeader(header),
        ...cards,
        const SizedBox(height: 100), // Bottom nav xalaqit bermasligi uchun
      ],
    );
  }

  // Dinamik Tab
  Widget _buildTab(InProgressController controller, int index, String label) {
    bool isActive = controller.selectedTab.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive ? [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))
            ] : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? Colors.black : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Road24 Premium Karta
  Widget _buildRoadCard(String name, String service, String time, String status, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2), // Tiniqlik beradi
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    Text(service, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(time, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Batafsil", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13)),
              Icon(Icons.chevron_right_rounded, color: Colors.blue, size: 18),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 10),
      child: Text(
        title,
        style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2),
      ),
    );
  }
}