import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant_model.dart';

class RestaurantService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ดึงข้อมูลร้านอาหารทั้งหมดมาเป็น Stream (Real-time)
  Stream<List<RestaurantModel>> getRestaurants() {
    return _db.collection('restaurants').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return RestaurantModel.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }


  // --- ฟังก์ชันให้คะแนนและคำนวณค่าเฉลี่ยดาว ---
  Future<void> submitRating({
    required String restaurantId,
    required String userId,
    required double score,
  }) async {
    try {
      // 1. ใช้ ID ผสม (User + Restaurant) เพื่อให้ 1 คนโหวตซ้ำร้านเดิมได้ แต่ข้อมูลจะถูกบันทึกทับ (อัปเดต)
      String ratingDocId = '${userId}_$restaurantId';

      await _db.collection('ratings').doc(ratingDocId).set({
        'userId': userId,
        'restaurantId': restaurantId,
        'score': score,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 2. ดึงคะแนน "ทั้งหมด" ของร้านนี้จากทุกคนมาคำนวณใหม่
      QuerySnapshot ratingsSnapshot = await _db
          .collection('ratings')
          .where('restaurantId', isEqualTo: restaurantId)
          .get();

      double totalScore = 0;
      for (var doc in ratingsSnapshot.docs) {
        totalScore += (doc['score'] as num).toDouble();
      }

      int reviewCount = ratingsSnapshot.docs.length;
      double avgRating = reviewCount > 0 ? totalScore / reviewCount : 0.0;

      // 3. อัปเดตค่าเฉลี่ยที่ได้ กลับไปที่ข้อมูลร้านอาหาร (ปัดเศษให้เหลือทศนิยม 1 ตำแหน่ง)
      await _db.collection('restaurants').doc(restaurantId).update({
        'rating': double.parse(avgRating.toStringAsFixed(1)),
        'reviewCount': reviewCount,
      });

      print(
        '✅ ให้คะแนนสำเร็จ! ร้านมีเรตติ้งใหม่: $avgRating (จาก $reviewCount รีวิว)',
      );
    } catch (e) {
      print('❌ เกิดข้อผิดพลาดในการให้คะแนน: $e');
    }
  }
}
