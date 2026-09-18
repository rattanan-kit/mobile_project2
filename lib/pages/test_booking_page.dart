import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/restaurant_service.dart';
import '../models/restaurant_model.dart';
import '../services/booking_service.dart';
import 'favorites_page.dart';

class TestBookingPage extends StatefulWidget {
  const TestBookingPage({super.key});

  @override
  State<TestBookingPage> createState() => _TestBookingPageState();
}

class _TestBookingPageState extends State<TestBookingPage> {
  final RestaurantService _restaurantService = RestaurantService();

  // 1. สร้างตัวแปรมารับ Stream เพื่อให้ดึงข้อมูลมาเก็บใน RAM แค่ครั้งเดียว
  late Stream<List<RestaurantModel>> _restaurantStream;

  String _selectedTag = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _availableTags = [
    'All',
    'thai',
    'japanese',
    'dessert',
    'cafe',
    'shushi',
  ];

  // 2. สั่งให้ดึงข้อมูลจาก Firebase ทันทีที่เปิดหน้านี้ (ดึงแค่ครั้งเดียว!)
  @override
  void initState() {
    super.initState();
    _restaurantStream = _restaurantService.getRestaurants();
  }

  // คืนพื้นที่หน่วยความจำเมื่อปิดหน้าแอป (Best Practice)
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- ฟังก์ชันแสดงหน้าต่างเลือกข้อมูลการจอง (BottomSheet) ---
  Future<void> _showBookingBottomSheet(
    BuildContext context,
    RestaurantModel restaurant,
  ) async {
    DateTime selectedDate = DateTime.now();
    String selectedTime = '12:00';
    int partySize = 2;

    // สร้างลิสต์เวลา 08:00 - 20:00
    final List<String> timeSlots = List.generate(
      13,
      (index) => '${(index + 8).toString().padLeft(2, '0')}:00',
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'จองโต๊ะ: ${restaurant.name}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 1. เลือกวันที่
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('วันที่จอง'),
                    subtitle: Text(
                      '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (picked != null) {
                        setModalState(() => selectedDate = picked);
                      }
                    },
                  ),

                  // 2. เลือกเวลา
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('เวลา'),
                    trailing: DropdownButton<String>(
                      value: selectedTime,
                      items: timeSlots.map((time) {
                        return DropdownMenuItem(value: time, child: Text(time));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedTime = val);
                        }
                      },
                    ),
                  ),

                  // 3. เลือกจำนวนคน
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('จำนวนคน'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: partySize > 1
                              ? () => setModalState(() => partySize--)
                              : null,
                        ),
                        Text(
                          '$partySize',
                          style: const TextStyle(fontSize: 18),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: partySize < restaurant.capacityPerSlot
                              ? () => setModalState(() => partySize++)
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ปุ่มยืนยันการจอง
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () async {
                      final userId = FirebaseAuth.instance.currentUser?.uid;
                      if (userId == null) return;

                      String formattedDate =
                          '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

                      final success = await BookingService().createBooking(
                        restaurantId: restaurant.id,
                        userId: userId,
                        date: formattedDate,
                        timeSlot: selectedTime,
                        partySize: partySize,
                      );

                      Navigator.pop(context); // ปิดหน้าต่าง Popup

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('จองสำเร็จ! 🎉'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'จองไม่สำเร็จ (คิวอาจเต็มหรือมีบิลค้าง)',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'ยืนยันการจอง',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? 'No Email';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Booking Flow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box, color: Colors.greenAccent),
            tooltip: 'เพิ่มร้านจำลอง',
            onPressed: () async {
              print('--- กำลังสร้างข้อมูลร้านอาหารจำลอง ---');
              final CollectionReference restaurants = FirebaseFirestore.instance
                  .collection('restaurants');

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
                for (var data in dummyData) {
                  await restaurants.add(data);
                }
                print('✅ เสกข้อมูลร้านจำลองสำเร็จ!');
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

          // --- ช่องค้นหา (Search Bar) ---
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ค้นหาชื่อร้าน, แท็ก, หรือรายละเอียด...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 20,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value
                      .toLowerCase(); // ค้นหาแบบไม่สนตัวพิมพ์เล็กใหญ่
                });
              },
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
              stream: _restaurantStream, // ใช้ตัวแปรที่ดึงจาก initState
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
                List<RestaurantModel> filteredRestaurants = allRestaurants;

                // 1. กรองด้วย Tag
                if (_selectedTag != 'All') {
                  filteredRestaurants = filteredRestaurants
                      .where(
                        (restaurant) => restaurant.tags.contains(_selectedTag),
                      )
                      .toList();
                }

                // 2. กรองด้วย Search Query (หาจาก RAM รวดเดียว)
                if (_searchQuery.isNotEmpty) {
                  filteredRestaurants = filteredRestaurants.where((restaurant) {
                    final nameMatch = restaurant.name.toLowerCase().contains(
                      _searchQuery,
                    );
                    final descMatch = restaurant.description
                        .toLowerCase()
                        .contains(_searchQuery);
                    final tagMatch = restaurant.tags.any(
                      (tag) => tag.toLowerCase().contains(_searchQuery),
                    );

                    return nameMatch || descMatch || tagMatch;
                  }).toList();
                }

                if (filteredRestaurants.isEmpty) {
                  return const Center(
                    child: Text('ไม่พบข้อมูลร้านอาหารที่ค้นหา'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredRestaurants.length,
                  itemBuilder: (context, index) {
                    final restaurant = filteredRestaurants[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
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
                          '${restaurant.description}\nความจุ: ${restaurant.capacityPerSlot} ที่นั่ง/รอบ\nเรตติ้ง: ${restaurant.rating} (${restaurant.reviewCount} รีวิว)',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
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

                            IconButton(
                              icon: const Icon(
                                Icons.star_border,
                                color: Colors.amber,
                              ),
                              onPressed: () {
                                final userId =
                                    FirebaseAuth.instance.currentUser?.uid;
                                if (userId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('กรุณาล็อกอินก่อนให้คะแนน'),
                                    ),
                                  );
                                  return;
                                }

                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(
                                        'ให้คะแนน ${restaurant.name}',
                                      ),
                                      content: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: List.generate(5, (index) {
                                          return IconButton(
                                            icon: const Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              await _restaurantService
                                                  .submitRating(
                                                    restaurantId: restaurant.id,
                                                    userId: userId,
                                                    score: (index + 1)
                                                        .toDouble(),
                                                  );
                                            },
                                          );
                                        }),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),

                            ElevatedButton(
                              onPressed: () {
                                final userId =
                                    FirebaseAuth.instance.currentUser?.uid;
                                if (userId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('กรุณาล็อกอินก่อนจองโต๊ะ'),
                                    ),
                                  );
                                  return;
                                }

                                _showBookingBottomSheet(context, restaurant);
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
