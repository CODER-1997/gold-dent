import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/home_controller/home_controller.dart';
import '../../controllers/main/in_progress_controller.dart';
import '../../services/sms_service.dart';

class InProgressScreen extends StatelessWidget {
  const InProgressScreen({super.key});

  // SMS yuborish dialogi
  void _showAppointmentSmsDialog(BuildContext context, Map<String, dynamic> patient) async {
    DocumentSnapshot settingsDoc;
    try {
      settingsDoc = await FirebaseFirestore.instance.collection('Settings').doc('sms_config').get();
    } catch (e) {
      Get.snackbar("Xato", "Server bilan bog'lanishda xatolik: $e");
      return;
    }

    String template = (settingsDoc.data() as Map<String, dynamic>?)?['appointment_template'] ??
        "Hurmatli [name], bugun soat [time] da qabulingiz bor. Sizni kutib qolamiz!";

    String patientName = patient['patientName'] ?? "Bemor";
    String appointmentTime = patient['nextVisit']?.toString() ?? "Belgilanmagan";
    String phoneNumber = (patient['phone'] ?? "").toString().replaceAll(RegExp(r'\D'), '');

    if (appointmentTime.contains(' ')) {
      appointmentTime = appointmentTime.split(' ').last;
    }

    String finalMessage = template
        .replaceAll("[name]", patientName)
        .replaceAll("[time]", appointmentTime);

    Get.bottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50, height: 5,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(color: const Color(0xFFE0E0E5), borderRadius: BorderRadius.circular(10)),
            ),
            const Icon(Icons.sms_rounded, size: 32, color: Color(0xFF2563EB)),
            const SizedBox(height: 16),
            const Text("SMS Tasdiqlash", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(finalMessage, style: const TextStyle(fontSize: 16, height: 1.4)),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F5F9),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      child: const Text("Bekor qilish", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
                        try {
                          await SMSService().sendSMS(phoneNumber, finalMessage);
                          String todayId = DateFormat('yyyy-MM-dd').format(DateTime.now());
                          var orderDoc = await FirebaseFirestore.instance.collection('DentisOrders').doc(todayId).get();

                          if (orderDoc.exists) {
                            List<dynamic> orders = List.from(orderDoc.data()?['orders'] ?? []);
                            int index = orders.indexWhere((e) => e['id'].toString() == patient['id'].toString());

                            if (index != -1) {
                              orders[index]['is_notified'] = true;
                              orders[index]['notified_at'] = DateTime.now().toIso8601String();
                              await FirebaseFirestore.instance.collection('DentisOrders').doc(todayId).update({'orders': orders});
                            }
                          }
                          Get.back(); Get.back();
                          Get.snackbar("Muvaffaqiyatli", "SMS yuborildi", backgroundColor: const Color(0xFF10B981), colorText: Colors.white);
                        } catch (e) {
                          Get.back();
                          Get.snackbar("Xato", "Xatolik: $e", backgroundColor: const Color(0xFFEF4444), colorText: Colors.white);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 0,
                      ),
                      child: const Text("YUBORISH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InProgressController());
    final homeController = Get.isRegistered<HomeController>() ? Get.find<HomeController>() : Get.put(HomeController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        centerTitle: false,
        title: const Text("Jarayonlar", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800, fontSize: 28)),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.search, size: 22, color: Color(0xFF475569)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_active_rounded, size: 22, color: Color(0xFF2563EB)),
            onPressed: () => _showMassSmsDialog(context, homeController),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Obx(() => Row(
                children: [
                  _buildModernTab(controller, 0, "Navbat", Icons.queue_music_rounded),
                  _buildModernTab(controller, 1, "Ogohlantirilgan", Icons.check_circle_rounded),
                ],
              )),
            ),
          ),
          Expanded(
            child: PageView(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              children: [
                _buildQueueList(homeController, context, false), // Navbatdagilar
                _buildQueueList(homeController, context, true),  // Ogohlantirilganlar
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueList(HomeController homeController, BuildContext context, bool showNotified) {
    return Obx(() {
      DateTime now = DateTime.now();
      DateTime todayOnly = DateTime(now.year, now.month, now.day);
      String bugunStr = DateFormat('dd.MM.yyyy').format(now);

      var list = homeController.todayOrders.where((o) {
        String? nextVisitRaw = o['nextVisit']?.toString();
        if (nextVisitRaw == null || nextVisitRaw.isEmpty) return false;

        try {
          String datePart = nextVisitRaw.split(' ').first;
          DateTime visitDate = DateFormat('dd.MM.yyyy').parse(datePart);
          DateTime visitOnly = DateTime(visitDate.year, visitDate.month, visitDate.day);
          bool isNotified = o['is_notified'] ?? false;

          if (showNotified) {
            return isNotified;
          } else {
            return !isNotified && ((datePart == bugunStr) || visitOnly.isBefore(todayOnly));
          }
        } catch (e) {
          return nextVisitRaw.contains(bugunStr);
        }
      }).toList();

      list.sort((a, b) {
        try {
          DateTime dateA = DateFormat('dd.MM.yyyy').parse(a['nextVisit'].toString().split(' ').first);
          DateTime dateB = DateFormat('dd.MM.yyyy').parse(b['nextVisit'].toString().split(' ').first);
          return dateA.compareTo(dateB);
        } catch (e) { return 0; }
      });

      if (list.isEmpty) {
        return _buildAjibEmptyState(
            showNotified ? "Ogohlantirilganlar yo'q" : "Navbatlar tugadi!",
            showNotified
                ? "Hali birorta ham bemorga SMS xabarnoma yuborilmadi."
                : "Barcha bemorlar ogohlantirildi. Bugun uchun rejalashtirilgan ishlar yakunlandi!",
            showNotified ? Icons.notifications_off_rounded : Icons.task_alt_rounded
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final order = list[index];
          return _buildModernPatientCard(
            name: order['patientName'] ?? "Noma'lum",
            phone: order['phone'] ?? "Raqam yo'q",
            services: order['services'] as List? ?? [],
            time: order['nextVisit']?.toString() ?? "--.--",
            debt: (order['debtAmount'] as num?)?.toDouble() ?? 0.0,
            serviceCount: (order['services'] as List? ?? []).length,
            onSmsTap: () => _showAppointmentSmsDialog(context, order),
            context: context,
            order: order,
          );
        },
      );
    });
  }

  // 🎨 AJIB EMPTY STATE (Premium Design)
  Widget _buildAjibEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140, height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [const Color(0xFF2563EB).withOpacity(0.1), Colors.transparent]),
                  ),
                ),
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 8))],
                  ),
                  child: Icon(icon, size: 40, color: const Color(0xFF2563EB)),
                ),
                Positioned(
                  top: 10, right: 10,
                  child: Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5)),
            const SizedBox(height: 12),
            Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, height: 1.5, color: const Color(0xFF64748B).withOpacity(0.8), fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildModernPatientCard({
    required String name,
    required String phone,
    required List services,
    required String time,
    required double debt,
    required BuildContext context,
    required Map<String, dynamic> order,
    required int serviceCount,
    required VoidCallback onSmsTap,
  }) {
    // Bemor holatini aniqlash
    final patientStatus = _getPatientStatus(order, time);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: _cardDecoration(patientStatus),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. Bemor haqida asosiy ma'lumotlar
            _buildPatientHeader(
              name: name,
              phone: phone,
              status: patientStatus,
            ),

            const SizedBox(height: 18),

            // 2. Xizmat va vaqt ma'lumotlari
            _buildServiceInfo(
              serviceCount: serviceCount,
              time: time,
              status: patientStatus,
            ),

            const SizedBox(height: 16),

            // 3. SMS holati va tugmasi
            _buildSmsStatus(
              status: patientStatus,
              order: order,
              onTap: onSmsTap,
            ),
          ],
        ),
      ),
    );
  }

