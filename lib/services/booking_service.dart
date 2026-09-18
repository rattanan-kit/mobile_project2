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
          .where('timeSlot', isEqualTo: timeSlot)
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
          .where('timeSlot', isEqualTo: timeSlot)
          .where('status', isEqualTo: 'confirmed')
          .get();

      int currentBookedSeats = 0;
      for (var doc in restaurantBookings.docs) {
        currentBookedSeats += (doc['partySize'] as num).toInt();
      }

      // 4.3 เช็กว่าที่นั่งเหลือพอไหม
      if (currentBookedSeats + partySize > maxCapacity) {
        int seatsLeft = maxCapacity - currentBookedSeats;
        print('❌ จองไม่ได้! รอบนี้เต็มแล้ว (เหลือแค่ $seatsLeft ที่นั่ง)');
        return false;
      }

      // --- ด่านที่ 5: ดึงข้อมูลโปรไฟล์ลูกค้า (เพื่อฝังชื่อและเบอร์ลงในบิล) ---
      // วางไว้ตรงนี้เพื่อประหยัดโควตาอ่าน DB ถ้าด่านก่อนหน้าไม่ผ่านจะได้ไม่ดึงฟรี
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
        'userId': userId,
        'customerName': customerName, 
        'customerPhone': customerPhone, 
        'date': date,
        'timeSlot': timeSlot,
        'partySize': partySize,
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
