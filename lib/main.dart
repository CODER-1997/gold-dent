import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/main/debtors_controller.dart';

class DebtorScreen extends StatelessWidget {
  const DebtorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller bir marta yaratiladi va xotiraga yuklanadi
    final controller = Get.put(DebtorController());

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Qarzdorlar",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 22),
        ),
      ),
      body: Column(
        children: [
          // 1. Qidiruv paneli
          _buildSearchBar(controller),

          // 2. Real-time Ro'yxat
          Expanded(
            // StreamBuilder eng yuqorida turishi kerak
            child: StreamBuilder<QuerySnapshot>(
              stream: controller.debtorStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Ulanishda xato yuz berdi"));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF007AFF)));
                }

                // Ma'lumotlar kelganda, filtr mantiqini Obx ichiga olamiz
                return Obx(() {
                  final filteredDebtors = controller.filterList(snapshot.data?.docs ?? []);

                  if (filteredDebtors.isEmpty) {
                    return const Center(
                      child: Text("Qarzdorlar topilmadi", style: TextStyle(color: Colors.grey)),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredDebtors.length,
                    itemBuilder: (context, index) {
                      final debtor = filteredDebtors[index];
                      return _buildDebtorCard(context, debtor);
                    },
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- QIDIRUV PANELI ---
  Widget _buildSearchBar(DebtorController controller) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 15),
      child: TextField(
        onChanged: (value) => controller.searchQuery.value = value,
        decoration: InputDecoration(
          hintText: "Ism bo'yicha qidirish...",
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey, size: 22),
          filled: true,
          fillColor: const Color(0xFFF2F2F7),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  // --- BEMOR KARTASI ---
  Widget _buildDebtorCard(BuildContext context, Map<String, dynamic> debtor) {
    String name = debtor['patientName'] ?? "Noma'lum";
    double debt = double.tryParse(debtor['debtAmount']?.toString() ?? '0') ?? 0;
    String phone = debtor['phone'] ?? "";
    String date = debtor['nextVisit'] ?? "-";

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.priority_high_rounded, color: Colors.red, size: 22),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                      const SizedBox(height: 4),
                      Text("Sana: $date", style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("${NumberFormat("#,###").format(debt)} so'm",
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 16)),
                    const Text("QARZ", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.w800)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () async {
                      final Uri launchUri = Uri(scheme: 'tel', path: phone.replaceAll(RegExp(r'\D'), ''));
                      if (await canLaunchUrl(launchUri)) await launchUrl(launchUri);
                    },
                    icon: const Icon(Icons.call_rounded, size: 18, color: Color(0xFF007AFF)),
                    label: const Text("QO'NG'IROQ", style: TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w900, fontSize: 12)),
                  ),
                ),
                Container(width: 1, height: 20, color: Colors.grey.shade100),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _showSmsDialog(context, debtor),
                    icon: const Icon(Icons.sms_rounded, size: 18, color: Colors.orange),
                    label: const Text("SMS XABAR", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w900, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- SMS MODAL OYNASI ---
  void _showSmsDialog(BuildContext context, Map<String, dynamic> debtor) async {
    // Firebase'dan SMS shablonini yuklash
    var settings = await FirebaseFirestore.instance.collection('Settings').doc('sms_config').get();
    String template = settings.data()?['debtor_template'] ?? "Hurmatli [name], sizning [sum] so'm qarzingiz bor.";

    String patientName = debtor['patientName'] ?? "Bemor";
    String debtSum = NumberFormat("#,###").format(debtor['debtAmount'] ?? 0);
    String finalMessage = template.replaceAll("[name]", patientName).replaceAll("[sum]", debtSum);

    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10))),
            ),
            const Text("SMS Xabarnoma", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(18)),
              child: Text(finalMessage, style: const TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final Uri smsUri = Uri(
                    scheme: 'sms',
                    path: debtor['phone'].toString().replaceAll(RegExp(r'\D'), ''),
                    queryParameters: <String, String>{'body': finalMessage},
                  );
                  if (await canLaunchUrl(smsUri)) {
                    await launchUrl(smsUri);
                    Get.back();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                label: const Text("SMS YUBORISH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}