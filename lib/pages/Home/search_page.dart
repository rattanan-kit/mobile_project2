import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/restaurant_model.dart';
import '../restaurant_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // ตัวแปรเก็บข้อความที่ผู้ใช้กำลังพิมพ์
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        // ช่องค้นหาบน AppBar
        title: TextField(
          autofocus: true, // เปิดหน้ามาปุ๊บ คีย์บอร์ดเด้งรอเลย
          decoration: InputDecoration(
            hintText: 'ค้นหาชื่อร้านอาหาร, ประเภท...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey[400]),
          ),
          onChanged: (value) {
            // อัปเดตข้อความทันทีที่พิมพ์
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
        ),
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                // TODO: ต้องใช้ TextEditingController ถ้าอยากให้ลบข้อความในช่องพิมพ์ด้วย
                // ตอนนี้ให้ล้างผลลัพธ์ไปก่อน
                setState(() {
                  _searchQuery = '';
                });
              },
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // ดึงข้อมูลร้านอาหารทั้งหมดมาเตรียมไว้
        stream: FirebaseFirestore.instance
            .collection('restaurants')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("ไม่มีข้อมูลร้านอาหาร"));
          }

          // 🛠️ ระบบกรองข้อมูล (Filter)
          final restaurants = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = (data['name'] ?? '').toString().toLowerCase();
            final desc = (data['description'] ?? '').toString().toLowerCase();
            // เช็กว่าข้อความที่พิมพ์ มีอยู่ในชื่อร้าน หรือ รายละเอียดร้านไหม
            return name.contains(_searchQuery) || desc.contains(_searchQuery);
          }).toList();

          // ถ้าค้นหาแล้วไม่เจออะไรเลย
          if (restaurants.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'ไม่พบร้านอาหารที่ค้นหา',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // ถ้าเจอ แสดงผลเป็นรายการ
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              var doc = restaurants[index];
              var data = doc.data() as Map<String, dynamic>;
              String id = doc.id;
              String name = data['name'] ?? 'ไม่มีชื่อ';
              String desc = data['description'] ?? '';

              String imageUrl = '';
              if (data['imageUrl'] != null) {
                if (data['imageUrl'] is List && data['imageUrl'].isNotEmpty) {
                  imageUrl = data['imageUrl'][0];
                } else if (data['imageUrl'] is String) {
                  imageUrl = data['imageUrl'];
                }
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: InkWell(
                  onTap: () {
                    // แปลงเป็น Model ก่อนส่งไปหน้า Detail
                    final restaurantData = RestaurantModel(
                      id: id,
                      name: name,
                      description: desc,
                      lat: (data['lat'] ?? 13.0).toDouble(),
                      lng: (data['lng'] ?? 99.0).toDouble(),
                      address: data['address'] ?? '',
                      phoneNumber: data['phoneNumber'] ?? '-',
                      images: data['imageUrl'] is List
                          ? List<String>.from(data['imageUrl'])
                          : (imageUrl.isNotEmpty ? [imageUrl] : []),
                      tags: data['tags'] != null
                          ? List<String>.from(data['tags'])
                          : [],
                      rating: (data['rating'] ?? 5.0).toDouble(),
                      reviewCount: data['reviewCount'] ?? 0,
                      capacityPerSlot: data['capacityPerSlot'] ?? 0,
                      socialLinks: data['socialLinks'] ?? {},
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RestaurantDetailPage(restaurant: restaurantData),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: imageUrl.isNotEmpty
                            ? Image.network(imageUrl, fit: BoxFit.cover)
                            : Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.restaurant,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                desc,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