// ============ KICHIK YORDAMCHI FUNKSIYALAR ============

  /// Bemor holatini aniqlaydi (ogohlantirilgan, kechikkan, normal)
  _PatientStatus _getPatientStatus(Map<String, dynamic> order, String time) {
    // Ogohlantirilganmi?
    if (order['is_notified'] == true) {
      return _PatientStatus.notified;
    }

    // Vaqt o'tib ketganmi?
    try {
      DateTime visitDate = DateFormat('dd.MM.yyyy').parse(time.split(' ').first);
      DateTime today = DateTime.now();
      DateTime visit = DateTime(visitDate.year, visitDate.month, visitDate.day);

      if (today.isAfter(visit)) {
        int daysLate = today.difference(visit).inDays;
        return _PatientStatus.overdue(daysLate);
      }
    } catch (e) {
      // Sana formatida xatolik
    }

    // Oddiy holat
    return _PatientStatus.normal;
  }

  /// Karta dekoratsiyasi (holatga qarab)
  BoxDecoration _cardDecoration(_PatientStatus status) {
    Color borderColor = Colors.transparent;

    if (status.type == 'overdue') {
      borderColor = const Color(0xFFEF4444).withOpacity(0.3);
    }

    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: borderColor != Colors.transparent
          ? Border.all(color: borderColor, width: 1.5)
          : null,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 20,
          offset: const Offset(0, 4),
        )
      ],
    );
  }

  /// Bemor sarlavhasi (rasm, ism, telefon)
  Widget _buildPatientHeader({
    required String name,
    required String phone,
    required _PatientStatus status,
  }) {
    return Row(
      children: [
        // Bemor avatari (bosh harf)
        _buildAvatar(name, status),

        const SizedBox(width: 16),

        // Ism va telefon
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                phone,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        // Agar ogohlantirilgan bo'lsa, tasdiq belgisi
        if (status.type == 'notified')
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF10B981),
            size: 24,
          ),
      ],
    );
  }

  /// Avatar (bemorning bosh harfi)
  Widget _buildAvatar(String name, _PatientStatus status) {
    // Avatar rangi (holatga qarab)
    Color startColor, endColor;

    switch (status.type) {
      case 'notified':
        startColor = const Color(0xFF10B981);
        endColor = const Color(0xFF059669);
        break;
      case 'overdue':
        startColor = const Color(0xFFEF4444);
        endColor = const Color(0xFFB91C1C);
        break;
      default:
        startColor = const Color(0xFF2563EB);
        endColor = const Color(0xFF7C3AED);
    }

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : "?",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Xizmat va vaqt ma'lumotlari
  Widget _buildServiceInfo({
    required int serviceCount,
    required String time,
    required _PatientStatus status,
  }) {
    // Vaqt rangini aniqlash
    Color timeColor;
    Color timeBgColor;

    switch (status.type) {
      case 'notified':
        timeColor = const Color(0xFF059669);
        timeBgColor = const Color(0xFFECFDF5);
        break;
      case 'overdue':
        timeColor = const Color(0xFFDC2626);
        timeBgColor = const Color(0xFFFEF2F2);
        break;
      default:
        timeColor = const Color(0xFF475569);
        timeBgColor = const Color(0xFFF1F5F9);
    }

    return Row(
      children: [
        // Xizmatlar soni
        Expanded(
          child: Text(
            "$serviceCount xizmat kiritilgan",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
        ),

        // Vaqt (faqat sana qismi)
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: timeBgColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            time.split(' ').first, // Faqat sana qismi
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: timeColor,
            ),
          ),
        ),
      ],
    );
  }

  /// SMS holati va tugmasi
  Widget _buildSmsStatus({
    required _PatientStatus status,
    required Map<String, dynamic> order,
    required VoidCallback onTap,
  }) {
    // Agar ogohlantirilgan bo'lsa, tugma bosilmaydi
    bool isButtonEnabled = status.type != 'notified';

    // Matn va ranglarni aniqlash
    String statusText;
    IconData statusIcon;
    Color statusColor;
    Color bgColor;

    if (status.type == 'notified') {
      String notifiedTime = order['notified_at'] != null
          ? DateFormat('HH:mm').format(DateTime.parse(order['notified_at']))
          : '';
      statusText = "Ogohlantirildi ${notifiedTime.isNotEmpty ? '($notifiedTime)' : ''}";
      statusIcon = Icons.done_all_rounded;
      statusColor = const Color(0xFF10B981);
      bgColor = const Color(0xFF10B981).withOpacity(0.1);
    } else if (status.type == 'overdue') {
      statusText = "${status.daysLate} kundan beri ogohlantirilmagan!";
      statusIcon = Icons.notification_important_rounded;
      statusColor = const Color(0xFFEF4444);
      bgColor = const Color(0xFFEF4444).withOpacity(0.08);
    } else {
      statusText = "SMS yuborish kerak";
      statusIcon = Icons.notification_important_rounded;
      statusColor = Colors.orange;
      bgColor = const Color(0xFFF1F5F9);
    }

    return InkWell(
      onTap: isButtonEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Status ikonkasi
            Icon(
              statusIcon,
              size: 20,
              color: statusColor,
            ),

            const SizedBox(width: 10),

            // Status matni
            Expanded(
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ),

            // Agar tugma bosiladigan bo'lsa, o'q belgisi
            if (isButtonEnabled)
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: Colors.grey,
              ),
          ],
        ),
      ),
    );
  }

