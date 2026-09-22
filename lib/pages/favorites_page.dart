import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/restaurant_model.dart';
import '../services/user_service.dart';
import 'restaurant_detail_page.dart'; // อย่าลืม import หน้า Detail เพื่อให้กดเข้าไปดูได้

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('ร้านโปรด')),
        body: const Center(child: Text('กรุณาล็อกอินเพื่อดูร้านโปรด')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50], // ปรับพื้นหลังให้ซอฟต์ลง
      appBar: AppBar(
        title: const Text(
          'ร้านโปรดของฉัน 💖',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<dynamic> favorites = [];
          if (userSnapshot.hasData && userSnapshot.data!.exists) {
            try {
              favorites = userSnapshot.data!.get('favorites') ?? [];
            } catch (e) {
              favorites = [];
            }
          }

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'คุณยังไม่มีร้านโปรดเลย\nลองไปกดหัวใจดูสิ!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('restaurants')
                .where(FieldPath.documentId, whereIn: favorites)
                .snapshots(),
            builder: (context, restSnapshot) {
              if (restSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final restaurants = restSnapshot.data?.docs ?? [];

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: restaurants.length,
                itemBuilder: (context, index) {
                  final doc = restaurants[index];
                  final restaurant = RestaurantModel.fromJson(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  );

                  // --- ดีไซน์การ์ดร้านโปรดโฉมใหม่ ---
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    child: InkWell(
                      onTap: () {
                        // กดแล้วพาไปหน้ารายละเอียด
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RestaurantDetailPage(restaurant: restaurant),
                          ),
                        );
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. รูปภาพฝั่งซ้าย
                          SizedBox(
                            width: 120,
                            height: 135,
                            child: restaurant.images.isNotEmpty
                                ? Image.network(
                                    restaurant.images[0],
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.restaurant,
                                      color: Colors.grey,
                                      size: 40,
                                    ),
                                  ),
                          ),
                          // 2. ข้อมูลร้านฝั่งขวา
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          restaurant.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // ปุ่มเอาออกจากร้านโปรด
                                      GestureDetector(
                                        onTap: () {
                                          UserService().toggleFavorite(
                                            restaurant.id,
                                          );
                                        },
                                        child: const Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                          size: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  // เรตติ้งดาว
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${restaurant.rating}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        ' (${restaurant.reviewCount})',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  // คำอธิบายสั้นๆ
                                  Text(
                                    restaurant.description,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  // Tags หมวดหมู่ (โชว์เต็มที่ 2 อัน ป้องกันล้น)
                                  if (restaurant.tags.isNotEmpty)
                                    Wrap(
                                      spacing: 6,
                                      children: restaurant.tags
                                          .take(2)
                                          .map(
                                            (tag) => Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Theme.of(
                                                  context,
                                                ).primaryColor.withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                tag,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Theme.of(
                                                    context,
                                                  ).primaryColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
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
          );
        },
      ),
    );
  }
}
