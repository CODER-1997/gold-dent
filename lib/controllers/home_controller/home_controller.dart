import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isWorkStarted = false.obs;
  var isLoading = false.obs;
  var totalPatients = 0.obs;
  var dailyRevenue = 0.0.obs;
  var todayOrders = <Map<String, dynamic>>[].obs;

  // BottomSheet uchun vaqtinchalik tanlangan xizmatlar
  var selectedServices = <Map<String, dynamic>>[].obs;

  String get todayId => DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void onInit() {
    super.onInit();
    _listenToTodayWork();
  }

  // 1. Bugunni real-time kuzatish
  void _listenToTodayWork() {
    _firestore.collection('DentisOrders').doc(todayId).snapshots().listen((doc) {
      if (doc.exists) {
        isWorkStarted.value = true;
        var data = doc.data() as Map<String, dynamic>;

        totalPatients.value = data['total_patients'] ?? 0;
        dailyRevenue.value = (data['daily_revenue'] ?? 0).toDouble();

        // Massivni o'qish va vaqt bo'yicha saralash
        List rawOrders = data['orders'] ?? [];
        todayOrders.value = List<Map<String, dynamic>>.from(rawOrders)
          ..sort((a, b) => b['time'].compareTo(a['time']));
      } else {
        isWorkStarted.value = false;
        todayOrders.clear();
      }
    });
  }

  // 2. Ishni boshlash
  Future<void> startWork() async {
    isLoading.value = true;
    try {
      await _firestore.collection('DentisOrders').doc(todayId).set({
        'date': DateTime.now(),
        'status': 'started',
        'total_patients': 0,
        'daily_revenue': 0,
        'orders': [],
      });
    } catch (e) {
      Get.snackbar("Xato", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // 3. Xizmatlar asosida summani avtomat hisoblash
  void calculateTotal(TextEditingController totalCtrl) {
    double total = 0;
    for (var item in selectedServices) {
      total += (item['price'] * item['quantity']);
    }
    totalCtrl.text = total.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ');
  }

  // 4. Order qo'shish (FieldValue.arrayUnion)
  Future<void> addOrder(Map<String, dynamic> orderData) async {
    try {
      await _firestore.collection('DentisOrders').doc(todayId).update({
        'orders': FieldValue.arrayUnion([orderData]),
        'total_patients': FieldValue.increment(1),
        'daily_revenue': FieldValue.increment(orderData['paidAmount']),
      });
      Get.back();
      Get.snackbar("Muvaffaqiyatli", "Bemor qo'shildi");
    } catch (e) {
      Get.snackbar("Xato", e.toString());
    }
  }

  // 5. Orderni o'chirish (FieldValue.arrayRemove)
  Future<void> deleteOrder(Map<String, dynamic> order) async {
    try {
      await _firestore.collection('DentisOrders').doc(todayId).update({
        'orders': FieldValue.arrayRemove([order]),
        'total_patients': FieldValue.increment(-1),
        'daily_revenue': FieldValue.increment(-(order['paidAmount'] ?? 0)),
      });
    } catch (e) {
      Get.snackbar("Xato", "O'chirishda xatolik");
    }
  }

  // 6. Orderni tahrirlash (Massivni to'liq yangilash orqali)
  Future<void> updateOrder(Map<String, dynamic> oldOrder, Map<String, dynamic> newOrder) async {
    try {
      List current = List.from(todayOrders);
      int index = current.indexWhere((e) => e['id'] == oldOrder['id']);

      if (index != -1) {
        current[index] = newOrder;
        num revenueDiff = (newOrder['paidAmount'] as num) - (oldOrder['paidAmount'] as num);

        await _firestore.collection('DentisOrders').doc(todayId).update({
          'orders': current,
          'daily_revenue': FieldValue.increment(revenueDiff),
        });
        Get.back();
      }
    } catch (e) {
      Get.snackbar("Xato", "Yangilashda xatolik");
    }
  }
}