// ============ YORDAMCHI KLASS ============



  void _showMassSmsDialog(BuildContext context, HomeController controller) {
    DateTime now = DateTime.now();
    DateTime todayOnly = DateTime(now.year, now.month, now.day);
    String bugunStr = DateFormat('dd.MM.yyyy').format(now);

    var targetPatients = controller.todayOrders.where((o) {
      String datePart = o['nextVisit'].toString().split(' ').first;
      DateTime visitDate = DateFormat('dd.MM.yyyy').parse(datePart);
      bool isNotified = o['is_notified'] ?? false;
      return !isNotified && ((datePart == bugunStr) || visitDate.isBefore(todayOnly));
    }).toList();

    if (targetPatients.isEmpty) {
      Get.snackbar("Ma'lumot", "SMS yuborish uchun bemorlar yo'q", backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Ommaviy SMS", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("${targetPatients.length} ta bemorga eslatma yuborishni xohlaysizmi?", textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  Get.back();
                  Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
                  for (var p in targetPatients) {
                    await SMSService().sendSMS(p['phone'], "Sizda qabul bor.");
                  }
                  Get.back();
                  Get.snackbar("Bajarildi", "Hamma SMSlar yuborildi", backgroundColor: Colors.green, colorText: Colors.white);
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                child: const Text("HAMMASIGA YUBORISH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildModernTab(InProgressController controller, int index, String label, IconData icon) {
    bool isActive = controller.selectedTab.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: isActive ? const Color(0xFF2563EB) : Colors.transparent, borderRadius: BorderRadius.circular(100)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isActive ? Colors.white : const Color(0xFF94A3B8)),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isActive ? Colors.white : const Color(0xFF64748B))),
            ],
          ),
        ),
      ),
    );
  }
}



