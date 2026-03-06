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
    // Listenerlar qarzdorlikni real vaqtda hisoblash uchun
    totalCtrl.addListener(() => setState(() {}));
    paidCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    totalCtrl.dispose();
    paidCtrl.dispose();
    super.dispose();
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
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(12)),
          child: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2E3A59), size: 20),
          ),
        ),
        title: Text(widget.doc == null ? "Yangi Bemor" : "Tahrirlash",
            style: const TextStyle(color: Color(0xFF2E3A59), fontWeight: FontWeight.w800, fontSize: 20)),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(12)),
            child: IconButton(onPressed: _handleSave, icon: const Icon(Icons.check_rounded, color: Color(0xFF2E3A59))),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 1. BEMOR MA'LUMOTLARI
              _buildCard(
                child: Column(
                  children: [
                    _buildSectionHeader(Icons.person_outline_rounded, "BEMOR MA'LUMOTLARI", const Color(0xFFEEF2FF), const Color(0xFF4F5B7A)),
                    const SizedBox(height: 20),
                    _buildField(nameCtrl, "To'liq ism (F.I.O)", Icons.person_outline_rounded),
                    const SizedBox(height: 16),
                    _buildField(phoneCtrl, "Telefon raqami", Icons.phone_android_rounded,
                        keyboardType: TextInputType.phone, inputFormatters: [UzbekPhoneInputFormatter()]),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. XIZMATLAR (Yangi Dizayn)
              _buildCard(
                child: Column(
                  children: [
                    _buildSectionHeader(Icons.medical_services_outlined, "XIZMATLAR", const Color(0xFFE6F7FF), const Color(0xFF0077B6)),
                    const SizedBox(height: 20),
                    Obx(() => controller.selectedServices.isEmpty
                        ? _emptyServiceInfo()
                        : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.selectedServices.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _buildServiceItem(controller.selectedServices[index], index),
                    ),
                    ),
                    const SizedBox(height: 20),
                    _servicePickerButton(),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. TO'LOV
              _buildCard(
                child: Column(
                  children: [
                    _buildSectionHeader(Icons.account_balance_wallet_outlined, "TO'LOV MA'LUMOTLARI", const Color(0xFFFFF1E6), const Color(0xFFE65C4B)),
                    const SizedBox(height: 20),
                    _buildPaymentField(totalCtrl, "Umumiy summa", Icons.monetization_on_outlined, color: const Color(0xFF2E7D32)),
                    const SizedBox(height: 16),
                    _buildPaymentField(paidCtrl, "To'langan summa", Icons.payment_outlined, color: const Color(0xFFE65C4B), isRequired: false),
                    const SizedBox(height: 20),
                    _buildDebtSection(),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI KOMPONENTLARI ---

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 5))]
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, Color bgColor, Color iconColor) {
    return Row(
      children: [
        Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 20)
        ),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF4F5B7A), letterSpacing: 0.5)),
      ],
    );
  }

  // Xizmat elementi dizayni
  Widget _buildServiceItem(Map<String, dynamic> s, int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFFF8F9FF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE9ECF5))
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.vaccines_rounded, color: Color(0xFF0077B6), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s['name'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF2E3A59))),
                Text("${NumberFormat("#,###").format(s['price'])} so'm", style: const TextStyle(fontSize: 12, color: Color(0xFF2E7D32), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          _qtySelector(s, index),
        ],
      ),
    );
  }

  Widget _qtySelector(Map<String, dynamic> s, int index) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE9ECF5))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              if (s['quantity'] > 1) {
                var item = Map<String, dynamic>.from(controller.selectedServices[index]);
                item['quantity']--;
                controller.selectedServices[index] = item;
              } else {
                controller.selectedServices.removeAt(index);
              }
              controller.calculateTotal(totalCtrl);
            },
            icon: const Icon(Icons.remove, color: Colors.red, size: 18),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
          Text("${s['quantity']}", style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          IconButton(
            onPressed: () {
              var item = Map<String, dynamic>.from(controller.selectedServices[index]);
              item['quantity']++;
              controller.selectedServices[index] = item;
              controller.calculateTotal(totalCtrl);
            },
            icon: const Icon(Icons.add, color: Colors.green, size: 18),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _servicePickerButton() {
    return InkWell(
      onTap: () => _showServicesPicker(),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
            color: const Color(0xFFE6F7FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFB8E2F2), width: 1.5)
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: Color(0xFF0077B6), size: 20),
            SizedBox(width: 8),
            Text("XIZMAT QO'SHISH", style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0077B6), letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint, IconData icon,
      {TextInputType keyboardType = TextInputType.text, List<TextInputFormatter>? inputFormatters, bool isRequired = true}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: isRequired ? (v) => v == null || v.isEmpty ? "Maydonni to'ldiring" : null : null,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF4F5B7A), size: 20),
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8F9FF),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade100)),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildPaymentField(TextEditingController ctrl, String hint, IconData icon, {required Color color, bool isRequired = true}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      inputFormatters: [ThousandsSeparatorInputFormatter()],
      validator: isRequired ? (v) => v == null || v.isEmpty ? "Maydonni to'ldiring" : null : null,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: color, size: 22),
        hintText: hint,
        suffixText: "so'm",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: color.withOpacity(0.2))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: color, width: 2)),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildDebtSection() {
    double total = double.tryParse(totalCtrl.text.replaceAll(' ', '')) ?? 0;
    double paid = double.tryParse(paidCtrl.text.replaceAll(' ', '')) ?? 0;
    double debt = total - paid;
    bool isDebt = debt > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDebt ? const Color(0xFFFFF1E6) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDebt ? const Color(0xFFFFB74D) : const Color(0xFF81C784)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(isDebt ? "Qarzdorlik" : "To'liq to'lov",
              style: TextStyle(fontWeight: FontWeight.w600, color: isDebt ? const Color(0xFFFF6B35) : const Color(0xFF2E7D32))),
          Text(NumberFormat("#,###").format(debt),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: isDebt ? const Color(0xFFFF6B35) : const Color(0xFF2E7D32))),
        ],
      ),
    );
  }

  void _showServicesPicker() {
    final searchCtrl = TextEditingController();
    RxString query = "".obs;
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: CupertinoSearchTextField(controller: searchCtrl, onChanged: (v) => query.value = v.toLowerCase())),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('DentistServices').orderBy('name').snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) return const Center(child: CupertinoActivityIndicator());
                  return Obx(() {
                    var docs = snap.data!.docs.where((d) => (d.data() as Map)['name'].toString().toLowerCase().contains(query.value)).toList();
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        var data = docs[i].data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text(data['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(NumberFormat("#,###").format(data['price'])),
                          trailing: const Icon(Icons.add_circle_outline, color: Color(0xFF0077B6)),
                          onTap: () {
                            var idx = controller.selectedServices.indexWhere((s) => s['name'] == data['name']);
                            if (idx != -1) {
                              var item = Map<String, dynamic>.from(controller.selectedServices[idx]);
                              item['quantity']++;
                              controller.selectedServices[idx] = item;
                            } else {
                              controller.selectedServices.add({'name': data['name'], 'price': data['price'].toDouble(), 'quantity': 1});
                            }
                            controller.calculateTotal(totalCtrl);
                            Get.back();
                          },
                        );
                      },
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

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
        if (widget.doc == null) await controller.addOrder(data);
        else await controller.updateOrder(widget.doc!, data);
        Get.back();
      } finally {
        controller.isLoading.value = false;
      }
    }
  }

  Widget _emptyServiceInfo() => const Padding(padding: EdgeInsets.all(20), child: Center(child: Text("Xizmatlar qo'shilmadi", style: TextStyle(color: Colors.grey))));
}

// FORMATTERS
class UzbekPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue newVal) {
    if (newVal.selection.baseOffset < old.selection.baseOffset) return newVal;
    String digits = newVal.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer()..write('+');
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
    if (newVal.text.isEmpty) return newVal;
    String clean = newVal.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < clean.length; i++) {
      if (i > 0 && (clean.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(clean[i]);
    }
    return TextEditingValue(text: buffer.toString(), selection: TextSelection.collapsed(offset: buffer.toString().length));
  }
}