import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/home_controller/home_controller.dart';

class PatientFormScreen extends StatefulWidget {
  final Map<String, dynamic>? doc;
  const PatientFormScreen({super.key, this.doc});

  @override
  State<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final controller = Get.find<HomeController>();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final totalCtrl = TextEditingController();
  final paidCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    if (widget.doc != null) {
      nameCtrl.text = widget.doc!['patientName'];
      phoneCtrl.text = widget.doc!['phone'];
      String format(v) => v.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
      totalCtrl.text = format(widget.doc!['totalPrice']);
      paidCtrl.text = format(widget.doc!['paidAmount']);
      controller.selectedServices.value =
      List<Map<String, dynamic>>.from(widget.doc!['services']);
    } else {
      nameCtrl.clear();
      phoneCtrl.text = "+998 ";
      totalCtrl.clear();
      paidCtrl.clear();
      controller.selectedServices.clear();
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
        leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.black, size: 20)),
        title: Text(widget.doc == null ? "Yangi Bemor" : "Tahrirlash",
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.w900, fontSize: 20)),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("BEMOR MA'LUMOTLARI"),
              const SizedBox(height: 12),
              _buildField(nameCtrl, "To'liq ism (F.I.SH)", Icons.person_outline_rounded,
                  Colors.blue),
              const SizedBox(height: 16),
              _buildField(phoneCtrl, "Telefon raqami", Icons.phone_android_rounded,
                  Colors.green,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [UzbekPhoneInputFormatter()]),

              const SizedBox(height: 32),
              _sectionTitle("XIZMATLAR"),
              const SizedBox(height: 12),
              _servicePickerButton(context),
              const SizedBox(height: 16),

              // TANLANGAN XIZMATLAR BLOKI
              _selectedServicesList(),

              const SizedBox(height: 32),
              _sectionTitle("KASSA VA TO'LOV"),
              const SizedBox(height: 12),
              _buildField(totalCtrl, "Umumiy summa", Icons.monetization_on_outlined,
                  Colors.orange,
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandsSeparatorInputFormatter()]),
              const SizedBox(height: 16),
              _buildField(paidCtrl, "To'langan (Avans)",
                  Icons.account_balance_wallet_outlined, Colors.teal,
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandsSeparatorInputFormatter()]),
              const SizedBox(height: 40),
              _saveButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- SAQLASH FUNKSIYASI ---
  void _handleSave() async {
    if (_formKey.currentState!.validate()) {
      controller.isLoading.value = true;
      double clean(String v) => double.tryParse(v.replaceAll(' ', '')) ?? 0;

      Map<String, dynamic> data = {
        'id': widget.doc?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'patientName': nameCtrl.text.trim(),
        'phone': phoneCtrl.text,
        'services': List.from(controller.selectedServices),
        'totalPrice': clean(totalCtrl.text),
        'paidAmount': clean(paidCtrl.text),
        'debtAmount': clean(totalCtrl.text) - clean(paidCtrl.text),
        'nextVisit': DateFormat('dd.MM.yyyy').format(DateTime.now()),
        'time': widget.doc?['time'] ?? DateTime.now().toIso8601String()
      };

      try {
        if (widget.doc == null) {
          await controller.addOrder(data);
        } else {
          await controller.updateOrder(widget.doc!, data);
        }
        controller.isLoading.value = false;
        Get.back();
        Get.snackbar("Muvaffaqiyatli", "Ma'lumotlar saqlandi",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(15),
            borderRadius: 15);
      } catch (e) {
        controller.isLoading.value = false;
        Get.snackbar("Xato", "Xatolik yuz berdi", backgroundColor: Colors.red, colorText: Colors.white);
      }
    }
  }

  // --- PREMIUM INPUT WIDGET ---
  Widget _buildField(TextEditingController ctrl, String hint, IconData icon, Color iconColor,
      {TextInputType keyboardType = TextInputType.text,
        List<TextInputFormatter>? inputFormatters}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: iconColor, size: 22),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: iconColor, width: 2),
        ),
        contentPadding: const EdgeInsets.all(18),
      ),
    );
  }

  // --- XIZMATLAR RO'YXATI KONTEYNERI ---
  Widget _selectedServicesList() {
    return Obx(() => controller.selectedServices.isEmpty
        ? _emptyServiceInfo()
        : Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blue.withOpacity(0.1), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.selectedServices.length,
        separatorBuilder: (context, index) => Divider(color: Colors.grey.shade100, height: 1, indent: 20, endIndent: 20),
        itemBuilder: (context, index) => _selectedServiceTile(controller.selectedServices[index]),
      ),
    ));
  }

  Widget _selectedServiceTile(Map<String, dynamic> s) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s['name'], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 2),
                Text("${NumberFormat("#,###").format(s['price'])} so'm",
                    style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w700, fontSize: 12)),
              ],
            ),
          ),
          _qtyController(s),
        ],
      ),
    );
  }

  Widget _qtyController(Map<String, dynamic> s) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qtyActionBtn(
            icon: Icons.remove_rounded,
            color: Colors.redAccent,
            onTap: () {
              var idx = controller.selectedServices.indexOf(s);
              if (s['quantity'] > 1) {
                var item = Map<String, dynamic>.from(controller.selectedServices[idx]);
                item['quantity']--;
                controller.selectedServices[idx] = item;
              } else {
                controller.selectedServices.removeAt(idx);
              }
              controller.selectedServices.refresh();
              controller.calculateTotal(totalCtrl);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text("${s['quantity']}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
          ),
          _qtyActionBtn(
            icon: Icons.add_rounded,
            color: Colors.blue,
            onTap: () {
              var idx = controller.selectedServices.indexOf(s);
              var item = Map<String, dynamic>.from(controller.selectedServices[idx]);
              item['quantity']++;
              controller.selectedServices[idx] = item;
              controller.selectedServices.refresh();
              controller.calculateTotal(totalCtrl);
            },
          ),
        ],
      ),
    );
  }

  Widget _qtyActionBtn({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  // --- QOLGAN YORDAMCHI WIDGETLAR ---
  Widget _saveButton() {
    return SizedBox(
      width: double.infinity, height: 60,
      child: Obx(() => ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade600,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        onPressed: controller.isLoading.value ? null : _handleSave,
        child: controller.isLoading.value
            ? const CupertinoActivityIndicator(color: Colors.white)
            : const Text("SAQLASH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
      )),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.blueGrey.shade700, letterSpacing: 1)),
    );
  }

  Widget _emptyServiceInfo() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
      child: const Center(child: Text("Xizmatlar qo'shilmadi", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600))),
    );
  }

  Widget _servicePickerButton(BuildContext context) {
    return InkWell(
      onTap: () => _showAllServicesPicker(context),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.blue.shade700, Colors.blue.shade400], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_shopping_cart_rounded, color: Colors.white), SizedBox(width: 12), Text("XIZMATLARNI TANLASH", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 14, letterSpacing: 1))]),
      ),
    );
  }

  void _showAllServicesPicker(BuildContext context) {
    final searchCtrl = TextEditingController();
    RxString query = "".obs;
    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        height: Get.height * 0.85,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
            const Padding(padding: EdgeInsets.all(20), child: Text("STOMATOLOGIK XIZMATLAR", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: searchCtrl, onChanged: (v) => query.value = v.toLowerCase(),
                decoration: InputDecoration(hintText: "Qidirish...", prefixIcon: const Icon(Icons.search, color: Colors.blue), filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('DentistServices').orderBy('name').snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) return const Center(child: CupertinoActivityIndicator());
                  return Obx(() {
                    var docs = snap.data!.docs.where((d) => (d.data() as Map)['name'].toString().toLowerCase().contains(query.value)).toList();
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        var data = docs[i].data() as Map<String, dynamic>;
                        return Obx(() {
                          bool isSelected = controller.selectedServices.any((s) => s['name'] == data['name']);
                          int count = controller.selectedServices.firstWhereOrNull((s) => s['name'] == data['name'])?['quantity'] ?? 0;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200), margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(color: isSelected ? Colors.blue.shade50 : Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: isSelected ? Colors.blue.shade200 : Colors.grey.shade200)),
                            child: ListTile(
                              title: Text(data['name'], style: TextStyle(fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700)),
                              subtitle: Text("${NumberFormat("#,###").format(data['price'])} so'm", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                              trailing: isSelected ? Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle), child: Text("$count", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))) : Icon(Icons.add_circle_outline, color: Colors.grey.shade400),
                              onTap: () {
                                var idx = controller.selectedServices.indexWhere((s) => s['name'] == data['name']);
                                if (idx != -1) {
                                  var item = Map<String, dynamic>.from(controller.selectedServices[idx]);
                                  item['quantity']++;
                                  controller.selectedServices[idx] = item;
                                } else {
                                  controller.selectedServices.add({'name': data['name'], 'price': (data['price'] as num).toDouble(), 'quantity': 1});
                                }
                                controller.selectedServices.refresh();
                                controller.calculateTotal(totalCtrl);
                              },
                            ),
                          );
                        });
                      },
                    );
                  });
                },
              ),
            ),
            Padding(padding: const EdgeInsets.all(20), child: SizedBox(width: double.infinity, height: 55, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), onPressed: () => Get.back(), child: const Text("YAKUNLASH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900))))),
          ],
        ),
      ),
    );
  }
}

// FORMATTERS
class UzbekPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue newVal) {
    if (newVal.selection.baseOffset < old.selection.baseOffset) return newVal;
    String digits = newVal.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return newVal.copyWith(text: '');
    final buffer = StringBuffer();
    buffer.write('+');
    for (int i = 0; i < digits.length; i++) {
      if (i == 3) buffer.write(' (');
      if (i == 5) buffer.write(') ');
      if (i == 8 || i == 10) buffer.write('-');
      if (i < 12) buffer.write(digits[i]);
    }
    return TextEditingValue(text: buffer.toString(), selection: TextSelection.collapsed(offset: buffer.toString().length));
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue newVal) {
    if (newVal.text.isEmpty) return newVal.copyWith(text: '');
    String clean = newVal.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < clean.length; i++) {
      if (i > 0 && (clean.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(clean[i]);
    }
    return TextEditingValue(text: buffer.toString(), selection: TextSelection.collapsed(offset: buffer.toString().length));
  }
}