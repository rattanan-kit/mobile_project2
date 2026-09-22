import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/restaurant_model.dart';
// TODO: เปลี่ยน path ให้ตรงกับที่เก็บไฟล์หน้าจองโต๊ะของคุณ
import '../restaurant_detail_page.dart';

class DealsPage extends StatelessWidget {
  const DealsPage({super.key});

  // --- ข้อมูลโปรโมชั่น (จำลอง) ที่จะเอาไปแปะคู่กับร้านใน Database ---
  final List<Map<String, dynamic>> mockPromotions = const [
    {
      'title': 'เซตสำรับไทยพื้นบ้าน ลด 20%',
      'description':
          'ต้มยำกุ้งแม่น้ำ + แกงรัญจวน + ไข่เจียวปูคอนโด พร้อมข้าวหอมมะลิ 2 จาน',
      'badge': 'ลด 20%',
      'badgeColor': Colors.green,
      'originalPrice': '1,200',
      'promoPrice': '960',
    },
    {
      'title': 'ซื้อ 3 แถม 1 ขนมปังปิ้งสังขยา',
      'description':
          'เมื่อสั่งขนมปังหน้าใดก็ได้ 3 แผ่น รับฟรี! ปังปิ้งสังขยาไข่ 1 แผ่น',
      'badge': '3 แถม 1',
      'badgeColor': Colors.amber,
      'originalPrice': '140',
      'promoPrice': '105',
    },
    {
      'title': 'เซตตำนานประตูผีสุดคุ้ม ลด 25%',
      'description':
          'ผัดไทยมันกุ้งกุ้งสดห่อไข่ 2 จาน + น้ำส้มคั้นสดแท้แก้วใหญ่ 2 แก้ว',
      'badge': 'ลด 25%',
      'badgeColor': Colors.deepOrange,
      'originalPrice': '620',
      'promoPrice': '465',
    },
    {
      'title': '1 แถม 1 สั่งข้าวซอย ฟรีไส้อั่ว',
      'description':
          'สั่งข้าวซอยเนื้อหรือไก่ 1 ชาม รับฟรี! ไส้อั่วเมืองเหนือทรงเครื่อง 1 จาน',
      'badge': '1 แถม 1',
      'badgeColor': Colors.green,
      'originalPrice': '140',
      'promoPrice': '80',
    },
    {
      'title': 'คูปองส่วนลด 100 บาท',
      'description':
          'รับส่วนลดทันทีเมื่อซื้อลอดช่องน้ำกะทิ หรือชุดของฝากครบ 500 บาทขึ้นไป',
      'badge': 'ส่วนลด 100฿',
      'badgeColor': Colors.blue,
      'originalPrice': '500',
      'promoPrice': '400',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'ดีลสุดคุ้มประจำเดือน',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      // --- ใช้ StreamBuilder ดึงร้านอาหารจาก Firestore (ดึงมา 5 ร้าน) ---
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('restaurants')
            .limit(5)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'ยังไม่มีดีลพิเศษในขณะนี้',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              // นำโปรโมชั่นจำลองมาวนลูปใช้กับร้าน
              final promo = mockPromotions[index % mockPromotions.length];

              // แปลงรูปภาพ
              List<String> images = [];
              if (data['imageUrl'] != null) {
                if (data['imageUrl'] is List) {
                  images = List<String>.from(data['imageUrl']);
                } else if (data['imageUrl'] is String) {
                  images = [data['imageUrl']];
                }
              }
              final displayImage = images.isNotEmpty
                  ? images[0]
                  : 'https://via.placeholder.com/400x150?text=No+Image';

              // สร้าง RestaurantModel เพื่อเตรียมส่งไปหน้าจอง
              final restaurantModel = RestaurantModel(
                id: doc.id,
                name: data['name'] ?? 'ไม่มีชื่อร้าน',
                description: data['description'] ?? '',
                images: images,
                tags: data['tags'] != null
                    ? List<String>.from(data['tags'])
                    : [],
                rating: (data['rating'] ?? 5.0).toDouble(),
                reviewCount: data['reviewCount'] ?? 0,
                lat: (data['lat'] ?? 0.0).toDouble(),
                lng: (data['lng'] ?? 0.0).toDouble(),
                capacityPerSlot: data['capacityPerSlot'] ?? 0,
                address: data['address'] ?? '',
                phoneNumber: data['phoneNumber'] ?? '-',
                socialLinks: data['socialLinks'] ?? {},
              );

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- รูปภาพ + Badge โปรโมชั่น ---
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.network(
                            displayImage,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 150,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: promo['badgeColor'],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              promo['badge'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // --- รายละเอียดโปรโมชั่น ---
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurantModel.name, // ดึงชื่อร้านจริงจาก Database
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            promo['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            promo['description'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          const Divider(height: 24),

                          // --- ราคา + ปุ่มจองเลย ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '฿${promo['promoPrice']}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '฿${promo['originalPrice']}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // นำทางไปยังหน้าจองโต๊ะ พร้อมส่งข้อมูลร้านไป
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RestaurantDetailPage(
                                            restaurant: restaurantModel,
                                          ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                ),
                                child: const Text(
                                  'จองเลย', // เปลี่ยนข้อความเป็น จองเลย
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
