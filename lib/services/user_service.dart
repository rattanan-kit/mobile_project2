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
}

