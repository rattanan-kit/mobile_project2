import 'package:cloud_firestore/cloud_firestore.dart';

class BookingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ฟังก์ชันสร้างการจอง (เวอร์ชันแรก: เน้นบันทึกข้อมูลพื้นฐานให้ลง Database สำเร็จ)
  Future<bool> createBooking({
    required String restaurantId,
    required String userId,
    required String date,
    required String timeSlot,
    required int partySize,
  }) async {
    try {
      await _db.collection('bookings').add({
        'restaurantId': restaurantId,
        'userId': userId,
        'date': date,
        'timeSlot': timeSlot,
        'partySize': partySize,
        'status': 'confirmed', // ตั้งค่าเริ่มต้นเป็น confirmed ทันทีที่จอง
        'createdAt': FieldValue.serverTimestamp(), // ประทับเวลาของเซิร์ฟเวอร์
      });
      return true; // บันทึกสำเร็จ
    } catch (e) {
      print('Error creating booking: $e');
      return false; // บันทึกล้มเหลว
    }
  }
}
