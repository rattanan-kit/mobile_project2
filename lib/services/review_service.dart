import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> submitReviewAndUpdateRating({
    required String bookingId,
    required String restaurantId,
    required String restaurantName,
    required String userId,
    required String userName,
    required int rating,
    required String comment,
  }) async {
    try {
      print('--- 🚀 เริ่มกระบวนการส่งรีวิว ---');
      print('Booking ID: $bookingId');
      print('Restaurant ID: $restaurantId');

      if (restaurantId.isEmpty) {
        throw Exception('ไม่พบ ID ของร้านอาหาร (restaurantId เป็นค่าว่าง)');
      }

      // 1. บันทึกรีวิวลง Collection reviews
      print('1. กำลังบันทึกลง Collection reviews...');
      await _db.collection('reviews').add({
        'bookingId': bookingId,
        'restaurantId': restaurantId,
        'restaurantName': restaurantName,
        'userId': userId,
        'userName': userName,
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('✅ บันทึกรีวิวสำเร็จ');

      // 2. อัปเดตสถานะการจองว่ารีวิวแล้ว
      print('2. กำลังอัปเดตสถานะการจอง...');
      await _db.collection('bookings').doc(bookingId).update({
        'isReviewed': true,
      });
      print('✅ อัปเดตสถานะการจองสำเร็จ');

      // 3. ระบบคำนวณคะแนนดาวเฉลี่ยของร้าน (Transaction)
      print('3. กำลังดึงข้อมูลร้านเพื่อคำนวณเรตติ้งใหม่...');
      DocumentReference restaurantRef = _db
          .collection('restaurants')
          .doc(restaurantId);

      await _db.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(restaurantRef);

        if (!snapshot.exists) {
          print(
            '❌ หา Document ของร้านนี้ไม่เจอใน Firestore! (ID: $restaurantId)',
          );
          throw Exception('ไม่พบข้อมูลร้านอาหารในระบบ');
        }

        final data = snapshot.data() as Map<String, dynamic>;

        // ดึงค่าเดิมออกมา (ป้องกัน Error ถ้าข้อมูลเดิมไม่มี)
        double currentRating = (data['rating'] ?? 0.0).toDouble();
        int currentReviewCount = data['reviewCount'] ?? 0;

        print(
          '⭐ เรตติ้งเดิม: $currentRating | คนรีวิวเดิม: $currentReviewCount',
        );

        // สูตรคำนวณคะแนนเฉลี่ย
        double newRating =
            ((currentRating * currentReviewCount) + rating) /
            (currentReviewCount + 1);

        // ปัดเศษให้อยู่ในทศนิยม 1 ตำแหน่ง (เช่น 4.56 -> 4.6)
        newRating = double.parse(newRating.toStringAsFixed(1));
        int newReviewCount = currentReviewCount + 1;

        print('🌟 เรตติ้งใหม่: $newRating | คนรีวิวใหม่: $newReviewCount');

        // อัปเดตคะแนนและจำนวนคนรีวิวกลับเข้าไป
        transaction.update(restaurantRef, {
          'rating': newRating,
          'reviewCount': newReviewCount,
        });
      });

      print('✅ อัปเดต Rating ของร้านสำเร็จ!');
      print('---------------------------------');
    } catch (e) {
      print('❌ เกิดข้อผิดพลาดใน ReviewService: $e');
      throw Exception('ไม่สามารถบันทึกรีวิวได้: $e');
    }
  }
}
