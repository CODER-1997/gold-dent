import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gold_dent/views/profil/services.dart';
import 'package:gold_dent/views/profil/sms_template_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
          // 1. Profil Kartasi
          _buildProfileHeader(iosBlue),

          const SizedBox(height: 25),

          // 2. KLINIKA BOSHQUROVI
          _buildSectionHeader("KLINIKA"),
          _buildGroupedContainer([
            _profileTile("Ish grafigi", Icons.calendar_today_rounded, Colors.orange, () {}),
            _profileTile("Xizmatlar va Narxlar", Icons.account_balance_wallet_rounded, Colors.green, () {
              Get.to(ServicesScreen());
            }),
            _profileTile("Mening daromadim", Icons.bar_chart_rounded, Colors.purple, () {}),
          ]),

          const SizedBox(height: 25),

          // 3. XAVFSIZLIK VA SOZLAMALAR
          _buildSectionHeader("SOZLAMALAR"),
          _buildGroupedContainer([
            _profileTile("SMS Xabarnoma", Icons.sms_rounded, Colors.green, () {
              Get.to(() =>   SmsTemplateScreen());
            }),
            _profileTile("Bildirishnomalar", Icons.notifications_rounded, Colors.redAccent, () {}),
            _profileTile("Ilova tili", Icons.translate_rounded, iosBlue, () {}),
            _profileTile("Parol va xavfsizlik", Icons.lock_person_rounded, Colors.blueGrey, () {}),
          ]),

          const SizedBox(height: 25),

          // 4. CHIQISH
          _buildGroupedContainer([
            _buildExitButton(),
          ]),

          const SizedBox(height: 30),
          _buildFooter(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(Color blue) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: const Color(0xFFF2F2F7),
            child: Icon(Icons.person, size: 40, color: Colors.grey.shade400),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Dr. Lazizbek Komilov", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text("Stomatolog-ortoped", style: TextStyle(color: Colors.grey, fontSize: 14)),
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
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
    );
  }

  Widget _buildGroupedContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: children.asMap().entries.map((entry) {
          int idx = entry.key;
          Widget child = entry.value;
          if (idx == children.length - 1) return child;
          return Column(
            children: [
              child,
              Padding(
                padding: const EdgeInsets.only(left: 56),
                child: Divider(height: 1, color: Colors.grey.shade100),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _profileTile(String title, IconData icon, Color iconColor, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: iconColor, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFC7C7CC)),
      onTap: onTap,
    );
  }

  Widget _buildExitButton() {
    return InkWell(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: const Center(child: Text("Chiqish", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 16))),
      ),
    );
  }

  Widget _buildFooter() {
    return const Center(
      child: Text(
        "Gold Dent v1.0.2 \n Made with ❤️ for Dentists",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.5),
      ),
    );
  }
}