/**
 * ไฟล์นี้ทำหน้าที่เป็น Service Layer จัดการข้อมูลร้านอาหาร (Restaurant System)
 * โดยจะรวบรวม Business Logic เกี่ยวกับการดึงข้อมูลร้านอาหารลง Firestore
 * 
 * ฟังก์ชันหลักในคลาส RestaurantService:
 * 1. [getRestaurants] : ดึงข้อมูลรายการร้านอาหารทั้งหมดแบบ Real-time (Stream)
 */

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
}
