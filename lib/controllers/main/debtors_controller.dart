import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class DebtorController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var searchQuery = "".obs;

  // Stream: Barcha kunlik hisobotlarni kuzatib boradi
  Stream<QuerySnapshot> get debtorStream => _firestore
      .collection('DentisOrders') // HomeController bilan bir xil kolleksiya nomi
      .snapshots();

  // Massiv ichidagi ma'lumotlarni qayta ishlash va filtrlash
  List<Map<String, dynamic>> filterList(List<QueryDocumentSnapshot> dayDocs) {
    List<Map<String, dynamic>> allDebtors = [];

    for (var dayDoc in dayDocs) {
      var dayData = dayDoc.data() as Map<String, dynamic>;

      // Kunlik orders massivini olamiz
      List rawOrders = dayData['orders'] ?? [];

      for (var order in rawOrders) {
        Map<String, dynamic> orderMap = Map<String, dynamic>.from(order);

        // FAQAT qarzi 0 dan katta bo'lganlarni qo'shamiz
        // HomeController'dagi field nomi 'debtAmount' ekanligiga ishonch hosil qiling
        double debt = double.tryParse(orderMap['debtAmount']?.toString() ?? '0') ?? 0;

        if (debt > 0) {
          orderMap['dayDocId'] = dayDoc.id; // Qaysi kunga tegishliligini bilish uchun
          allDebtors.add(orderMap);
        }
      }
    }

    // Vaqt bo'yicha saralash (eng yangi qarzlar tepada)
    allDebtors.sort((a, b) => (b['time'] ?? "").compareTo(a['time'] ?? ""));

    // Qidiruv mantiqi
    if (searchQuery.isEmpty) return allDebtors;

    return allDebtors.where((item) {
      final name = (item['patientName'] ?? "").toString().toLowerCase();
      return name.contains(searchQuery.value.toLowerCase());
    }).toList();
  }
}