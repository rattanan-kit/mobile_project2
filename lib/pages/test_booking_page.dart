import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/restaurant_service.dart';
import '../models/restaurant_model.dart';

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
                        trailing: ElevatedButton(
                          onPressed: () {
                            // เดี๋ยวเราจะมาเขียนฟังก์ชันจองโต๊ะตรงนี้!
                            print('กดจองร้าน ${restaurant.name}');
                          },
                          child: const Text('จอง'),
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
