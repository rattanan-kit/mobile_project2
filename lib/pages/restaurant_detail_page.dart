import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- นำเข้า Firestore
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
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          // --- 1. รูปหน้าร้านแบบอลังการ ---
          SliverAppBar(
            expandedHeight: 280.0,
            pinned: true,
            backgroundColor: Colors.blue,
            iconTheme: const IconThemeData(color: Colors.white),
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
                                  side: BorderSide.none,
                                  padding: EdgeInsets.zero,
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 24),

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
                                        ),
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

                        _buildCommentItem(
                          name: 'คุณ สมชาย ใจดี',
                          time: '2 วันที่แล้ว',
                          rating: 5,
                          comment:
                              'บรรยากาศดีมาก อาหารอร่อย พนักงานบริการดีเยี่ยม แนะนำเลย!',
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
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

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
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  // --- ส่งข้อมูลร้านเข้าไปใน Bottom Sheet ด้วย ---
                  builder: (context) =>
                      BookingBottomSheetWidget(restaurant: restaurant),
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
        color: Colors.grey[50],
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

// =========================================================================
// Widget สำหรับฟอร์มจองโต๊ะแบบ Bottom Sheet (อ่านจาก Database + บันทึก)
// =========================================================================
class BookingBottomSheetWidget extends StatefulWidget {
  final RestaurantModel restaurant; // รับข้อมูลร้านเข้ามาเพื่อใช้อ้างอิง ID

  const BookingBottomSheetWidget({super.key, required this.restaurant});

  @override
  State<BookingBottomSheetWidget> createState() =>
      _BookingBottomSheetWidgetState();
}

class _BookingBottomSheetWidgetState extends State<BookingBottomSheetWidget> {
  int _guestCount = 2;
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  bool _isLoading = false; // เอาไว้หมุนโหลดตอนกำลังบันทึก

  // สมมติว่าร้านนี้รับคิวได้รอบละ 20 คน (ในอนาคตควรดึงค่านี้มาจาก Database ของร้าน)
  final int capacityPerSlot = 20;

  List<String> _getAvailableTimeSlots() {
    List<String> allSlots = [
      '08:00',
      '09:00',
      '10:00',
      '11:00',
      '12:00',
      '13:00',
      '14:00',
      '15:00',
      '16:00',
      '17:00',
      '18:00',
      '19:00',
      '20:00',
    ];

    DateTime now = DateTime.now();
    bool isToday =
        _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;

    if (isToday) {
      return allSlots.where((time) {
        int hour = int.parse(time.split(':')[0]);
        return hour > now.hour;
      }).toList();
    }
    return allSlots;
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTime = null;
      });
    }
  }

  // ฟังก์ชันบันทึกข้อมูลลง Firebase
  Future<void> _submitBooking() async {
    setState(() => _isLoading = true);

    try {
      // แปลงวันที่ให้อยู่ใน Format ปี-เดือน-วัน (เช่น 2026-09-21) เพื่อเซฟลงฐานข้อมูล
      String dbDate =
          "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

      // บันทึกลง Collection "bookings"
      await FirebaseFirestore.instance.collection('bookings').add({
        'restaurantId': widget.restaurant.id,
        'restaurantName': widget.restaurant.name,
        'date': dbDate,
        'time': _selectedTime,
        'guestCount': _guestCount,
        'status': 'confirmed',
        'userId': 'demo_user_001', // ตอนนี้จำลองรหัสผู้ใช้ไปก่อน
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context); // ปิดหน้าต่าง
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('จองโต๊ะสำเร็จแล้ว!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String displayDate =
        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year + 543}';
    final availableTimeSlots = _getAvailableTimeSlots();

    // สร้าง Format วันที่สำหรับใช้ค้นหาใน Database
    final String dbSearchDate =
        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'รายละเอียดการจอง',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // --- 1. เลือกจำนวนคน ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.people,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'จำนวนคน',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        // ถ้าลดคน แล้วที่นั่งเวิร์คกับรอบที่เลือกไว้ ค่อยยอมให้ลด
                        if (_guestCount > 1) setState(() => _guestCount--);
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                      color: _guestCount > 1 ? Colors.blue : Colors.grey,
                    ),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '$_guestCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _guestCount++),
                      icon: const Icon(Icons.add_circle_outline),
                      color: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(),
            ),

            // --- 2. เลือกวันที่ ---
            const Text(
              'วันที่ต้องการจอง',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _pickDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          color: Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          displayDate,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'เปลี่ยน',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- 3. เลือกรอบเวลา (StreamBuilder ดึงข้อมูลสดมาเช็ก Capacity) ---
            const Text(
              'เลือกรอบเวลา',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            availableTimeSlots.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ไม่มีรอบเวลาว่างสำหรับวันนี้แล้ว',
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  )
                : StreamBuilder<QuerySnapshot>(
                    // ยิง Query เช็กยอดการจองของร้านนี้ ในวันที่เลือกว่ามีกี่คนแล้ว
                    stream: FirebaseFirestore.instance
                        .collection('bookings')
                        .where('restaurantId', isEqualTo: widget.restaurant.id)
                        .where('date', isEqualTo: dbSearchDate)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // คำนวณหายอดจองในแต่ละช่วงเวลา
                      Map<String, int> bookedSeatsPerSlot = {};
                      for (var doc in snapshot.data!.docs) {
                        String time = doc['time'];
                        int guests = doc['guestCount'] ?? 0;
                        bookedSeatsPerSlot[time] =
                            (bookedSeatsPerSlot[time] ?? 0) + guests;
                      }

                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: availableTimeSlots.map((time) {
                          // คำนวณที่นั่งว่าง
                          int booked = bookedSeatsPerSlot[time] ?? 0;
                          int remainingSeats = capacityPerSlot - booked;

                          // ถ้ายอดที่ผู้ใช้ต้องการจอง มันเยอะกว่าที่นั่งว่าง ให้กดไม่ได้
                          bool isNotEnoughSeats = _guestCount > remainingSeats;
                          bool isSelected = _selectedTime == time;

                          return ChoiceChip(
                            label: Column(
                              children: [
                                Text(time),
                                Text(
                                  remainingSeats > 0
                                      ? '(ว่าง $remainingSeats)'
                                      : '(เต็ม)',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isNotEnoughSeats
                                        ? Colors.red[300]
                                        : (isSelected
                                              ? Colors.white70
                                              : Colors.green[600]),
                                  ),
                                ),
                              ],
                            ),
                            selected: isSelected,
                            // ถ้าที่นั่งไม่พอ ให้ disable ปุ่ม (ใส่ null)
                            onSelected: isNotEnoughSeats
                                ? null
                                : (selected) {
                                    if (selected)
                                      setState(() => _selectedTime = time);
                                  },
                            selectedColor: Colors.blue,
                            labelStyle: TextStyle(
                              color: isNotEnoughSeats
                                  ? Colors.grey
                                  : (isSelected
                                        ? Colors.white
                                        : Colors.black87),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            backgroundColor: Colors.grey[100],
                            disabledColor: Colors.grey[200],
                            side: BorderSide.none,
                          );
                        }).toList(),
                      );
                    },
                  ),
            const SizedBox(height: 32),

            // --- 4. ปุ่มยืนยัน ---
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedTime != null
                      ? Colors.blue
                      : Colors.grey[300],
                  foregroundColor: _selectedTime != null
                      ? Colors.white
                      : Colors.grey[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: (_selectedTime == null || _isLoading)
                    ? null
                    : _submitBooking,
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        'ยืนยันการจอง',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
