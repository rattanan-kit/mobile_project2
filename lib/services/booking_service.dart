import 'package:cloud_firestore/cloud_firestore.dart';

class BookingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<bool> createBooking({
    required String restaurantId,
    required String userId,
    required String date,
    required String timeSlot,
    required int partySize,
  }) async {
    try {
      // 1. ดึงข้อมูลร้านเพื่อดูว่ารอบนึงรับได้กี่คน (capacityPerSlot)
      DocumentSnapshot restaurantDoc = await _db
          .collection('restaurants')
          .doc(restaurantId)
          .get();
      if (!restaurantDoc.exists) {
        print('หาร้านไม่เจอ');
        return false;
      }
      int maxCapacity = restaurantDoc['capacityPerSlot'] ?? 0;

      // 2. ค้นหาประวัติการจองของร้านนี้ ในวันและเวลาที่ระบุ (เอาเฉพาะที่ confirmed)
      QuerySnapshot bookingsSnapshot = await _db
          .collection('bookings')
          .where('restaurantId', isEqualTo: restaurantId)
          .where('date', isEqualTo: date)
          .where('timeSlot', isEqualTo: timeSlot)
          .where('status', isEqualTo: 'confirmed')
          .get();

      // 3. เอาจำนวนคน (partySize) ของทุกคิวในรอบนั้นมาบวกกัน
      int currentBookedSeats = 0;
      for (var doc in bookingsSnapshot.docs) {
        currentBookedSeats += (doc['partySize'] as num).toInt();
      }

      // 4. เช็กว่าถ้าบวกคนที่กำลังจะกดจองเข้าไป มันเกินโควตาไหม
      if (currentBookedSeats + partySize > maxCapacity) {
        int seatsLeft = maxCapacity - currentBookedSeats;
        print('❌ จองไม่ได้! รอบนี้เต็มแล้ว (เหลือแค่ $seatsLeft ที่นั่ง)');
        return false; // บล็อกการจองทันที
      }

      // 5. ถ้าที่นั่งเหลือพอ ก็บันทึกลง Database ตามปกติ
      await _db.collection('bookings').add({
        'restaurantId': restaurantId,
        'userId': userId,
        'date': date,
        'timeSlot': timeSlot,
        'partySize': partySize,
        'status': 'confirmed',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ จองสำเร็จ!');
      return true;
    } catch (e) {
      print('Error creating booking: $e');
      return false;
    }
  }
}
