import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_project2/pages/Home/deal_page.dart';
import '../../models/restaurant_model.dart';
import '../Detail/restaurant_detail_page.dart';
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
            // ==========================================
            // 1. ส่วน Header (สีส้ม) และแถบค้นหา
            // ==========================================
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
                          IconButton(
                            icon: const Icon(
                              Icons.favorite_border,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FavoritesPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
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

            // ==========================================
            // 2. ส่วนเมนู 4 ช่อง
            // ==========================================
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
                          Icons.casino,
                          'สุ่มร้านอาหารเลย',
                          'วันนี้ไม่รู้จะกินอะไรดี?',
                          Colors.green,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const RandomRestaurantPage(),
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
                          Icons.local_offer,
                          'ดีลสุดคุ้ม',
                          'โปรโมชั่นพิเศษ',
                          Colors.purple,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DealsPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ==========================================
            // 3. หมวดหมู่ร้านอาหาร (แก้ไขให้กดไปหน้า Search ได้)
            // ==========================================
            SizedBox(
              height: 110,
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
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTfMxynDcDM3qZjgxINHwOOstD3c2qetBusmdteybs6pA&s=10',
                  ),
                  const SizedBox(width: 16),
                  _buildCategoryItem(
                    context,
                    'พิซซ่า',
                    'https://images.unsplash.com/photo-1551183053-bf91a1d81141?q=80&w=200&auto=format&fit=crop',
                  ),
                  const SizedBox(width: 16),
                  _buildCategoryItem(
                    context,
                    'เบอร์เกอร์',
                    'https://cdn.apartmenttherapy.info/image/upload/f_jpg,q_auto:eco,c_fill,g_auto,w_1500,ar_4:3/tk%2Fphoto%2F2025%2F06-2025%2F2025-06-burger-doneness-guide%2Fburger-doneness-guide-0195',
                  ),
                  const SizedBox(width: 16),
                  _buildCategoryItem(
                    context,
                    'สเต๊ก',
                    'https://theblackfarmer.com/cdn/shop/files/cookedBeefTomahawkSteak_31.7oz_900g_2048x.jpg?v=1773327176',
                  ),
                  const SizedBox(width: 16),
                  _buildCategoryItem(
                    context,
                    'คาเฟ่',
                    'https://raw.githubusercontent.com/aphipatb/photo/main/1.jpg',
                  ),
                  const SizedBox(width: 16),
                  _buildCategoryItem(
                    context,
                    'เครื่องดื่ม',
                    'https://raw.githubusercontent.com/aphipatb/photo/main/2.jpg',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ==========================================
            // 4. ร้านแนะนำห้ามพลาด (ดึงจาก Firebase เรียงตามคะแนน)
            // ==========================================
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
              child: StreamBuilder<QuerySnapshot>(
                // ดึง 5 ร้านที่คะแนนสูงสุดมาโชว์
                stream: FirebaseFirestore.instance
                    .collection('restaurants')
                    .orderBy('rating', descending: true)
                    .limit(5)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("ไม่มีข้อมูลร้านแนะนำ"));
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(right: 20),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      var data = doc.data() as Map<String, dynamic>;
                      return _buildRecommendedCard(context, doc.id, data);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            // ==========================================
            // 5. ร้านยอดนิยม (UI ดีไซน์ใหม่)
            // ==========================================
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
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("ยังไม่มีร้านอาหารในระบบ"));
                }

                final restaurants = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: restaurants.length,
                  itemBuilder: (context, index) {
                    var doc = restaurants[index];
                    var data = doc.data() as Map<String, dynamic>;
                    return _buildModernRestaurantCard(context, doc.id, data);
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
      onTap: () {
        // เมื่อกดหมวดหมู่ ให้ส่งคำค้นหาไปหน้า SearchPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchPage(initialQuery: title),
          ),
        );
      },
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

  // 🛠️ อัปเดต: การ์ดแนะนำดึงข้อมูลจาก DB แล้วประกอบร่างเป็น Model เพื่อให้กดดู Detail ได้
  Widget _buildRecommendedCard(
    BuildContext context,
    String id,
    Map<String, dynamic> data,
  ) {
    String name = data['name'] ?? 'ไม่มีชื่อ';
    String desc = data['description'] ?? '';

    List<String> images = [];
    if (data['imageUrl'] != null) {
      if (data['imageUrl'] is List)
        images = List<String>.from(data['imageUrl']);
      else if (data['imageUrl'] is String)
        images = [data['imageUrl']];
    }
    String coverImg = images.isNotEmpty ? images[0] : '';

    return GestureDetector(
      onTap: () {
        final restaurantData = RestaurantModel(
          id: id,
          name: name,
          description: desc,
          lat: (data['lat'] ?? 13.0).toDouble(),
          lng: (data['lng'] ?? 99.0).toDouble(),
          address: data['address'] ?? '',
          phoneNumber: data['phoneNumber'] ?? '-',
          images: images,
          tags: data['tags'] != null ? List<String>.from(data['tags']) : [],
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
      child: Container(
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD84315),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      desc,
                      style: const TextStyle(fontSize: 11, height: 1.5),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          '${data['rating'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: SizedBox(
                height: 210,
                child: coverImg.isNotEmpty
                    ? Image.network(coverImg, fit: BoxFit.cover)
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.restaurant),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🛠️ อัปเดต: การ์ดร้านยอดนิยม ดีไซน์ใหม่ ใหญ่และสวยขึ้น
  Widget _buildModernRestaurantCard(
    BuildContext context,
    String id,
    Map<String, dynamic> data,
  ) {
    String name = data['name'] ?? 'ไม่มีชื่อร้าน';
    String description = data['description'] ?? '';

    List<String> allImages = [];
    if (data['imageUrl'] != null) {
      if (data['imageUrl'] is List)
        allImages = List<String>.from(data['imageUrl']);
      else if (data['imageUrl'] is String)
        allImages = [data['imageUrl']];
    }
    String coverImage = allImages.isNotEmpty ? allImages[0] : '';

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
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
              lat: (data['lat'] ?? 13.0).toDouble(),
              lng: (data['lng'] ?? 99.0).toDouble(),
              address: data['address'] ?? '',
              phoneNumber: data['phoneNumber'] ?? '-',
              images: allImages,
              tags: data['tags'] != null ? List<String>.from(data['tags']) : [],
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // รูปภาพด้านบนเต็มความกว้าง
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: coverImage.isNotEmpty
                          ? Image.network(coverImage, fit: BoxFit.cover)
                          : Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.restaurant,
                                color: Colors.grey,
                                size: 50,
                              ),
                            ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${data['rating'] ?? 'N/A'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ข้อมูลด้านล่าง
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'จองโต๊ะ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 2,
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
}
