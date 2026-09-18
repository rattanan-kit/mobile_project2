import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/restaurant_service.dart';
import '../models/restaurant_model.dart';
import '../services/booking_service.dart';
import 'favorites_page.dart';


import 'package:cloud_firestore/cloud_firestore.dart';

class TestBookingPage extends StatelessWidget {
  const TestBookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? 'No Email';
    final RestaurantService _restaurantService = RestaurantService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Booking Flow'),
        actions: [
          // ปุ่มไปหน้าร้านโปรด
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () async {
              final userId = FirebaseAuth.instance.currentUser?.uid;
              if (userId == null) return;

              print('--- กำลังดึงประวัติการจอง ---');
              final bookings = await BookingService().getUserBookings(userId);
              
              if (bookings.isEmpty) {
                print('ไม่มีประวัติการจอง');
                return;
              }

              // ปริ้นต์รายการจองทั้งหมดออกมาดู
              for (var doc in bookings) {
                print('ID: ${doc.id} | วันที่: ${doc['date']} | สถานะ: ${doc['status']}');
              }

              // --- เทสระบบยกเลิก: ลองยกเลิกคิวแรกที่สถานะยังเป็น confirmed ---
              for (var doc in bookings) {
                if (doc['status'] == 'confirmed') {
                  print('กำลังพยายามยกเลิกคิว ${doc.id}...');
                  await BookingService().cancelBooking(doc.id);
                  break; // ยกเลิกแค่อันเดียวพอเพื่อเทส
                }
              }
            },
          ),
          // ปุ่ม Logout เดิม
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AuthService().logout();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'ผู้ใช้งาน: $userEmail',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          Expanded(
            // ใช้ StreamBuilder เพื่อรอรับข้อมูลจาก Firestore
            child: StreamBuilder<List<RestaurantModel>>(
              stream: _restaurantService.getRestaurants(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
                  );
                }

                final restaurants = snapshot.data ?? [];

                if (restaurants.isEmpty) {
                  return const Center(child: Text('ไม่พบข้อมูลร้านอาหาร'));
                }

                // แสดงรายการร้านอาหารแบบง่ายๆ
                return ListView.builder(
                  itemCount: restaurants.length,
                  itemBuilder: (context, index) {
                    final restaurant = restaurants[index];
                    return Card(
                      margin: const EdgeInsets.all(16),
                      child: ListTile(
                        leading: Image.network(
                          restaurant.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          // เผื่อลิงก์รูปพัง จะได้โชว์ไอคอนแทน
                          errorBuilder: (c, o, s) =>
                              const Icon(Icons.restaurant, size: 40),
                        ),
                        title: Text(restaurant.name),
                        subtitle: Text(
                          'ความจุ: ${restaurant.capacityPerSlot} ที่นั่ง/รอบ\nเรตติ้ง: ${restaurant.rating}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // --- ส่วนที่เพิ่มใหม่: ปุ่มกดหัวใจ ---
                            if (userEmail != 'No Email') // เช็กว่าล็อกอินอยู่ไหม
                              StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).snapshots(),
                                builder: (context, userSnap) {
                                  if (!userSnap.hasData || !userSnap.data!.exists) {
                                    return const Icon(Icons.favorite_border, color: Colors.grey);
                                  }
                                  
                                  // ดึง Array ร้านโปรดมาเช็ก
                                  List<dynamic> favorites = userSnap.data!.get('favorites') ?? [];
                                  bool isFav = favorites.contains(restaurant.id);

                                  return IconButton(
                                    icon: Icon(
                                      isFav ? Icons.favorite : Icons.favorite_border,
                                      color: isFav ? Colors.red : Colors.grey,
                                    ),
                                    onPressed: () {
                                      AuthService().toggleFavorite(restaurant.id);
                                    },
                                  );
                                },
                              ),

                            // --- ส่วนเดิม: ปุ่มจองโต๊ะ ---
                            ElevatedButton(
                              onPressed: () async {
                                // 1. ดึง UID ของคนที่ล็อกอินอยู่
                                final userId =
                                    FirebaseAuth.instance.currentUser?.uid;
                                if (userId == null) {
                                  print('ยังไม่ได้ล็อกอิน');
                                  return;
                                }

                                // 2. เรียกใช้ Service เพื่อบันทึกการจอง (จำลองข้อมูลวันที่และจำนวนคนไปก่อน)
                                final success = await BookingService()
                                    .createBooking(
                                      restaurantId: restaurant.id,
                                      userId: userId,
                                      date: '2026-10-20', // ฟิกซ์วันที่ไว้เทส
                                      timeSlot: '12:00', // ฟิกซ์เวลาไว้เทส
                                      partySize: 2, // สมมติว่ามา 2 คน
                                    );
                                    
                                // 3. แสดงผลลัพธ์ใน Terminal
                                if (success) {
                                  print(
                                    'จองร้าน ${restaurant.name} สำเร็จ! (UID: $userId)',
                                  );
                                } else {
                                  print('จองไม่สำเร็จ');
                                }
                              },
                              child: const Text('จอง'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
