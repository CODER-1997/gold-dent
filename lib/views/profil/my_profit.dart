import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/home_controller/home_controller.dart';

class MyProfitScreen extends StatefulWidget {
  const MyProfitScreen({super.key});

  @override
  State<MyProfitScreen> createState() => _MyProfitScreenState();
}

class _MyProfitScreenState extends State<MyProfitScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final currencyFormat = NumberFormat("#,###", "uz_UZ");
  // Siz xohlagan format: dd-MM-yyyy HH:mm
  final DateFormat fullDateFormat = DateFormat('dd-MM-yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Mening daromadim",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 22),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF007AFF),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF007AFF),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          tabs: const [
            Tab(text: "Bugun"),
            Tab(text: "Hafta"),
            Tab(text: "Oy"),
          ],
        ),
      ),
      body: Obx(() {
        // Ma'lumotlarni hisoblash mantiqi shu yerda (UI ichida)
        double dailyRev = homeController.dailyRevenue.value;
        int dailyPat = homeController.totalPatients.value;

        // Namuna uchun (Haftalik va oylik mantiqni UI darajasida hisoblash)
        // Agar sizda haftalik stream bo'lmasa, hozircha mavjud ma'lumotdan foydalanamiz
        return TabBarView(
          controller: _tabController,
          physics: const BouncingScrollPhysics(),
          children: [
            // 1. KUNLIK
            _buildProfitView(homeController, "Bugun", dailyRev, dailyPat),

            // 2. HAFTALIK (Mavjud ma'lumot asosida)
            _buildProfitView(homeController, "Hafta", dailyRev, dailyPat, isWeekly: true),

            // 3. OYLIK
            _buildProfitView(homeController, "Oy", dailyRev, dailyPat, isMonthly: true),
          ],
        );
      }),
    );
  }

  Widget _buildProfitView(HomeController controller, String period, double total, int patients, {bool isWeekly = false, bool isMonthly = false}) {
    if (!controller.isWorkStarted.value && !isWeekly && !isMonthly) {
      return _buildEmptyState();
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        _buildTotalRevenueCard(total, patients, "$period tushumi"),
        const SizedBox(height: 30),
        Text(
          "$period hisoboti va tranzaksiyalar",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        const SizedBox(height: 15),

        // Tranzaksiyalarni builder orqali chiqarish
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.todayOrders.length,
          itemBuilder: (context, index) {
            final order = controller.todayOrders[index];
            return _buildOrderTile(order);
          },
        ),
      ],
    );
  }

  Widget _buildOrderTile(Map<String, dynamic> order) {
    // Vaqtni qismlarga ajratish
    String datePart = "";
    String timePart = "";

    try {
      DateTime dt;
      if (order['date'] != null) {
        dt = (order['date'] as Timestamp).toDate();
      } else {
        // Agar date bo'lmasa, bugungi sana va order['time']dan foydalanamiz
        String rawTime = order['time'] ?? "00:00";
        dt = DateTime.now();
        timePart = rawTime;
      }

      // Chiroyli formatlash: "25-Iyun, 2026" va "12:45"
      datePart = DateFormat('d-MMM, yyyy', 'uz_UZ').format(dt); // Masalan: 25-Iyun, 2026
      timePart = DateFormat('HH:mm').format(dt);
    } catch (e) {
      datePart = "Noma'lum sana";
      timePart = "--:--";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 8)
          )
        ],
      ),
      child: Row(
        children: [
          // Chap tomondagi holat belgisi
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFF34C759).withOpacity(0.1),
                shape: BoxShape.circle
            ),
            child: const Icon(Icons.check_circle_rounded, color: Color(0xFF34C759), size: 24),
          ),
          const SizedBox(width: 15),

          // Markazdagi ma'lumotlar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    order['patientName'] ?? "Bemor",
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, letterSpacing: -0.5)
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.calendar_month_outlined, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(datePart, style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 10),
                    Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(timePart, style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),

          // O'ng tomondagi summa
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "+${currencyFormat.format(order['paidAmount'] ?? 0)}",
                style: const TextStyle(color: Color(0xFF34C759), fontWeight: FontWeight.w900, fontSize: 16),
              ),
              const Text(
                "so'm",
                style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildTotalRevenueCard(double revenue, int patients, String title) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF007AFF), Color(0xFF00C6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: const Color(0xFF007AFF).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(currencyFormat.format(revenue), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)),
              const SizedBox(width: 8),
              const Text("so'm", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(color: Colors.white24),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSmallStat("Bemorlar", patients.toString(), Icons.people_outline),
              _buildSmallStat("O'rtacha chek", currencyFormat.format(patients > 0 ? revenue / patients : 0), Icons.payments_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 15),
          const Text("Hali ma'lumot yo'q", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}