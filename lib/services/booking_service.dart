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
      // --- ด่านที่ 1: (จำนวนคนผิดปกติ) ---
      if (partySize <= 0) {
        print('❌ จองไม่ได้! จำนวนคนต้องมากกว่า 0');
        return false;
      }

      // --- ด่านที่ 2: (ป้องกันการจองย้อนหลัง) ---
      // นำ date และ timeSlot มาต่อกันแล้วแปลงเป็นเวลาของเครื่อง
      DateTime bookingDateTime = DateTime.parse('$date $timeSlot:00');
      if (bookingDateTime.isBefore(DateTime.now())) {
        print('❌ จองไม่ได้! ไม่สามารถจองเวลาในอดีตได้');
        return false;
      }

      // --- ด่านที่ 3: (ป้องกัน User จองซ้ำเวลาเดิม) ---
      QuerySnapshot userBookings = await _db
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .where('date', isEqualTo: date)
          .where('timeSlot', isEqualTo: timeSlot)
          .where('status', isEqualTo: 'confirmed')
          .get();

      if (userBookings.docs.isNotEmpty) {
        print('❌ จองไม่ได้! คุณมีคิวจองในเวลานี้ไปแล้ว');
        return false;
      }

      // --- ด่านที่ 4: เช็กโควตาโต๊ะของร้าน  ---
      DocumentSnapshot restaurantDoc = await _db
          .collection('restaurants')
          .doc(restaurantId)
          .get();
      if (!restaurantDoc.exists) {
        print('❌ หาร้านไม่เจอ');
        return false;
      }
      int maxCapacity = restaurantDoc['capacityPerSlot'] ?? 0;

      QuerySnapshot restaurantBookings = await _db
          .collection('bookings')
          .where('restaurantId', isEqualTo: restaurantId)
          .where('date', isEqualTo: date)
          .where('timeSlot', isEqualTo: timeSlot)
          .where('status', isEqualTo: 'confirmed')
          .get();

      int currentBookedSeats = 0;
      for (var doc in restaurantBookings.docs) {
        currentBookedSeats += (doc['partySize'] as num).toInt();
      }

      if (currentBookedSeats + partySize > maxCapacity) {
        int seatsLeft = maxCapacity - currentBookedSeats;
        print('❌ จองไม่ได้! รอบนี้เต็มแล้ว (เหลือแค่ $seatsLeft ที่นั่ง)');
        return false;
      }

      // --- ผ่านหมด: บันทึกลง Database ---
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
