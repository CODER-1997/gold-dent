import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ServiceController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var isLoading = false.obs;

  // Xizmatlar oqimi (Stream)
  Stream<QuerySnapshot> getServices() {
    return _firestore.collection('DentistServices').orderBy('name').snapshots();
  }

  // Xizmat qo'shish yoki yangilash
  Future<void> saveService({String? docId, required String name, required double price}) async {
    isLoading.value = true;
    try {
      final data = {
        'name': name,
        'price': price,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (docId == null) {
        await _firestore.collection('DentistServices').add(data);
      } else {
        await _firestore.collection('DentistServices').doc(docId).update(data);
      }
      Get.back();
    } catch (e) {
      Get.snackbar("Xato", "Saqlashda muammo: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // O'chirish
  Future<void> deleteService(String docId) async {
    try {
      await _firestore.collection('DentistServices').doc(docId).delete();
    } catch (e) {
      Get.snackbar("Xato", "O'chirishda muammo: $e");
    }
  }
}