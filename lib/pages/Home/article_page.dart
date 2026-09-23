import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/restaurant_model.dart';
import '../Detail/restaurant_detail_page.dart';

class ArticlePage extends StatefulWidget {
  const ArticlePage({super.key});

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  String _selectedCategory = 'ทั้งหมด';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'บทความรีวิว',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('restaurants')
            .limit(10)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("เกิดข้อผิดพลาดในการโหลดข้อมูล"));
          }

          final docs = snapshot.data?.docs ?? [];

          final List<RestaurantModel> restaurants = docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            List<String> images = [];
            if (data['imageUrl'] != null) {
              if (data['imageUrl'] is List) {
                images = List<String>.from(data['imageUrl']);
              } else if (data['imageUrl'] is String) {
                images = [data['imageUrl']];
              }
            }

            return RestaurantModel(
              id: doc.id,
              name: data['name'] ?? 'ไม่มีชื่อร้าน',
              description: data['description'] ?? '',
              images: images,
              tags: data['tags'] != null
                  ? List<String>.from(data['tags'])
                  : ['แนะนำ'],
              rating: (data['rating'] ?? 4.5).toDouble(),
              reviewCount: data['reviewCount'] ?? 0,
              lat: (data['lat'] ?? 13.0).toDouble(),
              lng: (data['lng'] ?? 99.0).toDouble(),
              capacityPerSlot: data['capacityPerSlot'] ?? 0,
              address: data['address'] ?? 'ไม่ระบุที่อยู่',
              phoneNumber: data['phoneNumber'] ?? '-',
              socialLinks: data['socialLinks'] ?? {},
            );
          }).toList();

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 220,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?q=80&w=1000&auto=format&fit=crop',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'ร้านอาหารจานเด็ดในกรุงเทพ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'รวม 10 พิกัดร้านยอดนิยมที่คุณต้องลอง',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'เราตอบโจทย์ความหิวของคุณได้ทุกรูปแบบ คั่นหน้านี้ไว้เป็นคู่มือสำรวจร้านอาหาร แล้วค้นพบร้านโปรดแห่งใหม่ของคุณได้ในไม่กี่คลิก!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: 100,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children:
                        [
                          'ทั้งหมด',
                          'เทรนด์มาแรง',
                          'กำลังเป็นที่นิยม',
                          'บรรณาธิการแนะนำ',
                        ].map((category) {
                          final isSelected = _selectedCategory == category;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _selectedCategory = category);
                                }
                              },
                              selectedColor: const Color(0xFFFFC107),
                              backgroundColor: Colors.grey[100],
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.black
                                    : Colors.grey[700],
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                if (_selectedCategory == 'ทั้งหมด' ||
                    _selectedCategory == 'เทรนด์มาแรง') ...[
                  _buildSectionHeader('เทรนด์มาแรง'),
                  if (restaurants.isNotEmpty)
                    _buildHeroArticleCard(context, restaurants.first),
                  const SizedBox(height: 28),
                ],

                if (_selectedCategory == 'ทั้งหมด' ||
                    _selectedCategory == 'กำลังเป็นที่นิยม') ...[
                  _buildSectionHeader('กำลังเป็นที่นิยม'),
                  _buildPromoCard(),
                  const SizedBox(height: 16),
                  if (restaurants.length > 1)
                    _buildStandardArticleCard(context, restaurants[1]),
                  const SizedBox(height: 28),
                ],

                if (_selectedCategory == 'ทั้งหมด' ||
                    _selectedCategory == 'บรรณาธิการแนะนำ') ...[
                  _buildSectionHeader('บรรณาธิการแนะนำ'),
                  if (restaurants.length > 2)
                    _buildStandardArticleCard(context, restaurants[2]),
                  const SizedBox(height: 28),
                ],

                _buildSectionHeader('10 อันดับร้านอาหารแนะนำห้ามพลาด'),
                if (restaurants.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('ยังไม่มีข้อมูลร้านอาหาร')),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    itemCount: restaurants.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = restaurants[index];
                      return _buildCompactRestaurantRow(
                        context,
                        item,
                        index + 1,
                      );
                    },
                  ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      children: [
        Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Container(
            width: 50,
            height: 3,
            color: const Color(0xFFFFC107),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHeroArticleCard(BuildContext context, RestaurantModel item) {
    String image = item.images.isNotEmpty ? item.images[0] : '';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RestaurantDetailPage(restaurant: item),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: image.isNotEmpty
                    ? Image.network(image, fit: BoxFit.cover)
                    : Container(color: Colors.grey[200]),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              maxLines: 1, // 🛠️ ดักชื่อร้านยาวทะลุจอ
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              item.description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardArticleCard(BuildContext context, RestaurantModel item) {
    String image = item.images.isNotEmpty ? item.images[0] : '';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RestaurantDetailPage(restaurant: item),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: image.isNotEmpty
                    ? Image.network(image, fit: BoxFit.cover)
                    : Container(color: Colors.grey[200]),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1, // 🛠️ ดักชื่อร้านยาวทะลุจอ
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              item.description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                'https://raw.githubusercontent.com/aphipatb/photo/main/LeDu.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'ฤดู (LE DU)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'ลิ้มรสอาหารไทย Fine Dining ระดับมิชลินสตาร์ รังสรรค์ด้วยวัตถุดิบท้องถิ่นตามฤดูกาล ยกระดับรสชาติไทยดั้งเดิมด้วยเทคนิคโมเดิร์นสุดประณีต โดยเชฟต้น',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.4,
            ),
            maxLines: 3, // 🛠️ ดักคำอธิบายยาวทะลุจอ
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactRestaurantRow(
    BuildContext context,
    RestaurantModel item,
    int index,
  ) {
    String image = item.images.isNotEmpty ? item.images[0] : '';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RestaurantDetailPage(restaurant: item),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: image.isNotEmpty
                      ? Image.network(image, fit: BoxFit.cover)
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.restaurant,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "#$index ",
                          style: const TextStyle(
                            color: Color(0xFFFF9800),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          '${item.rating}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${item.reviewCount} รีวิว)',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
