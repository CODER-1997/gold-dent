import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../controllers/profile/service_controller.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  // Pul formatlash funksiyasi (1 000 000 so'm)
  String formatMoney(dynamic amount) {
    final formatter = NumberFormat.decimalPattern('uz');
    return "${formatter.format(amount).replaceAll(',', ' ')} so'm";
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ServiceController());

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Xizmatlar",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 24)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () => _showServiceSheet(context, controller),
              icon: const Icon(Icons.add_box_rounded, color: Color(0xFF007AFF), size: 32),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: controller.getServices(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              String docId = docs[index].id;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  // Soya yanada nafisroq (Soft Shadow)
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF475569).withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Xizmat belgisi (Service Icon Badge)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF007AFF).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.layers_outlined, color: Color(0xFF007AFF), size: 24),
                          ),
                          const SizedBox(width: 16),
                          // Ism va Narx
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 17,
                                    color: Color(0xFF1E293B),
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatMoney(data['price']),
                                  style: const TextStyle(
                                    color: Color(0xFF10B981), // Zümrüd yashil
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Pastki tugmalar paneli (Nafis kulrang fon bilan ajratilgan)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                        border: Border(
                          top: BorderSide(color: Colors.grey.withOpacity(0.05)),
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 8),
                          // ID yoki Status kabi kichik belgi qo'yish mumkin
                          Text(
                            "Faol xizmat",
                            style: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          // Tahrirlash tugmasi (Minimalist)
                          _actionButton(
                            icon: Icons.edit_note_rounded,
                            label: "O'zgartirish",
                            color: const Color(0xFF007AFF),
                            onTap: () => _showServiceSheet(context, controller, docId: docId, data: data),
                          ),
                          const SizedBox(width: 8),
                          // O'chirish (Nafis qizil)
                          _actionButton(
                            icon: Icons.delete_outline_rounded,
                            label: "", // Faqat ikonka joy tejash uchun
                            color: Colors.redAccent,
                            onTap: () => _confirmDelete(docId, controller),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Nafis harakat tugmasi
  Widget _actionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  // Xizmat Sheet (Input formatlari bilan)
  void _showServiceSheet(BuildContext context, ServiceController controller, {String? docId, Map<String, dynamic>? data}) {
    final nameCtrl = TextEditingController(text: data?['name']);

    // Eski narxni formatlab yuklash
    String initialPrice = "";
    if (data != null) {
      initialPrice = data['price'].toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ');
    }
    final priceCtrl = TextEditingController(text: initialPrice);

    const Color greenColor = Color(0xFF007AFF); // Sizning greenColor yoki asosiy ko'k rang

    // Siz bergan dizayn mantiqi bo'yicha InputDecoration
    InputDecoration customDecoration(String hint, IconData icon) {
      return InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blue.shade300, size: 22),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        hintText: hint,
        hintStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            fontFamily: "Manrope",
            color: Colors.black.withOpacity(.3)),
        focusColor: greenColor,
        fillColor: const Color(0xFFfafafa),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xffE9E9E9))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: greenColor, width: 2)),
      );
    }

    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10))
            ),

            Text(
                docId == null ? "Yangi Xizmat" : "Xizmatni Tahrirlash",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, fontFamily: "Manrope")
            ),
            const SizedBox(height: 32),

            // Xizmat nomi
            TextField(
              controller: nameCtrl,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              decoration: customDecoration("Xizmat nomi", Icons.medical_services_rounded),
            ),
            const SizedBox(height: 16),

            // Narxi (Formatlangan)
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              inputFormatters: [ThousandsSeparatorInputFormatter()],
              decoration: customDecoration("Xizmat narxi (so'm)", Icons.payments_rounded),
            ),

            const SizedBox(height: 32),

            // Saqlash tugmasi
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: greenColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  String cleanPrice = priceCtrl.text.replaceAll(' ', '');
                  controller.saveService(
                    docId: docId,
                    name: nameCtrl.text,
                    price: double.tryParse(cleanPrice) ?? 0,
                  );
                },
                child: const Text(
                    "SAQLASH",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white, letterSpacing: 1)
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
  void _confirmDelete(String docId, ServiceController controller) {
    Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("O'chirish?", style: TextStyle(fontWeight: FontWeight.w900)),
          content: const Text("Ushbu xizmat turi ro'yxatdan butunlay o'chiriladi."),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text("Bekor qilish")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, elevation: 0),
              onPressed: () { controller.deleteService(docId); Get.back(); },
              child: const Text("O'CHIRISH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        )
    );
  }

  InputDecoration _inputStyle(String hint, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.blue.shade300, size: 22),
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFF1F5F9))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF007AFF), width: 1.5)),
    );
  }
}

// O'sha pul formatlovchi klass
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue.copyWith(text: '');
    String newValueText = newValue.text.replaceAll(' ', '');
    final StringBuffer newText = StringBuffer();
    for (int i = 0; i < newValueText.length; i++) {
      if (i > 0 && (newValueText.length - i) % 3 == 0) newText.write(' ');
      newText.write(newValueText[i]);
    }
    return newValue.copyWith(text: newText.toString(), selection: TextSelection.collapsed(offset: newText.length));
  }
}