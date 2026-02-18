import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gold_dent/views/home/patient_form_screen.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../controllers/home_controller/home_controller.dart';

// --- ASOSIY SAHIFA ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    const Color roadBlue = Color(0xFF007AFF);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text("Gold Dent",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 24)),
      ),

      floatingActionButton: Obx(() => controller.isWorkStarted.value
          ? FloatingActionButton.extended(
        onPressed: () => Get.to(() => const PatientFormScreen()), // Alohida sahifaga o'tish
        backgroundColor: roadBlue,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        label: const Text("YANGI BUYURTMA",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
      )
          : const SizedBox()),

      body: Obx(() {
        if (!controller.isWorkStarted.value) return _startWorkBody(controller);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                _statCard("Bemorlar", controller.totalPatients.value.toString(), Icons.people_rounded, roadBlue),
                const SizedBox(width: 12),
                _statCard("Kassa", "${NumberFormat("#,###").format(controller.dailyRevenue.value)} so'm", Icons.account_balance_wallet_rounded, Colors.green),
              ],
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text("BUGUNGI NAVBAT",
                  style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey, fontSize: 13, letterSpacing: 1.1)),
            ),
            const SizedBox(height: 8),
            controller.todayOrders.isEmpty
                ? const Center(child: Padding(
              padding: EdgeInsets.only(top: 80),
              child: Text("Bugun hali bemor qo'shilmagan", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
            ))
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.todayOrders.length,
              itemBuilder: (context, index) {
                final order = controller.todayOrders[index];
                return InkWell(
                  onTap: () => _showOrderDetail(context, order),
                  borderRadius: BorderRadius.circular(24),
                  child: _orderCard(context, order, controller),
                );
              },
            ),
            const SizedBox(height: 100),
          ],
        );
      }),
    );
  }

  // --- PREMIUM DETAL OYNASI ---
  void _showOrderDetail(BuildContext context, Map<String, dynamic> order) {
    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        height: Get.height * 0.8,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(35))),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 25),
            Row(
              children: [
                CircleAvatar(radius: 35, backgroundColor: const Color(0xFF007AFF).withOpacity(0.1), child: Text(order['patientName']?[0].toUpperCase() ?? "?", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF007AFF)))),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(order['patientName'] ?? "Noma'lum", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), Text(order['phone'] ?? "-", style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600))])),
              ],
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: (order['services'] as List).length,
                itemBuilder: (context, i) {
                  final s = order['services'][i];
                  return _detailServiceItem(s);
                },
              ),
            ),
            _bottomTotalBlock(order['totalPrice']),
          ],
        ),
      ),
    );
  }

  Widget _detailServiceItem(Map<String, dynamic> s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFF2F2F7), Colors.white]), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: Row(children: [const Icon(Icons.done_all_rounded, color: Colors.green, size: 20), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s['name'], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)), Text("${s['quantity']} ta", style: const TextStyle(color: Colors.grey, fontSize: 12))])), Text("${NumberFormat("#,###").format(s['price'] * s['quantity'])} so'm", style: const TextStyle(fontWeight: FontWeight.w900))]),
    );
  }

  Widget _bottomTotalBlock(dynamic total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(28)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("JAMI SUMMA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)), Text("${NumberFormat("#,###").format(total)} so'm", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900))]),
    );
  }

  void _showOrderActions(BuildContext context, Map<String, dynamic> order, HomeController controller) {
    Get.bottomSheet(Container(padding: const EdgeInsets.all(24), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))), child: Column(mainAxisSize: MainAxisSize.min, children: [Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 24), decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10))), _buildActionItem(label: "Ma'lumotlarni tahrirlash", icon: Icons.edit_rounded, color: const Color(0xFF007AFF), onTap: () { Get.back(); Get.to(() => PatientFormScreen(doc: order)); }), const SizedBox(height: 12), _buildActionItem(label: "Orderni o'chirish", icon: Icons.delete_outline_rounded, color: Colors.redAccent, onTap: () { Get.back(); _confirmDelete(order, controller); })])));
  }

  // --- QOLGAN STANDART WIDGETLAR ---
  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 22)), const SizedBox(height: 12), Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12))])));
  }

  Widget _orderCard(BuildContext context, Map<String, dynamic> order, HomeController controller) {
    return Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)), child: Column(children: [ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), leading: CircleAvatar(backgroundColor: const Color(0xFF007AFF).withOpacity(0.1), child: Text(order['patientName']?[0].toUpperCase() ?? "?", style: const TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w900))), title: Text(order['patientName'] ?? "Noma'lum", style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text(order['phone'] ?? "Raqam yo'q"), trailing: IconButton(icon: const Icon(Icons.more_horiz_rounded), onPressed: () => _showOrderActions(context, order, controller))), Container(padding: const EdgeInsets.all(14), decoration: const BoxDecoration(color: Color(0xFFF8FAFC), borderRadius: BorderRadius.vertical(bottom: Radius.circular(24))), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_miniInfo("TO'LANDI", "${NumberFormat("#,###").format(order['paidAmount'])} so'm", Colors.green), _miniInfo("QARZ", "${NumberFormat("#,###").format(order['debtAmount'])} so'm", Colors.redAccent), _miniInfo("SANA", order['nextVisit'] ?? "-", Colors.black87)]))]));
  }

  Widget _miniInfo(String label, String value, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w900)), Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color))]);
  }

  Widget _startWorkBody(HomeController controller) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Lottie.asset('assets/lottie/start.json', width: 250, height: 250), const SizedBox(height: 24), const Text("Xayrli kun!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)), const SizedBox(height: 32), SizedBox(width: 220, height: 60, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007AFF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))), onPressed: () => controller.startWork(), child: Obx(() => controller.isLoading.value ? const CircularProgressIndicator(color: Colors.white) : const Text("ISHNI BOSHLASH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)))))]));
  }

  Widget _buildActionItem({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(16)), child: Row(children: [Icon(icon, color: color), const SizedBox(width: 16), Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800)), const Spacer(), const Icon(Icons.arrow_forward_ios_rounded, size: 14)])));
  }

  void _confirmDelete(Map<String, dynamic> order, HomeController controller) {
    Get.dialog(AlertDialog(title: const Text("O'chirish?"), content: Text("${order['patientName']} ma'lumotlari o'chadi."), actions: [TextButton(onPressed: () => Get.back(), child: const Text("BEKOR")), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () { controller.deleteOrder(order); Get.back(); }, child: const Text("O'CHIRISH"))]));
  }

  void _showSuccessAnimation() {
    Get.dialog(Dialog(backgroundColor: Colors.transparent, child: Lottie.asset('assets/lottie/successfully_done.json', repeat: false, onLoaded: (comp) => Future.delayed(const Duration(milliseconds: 1500), () => Get.back()))));
  }
}

// --- ALOHIDA SAHIFA: BEMOR YARATISH VA TAHRIRLASH ---

