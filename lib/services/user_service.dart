import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ฟังก์ชันสลับสถานะร้านโปรด (กดใจ / เอาใจออก)
  Future<void> toggleFavorite(String restaurantId) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    DocumentReference userDoc = _db.collection('users').doc(uid);
    DocumentSnapshot docSnap = await userDoc.get();

    if (docSnap.exists) {
      List<dynamic> favorites = docSnap['favorites'] ?? [];

      if (favorites.contains(restaurantId)) {
        await userDoc.update({
          'favorites': FieldValue.arrayRemove([restaurantId]),
        });
        print('ลบออกจากร้านโปรดแล้ว');
      } else {
        await userDoc.update({
          'favorites': FieldValue.arrayUnion([restaurantId]),
        });
        print('เพิ่มเป็นร้านโปรดแล้ว 💖');
      }
    }
  }

  // --- 🛠️ 1. ฟังก์ชันดึงข้อมูลโปรไฟล์ ---
  Future<Map<String, dynamic>?> getUserData() async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
    return null;
  }

  // --- 🛠️ 2. ฟังก์ชันอัปเดตข้อมูลโปรไฟล์ ---
  Future<bool> updateProfile(String username, String phone) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    try {
      await _db.collection('users').doc(uid).update({
        'username': username,
        'phone': phone,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true; // สำเร็จ
    } catch (e) {
      print("Error updating profile: $e");
      return false; // พัง
    }
  }

  // --- 🛠️ 3. ฟังก์ชันเช็กสถานะร้านโปรดแบบ Real-time ---
  Stream<bool> isFavoriteStream(String restaurantId) {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(false);

    return _db.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return false;

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      List<dynamic> favorites = data['favorites'] ?? [];

      return favorites.contains(restaurantId);
    });
  }
}