Widget _buildModernPatientCard({
  required String name,
  required String phone,
  required List services,
  required String time,
  required double debt,
  required BuildContext context,
  required Map<String, dynamic> order,
  required int serviceCount,
  required VoidCallback onSmsTap,
}) {
  // Bemor holatini aniqlash
  final patientStatus = _getPatientStatus(order, time);

  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: _cardDecoration(patientStatus),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 1. Bemor haqida asosiy ma'lumotlar
          _buildPatientHeader(
            name: name,
            phone: phone,
            status: patientStatus,
          ),

          const SizedBox(height: 18),

          // 2. Xizmat va vaqt ma'lumotlari
          _buildServiceInfo(
            serviceCount: serviceCount,
            time: time,
            status: patientStatus,
          ),

          const SizedBox(height: 16),

          // 3. SMS holati va tugmasi
          _buildSmsStatus(
            status: patientStatus,
            order: order,
            onTap: onSmsTap,
          ),
        ],
      ),
    ),
  );
}

// ============ KICHIK YORDAMCHI FUNKSIYALAR ============

/// Bemor holatini aniqlaydi (ogohlantirilgan, kechikkan, normal)
_PatientStatus _getPatientStatus(Map<String, dynamic> order, String time) {
  // Ogohlantirilganmi?
  if (order['is_notified'] == true) {
    return _PatientStatus.notified;
  }

  // Vaqt o'tib ketganmi?
  try {
    DateTime visitDate = DateFormat('dd.MM.yyyy').parse(time.split(' ').first);
    DateTime today = DateTime.now();
    DateTime visit = DateTime(visitDate.year, visitDate.month, visitDate.day);

    if (today.isAfter(visit)) {
      int daysLate = today.difference(visit).inDays;
      return _PatientStatus.overdue(daysLate);
    }
  } catch (e) {
    // Sana formatida xatolik
  }

  // Oddiy holat
  return _PatientStatus.normal;
}

/// Karta dekoratsiyasi (holatga qarab)
BoxDecoration _cardDecoration(_PatientStatus status) {
  Color borderColor = Colors.transparent;

  if (status.type == 'overdue') {
    borderColor = const Color(0xFFEF4444).withOpacity(0.3);
  }

  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    border: borderColor != Colors.transparent
        ? Border.all(color: borderColor, width: 1.5)
        : null,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.02),
        blurRadius: 20,
        offset: const Offset(0, 4),
      )
    ],
  );
}

