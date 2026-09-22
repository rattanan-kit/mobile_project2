import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/restaurant_model.dart';
import '../restaurant_detail_page.dart';
import 'dummy_pages.dart'; 
import 'search_page.dart'; 
import '../favorites_page.dart';
import 'random_restaurant_page.dart';
import 'article_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. ส่วน Header (สีส้ม) และแถบค้นหา ---
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 16, left: 20, right: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'กรุงเทพ, ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.favorite_border,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const FavoritesPage(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // จุดแก้ 2: ป้องกันชื่อ User ยาวทะลุจอ
                      const Text(
                        'สวัสดี คุณ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'เลือกร้านที่ใช่ จองโต๊ะที่ชอบ',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: -24,
                  left: 20,
                  right: 20,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchPage(),
                        ),
                      );
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          const Icon(Icons.search, color: Colors.grey),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'ค้นหาร้านอาหารโปรดร้านถัดไปของคุณ',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 48),

            // --- 2. ส่วนเมนู 4 ช่อง ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildMenuItem(
                          context,
                          Icons.restaurant,
                          'จองโต๊ะ',
                          'ค้นหาร้านอาหาร',
                          Colors.blue,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SearchPage(),
                              ),
                            );
                          },
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.grey.shade200,
                        ),
                        _buildMenuItem(
                          context,
                          Icons.new_releases,
                          'สุ่มร้านอาหารเลย',
                          'วันนี้ไม่รู้จะกินอะไรดี?',
                          Colors.green,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RandomRestaurantPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1),
                    ),
                    Row(
                      children: [
                        _buildMenuItem(
                          context,
                          Icons.menu_book,
                          'แนะนำ',
                          'บทความรีวิว',
                          Colors.orange,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ArticlePage(),
                              ),
                            );
                          },
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.grey.shade200,
                        ),
                        _buildMenuItem(
                          context,
                          Icons.map,
                          'ใกล้ฉัน',
                          'ดูบนแผนที่',
                          Colors.purple,
                          () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- 3. หมวดหมู่ร้านอาหาร ---
            SizedBox(
              height:
                  110, // จุดแก้ 4: ปรับความสูงจาก 90 เป็น 110 ป้องกันขอบล่างทะลุ 1 pixel
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildCategoryItem(
                    context,
                    'ญี่ปุ่น',
                    'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?q=80&w=200&auto=format&fit=crop',
                  ),
                  const SizedBox(width: 16),
                  _buildCategoryItem(
                    context,
                    'ไทย',
                    'https://images.unsplash.com/photo-1559314809-0d155014e29e?q=80&w=200&auto=format&fit=crop',
                  ),
                  const SizedBox(width: 16),
                  _buildCategoryItem(
                    context,
                    'นานาชาติ',
                    'https://images.unsplash.com/photo-1544025162-835002bdf603?q=80&w=200&auto=format&fit=crop',
                  ),
                  const SizedBox(width: 16),
                  _buildCategoryItem(
                    context,
                    'อิตาเลียน',
                    'https://images.unsplash.com/photo-1551183053-bf91a1d81141?q=80&w=200&auto=format&fit=crop',
                  ),
                  const SizedBox(width: 16),
                  _buildCategoryItem(
                    context,
                    'ฟิวชั่น',
                    'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=200&auto=format&fit=crop',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- 4. ร้านแนะนำห้ามพลาด ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "ร้านแนะนำห้ามพลาด",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 210,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 20),
                children: [
                  _buildRecommendedCard(
                    context,
                    title: 'SOI',
                    desc:
                        'สัมผัสรสชาติอาหารไทยแท้ ในบรรยากาศร้านสไตล์โมเดิร์น พร้อมเมนูเด็ดอย่างแกงพะแนง และสตรีทฟู้ดพรีเมียม',
                    time: '06:30 - 23:00',
                    imageUrl:
                        'https://images.unsplash.com/photo-1559314809-0d155014e29e?q=80&w=400&auto=format&fit=crop',
                  ),
                  _buildRecommendedCard(
                    context,
                    title: 'SUSHI',
                    desc:
                        'โอมากาเสะพรีเมียม วัตถุดิบส่งตรงจากตลาดปลาโทโยสุ โตเกียว สดใหม่ทุกวันเหมือนบินไปกินที่ญี่ปุ่น',
                    time: '11:00 - 22:00',
                    imageUrl:
                        'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?q=80&w=400&auto=format&fit=crop',
                  ),
                  _buildRecommendedCard(
                    context,
                    title: 'STEAK',
                    desc:
                        'สเต็กเนื้อดรายเอจ 45 วัน ย่างบนเตาถ่านไม้หอมกรุ่น ละลายในปาก พร้อมไวน์ชั้นเลิศ',
                    time: '17:00 - 24:00',
                    imageUrl:
                        'https://images.unsplash.com/photo-1544025162-835002bdf603?q=80&w=400&auto=format&fit=crop',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- 5. ร้านยอดนิยม (ดึงจาก Firestore) ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "ร้านยอดนิยม",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('restaurants')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text("เกิดข้อผิดพลาดในการโหลดข้อมูล"),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("ยังไม่มีร้านอาหารในระบบ"));
                }

                final restaurants = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: restaurants.length,
                  itemBuilder: (context, index) {
                    var data =
                        restaurants[index].data() as Map<String, dynamic>;
                    String id = restaurants[index].id;
                    String name = data['name'] ?? 'ไม่มีชื่อร้าน';
                    String description = data['description'] ?? '';
                    String imageUrl = '';

                    if (data['imageUrl'] != null) {
                      if (data['imageUrl'] is List &&
                          data['imageUrl'].isNotEmpty) {
                        imageUrl = data['imageUrl'][0];
                      } else if (data['imageUrl'] is String) {
                        imageUrl = data['imageUrl'];
                      }
                    }

                    return _buildRestaurantCard(
                      context,
                      id,
                      name,
                      description,
                      imageUrl,
                      data,
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // Helper Widgets
  // ==========================================

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: Material(
        // จุดแก้ 5: ครอบ InkWell ด้วย Material สีโปร่งใส เพื่อแก้ UI พังจอแดง
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 16),
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String title,
    String imageUrl,
  ) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedCard(
    BuildContext context, {
    required String title,
    required String desc,
    required String time,
    required String imageUrl,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      margin: const EdgeInsets.only(left: 20),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD84315),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    desc,
                    style: const TextStyle(fontSize: 11, height: 1.5),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(80, 30),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: SizedBox(
              height: 210,
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildRestaurantCard(
    BuildContext context,
    String id,
    String name,
    String description,
    String imageUrl, // ตัวแปรนี้คือรูปหน้าปก (ถ้ามี)
    Map<String, dynamic> data,
  ) {
    // 🛠️ 1. เพิ่มโค้ดดึงรูปภาพทั้งหมดออกมาเป็น List
    List<String> allImages = [];
    if (data['imageUrl'] != null) {
      if (data['imageUrl'] is List) {
        allImages = List<String>.from(data['imageUrl']); // ดึงมาให้หมดทุก Index
      } else if (data['imageUrl'] is String) {
        allImages = [data['imageUrl']];
      }
    }

    // เผื่อรูปหน้าปกไว้โชว์ในการ์ด
    String coverImage = allImages.isNotEmpty ? allImages[0] : '';

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            final restaurantData = RestaurantModel(
              id: id,
              name: name,
              description: description,
              lat: (data['lat'] ?? 13.0234).toDouble(),
              lng: (data['lng'] ?? 99.9912).toDouble(),
              address: data['address'] ?? 'ไม่ระบุที่อยู่',
              phoneNumber: data['phoneNumber'] ?? '-',
              // 🛠️ 2. เปลี่ยนให้ส่ง List รูปภาพทั้งหมดเข้าไปแทน
              images: allImages,
              tags: data['tags'] != null
                  ? List<String>.from(data['tags'])
                  : ['แนะนำ'],
              rating: (data['rating'] ?? 4.5).toDouble(),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child:
                    coverImage
                        .isNotEmpty // 🛠️ 3. ใช้ coverImage ตรงนี้แทน
                    ? Image.network(
                        coverImage,
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 110,
                          height: 110,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Container(
                        width: 110,
                        height: 110,
                        color: Colors.grey[200],
                        child: const Icon(Icons.restaurant, color: Colors.grey),
                      ),
              ),
              // ... โค้ดส่วน Expanded ข้อมูลร้านด้านล่างปล่อยไว้เหมือนเดิมเป๊ะๆ ครับ
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.star, color: Colors.orange, size: 16),
                              SizedBox(width: 4),
                              Text(
                                '4.8',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'จองโต๊ะ',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
