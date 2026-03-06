import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SmsTemplateScreenRecall extends StatefulWidget {
  const SmsTemplateScreenRecall({super.key});

  @override
  _SmsTemplateScreenRecallState createState() => _SmsTemplateScreenRecallState();
}

class _SmsTemplateScreenRecallState extends State<SmsTemplateScreenRecall> {
  final TextEditingController _templateController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = true;
  bool isSaving = false;

  // Qabul uchun standart shablon
  final String defaultTemplate =
      "Hurmatli [name], bugun soat [time] da Gold Dent klinikasida qabulingiz bor. Sizni kutib qolamiz!";

  @override
  void initState() {
    super.initState();
    _loadTemplate();
  }

  // Firebase'dan qabul shablonini yuklash
  void _loadTemplate() async {
    try {
      var doc = await _firestore.collection('Settings').doc('sms_config').get();
      // 'appointment_template' maydonidan o'qiymiz
      if (doc.exists && doc.data()?['appointment_template'] != null) {
        _templateController.text = doc.data()?['appointment_template'];
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

    setState(() => isSaving = true);

    try {
      await _firestore.collection('Settings').doc('sms_config').set({
        'appointment_template': _templateController.text.trim(),
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Get.snackbar(
        "Muvaffaqiyatli",
        "Qabul shabloni saqlandi",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(15),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) Navigator.of(context).pop();
      });
    } catch (e) {
      Get.snackbar("Xato", "Saqlashda xatolik yuz berdi",
          backgroundColor: Colors.red, colorText: Colors.white);
      setState(() => isSaving = false);
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
        title: const Text("Qabul SMS shabloni",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF007AFF)),
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
              "NAVBTDAGI BEMORLAR UCHUN MATN",
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
        onPressed: isSaving ? null : _saveTemplate,
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
        color: const Color(0xFF007AFF).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.tips_and_updates_outlined, color: Color(0xFF007AFF), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Eslatma: [name] - bemor ismi, [time] - qabul vaqti o'rniga avtomatik qo'yiladi.",
              style: TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
          ),
        ],
      ),
    );
  }
}