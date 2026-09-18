import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/restaurant_service.dart';
import '../models/restaurant_model.dart';
import '../services/booking_service.dart';
import 'favorites_page.dart';

// เปลี่ยนเป็น StatefulWidget เพื่อให้หน้าจอจดจำสถานะการกดปุ่ม Filter ได้
class TestBookingPage extends StatefulWidget {
  const TestBookingPage({super.key});

  @override
  State<TestBookingPage> createState() => _TestBookingPageState();
}

class _TestBookingPageState extends State<TestBookingPage> {
  final RestaurantService _restaurantService = RestaurantService();

  // ตัวแปรเก็บสถานะว่าตอนนี้เลือกหมวดหมู่อะไรอยู่
  String _selectedTag = 'All';

  // รายการป้ายกำกับ (Tags) ที่จะแสดงเป็นปุ่มให้กด
  final List<String> _availableTags = [
    'All',
    'thai',
    'japanese',
    'dessert',
    'cafe',
    'shushi',
  ];

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? 'No Email';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Booking Flow'),
        actions: [
          // ปุ่มข้อมูล Dummy )
          IconButton(
            icon: const Icon(Icons.add_box, color: Colors.greenAccent),
            tooltip: 'เพิ่มร้านจำลอง',
            onPressed: () async {
              print('--- กำลังสร้างข้อมูลร้านอาหารจำลอง ---');
              final CollectionReference restaurants = FirebaseFirestore.instance
                  .collection('restaurants');

              // เตรียมข้อมูลร้าน 3 สไตล์ให้ตรงกับ tags ที่เราตั้งไว้เทส Filter
              final List<Map<String, dynamic>> dummyData = [
                {
                  'name': 'ร้านข้าวแกงป้าสม',
                  'description': 'ข้าวแกงรสเด็ด อร่อยคุ้มค่า ราคาประหยัด',
                  'capacityPerSlot': 20,
                  'imageUrl': [
                    'https://images.unsplash.com/photo-1559314809-0d155014e29e',
                    '',
                  ],
                  'lat': 13.7563,
                  'lng': 100.5018,
                  'rating': 4.5,
                  'reviewCount': 120,
                  'tags': ['thai', 'ของคาว'],
                },
                {
                  'name': 'ซูชิขั้นเทพ (Sushi God)',
                  'description': 'ซูชิปลาสด ส่งตรงจากญี่ปุ่น',
                  'capacityPerSlot': 10,
                  'imageUrl': [
                    'https://images.unsplash.com/photo-1579871494447-9811cf80d66c',
                    '',
                  ],
                  'lat': 13.7463,
                  'lng': 100.5318,
                  'rating': 4.8,
                  'reviewCount': 250,
                  'tags': ['japanese', 'sushi', 'ซูชิ', 'ญี่ปุ่น'],
                },
                {
                  'name': 'Sweet Cafe & Dessert',
                  'description':
                      'กาแฟหอมกรุ่น บรรยากาศชิลๆ พร้อมเบเกอรี่โฮมเมด',
                  'capacityPerSlot': 15,
                  'imageUrl': [
                    'https://images.unsplash.com/photo-1554118811-1e0d58224f24',
                    '',
                  ],
                  'lat': 13.7363,
                  'lng': 100.5218,
                  'rating': 4.2,
                  'reviewCount': 85,
                  'tags': ['cafe', 'dessert', 'ของหวาน', 'ทานเล่น'],
                },
              ];

              try {
                // วนลูปบันทึกลง Firebase ทีละร้าน
                for (var data in dummyData) {
                  await restaurants.add(data);
                }
                print('✅ เสกข้อมูลร้านจำลองสำเร็จ! (ลองกด Filter ดูได้เลย)');
              } catch (e) {
                print('❌ เกิดข้อผิดพลาด: $e');
              }
            },
          ),
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

              for (var doc in bookings) {
                print(
                  'ID: ${doc.id} | วันที่: ${doc['date']} | สถานะ: ${doc['status']}',
                );
              }

              for (var doc in bookings) {
                if (doc['status'] == 'confirmed') {
                  print('กำลังพยายามยกเลิกคิว ${doc.id}...');
                  await BookingService().cancelBooking(doc.id);
                  break;
                }
              }
            },
          ),
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

          // --- แถบปุ่มกด Filter หมวดหมู่ ---
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              itemCount: _availableTags.length,
              itemBuilder: (context, index) {
                final tag = _availableTags[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(tag == 'All' ? 'ทั้งหมด' : tag.toUpperCase()),
                    selected: _selectedTag == tag,
                    onSelected: (selected) {
                      setState(() {
                        _selectedTag = tag;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(),

          // --- รายชื่อร้านอาหาร ---
          Expanded(
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

                List<RestaurantModel> allRestaurants = snapshot.data ?? [];

                // --- ระบบกรองข้อมูล (Filter Logic) ---
                List<RestaurantModel> filteredRestaurants = allRestaurants;
                if (_selectedTag != 'All') {
                  filteredRestaurants = allRestaurants
                      .where(
                        (restaurant) => restaurant.tags.contains(_selectedTag),
                      )
                      .toList();
                }

                if (filteredRestaurants.isEmpty) {
                  return const Center(
                    child: Text('ไม่พบข้อมูลร้านอาหารในหมวดหมู่นี้'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredRestaurants.length,
                  itemBuilder: (context, index) {
                    final restaurant = filteredRestaurants[index];
                    return Card(
                      margin: const EdgeInsets.all(16),
                      child: ListTile(
                        // แก้ไขการแสดงรูปภาพเป็นแบบดึงจาก Array ช่องแรก (Index 0)
                        leading: restaurant.images.isNotEmpty
                            ? Image.network(
                                restaurant.images[0],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (c, o, s) =>
                                    const Icon(Icons.restaurant, size: 40),
                              )
                            : const Icon(Icons.restaurant, size: 40),
                        title: Text(restaurant.name),
                        subtitle: Text(
                          'ความจุ: ${restaurant.capacityPerSlot} ที่นั่ง/รอบ\nเรตติ้ง: ${restaurant.rating}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (userEmail != 'No Email')
                              StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(FirebaseAuth.instance.currentUser?.uid)
                                    .snapshots(),
                                builder: (context, userSnap) {
                                  if (!userSnap.hasData ||
                                      !userSnap.data!.exists) {
                                    return const Icon(
                                      Icons.favorite_border,
                                      color: Colors.grey,
                                    );
                                  }

                                  List<dynamic> favorites =
                                      userSnap.data!.get('favorites') ?? [];
                                  bool isFav = favorites.contains(
                                    restaurant.id,
                                  );

                                  return IconButton(
                                    icon: Icon(
                                      isFav
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isFav ? Colors.red : Colors.grey,
                                    ),
                                    onPressed: () {
                                      AuthService().toggleFavorite(
                                        restaurant.id,
                                      );
                                    },
                                  );
                                },
                              ),
                              

                            ElevatedButton(
                              onPressed: () async {
                                final userId =
                                    FirebaseAuth.instance.currentUser?.uid;
                                if (userId == null) {
                                  print('ยังไม่ได้ล็อกอิน');
                                  return;
                                }

                                final success = await BookingService()
                                    .createBooking(
                                      restaurantId: restaurant.id,
                                      userId: userId,
                                      date: '2026-10-20',
                                      timeSlot: '12:00',
                                      partySize: 2,
                                    );

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
