import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart'; // Xotira uchun
import 'package:gold_dent/views/profil/my_profit.dart';
import 'package:gold_dent/views/profil/services.dart';
import 'package:gold_dent/views/profil/sms_template_screen_debtors.dart';
import 'package:gold_dent/views/profil/sms_template_screen_recall.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final box = GetStorage();

  // Daromad bo'limi ochiq yoki yopiqligini tekshirish
  bool get isUnlocked => box.read('is_profit_unlocked') ?? false;

  @override
  Widget build(BuildContext context) {
    const Color iosBlue = Color(0xFF007AFF);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F7),
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "Profil",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 28),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          _buildProfileHeader(iosBlue),
          const SizedBox(height: 25),

          _buildSectionHeader("KLINIKA"),
          _buildGroupedContainer([
            _profileTile("Ish grafigi", Icons.calendar_today_rounded, Colors.orange, () {}),
            _profileTile("Xizmatlar va Narxlar", Icons.account_balance_wallet_rounded, Colors.green, () {
              Get.to(() => const ServicesScreen());
            }),

            // DAROMAD BO'LIMI: Qulf holatiga qarab ikonka va mantiq o'zgaradi
            _profileTile(
              "Mening daromadim",
              isUnlocked ? Icons.bar_chart_rounded : Icons.lock_outline_rounded,
              Colors.purple,
                  () {
                if (isUnlocked) {
                  Get.to(() => const MyProfitScreen());
                } else {
                  _showPasswordDialog(context);
                }
              },
              trailingIcon: isUnlocked ? Icons.arrow_forward_ios_rounded : Icons.lock_rounded,
            ),
          ]),

          const SizedBox(height: 25),

          _buildSectionHeader("SOZLAMALAR"),
          _buildGroupedContainer([
            _profileTile("Sms xabar qarzdorlarga", Icons.sms_rounded, Colors.green, () {
              Get.to(() => const SmsTemplateScreen());
            }),
            _profileTile("Sms qayta qabul", Icons.sms_rounded, Colors.green, () {
              Get.to(() => const SmsTemplateScreenRecall());
            }),
            _profileTile("Bildirishnomalar", Icons.notifications_rounded, Colors.redAccent, () {}),
            _profileTile("Ilova tili", Icons.translate_rounded, iosBlue, () {}),

            // Xavfsizlik bo'limida qulfni qayta yopish funksiyasini qo'shish mumkin
            _profileTile("Qulfni qayta faollashtirish", Icons.security_rounded, Colors.blueGrey, () {
              box.write('is_profit_unlocked', false);
              setState(() {});
              Get.snackbar("Xavfsizlik", "Daromad bo'limi qayta qulflandi");
            }),
          ]),

          const SizedBox(height: 25),
          _buildGroupedContainer([_buildExitButton()]),
          const SizedBox(height: 30),
          _buildFooter(),
        ],
      ),
    );
  }

  // --- PAROL SO'RASH DIALOGI ---
  void _showPasswordDialog(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.lock_person_rounded, color: Colors.purple, size: 35),
              ),
              const SizedBox(height: 20),
              const Text("Xavfsizlik", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 25),
              TextField(
                controller: passwordController,
                obscureText: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
                decoration: InputDecoration(
                  hintText: "••••••••",
                  filled: true,
                  fillColor: const Color(0xFFF2F2F7),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(child: TextButton(onPressed: () => Get.back(), child: const Text("BEKOR QILISH"))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (passwordController.text == "19971997") {
                          box.write('is_profit_unlocked', true); // Xotiraga saqlash
                          setState(() {}); // UI-ni yangilash
                          Get.back();
                          Get.to(() => const MyProfitScreen());
                        } else {
                          Get.snackbar("Xato", "Parol noto'g'ri!", backgroundColor: Colors.redAccent, colorText: Colors.white);
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: const Text("KIRISH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- YORDAMCHI WIDGETLAR ---

  Widget _profileTile(String title, IconData icon, Color iconColor, VoidCallback onTap, {IconData trailingIcon = Icons.arrow_forward_ios_rounded}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: iconColor, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      trailing: Icon(trailingIcon, size: 14, color: const Color(0xFFC7C7CC)),
      onTap: onTap,
    );
  }

  // ... Boshqa widgetlar (_buildProfileHeader, _buildSectionHeader, va h.k. o'zgarishsiz qoladi)

  Widget _buildProfileHeader(Color blue) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
      child: Row(
        children: [
          CircleAvatar(radius: 35, backgroundColor: const Color(0xFFF2F2F7), child: Icon(Icons.person_rounded, size: 40, color: Colors.grey.shade400)),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Dr. Lazizbek Komilov", style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                SizedBox(height: 4),
                Text("Stomatolog-ortoped", style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFFC7C7CC)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
    );
  }

  Widget _buildGroupedContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: children.asMap().entries.map((entry) {
          int idx = entry.key;
          Widget child = entry.value;
          if (idx == children.length - 1) return child;
          return Column(
            children: [
              child,
              Padding(padding: const EdgeInsets.only(left: 60), child: Divider(height: 1, color: Colors.grey.shade100)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExitButton() {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: const Center(child: Text("Chiqish", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w800, fontSize: 16))),
      ),
    );
  }

  Widget _buildFooter() {
    return const Center(
      child: Text(
        "Gold Dent v1.2.0 \n Professional Dental CRM",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.6, fontWeight: FontWeight.w500),
      ),
    );
  }
}