/// Bemor sarlavhasi (rasm, ism, telefon)
Widget _buildPatientHeader({
  required String name,
  required String phone,
  required _PatientStatus status,
}) {
  return Row(
    children: [
      // Bemor avatari (bosh harf)
      _buildAvatar(name, status),

      const SizedBox(width: 16),

      // Ism va telefon
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              phone,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),

      // Agar ogohlantirilgan bo'lsa, tasdiq belgisi
      if (status.type == 'notified')
        const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF10B981),
          size: 24,
        ),
    ],
  );
}

/// Avatar (bemorning bosh harfi)
Widget _buildAvatar(String name, _PatientStatus status) {
  // Avatar rangi (holatga qarab)
  Color startColor, endColor;

  switch (status.type) {
    case 'notified':
      startColor = const Color(0xFF10B981);
      endColor = const Color(0xFF059669);
      break;
    case 'overdue':
      startColor = const Color(0xFFEF4444);
      endColor = const Color(0xFFB91C1C);
      break;
    default:
      startColor = const Color(0xFF2563EB);
      endColor = const Color(0xFF7C3AED);
  }

  return Container(
    width: 52,
    height: 52,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [startColor, endColor],
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : "?",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

/// Xizmat va vaqt ma'lumotlari
Widget _buildServiceInfo({
  required int serviceCount,
  required String time,
  required _PatientStatus status,
}) {
  // Vaqt rangini aniqlash
  Color timeColor;
  Color timeBgColor;

  switch (status.type) {
    case 'notified':
      timeColor = const Color(0xFF059669);
      timeBgColor = const Color(0xFFECFDF5);
      break;
    case 'overdue':
      timeColor = const Color(0xFFDC2626);
      timeBgColor = const Color(0xFFFEF2F2);
      break;
    default:
      timeColor = const Color(0xFF475569);
      timeBgColor = const Color(0xFFF1F5F9);
  }

  return Row(
    children: [
      // Xizmatlar soni
      Expanded(
        child: Text(
          "$serviceCount xizmat kiritilgan",
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
      ),

      // Vaqt (faqat sana qismi)
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: timeBgColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          time.split(' ').first, // Faqat sana qismi
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: timeColor,
          ),
        ),
      ),
    ],
  );
}

/// SMS holati va tugmasi
Widget _buildSmsStatus({
  required _PatientStatus status,
  required Map<String, dynamic> order,
  required VoidCallback onTap,
}) {
  // Agar ogohlantirilgan bo'lsa, tugma bosilmaydi
  bool isButtonEnabled = status.type != 'notified';

  // Matn va ranglarni aniqlash
  String statusText;
  IconData statusIcon;
  Color statusColor;
  Color bgColor;

  if (status.type == 'notified') {
    String notifiedTime = order['notified_at'] != null
        ? DateFormat('HH:mm').format(DateTime.parse(order['notified_at']))
        : '';
    statusText = "Ogohlantirildi ${notifiedTime.isNotEmpty ? '($notifiedTime)' : ''}";
    statusIcon = Icons.done_all_rounded;
    statusColor = const Color(0xFF10B981);
    bgColor = const Color(0xFF10B981).withOpacity(0.1);
  } else if (status.type == 'overdue') {
    statusText = "${status.daysLate} kundan beri ogohlantirilmagan!";
    statusIcon = Icons.notification_important_rounded;
    statusColor = const Color(0xFFEF4444);
    bgColor = const Color(0xFFEF4444).withOpacity(0.08);
  } else {
    statusText = "SMS yuborish kerak";
    statusIcon = Icons.notification_important_rounded;
    statusColor = Colors.orange;
    bgColor = const Color(0xFFF1F5F9);
  }

  return InkWell(
    onTap: isButtonEnabled ? onTap : null,
    borderRadius: BorderRadius.circular(16),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Status ikonkasi
          Icon(
            statusIcon,
            size: 20,
            color: statusColor,
          ),

          const SizedBox(width: 10),

          // Status matni
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),

          // Agar tugma bosiladigan bo'lsa, o'q belgisi
          if (isButtonEnabled)
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: Colors.grey,
            ),
        ],
      ),
    ),
  );
}

// ============ YORDAMCHI KLASS ============

/// Bemor holatini ifodalovchi klass
class _PatientStatus {
  final String type; // 'notified', 'overdue', 'normal'
  final int daysLate; // faqat 'overdue' uchun

  _PatientStatus._(this.type, this.daysLate);

  static _PatientStatus notified = _PatientStatus._('notified', 0);
  static _PatientStatus normal = _PatientStatus._('normal', 0);
  static _PatientStatus overdue(int days) => _PatientStatus._('overdue', days);
}