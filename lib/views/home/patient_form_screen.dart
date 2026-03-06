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
    totalCtrl.addListener(() => setState(() {}));
    paidCtrl.addListener(() => setState(() {}));
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
      backgroundColor: const Color(0xFFF8F9FF), // Yumshoq fon rangi
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F3FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF2E3A59), size: 20),
          ),
        ),
        title: Text(
          widget.doc == null ? "Yangi Bemor" : "Tahrirlash",
          style: const TextStyle(
            color: Color(0xFF2E3A59),
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),

      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bemor ma'lumotlari kartasi
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.person_outline_rounded,
                              color: Color(0xFF4F5B7A), size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "BEMOR MA'LUMOTLARI",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4F5B7A),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildField(
                      nameCtrl,
                      "To'liq ism (F.I.O)",
                      Icons.person_outline_rounded,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      phoneCtrl,
                      "Telefon raqami",
                      Icons.phone_android_rounded,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [UzbekPhoneInputFormatter()],
                      isRequired: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Xizmatlar kartasi
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE6F7FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.medical_services_outlined,
                                  color: Color(0xFF0077B6), size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "XIZMATLAR",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF4F5B7A),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F7FF),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Obx(() => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Text(
                              "${controller.selectedServices.length} ta",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0077B6),
                              ),
                            ),
                          )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Tanlangan xizmatlar
                    Obx(() => controller.selectedServices.isEmpty
                        ? _emptyServiceInfo()
                        : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.selectedServices.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        var s = controller.selectedServices[index];
                        return _buildServiceCard(s, index);
                      },
                    )),

                    const SizedBox(height: 16),

                    // Xizmat qo'shish tugmasi
                    _servicePickerButton(),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Kassa va to'lov kartasi
              _buildPaymentSection(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: double.infinity-32,
          height: 62,
          child: Obx(() => GestureDetector(
            onTap: controller.isLoading.value ? null : _handleSave,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF2563EB),
                    Color(0xFF3B82F6),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Center(
                child: controller.isLoading.value
                    ? const CupertinoActivityIndicator(color: Colors.white)
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.check_circle_outline,
                        color: Colors.white, size: 22),
                    SizedBox(width: 10),
                    Text(
                      "SAQLASH",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
        ),
      ) ,
    );
  }

  Widget _buildPaymentSection() {
    // Qiymatlarni raqamga o'tkazish (Formatlashdan tozalash)
    double total = double.tryParse(totalCtrl.text.replaceAll(' ', '')) ?? 0;
    double paid = double.tryParse(paidCtrl.text.replaceAll(' ', '')) ?? 0;
    double debt = total - paid;
    bool isDebt = debt > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
              Icons.account_balance_wallet_outlined,
              "TO'LOV MA'LUMOTLARI",
              const Color(0xFFFFF1E6),
              const Color(0xFFE65C4B)
          ),
          const SizedBox(height: 20),

          // Umumiy summa - formatlash va faqat raqam bilan
          _buildField(
            totalCtrl,
            "Umumiy summa",
            Icons.monetization_on_outlined,
            isRequired: true,
            keyboardType: TextInputType.number, // Faqat raqamli klaviatura
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // Faqat raqam kiritish
              ThousandsSeparatorInputFormatter(), // Probellar bilan formatlash
            ],
          ),
          const SizedBox(height: 16),

          // To'langan summa (Avans) - formatlash va faqat raqam bilan
          _buildField(
            paidCtrl,
            "To'langan summa",
            Icons.payment_outlined,
            isRequired: false,
            keyboardType: TextInputType.number, // Faqat raqamli klaviatura
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // Faqat raqam kiritish
              ThousandsSeparatorInputFormatter(), // Probellar bilan formatlash
            ],
          ),
          const SizedBox(height: 20),

          // Qarzdorlik indikatori
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDebt ? const Color(0xFFFFF1E6).withOpacity(0.5) : const Color(0xFFE8F5E9).withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDebt ? const Color(0xFFFFB74D).withOpacity(0.3) : const Color(0xFF81C784).withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isDebt ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                      color: isDebt ? const Color(0xFFFF6B35) : const Color(0xFF2E7D32),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isDebt ? "Qarzdorlik" : "To'liq to'lov",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDebt ? const Color(0xFFFF6B35) : const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
                Text(
                  "${NumberFormat("#,###").format(debt)} so'm",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isDebt ? const Color(0xFFFF6B35) : const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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






  Widget _buildField(
      TextEditingController ctrl,
      String hint,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
        List<TextInputFormatter>? inputFormatters,
        bool isRequired = true,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isRequired)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              hint,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8E9AAE),
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: ctrl,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            validator: isRequired ? (value) {
              if (value == null || value.trim().isEmpty) {
                return "Maydonni to'ldiring";
              }
              return null;
            } : null, // Validator kerak bo'lmaganda null
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF2E3A59),
            ),
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F3FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF4F5B7A), size: 20),
              ),
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: const Color(0xFF4F5B7A), width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE65C4B), width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE65C4B), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              errorStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE65C4B),
              ),
            ),
          ),
        ),
      ],
    );
  }


  // Xizmat kartasi (tish xaritasisiz)
  Widget _buildServiceCard(Map<String, dynamic> service, int index) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9ECF5), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.medical_services_outlined,
                color: const Color(0xFF0077B6),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF2E3A59),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.monetization_on_outlined,
                          size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        NumberFormat("#,###").format(service['price']),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildQuantityControl(service, index),
          ],
        ),
      ),
    );
  }

  // Miqdor boshqaruvi
  Widget _buildQuantityControl(Map<String, dynamic> service, int index) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE9ECF5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuantityButton(
            icon: Icons.remove_rounded,
            onTap: () {
              if (service['quantity'] > 1) {
                var item = Map<String, dynamic>.from(controller.selectedServices[index]);
                item['quantity']--;
                controller.selectedServices[index] = item;
              } else {
                controller.selectedServices.removeAt(index);
              }
              controller.selectedServices.refresh();
              controller.calculateTotal(totalCtrl);
            },
            color: const Color(0xFFE65C4B),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              "${service['quantity']}",
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: Color(0xFF2E3A59),
              ),
            ),
          ),
          _buildQuantityButton(
            icon: Icons.add_rounded,
            onTap: () {
              var item = Map<String, dynamic>.from(controller.selectedServices[index]);
              item['quantity']++;
              controller.selectedServices[index] = item;
              controller.selectedServices.refresh();
              controller.calculateTotal(totalCtrl);
            },
            color: const Color(0xFF2E7D32),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  // Xizmat qo'shish tugmasi
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
          border: Border.all(color: const Color(0xFFB8E2F2), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Color(0xFF0077B6), size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              "XIZMAT QO'SHISH",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0077B6),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bo'sh xizmatlar uchun
  Widget _emptyServiceInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9ECF5), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.medical_services_outlined,
              size: 40,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Xizmatlar qo'shilmagan",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Xizmat qo'shish uchun pastdagi tugmani bosing",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
 // Xizmatlar picker (tish xaritasi olib tashlangan)
  Future<DateTime?> _pickNextVisitDate() async {
    return await Get.dialog<DateTime>(
      Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          width: Get.width * 0.85,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ICON
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.calendar_month_rounded, color: Color(0xFF2E5BFF), size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                "Keyingi ko'rik",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 18),

              // --- GRIDVIEW ---
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.2,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _quickDateBtn("Ertaga", 1, const Color(0xFF00C48C)),
                  _quickDateBtn("Indinga", 2, const Color(0xFF00C48C)),
                  _quickDateBtn("3 kundan keyin", 3, const Color(0xFF00C48C)),
                  _quickDateBtn("5 kundan keyin", 5, const Color(0xFF00C48C)),
                  _quickDateBtn("7 kundan keyin", 7, const Color(0xFF00C48C)),
                  // Kerak emas tugmasi ham Grid ichida
                  ElevatedButton(
                    onPressed: () => Get.back(result: null),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                      foregroundColor: const Color(0xFF64748B),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text("Shart emas", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Calendar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: const Text("Kalendarni ochish"),
                  onPressed: () async {
                    DateTime? date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) Get.back(result: date);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E5BFF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickDateBtn(String title, int days, Color color) {
    return ElevatedButton(
      onPressed: () => Get.back(result: DateTime.now().add(Duration(days: days))),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
    );
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    // Dialog natijasini kutamiz
    DateTime? pickedDate = await _pickNextVisitDate();

    // DIALOGDAN KEYIN ISHLAYDI:
    controller.isLoading.value = true;

    double clean(String v) => double.tryParse(v.replaceAll(' ', '')) ?? 0;
    String name = nameCtrl.text.trim();

    Map<String, dynamic> data = {
      'id': widget.doc?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'patientName': name,
      'phone': phoneCtrl.text,
      'services': List.from(controller.selectedServices),
      'totalPrice': clean(totalCtrl.text),
      'paidAmount': clean(paidCtrl.text),
      'debtAmount': clean(totalCtrl.text) - clean(paidCtrl.text),
      'nextVisit': pickedDate == null ? null : DateFormat('dd.MM.yyyy').format(pickedDate),
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

      // Agar sana tanlangan bo'lsa snackbarda ko'rsatamiz
      String msg = pickedDate == null
          ? "Ma'lumot saqlandi"
          : "Keyingi ko'rik: ${DateFormat('dd.MM.yyyy').format(pickedDate)}";

      Get.snackbar(
        "Muvaffaqiyatli",
        msg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF00C48C),
        colorText: Colors.white,
      );
    } catch (e) {
      controller.isLoading.value = false;
      Get.snackbar("Xato", "Xatolik: $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }





  void _showServicesPicker() {
    final searchCtrl = TextEditingController();
    RxString query = "".obs;

    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        height: Get.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "STOMATOLOGIK XIZMATLAR",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: Color(0xFF2E3A59),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE9ECF5)),
                ),
                child: TextField(
                  controller: searchCtrl,
                  onChanged: (v) => query.value = v.toLowerCase(),
                  decoration: InputDecoration(
                    hintText: "Xizmat nomini kiriting...",
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0077B6)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('DentistServices')
                    .orderBy('name')
                    .snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(
                      child: CupertinoActivityIndicator(),
                    );
                  }

                  return Obx(() {
                    var docs = snap.data!.docs
                        .where((d) => (d.data() as Map)['name']
                        .toString()
                        .toLowerCase()
                        .contains(query.value))
                        .toList();

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        var data = docs[i].data() as Map<String, dynamic>;

                        return Obx(() {
                          bool isSelected = controller.selectedServices
                              .any((s) => s['name'] == data['name']);
                          int count = controller.selectedServices
                              .firstWhereOrNull((s) => s['name'] == data['name'])
                          ?['quantity'] ?? 0;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFE6F7FF) : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF0077B6).withOpacity(0.3)
                                    : const Color(0xFFE9ECF5),
                                width: 1.5,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.medical_services_outlined,
                                  color: isSelected
                                      ? const Color(0xFF0077B6)
                                      : Colors.grey.shade500,
                                  size: 22,
                                ),
                              ),
                              title: Text(
                                data['name'],
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                  color: isSelected ? const Color(0xFF0077B6) : const Color(0xFF2E3A59),
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: Text(
                                NumberFormat("#,###").format(data['price']),
                                style: const TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              trailing: isSelected
                                  ? Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0077B6),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  "$count",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                                  : Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F3FF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  color: Color(0xFF4F5B7A),
                                  size: 18,
                                ),
                              ),
                              onTap: () {
                                var idx = controller.selectedServices
                                    .indexWhere((s) => s['name'] == data['name']);

                                if (idx != -1) {
                                  var item = Map<String, dynamic>.from(
                                      controller.selectedServices[idx]);
                                  item['quantity']++;
                                  controller.selectedServices[idx] = item;
                                } else {
                                  controller.selectedServices.add({
                                    'name': data['name'],
                                    'price': (data['price'] as num).toDouble(),
                                    'quantity': 1,
                                  });
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
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0077B6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Get.back(),
                  child: const Text(
                    "TASDIQLASH",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// UzbekPhoneInputFormatter (o'zgarishsiz)
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
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.toString().length),
    );
  }
}

// ThousandsSeparatorInputFormatter (o'zgarishsiz)
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
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.toString().length),
    );
  }
}