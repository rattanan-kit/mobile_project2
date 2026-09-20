import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/restaurant_model.dart';

class RestaurantDetailPage extends StatelessWidget {
  final RestaurantModel restaurant;

  const RestaurantDetailPage({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final String storefrontImage = restaurant.images.isNotEmpty
        ? restaurant.images[0]
        : '';
    final List<String> menuImages = restaurant.images.length > 1
        ? restaurant.images.skip(1).toList()
        : [];

    return Scaffold(
      backgroundColor:
          Colors.grey[100], // 1. ปรับพื้นหลังฉากหลังเป็นเทาอ่อนลดความขาวโพลน
      body: CustomScrollView(
        slivers: [
          // --- 1. รูปหน้าร้านแบบอลังการ ---
          SliverAppBar(
            expandedHeight: 280.0, // เพิ่มความสูงปกนิดหน่อย
            pinned: true,
            backgroundColor: const Color.fromARGB(255, 243, 93, 33),
            iconTheme: const IconThemeData(
              color: Colors.white,
            ), // ให้ปุ่ม back เป็นสีขาว
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  storefrontImage.isNotEmpty
                      ? Image.network(storefrontImage, fit: BoxFit.cover)
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.restaurant, size: 80),
                        ),
                  // ใส่ Gradient สีดำบางๆ ด้านล่างรูปร้าน เพื่อให้ไอคอนดูชัดขึ้น
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black38,
                          Colors.transparent,
                          Colors.black45,
                        ],
                        stops: [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // ปรับปุ่ม Favorite ให้อยู่ในวงกลมโปร่งแสง จะได้ดูพรีเมียม
              Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.white),
                  onPressed: () {},
                ),
              ),
            ],
          ),

          // --- 2. เนื้อหาในหน้าร้าน ---
          SliverToBoxAdapter(
            child: Container(
              // 2. ทำขอบเนื้อหาโค้งมน ซ้อนทับรูปด้านบนนิดๆ
              transform: Matrix4.translationValues(0.0, -20.0, 0.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                restaurant.name,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${restaurant.rating}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    ' (${restaurant.reviewCount})',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Wrap(
                          spacing: 8,
                          children: restaurant.tags
                              .map(
                                (tag) => Chip(
                                  label: Text(
                                    tag.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  backgroundColor: Colors.blue[50],
                                  side:
                                      BorderSide.none, // เอาเส้นขอบออกให้ดูคลีน
                                  padding: EdgeInsets.zero,
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 24),

                        // --- เพิ่มไอคอนสิ่งอำนวยความสะดวก (Facilities) เพื่อลดความโล่ง ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildFacilityIcon(
                              Icons.directions_car,
                              'ที่จอดรถ',
                            ),
                            _buildFacilityIcon(Icons.wifi, 'ฟรี Wi-Fi'),
                            _buildFacilityIcon(
                              Icons.credit_card,
                              'รับบัตรเครดิต',
                            ),
                            _buildFacilityIcon(Icons.ac_unit, 'ห้องแอร์'),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Divider(),
                        ),

                        const Text(
                          'เกี่ยวกับร้าน',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          restaurant.description,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // --- 3. ส่วนรูปเมนู (Animated Carousel) ---
                  if (menuImages.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'เมนูแนะนำ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    MenuCarousel(images: menuImages),
                    const SizedBox(height: 30),
                  ],

                  // --- 4. แผนที่และที่อยู่ (OpenStreetMap) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'สถานที่ตั้ง',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            height: 200,
                            width: double.infinity,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: FlutterMap(
                                options: MapOptions(
                                  initialCenter: LatLng(
                                    restaurant.lat,
                                    restaurant.lng,
                                  ),
                                  initialZoom: 15.0,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.example.app',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: LatLng(
                                          restaurant.lat,
                                          restaurant.lng,
                                        ),
                                        width: 80,
                                        height: 80,
                                        child: const Icon(
                                          Icons.location_on,
                                          color: Colors.red,
                                          size: 45,
                                        ), // หมุดใหญ่ขึ้นนิดนึง
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                restaurant.address,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.phone,
                              color: Colors.green,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              restaurant.phoneNumber,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Divider(),
                        ),
                      ],
                    ),
                  ),

                  // --- 5. ส่วนรีวิวและคอมเมนต์ (ที่อยากทำตอนแรก) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'รีวิวจากลูกค้า',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text('ดูทั้งหมด'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // ตัวอย่างคอมเมนต์จำลอง (Dummy Comment)
                        _buildCommentItem(
                          name: 'คุณ สมชาย ใจดี',
                          time: '2 วันที่แล้ว',
                          rating: 5,
                          comment:
                              'บรรยากาศดีมากครับ อาหารอร่อย พนักงานบริการดีเยี่ยม แนะนำเลยครับ!',
                          avatarColor: Colors.blue[200]!,
                        ),
                        const SizedBox(height: 16),
                        _buildCommentItem(
                          name: 'แพรวา รักกิน',
                          time: '1 สัปดาห์ที่แล้ว',
                          rating: 4,
                          comment:
                              'สเต็กเนื้อนุ่มมาก แต่แอบหาที่จอดรถยากนิดนึงช่วงเย็น โดยรวมประทับใจค่ะ',
                          avatarColor: Colors.pink[200]!,
                        ),
                        const SizedBox(
                          height: 40,
                        ), // ระยะห่างก่อนถึงปุ่มจองด้านล่าง
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // --- ปุ่มจองโต๊ะปรับดีไซน์นิดหน่อยให้ดูเด่นขึ้น ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 12.0,
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('กำลังเปิดหน้าต่างจองโต๊ะ...')),
                );
              },
              child: const Text(
                'จองโต๊ะเลย',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget ช่วยสร้างไอคอนสิ่งอำนวยความสะดวก
  Widget _buildFacilityIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blue[700], size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }

  // Widget ช่วยสร้างรายการคอมเมนต์
  Widget _buildCommentItem({
    required String name,
    required String time,
    required int rating,
    required String comment,
    required Color avatarColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50], // พื้นหลังกล่องคอมเมนต์สีเทาอ่อนๆ
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: avatarColor,
                radius: 20,
                child: Text(
                  name[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget MenuCarousel คงเดิมเป๊ะๆ ครับ
class MenuCarousel extends StatefulWidget {
  final List<String> images;
  const MenuCarousel({super.key, required this.images});

  @override
  State<MenuCarousel> createState() => _MenuCarouselState();
}

class _MenuCarouselState extends State<MenuCarousel> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 1.0;
              if (_pageController.position.haveDimensions) {
                value = _pageController.page! - index;
                value = (1 - (value.abs() * 0.15)).clamp(0.85, 1.0);
              } else {
                value = index == 0 ? 1.0 : 0.85;
              }
              return Transform.scale(scale: value, child: child);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                image: DecorationImage(
                  image: NetworkImage(widget.images[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
