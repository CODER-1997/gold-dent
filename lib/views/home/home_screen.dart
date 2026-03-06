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
        actions: [
          // BUGUNGI NAVBATDAGILAR UCHUN OGOHLANTIRISH
          Obx(() {
            // Bugungi sanani formatlash
            String today = DateFormat('dd.MM.yyyy').format(DateTime.now());

            // Faqat nextVisit bugunga to'g'ri keladiganlarni sanash
            int appointmentsCount = controller.todayOrders.where((order) =>
            order['nextVisit'] == today).length;

            if (appointmentsCount == 0) return const SizedBox();

            return Container(
              height: 64,
              margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, ),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.notifications_active_rounded,
                      color: Colors.red.shade700, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    "$appointmentsCount ta navbat",
                    style: TextStyle(
                      color: Colors.red.shade900,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
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
        height: Get.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xFFF8F9FB),
          borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // --- TOP HEADER LINE AND CLOSE BUTTON ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40), // Balans uchun bo'sh joy
                  Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.close_rounded, color: Colors.red, size: 33),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                children: [
                  // --- PROFILE HEADER ---
                  _buildOrderInfoProfile(order),
                  const SizedBox(height: 24),

                  // --- FINANCIAL SUMMARY ---
                  _buildFinanceRow(order),
                  const SizedBox(height: 32),

                  // --- SERVICES SECTION ---
                  const Text("AMALGA OSHIRILGAN MUOLAJALAR",
                      style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blueGrey, fontSize: 11, letterSpacing: 1.1)),
                  const SizedBox(height: 12),
                  ... (order['services'] as List).map((s) => _buildEnhancedServiceCard(s)).toList(),

                  const SizedBox(height: 24),
                  if (order['time'] != null)
                    Center(child: Text("Qabul vaqti: ${DateFormat('HH:mm, dd.MM.yyyy').format(DateTime.parse(order['time']))}",
                        style: const TextStyle(color: Colors.grey, fontSize: 12))),
                ],
              ),
            ),

            // --- BOTTOM ACTIONS ---
            _buildOrderBottomActions(order),
          ],
        ),
      ),
    );
  }
  // Bemor profili bloki
  Widget _buildOrderInfoProfile(Map<String, dynamic> order) {
    return Row(
      children: [
        Container(
          width: 70, height: 70,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blue.shade400, Colors.blue.shade700]),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Center(child: Text(order['patientName']?[0].toUpperCase() ?? "?",
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white))),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order['patientName'] ?? "Noma'lum",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.phone_iphone_rounded, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(order['phone'] ?? "-", style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // To'lov ma'lumotlari (Paid / Debt)
  Widget _buildFinanceRow(Map<String, dynamic> order) {
    return Row(
      children: [
        _miniFinanceCard("TO'LANDI", "${NumberFormat("#,###").format(order['paidAmount'])}", Colors.green),
        const SizedBox(width: 12),
        _miniFinanceCard("QARZDORLIK", "${NumberFormat("#,###").format(order['debtAmount'])}", Colors.redAccent),
      ],
    );
  }

  Widget _miniFinanceCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color.withOpacity(0.06), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.1))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text("$value so'm", style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  // Xizmat kartasi (Tishlar bilan)
  Widget _buildEnhancedServiceCard(Map<String, dynamic> s) {
    List<dynamic> teeth = s['teeth'] ?? [];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(s['name'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              Text("${NumberFormat("#,###").format(s['price'])} so'm", style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.blue)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                child: Text("Miqdor: ${s['quantity']} ta", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              ),
              const SizedBox(width: 8),
              if (teeth.isNotEmpty)
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: teeth.map((t) => Container(
                        margin: const EdgeInsets.only(right: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.shade100)),
                        child: Text("$t-tish", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
                      )).toList(),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Pastki Jami summa va tugmalar
  Widget _buildOrderBottomActions(Map<String, dynamic> order) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("UMUMIY SUMMA", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w900)),
                Text("${NumberFormat("#,###").format(order['totalPrice'])} so'm",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            onPressed: () {
              Get.back();
              Get.to(() => PatientFormScreen(doc: order));
            },
            child: const Row(
              children: [
                Icon(Icons.edit_document, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text("TAHRIRLASH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
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
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        elevation: 0,
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Yuqoridagi ogohlantirish ikonkasi
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_sweep_rounded,
                  color: Colors.redAccent,
                  size: 38,
                ),
              ),
              const SizedBox(height: 20),

              // Sarlavha
              const Text(
                "Orderni o'chirish",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),

              // Matn
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
                  children: [
                    const TextSpan(text: "Haqiqatdan ham "),
                    TextSpan(
                      text: "${order['patientName']}",
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: "ga tegishli barcha buyurtma ma'lumotlarini o'chirib tashlamoqchimisiz?"),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Tugmalar bloki
              Row(
                children: [
                  // Bekor qilish tugmasi
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text(
                          "BEKOR QILISH",
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Tasdiqlash tugmasi
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          controller.deleteOrder(order);
                          Get.back();
                          // Success xabarnomasi uchun:
                          Get.snackbar(
                            "O'chirildi",
                            "Ma'lumotlar muvaffaqiyatli tozalandi",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.black87,
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(15),
                            borderRadius: 15,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        label: const Text(
                          "O'CHIRISH",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true, // Tashqarini bossa yopiladi
    );
  }


}

// --- ALOHIDA SAHIFA: BEMOR YARATISH VA TAHRIRLASH ---

