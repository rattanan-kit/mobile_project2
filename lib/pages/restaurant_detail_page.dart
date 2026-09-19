import 'package:flutter/material.dart';
import '../models/restaurant_model.dart';

class RestaurantDetailPage extends StatelessWidget {
  final RestaurantModel restaurant;

  const RestaurantDetailPage({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    // แยกรูปหน้าร้าน (index 0) กับ รูปเมนู (index 1 เป็นต้นไป)
    final String storefrontImage = restaurant.images.isNotEmpty
        ? restaurant.images[0]
        : '';
    final List<String> menuImages = restaurant.images.length > 1
        ? restaurant.images.skip(1).toList()
        : [];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // --- 1. รูปหน้าร้านแบบอลังการ (SliverAppBar) ---
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: storefrontImage.isNotEmpty
                  ? Image.network(storefrontImage, fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.restaurant, size: 80),
                    ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  // TODO: โค้ดกดหัวใจ
                },
              ),
            ],
          ),

          // --- 2. เนื้อหาในหน้าร้าน ---
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ชื่อร้านและเรตติ้ง
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              restaurant.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 24,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${restaurant.rating} (${restaurant.reviewCount})',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // หมวดหมู่ (Tags)
                      Wrap(
                        spacing: 8,
                        children: restaurant.tags
                            .map(
                              (tag) => Chip(
                                label: Text(
                                  tag.toUpperCase(),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: Colors.grey[200],
                                padding: EdgeInsets.zero,
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 16),

                      // รายละเอียดร้าน
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
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // --- 3. ส่วนรูปเมนู (Animated Carousel เลื่อนแนวนอน) ---
                if (menuImages.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'เมนูแนะนำ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // เรียกใช้ Widget Carousel แบบย่อขยายที่เราสร้างไว้ด้านล่าง
                  MenuCarousel(images: menuImages),

                  const SizedBox(height: 24),
                ],

                // --- 4. แผนที่และที่อยู่ (Placeholder) ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                      const SizedBox(height: 12),
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map, size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              'พื้นที่สำหรับใส่ Google Maps API',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              restaurant.address,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            color: Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            restaurant.phoneNumber,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40), // เผื่อที่เว้นว่างด้านล่างสุด
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // --- 5. ปุ่มจองโต๊ะ (Sticky Bottom Bar) ---
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              // TODO: ย้ายฟังก์ชันเปิดหน้าต่างจองโต๊ะมาใส่ตรงนี้
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
    );
  }
}

// =========================================================================
// Widget สำหรับทำระบบเลื่อนการ์ดเมนูแบบมีแอนิเมชันย่อขยาย (Animated Carousel)
// =========================================================================
class MenuCarousel extends StatefulWidget {
  final List<String> images;
  const MenuCarousel({super.key, required this.images});

  @override
  State<MenuCarousel> createState() => _MenuCarouselState();
}

class _MenuCarouselState extends State<MenuCarousel> {
  // viewportFraction: 0.85 คือการ์ดตรงกลางจะกว้าง 85% ของจอ ทำให้เห็นการ์ดข้างๆ โผล่มานิดนึง
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
      height: 220, // ความสูงของการ์ดเมนู
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
                // คำนวณความเบลอ/หดตัว (ตรงกลางขนาด 1.0, ด้านข้างขนาด 0.85)
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
