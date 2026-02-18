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
    final controller = Get.put(DebtorController());

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Qarzdorlar",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 24)),
      ),
      body: Column(
        children: [
          // 1. Qidiruv paneli
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 15),
            child: TextField(
              onChanged: (value) => controller.searchQuery.value = value,
              decoration: InputDecoration(
                hintText: "Ism bo'yicha qidirish...",
                prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFF2F2F7),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),

          // 2. Real-time Ro'yxat
          StreamBuilder<QuerySnapshot>(
            stream: controller.debtorStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text("Ulanishda xato yoki Index xatosi"));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF007AFF)));
              }

              // Controller ichidagi filter metodini chaqiramiz
              final filteredDebtors = controller.filterList(snapshot.data?.docs ?? []);

              if (filteredDebtors.isEmpty) {
                return const Center(child: Text("Qarzdorlar topilmadi", style: TextStyle(color: Colors.grey)));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredDebtors.length,
                itemBuilder: (context, index) => _buildDebtorCard(filteredDebtors[index]),
              );
            },
           ),
        ],
      ),
    );
  }

  Widget _buildDebtorCard(Map<String, dynamic> debtor) {
    String name = debtor['patientName'] ?? "Noma'lum";
    double debt = (debtor['debtAmount'] ?? 0).toDouble();
    String phone = debtor['phone'] ?? "";
    String date = debtor['nextVisit'] ?? "-";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
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
                  child: const Icon(Icons.priority_high_rounded, color: Colors.red, size: 24),
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
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () async {
                      final Uri launchUri = Uri(scheme: 'tel', path: phone.replaceAll(RegExp(r'\D'), ''));
                      if (await canLaunchUrl(launchUri)) await launchUrl(launchUri);
                    },
                    icon: const Icon(Icons.call_rounded, size: 20, color: Color(0xFF007AFF)),
                    label: const Text("QO'NG'IROQ", style: TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w900, fontSize: 13)),
                  ),
                ),
                Container(width: 1, height: 20, color: Colors.grey.shade200),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () { /* Profil sahifasiga o'tish */ },
                    icon: const Icon(Icons.person_search_rounded, size: 20, color: Colors.grey),
                    label: const Text("PROFIL", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}