import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance; // เพิ่มตัวเรียก Firestore

  // อัปเกรดฟังก์ชันสมัครสมาชิก รับค่า username และ phone เพิ่ม
  Future<User?> register(String email, String password, String username, String phone) async {
    try {
      // 1. สร้างบัญชีใน Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      if (user != null) {
        // 2. ถ้าสมัครผ่าน ให้เอาข้อมูลมาบันทึกลง Collection 'users'
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'username': username,
          'phone': phone,
          'favorites': [], // เตรียม Array ว่างๆ ไว้เก็บร้านโปรด!
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } catch (e) {
      print("Error Register: $e");
      return null;
    }
  }

  // (ฟังก์ชัน login กับ logout ใช้โค้ดเดิมได้เลยครับ)
    // ฟังก์ชันล็อกอิน
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print("Error Login: $e");
      return null;
    }
  }
  
   // ฟังก์ชันออกจากระบบ
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ฟังก์ชันสลับสถานะร้านโปรด (กดใจ / เอาใจออก)
  Future<void> toggleFavorite(String restaurantId) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return; // ถ้าไม่ได้ล็อกอิน ไม่ต้องทำอะไร

    DocumentReference userDoc = _db.collection('users').doc(uid);
    DocumentSnapshot docSnap = await userDoc.get();

    if (docSnap.exists) {
      List<dynamic> favorites = docSnap['favorites'] ?? [];

      if (favorites.contains(restaurantId)) {
        // ถ้ามีร้านนี้อยู่แล้ว แปลว่ากดซ้ำ = เอาหัวใจออก
        await userDoc.update({
          'favorites': FieldValue.arrayRemove([restaurantId]),
        });
        print('ลบออกจากร้านโปรดแล้ว');
      } else {
        // ถ้ายังไม่มี = เพิ่มเข้าโหมดร้านโปรด
        await userDoc.update({
          'favorites': FieldValue.arrayUnion([restaurantId]),
        });
        print('เพิ่มเป็นร้านโปรดแล้ว 💖');
      }
    }
  }
}