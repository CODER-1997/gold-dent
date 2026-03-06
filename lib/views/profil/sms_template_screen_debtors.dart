import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SmsTemplateScreen extends StatefulWidget {
  const SmsTemplateScreen({super.key});

  @override
  _SmsTemplateScreenState createState() => _SmsTemplateScreenState();
}

class _SmsTemplateScreenState extends State<SmsTemplateScreen> {
  final TextEditingController _templateController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = true;      // Sahifa yuklanayotganidagi holat
  bool isSaving = false;      // Saqlash tugmasi bosilgandagi holat

  final String defaultTemplate =
      "Hurmatli [name], Gold Dent klinikasidan [sum] so'm qarzdorligingiz borligini eslatib o'tamiz. To'lovni amalga oshirishingizni so'raymiz.";

  @override
  void initState() {
    super.initState();
    _loadTemplate();
  }

  // Firebase'dan shablonni yuklash
  void _loadTemplate() async {
    try {
      var doc = await _firestore.collection('Settings').doc('sms_config').get();
      if (doc.exists && doc.data()?['debtor_template'] != null) {
        _templateController.text = doc.data()?['debtor_template'];
      } else {
        _templateController.text = defaultTemplate;
      }
    } catch (e) {
      debugPrint("Yuklashda xato: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Shablonni saqlash
  void _saveTemplate() async {
    if (_templateController.text.trim().isEmpty) {
      Get.snackbar("Xato", "Shablon bo'sh bo'lishi mumkin emas",
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    setState(() => isSaving = true); // Loader'ni yoqish

    try {
      await _firestore.collection('Settings').doc('sms_config').set({
        'debtor_template': _templateController.text.trim(),
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Get.snackbar(
        "Muvaffaqiyatli",
        "SMS shablon saqlandi",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(15),
      );

      // SAQLAGANDAN KEYIN ORQAGA QAYTISH
      Future.delayed(const Duration(milliseconds: 100), () {
        Navigator.of(context).pop();      });
    } catch (e) {
      Get.snackbar("Xato", "Saqlashda xatolik yuz berdi",
          backgroundColor: Colors.red, colorText: Colors.white);
      setState(() => isSaving = false); // Xato bo'lsa loader'ni o'chirish
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text("SMS Shablon",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.blue),
          onPressed: () => Get.back(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "QARZDORLAR UCHUN SMS MATNI",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ]),
              child: TextField(
                controller: _templateController,
                maxLines: 6,
                style: const TextStyle(fontSize: 16, height: 1.4),
                decoration: const InputDecoration(
                  hintText: "Shablonni shu yerga yozing...",
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildHintText(),
            const Spacer(),
            _buildSaveButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isSaving ? null : _saveTemplate, // Saqlanayotgan bo'lsa tugma o'chadi
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007AFF),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: isSaving
            ? const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
        )
            : const Text("SAQLASH",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
      ),
    );
  }

  Widget _buildHintText() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Eslatma: [name] - bemor ismi, [sum] - qarz miqdori o'rniga avtomatik qo'yiladi.",
              style: TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
          ),
        ],
      ),
    );
  }
}