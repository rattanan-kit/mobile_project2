/**
 * ไฟล์นี้ทำหน้าที่เป็น Booking System
 * รวม Business Logic และการตรวจสอบเงื่อนไขต่างๆ ก่อนบันทึกข้อมูลลง Firestore
 * 
 * ฟังก์ชันหลักในคลาส BookingService (มี 3 ส่วน):
 * 1. [createBooking] : สร้างการจองใหม่ โดยมีระบบ Validation ตรวจสอบ 4 ด่าน:
 *    - จำนวนคนต้องมากกว่า 0
 *    - เวลาจองต้องไม่เป็นอดีต
 *    - ผู้ใช้ต้องไม่มีคิวจองซ้ำในเวลาเดียวกัน
 *    - คำนวณที่นั่งว่าง (โควตาร้าน - ยอดจองปัจจุบัน) ต้องเพียงพอ
 *    (หากผ่าน จะไปดึงข้อมูลโปรไฟล์มาฝังในบิล และเซฟลงคอลเลกชัน 'bookings')
 * 
 * 2. [getUserBookings] : ดึงประวัติการจองทั้งหมดของ User นั้นๆ (ใช้แสดงในหน้า My Bookings)
 * 3. [cancelBooking] : อัปเดตสถานะการจอง (status) เป็น 'cancelled' (ยกเลิก)
 */

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
      // --- ด่านที่ 1: ป้องกันจำนวนคนผิดปกติ ---
      if (partySize <= 0) {
        print('❌ จองไม่ได้! จำนวนคนต้องมากกว่า 0');
        return false;
      }

      // --- ด่านที่ 2: ป้องกันการจองย้อนหลัง ---
      // นำ date และ timeSlot มาต่อกันแล้วแปลงเป็นเวลาของเครื่อง
      DateTime bookingDateTime = DateTime.parse('$date $timeSlot:00');
      if (bookingDateTime.isBefore(DateTime.now())) {
        print('❌ จองไม่ได้! ไม่สามารถจองเวลาในอดีตได้');
        return false;
      }

      // --- ด่านที่ 3: ป้องกัน User จองซ้ำเวลาเดิม ---
      QuerySnapshot userBookings = await _db
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .where('date', isEqualTo: date)
          .where('time', isEqualTo: timeSlot) // อิงชื่อ Field 'time'
          .where('status', isEqualTo: 'confirmed')
          .get();

      if (userBookings.docs.isNotEmpty) {
        print('❌ จองไม่ได้! คุณมีคิวจองในเวลานี้ไปแล้ว');
        return false;
      }

      // --- ด่านที่ 4: เช็กโควตาโต๊ะของร้าน ---
      // 4.1 ดึงข้อมูลร้านเพื่อดูว่ารับได้สูงสุดกี่คน
      DocumentSnapshot restaurantDoc = await _db
          .collection('restaurants')
          .doc(restaurantId)
          .get();
      if (!restaurantDoc.exists) {
        print('❌ หาร้านไม่เจอ');
        return false;
      }
      int maxCapacity = restaurantDoc['capacityPerSlot'] ?? 0;

      // 4.2 คำนวณยอดคนจองในรอบเวลานั้น
      QuerySnapshot restaurantBookings = await _db
          .collection('bookings')
          .where('restaurantId', isEqualTo: restaurantId)
          .where('date', isEqualTo: date)
          .where('time', isEqualTo: timeSlot) // อิงชื่อ Field 'time'
          .where('status', isEqualTo: 'confirmed')
          .get();

      int currentBookedSeats = 0;
      for (var doc in restaurantBookings.docs) {
        // อิงชื่อ Field 'guestCount'
        currentBookedSeats += (doc['guestCount'] as num).toInt();
      }

      // 4.3 เช็กว่าที่นั่งเหลือพอไหม
      if (currentBookedSeats + partySize > maxCapacity) {
        int seatsLeft = maxCapacity - currentBookedSeats;
        print('❌ จองไม่ได้! รอบนี้เต็มแล้ว (เหลือแค่ $seatsLeft ที่นั่ง)');
        return false;
      }

      // --- ด่านที่ 5: ดึงข้อมูลโปรไฟล์ลูกค้า (เพื่อฝังชื่อและเบอร์ลงในบิล) ---
      DocumentSnapshot userProfile = await _db
          .collection('users')
          .doc(userId)
          .get();
      String customerName = 'ไม่ระบุชื่อ';
      String customerPhone = 'ไม่ระบุเบอร์';

      if (userProfile.exists) {
        customerName = userProfile['username'] ?? 'ไม่ระบุชื่อ';
        customerPhone = userProfile['phone'] ?? 'ไม่ระบุเบอร์';
      }

      // --- ผ่านหมดทุกด่าน: บันทึกลง Database พร้อมชื่อและเบอร์ ---
      await _db.collection('bookings').add({
        'restaurantId': restaurantId,
        'restaurantName':
            restaurantDoc['name'] ??
            'ไม่ระบุชื่อร้าน', // เติมไว้เผื่อ UI ต้องแสดงชื่อร้าน
        'userId': userId,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'date': date,
        'time': timeSlot, // บันทึกเป็น time
        'guestCount': partySize, // บันทึกเป็น guestCount
        'status': 'confirmed',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ จองสำเร็จ! (บันทึกคิวของ: $customerName เบอร์: $customerPhone)');
      return true;
    } catch (e) {
      print('Error creating booking: $e');
      return false;
    }
  }

  // --- ฟังก์ชันดึงประวัติการจองของ User ---
  Future<List<QueryDocumentSnapshot>> getUserBookings(String userId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs;
    } catch (e) {
      print('Error fetching bookings: $e');
      return [];
    }
  }

  // --- ฟังก์ชันยกเลิกการจอง ---
  Future<bool> cancelBooking(String bookingId) async {
    try {
      await _db.collection('bookings').doc(bookingId).update({
        'status': 'cancelled',
      });
      print('✅ ยกเลิกการจองสำเร็จ! (ID: $bookingId)');
      return true;
    } catch (e) {
      print('❌ Error cancelling booking: $e');
      return false;
    }
  }
}
