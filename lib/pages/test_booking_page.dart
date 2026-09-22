import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/restaurant_service.dart';
import '../models/restaurant_model.dart';
import '../services/booking_service.dart';
import 'favorites_page.dart';
import 'restaurant_detail_page.dart'; // <-- เพิ่ม Import หน้า Detail ตรงนี้
import '../services/user_service.dart';

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

final List<Map<String, dynamic>> dummyData =  [
  {
    "name": "เจ๊ไฝ (Jay Fai)",
    "description": "ไข่เจียวปูแน่นๆ และราดหน้าทะเลระดับดาวมิชลิน sss",
    "address": "327 ถ.มหาไชย แขวงสำราญราษฎร์ เขตพระนคร กรุงเทพมหานคร 10200",
    "phoneNumber": "02-226-3914",
    "socialLinks": {
      "facebook": "fb.com/jayfaibangkok",
      "instagram": "@jayfaibangkok"
    },
    "openingHours": "เปิด พุธ - อาทิตย์ 09:00 - 19:30 น. (ปิดจันทร์ - อังคาร)",
    "capacityPerSlot": 30,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/เจ๊ไฝปก.png",
      "https://raw.githubusercontent.com/aphipatb/photo/main/เจ๊ไฝ5.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/เจ๊ไฝ1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/เจ๊ไฝ3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/เจ๊ไฝ2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/เจ๊ไฝ6.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/เจ๊ไฝ5.jpg"
    ],
    "lat": 13.7526,
    "lng": 100.5048,
    "rating": 4.6,
    "reviewCount": 1540,
    "tags": ["thai", "ของคาว", "michelin", "ขึ้น"]
  },
  {
    "name": "ทิพย์สมัย ผัดไทยประตูผี",
    "description": "ผัดไทยมันกุ้งห่อไข่ระดับตำนาน ",
    "address": "313-315 ถ.มหาไชย แขวงสำราญราษฎร์ เขตพระนคร กรุงเทพมหานคร 10200",
    "phoneNumber": "02-226-6666",
    "socialLinks": {
      "facebook": "fb.com/thipsamaipadthai",
      "instagram": "@thipsamaipadthai"
    },
    "openingHours": "เปิด พุธ - จันทร์ 09:00 - 24:00 น. (ปิดอังคาร)",
    "capacityPerSlot": 40,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/ทิพย์สมัย-ผัดไทยประตูผี.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ทิพย์สมัย-ผัดไทยประตูผี1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ทิพย์สมัย-ผัดไทยประตูผี2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ทิพย์สมัย-ผัดไทยประตูผี3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ds.jpg"
    ],
    "lat": 13.7528,
    "lng": 100.5047,
    "rating": 4.2,
    "reviewCount": 2100,
    "tags": ["thai", "ของคาว", "street food", "ไม่ขึ้น"]
  },
  {
    "name": "วัฒนาพานิช",
    "description": "ก๋วยเตี๋ยวเนื้อตุ๋นน้ำซุปเข้มข้น ย่านเอกมัย",
    "address": "336-338 ซ.เอกมัย ถ.สุขุมวิท 63 แขวงคลองตันเหนือ เขตวัฒนา กรุงเทพมหานคร 10110",
    "phoneNumber": "02-391-7264",
    "socialLinks": {
      "facebook": "fb.com/wattanapanich",
      "instagram": "@wattanapanich"
    },
    "openingHours": "เปิดทุกวัน 09:00 - 19:30 น.",
    "capacityPerSlot": 50,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/วัฒนาพานิช.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/วัฒนาพานิช1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/วัฒนาพานิช2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/วัฒนาพานิช3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/วัฒนาพานิช4.jpg"
    ],
    "lat": 13.7275,
    "lng": 100.5878,
    "rating": 4.5,
    "reviewCount": 950,
    "tags": ["thai", "ของคาว", "noodle"]
  },
  {
    "name": "รุ่งเรืองต้มยำ (สุขุมวิท 26)",
    "description": "ก๋วยเตี๋ยวหมูสับต้มยำมะนาวสด sss",
    "address": "10/3 ซ.สุขุมวิท 26 แขวงคลองตัน เขตคลองเตย กรุงเทพมหานคร 10110",
    "phoneNumber": "02-258-6746",
    "socialLinks": {
      "facebook": "fb.com/rungruangporknoodle",
      "instagram": "@rungruangtomyam"
    },
    "openingHours": "เปิดทุกวัน 08:00 - 17:00 น.",
    "capacityPerSlot": 35,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/รุ่งเรืองต้มยำ.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/รุ่งเรืองต้มยำ1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/รุ่งเรืองต้มยำ2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/รุ่งเรืองต้มยำ3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/รุ่งเรืองต้มยำ4.jpg"
    ],
    "lat": 13.7251,
    "lng": 100.5701,
    "rating": 4.4,
    "reviewCount": 1300,
    "tags": ["thai", "ของคาว", "noodle"]
  },
  {
    "name": "โกอ่างข้าวมันไก่ประตูน้ำ",
    "description": "ข้าวมันไก่ฉ่ำๆ ตำนานเสื้อชมพู ",
    "address": "960 ถ.เพชรบุรี แขวงมักกะสัน เขตราชเทวี กรุงเทพมหานคร 10400",
    "phoneNumber": "02-252-8772",
    "socialLinks": {
      "facebook": "fb.com/GoAngPratunamChickenRice",
      "instagram": "@goangpratunam"
    },
    "openingHours": "เปิดทุกวัน 06:00 - 22:30 น.",
    "capacityPerSlot": 40,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/โกอ่างข้าวมันไก่ประตูน้ำ.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/โกอ่างข้าวมันไก่ประตูน้ำ1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/โกอ่างข้าวมันไก่ประตูน้ำ2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/โกอ่างข้าวมันไก่ประตูน้ำ3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/โกอ่างข้าวมันไก่ประตูน้ำ4.jpg"
    ],
    "lat": 13.7497,
    "lng": 100.5422,
    "rating": 4.3,
    "reviewCount": 1850,
    "tags": ["thai", "ของคาว", "street food"]
  },
  {
    "name": "นายไซ",
    "description": "ข้าวหมูกรอบกรอบสนั่น ย่านประชาชื่น",
    "address": "1059 ถ.ประชาชื่น แขวงวงศ์สว่าง เขตบางซื่อ กรุงเทพมหานคร 10800",
    "phoneNumber": "081-845-6789",
    "socialLinks": {
      "facebook": "fb.com/nai.sai.moo.krob",
      "instagram": "@naisai_mookrob"
    },
    "openingHours": "เปิดทุกวัน 06:00 - 15:00 น.",
    "capacityPerSlot": 20,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/นายไซ.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/นายไซ1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/นายไซ2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/นายไซ3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/นายไซ4.jpg"
    ],
    "lat": 13.8242,
    "lng": 100.5367,
    "rating": 4.6,
    "reviewCount": 780,
    "tags": ["thai", "ของคาว", "street food"]
  },
  {
    "name": "ก๋วยจั๊บนายเอ็ก",
    "description": "ก๋วยจั๊บน้ำใสพริกไทยร้อนผ่าว ย่านเยาวราช",
    "address": "442 ซ.เยาวราช 9 แขวงสัมพันธวงศ์ เขตสัมพันธวงศ์ กรุงเทพมหานคร 10100",
    "phoneNumber": "02-226-4651",
    "socialLinks": {
      "facebook": "fb.com/NaiEkRollNoodle",
      "instagram": "@naiekrollnoodle"
    },
    "openingHours": "เปิดทุกวัน 08:00 - 24:00 น.",
    "capacityPerSlot": 30,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/ก๋วยจั๊บนายเอ็ก.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ก๋วยจั๊บนายเอ็ก1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ก๋วยจั๊บนายเอ็ก2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ก๋วยจั๊บนายเอ็ก3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ก๋วยจั๊บนายเอ็ก4.jpg"
    ],
    "lat": 13.7405,
    "lng": 100.5106,
    "rating": 4.3,
    "reviewCount": 1600,
    "tags": ["thai", "ของคาว", "street food"]
  },
  {
    "name": "เผ็ด เผ็ด (Phed Phed)",
    "description": "อาหารอีสานรสจัดจ้านและส้มตำวัตถุดิบพื้นบ้าน",
    "address": "ซ.พหลโยธิน 8 แขวงสามเสนใน เขตพญาไท กรุงเทพมหานคร 10400",
    "phoneNumber": "098-284-9599",
    "socialLinks": {
      "facebook": "fb.com/PhedPhedFood",
      "instagram": "@phedphed_food"
    },
    "openingHours": "เปิดทุกวัน 10:00 - 21:00 น.",
    "capacityPerSlot": 25,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/เผ็ดเผ็ด.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/เผ็ดเผ็ด1.webp",
      "https://raw.githubusercontent.com/aphipatb/photo/main/เผ็ดเผ็ด2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/เผ็ดเผ็ด3.webp",
      "https://raw.githubusercontent.com/aphipatb/photo/main/เผ็ดเผ็ด4.jpg"
    ],
    "lat": 13.7825,
    "lng": 100.5451,
    "rating": 4.7,
    "reviewCount": 850,
    "tags": ["thai", "isan", "ของคาว"]
  },
  {
    "name": "โจ๊กสามย่าน",
    "description": "โจ๊กหมูเด้งชิ้นโตเนื้อเนียน",
    "address": "245 ซ.จุฬาลงกรณ์ 11 แขวงวังใหม่ เขตปทุมวัน กรุงเทพมหานคร 10330",
    "phoneNumber": "02-216-4809",
    "socialLinks": {
      "facebook": "fb.com/JokSamYan",
      "instagram": "@joksamyan"
    },
    "openingHours": "เปิดทุกวัน 05:00 - 21:00 น.",
    "capacityPerSlot": 20,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/โจ๊กสามย่าน.webp",
      "https://raw.githubusercontent.com/aphipatb/photo/main/โจ๊กสามย่าน1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/โจ๊กสามย่าน3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/โจ๊กสามย่าน2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/โจ๊กสามย่าน4.jpg"
    ],
    "lat": 13.7381,
    "lng": 100.5284,
    "rating": 4.5,
    "reviewCount": 920,
    "tags": ["thai", "ของคาว", "street food"]
  },
  {
    "name": "ก๋วยเตี๋ยวเพ็ญพริกเผ็ด",
    "description": "ก๋วยเตี๋ยวหมู/เนื้อน้ำแดงรสเด็ด เอกลักษณ์เมืองเพชร",
    "address": "ถ.หน้าพระลาน ต.คลองกระแซง อ.เมือง จ.เพชรบุรี 76000",
    "phoneNumber": "032-412-140",
    "socialLinks": {
      "facebook": "fb.com/penprikphed",
      "instagram": "@penprikphed"
    },
    "openingHours": "เปิด พุธ - จันทร์ 09:30 - 16:00 น. (ปิดอังคาร)",
    "capacityPerSlot": 20,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/ก๋วยเตี๋ยวเพ็ญพริกเผ็ด.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ก๋วยเตี๋ยวเพ็ญพริกเผ็ด1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ก๋วยเตี๋ยวเพ็ญพริกเผ็ด2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ก๋วยเตี๋ยวเพ็ญพริกเผ็ด3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ก๋วยเตี๋ยวเพ็ญพริกเผ็ด4.jpg"
    ],
    "lat": 13.1118,
    "lng": 99.9453,
    "rating": 4.4,
    "reviewCount": 450,
    "tags": ["thai", "ของคาว", "noodle"]
  },
  {
    "name": "ศรณ์ (Sorn)",
    "description": "อาหารใต้สไตล์ Fine Dining 2 ดาวมิชลิน sss",
    "address": "56 ซ.สุขุมวิท 26 แขวงคลองตัน เขตคลองเตย กรุงเทพมหานคร 10110",
    "phoneNumber": "099-081-1119",
    "socialLinks": {
      "facebook": "fb.com/SornFineSouthernCuisine",
      "instagram": "@sornfinesouthern"
    },
    "openingHours": "เปิด อังคาร - อาทิตย์ 18:00 - 22:00 น. (ปิดจันทร์)",
    "capacityPerSlot": 15,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/sorn.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/sorn1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/sorn2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/sorn3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/sorn4.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Sorn5.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Sorn6.jpg"
    ],
    "lat": 13.7275,
    "lng": 100.5694,
    "rating": 4.9,
    "reviewCount": 420,
    "tags": ["thai", "ของคาว", "fine dining", "michelin"]
  },
  {
    "name": "ครัวอัปษร",
    "description": "อาหารไทยรสจัดจ้าน เมนูเด็ดไข่ฟูปูและแกงเหลือง",
    "address": "169 ถ.ดินสอ แขวงบวรนิเวศ เขตพระนคร กรุงเทพมหานคร 10200",
    "phoneNumber": "02-685-4531",
    "socialLinks": {
      "facebook": "fb.com/kruaapsorn",
      "instagram": "@kruaapsorn"
    },
    "openingHours": "เปิด จันทร์ - เสาร์ 10:30 - 20:00 น. (ปิดอาทิตย์)",
    "capacityPerSlot": 45,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/ครัวอัปษร.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ครัวอัปษร4.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ครัวอัปษร2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ครัวอัปษร3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ครัวอัปษร2.jpg"
    ],
    "lat": 13.7547,
    "lng": 100.5059,
    "rating": 4.6,
    "reviewCount": 1100,
    "tags": ["thai", "ของคาว"]
  },
  {
    "name": "สุพรรณิการ์ (Supanniga Eating Room)",
    "description": "อาหารไทยตราด-อีสานสูตรคุณยาย sss",
    "address": "160/11 ซ.สุขุมวิท 55 แขวงคลองตันเหนือ เขตวัฒนา กรุงเทพมหานคร 10110",
    "phoneNumber": "02-714-7508",
    "socialLinks": {
      "facebook": "fb.com/SupannigaEatingRoom",
      "instagram": "@supannigagroup"
    },
    "openingHours": "เปิดทุกวัน 11:30 - 22:30 น.",
    "capacityPerSlot": 35,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/Supanniga.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Supanniga1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Supanniga2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Supanniga3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Supanniga4.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Supanniga5.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Supanniga6.jpg"
    ],
    "lat": 13.7276,
    "lng": 100.5794,
    "rating": 4.5,
    "reviewCount": 890,
    "tags": ["thai", "ของคาว"]
  },
  {
    "name": "ศรีตราด (Sri Trat)",
    "description": "อาหารไทยตะวันออกรสเข้มข้น บรรยากาศดี sss",
    "address": "90 ซ.สุขุมวิท 33 แขวงคลองตันเหนือ เขตวัฒนา กรุงเทพมหานคร 10110",
    "phoneNumber": "02-088-0968",
    "socialLinks": {
      "facebook": "fb.com/sritrat",
      "instagram": "@sritrat"
    },
    "openingHours": "เปิดทุกวัน 11:00 - 22:00 น.",
    "open" : "11:00",
    "close" : "22:00",
    "capacityPerSlot": 40,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/tri.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/tri1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/tri2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/tri3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/tri4.jpg"
    ],
    "lat": 13.7346,
    "lng": 100.5721,
    "rating": 4.6,
    "reviewCount": 750,
    "tags": ["thai", "ของคาว"]
  },
  {
    "name": "เขียวไก่กา",
    "description": "อาหารไทยพื้นบ้านวัตถุดิบคุณภาพ",
    "address": "33 ถ.นาคนิวาส แขวงลาดพร้าว เขตลาดพร้าว กรุงเทพมหานคร 10230",
    "phoneNumber": "02-227-0685",
    "socialLinks": {
      "facebook": "fb.com/kiewkaika",
      "instagram": "@kiewkaika"
    },
    "openingHours": "เปิดทุกวัน 11:00 - 22:00 น.",
    "capacityPerSlot": 45,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/เขียวไก่กา.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/เขียวไก่กา1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/เขียวไก่กา2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/เขียวไก่กา3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/เขียวไก่กา4.jpg"
    ],
    "lat": 13.8052,
    "lng": 100.6053,
    "rating": 4.5,
    "reviewCount": 620,
    "tags": ["thai", "ของคาว"]
  },
  {
    "name": "พวงเพชร",
    "description": "ร้านอาหารไทย-พื้นบ้านเมืองเพชร เมนูต้มส้มและแกงป่า",
    "address": "389 ถ.เพชรเกษม ต.บ้านหม้อ อ.เมือง จ.เพชรบุรี 76000",
    "phoneNumber": "032-411-385",
    "socialLinks": {
      "facebook": "fb.com/PuangPechRestaurant",
      "instagram": "@puangpech"
    },
    "openingHours": "เปิดทุกวัน 10:00 - 20:30 น.",
    "capacityPerSlot": 50,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/พวงเพชร.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/พวงเพชร1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/พวงเพชร2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/พวงเพชร3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/พวงเพชร4.jpg"
    ],
    "lat": 13.1095,
    "lng": 99.9442,
    "rating": 4.4,
    "reviewCount": 510,
    "tags": ["thai", "ของคาว", "local"]
  },
  {
    "name": "สังเวียนซีฟู้ด",
    "description": "ร้านซีฟู้ดริมหาด จานใหญ่ วัตถุดิบสดใหม่",
    "address": "ริมหาดชะอำเหนือ ต.ชะอำ อ.ชะอำ จ.เพชรบุรี 76120",
    "phoneNumber": "032-472-280",
    "socialLinks": {
      "facebook": "fb.com/SangweanSeafood",
      "instagram": "@sangweanseafood"
    },
    "openingHours": "เปิดทุกวัน 10:00 - 20:00 น.",
    "capacityPerSlot": 80,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/สังเวียนซีฟู้ด.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/สังเวียนซีฟู้ด1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/สังเวียนซีฟู้ด2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/สังเวียนซีฟู้ด3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/สังเวียนซีฟู้ด4.jpg"
    ],
    "lat": 12.8021,
    "lng": 99.9837,
    "rating": 4.5,
    "reviewCount": 1250,
    "tags": ["seafood", "ของคาว"]
  },
  {
    "name": "แหลมเจริญซีฟู้ด",
    "description": "ต้นตำรับปลากะพงทอดน้ำปลา",
    "address": "ถ.เลียบชายฝั่ง ต.ปากน้ำ อ.เมือง จ.ระยอง 21000",
    "phoneNumber": "038-940-094",
    "socialLinks": {
      "facebook": "fb.com/LaemCharoenSeafood",
      "instagram": "@laemcharoenseafood"
    },
    "openingHours": "เปิดทุกวัน 10:00 - 21:00 น.",
    "capacityPerSlot": 100,
    "imageUrl": [
      "https://raw.githubusercontent.com/phipatb/photo/main/แหลมเจริญซีฟู้ด.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/แหลมเจริญซีฟู้ด1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/แหลมเจริญซีฟู้ด2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/แหลมเจริญซีฟู้ด3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/แหลมเจริญซีฟู้ด4.jpg"
    ],
    "lat": 12.6732,
    "lng": 101.2721,
    "rating": 4.6,
    "reviewCount": 3000,
    "tags": ["seafood", "ของคาว"]
  },
  {
    "name": "อบอร่อย",
    "description": "กุ้งอบวุ้นเส้นและอาหารทะเลสด ย่านทาวน์อินทาวน์",
    "address": "1329/53 ซ.ลาดพร้าว 94 (ปัญจมิตร) ถ.อินทราภรณ์ เขตวังทองหลาง กรุงเทพมหานคร 10310",
    "phoneNumber": "02-559-0628",
    "socialLinks": {
      "facebook": "fb.com/obaroi.townintown",
      "instagram": "@obaroi"
    },
    "openingHours": "เปิดทุกวัน 10:30 - 22:30 น.",
    "capacityPerSlot": 60,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/อบอร่อย.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/อบอร่อย1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/อบอร่อย2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/อบอร่อย3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/อบอร่อย4.webp"
    ],
    "lat": 13.7699,
    "lng": 100.6122,
    "rating": 4.5,
    "reviewCount": 1800,
    "tags": ["seafood", "ของคาว"]
  },
  {
    "name": "เรือนสายน้ำ",
    "description": "กุ้งแม่น้ำเผาตัวโต มันกุ้งเยิ้มริมแม่น้ำเจ้าพระยา",
    "address": "26/1 หมู่ 4 ต.เกาะเกิด อ.บางปะอิน จ.พระนครศรีอยุธยา 13160",
    "phoneNumber": "093-559-2895",
    "socialLinks": {
      "facebook": "fb.com/ruensainam",
      "instagram": "@ruensainam"
    },
    "openingHours": "เปิดทุกวัน 10:00 - 20:30 น.",
    "capacityPerSlot": 40,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/เรือนสายน้ำ.webp",
      "https://raw.githubusercontent.com/aphipatb/photo/main/เรือนสายน้ำ1.webp",
      "https://raw.githubusercontent.com/aphipatb/photo/main/เรือนสายน้ำ2.webp",
      "https://raw.githubusercontent.com/aphipatb/photo/main/เรือนสายน้ำ3.webp",
      "https://raw.githubusercontent.com/aphipatb/photo/main/เรือนสายน้ำ4.webp"
    ],
    "lat": 14.3411,
    "lng": 100.5732,
    "rating": 4.7,
    "reviewCount": 940,
    "tags": ["seafood", "thai", "ของคาว"]
  },
  {
    "name": "ระย้า (Raya)",
    "description": "แกงเนื้อปูใบชะพลูตำนานเมืองภูเก็ต sss",
    "address": "48 ถ.ดีบุก ต.ตลาดใหญ่ อ.เมือง จ.ภูเก็ต 83000",
    "phoneNumber": "076-218-155",
    "socialLinks": {
      "facebook": "fb.com/therayaphuket",
      "instagram": "@rayaphuket"
    },
    "openingHours": "เปิดทุกวัน 10:00 - 22:00 น.",
    "capacityPerSlot": 50,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/Raya.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Raya1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Raya2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Raya3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Raya4.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Raya5.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Raya6.jpg"
    ],
    "lat": 7.8862,
    "lng": 98.3904,
    "rating": 4.6,
    "reviewCount": 1500,
    "tags": ["thai", "ของคาว", "local"]
  },
  {
    "name": "ตู้กับข้าว",
    "description": "อาหารพื้นเมืองภูเก็ตในอาคารชิโน-โปรตุกีส",
    "address": "8 ถ.พังงา ต.ตลาดใหญ่ อ.เมือง จ.ภูเก็ต 83000",
    "phoneNumber": "076-608-888",
    "socialLinks": {
      "facebook": "fb.com/tukabkhao",
      "instagram": "@tukabkhao"
    },
    "openingHours": "เปิดทุกวัน 11:00 - 21:00 น.",
    "capacityPerSlot": 40,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/tuu.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/tuu1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/tuu2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/tuu3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/tuu4.jpg"
    ],
    "lat": 7.8845,
    "lng": 98.3895,
    "rating": 4.7,
    "reviewCount": 2200,
    "tags": ["thai", "ของคาว", "local"]
  },
  {
    "name": "โกเบ๊นซ์ ข้าวต้มบาทเดียว",
    "description": "ข้าวต้มแห้งหมูกรอบชื่อดัง",
    "address": "163 ถ.กระบี่ ต.ตลาดเหนือ อ.เมือง จ.ภูเก็ต 83000",
    "phoneNumber": "084-053-3456",
    "socialLinks": {
      "facebook": "fb.com/gobenzphuket",
      "instagram": "@gobenzphuket"
    },
    "openingHours": "เปิด อังคาร - อาทิตย์ 18:00 - 03:00 น. (ปิดจันทร์)",
    "capacityPerSlot": 30,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/โกเบ๊นซ์.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/โกเบ๊นซ์1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/โกเบ๊นซ์2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/โกเบ๊นซ์3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/โกเบ๊นซ์4.jpg"
    ],
    "lat": 7.8885,
    "lng": 98.3883,
    "rating": 4.6,
    "reviewCount": 2500,
    "tags": ["thai", "ของคาว", "street food"]
  },
  {
    "name": "ต๋องเต็มโต๊ะ",
    "description": "อาหารเหนือพื้นเมืองย่านนิมมานฯ",
    "address": "11 ซ.นิมมานเหมินท์ 13 ต.สุเทพ อ.เมือง จ.เชียงใหม่ 50200",
    "phoneNumber": "053-894-701",
    "socialLinks": {
      "facebook": "fb.com/TongTemToh",
      "instagram": "@tongtemtoh"
    },
    "openingHours": "เปิดทุกวัน 11:00 - 21:00 น.",
    "capacityPerSlot": 40,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/ต๋องเต็มโต๊ะ.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ต๋องเต็มโต๊ะ1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ต๋องเต็มโต๊ะ2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ต๋องเต็มโต๊ะ3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ต๋องเต็มโต๊ะ4.jpg"
    ],
    "lat": 18.7963,
    "lng": 98.9663,
    "rating": 4.4,
    "reviewCount": 3100,
    "tags": ["thai", "ของคาว", "local"]
  },
  {
    "name": "ข้าวซอยแม่สาย",
    "description": "ข้าวซอยเนื้อ-ไก่ รสเข้มข้นดั้งเดิม",
    "address": "29/1 ซ.ราชพฤกษ์ ถ.ห้วยแก้ว ต.ช้างเผือก อ.เมือง จ.เชียงใหม่ 50300",
    "phoneNumber": "053-213-284",
    "socialLinks": {
      "facebook": "fb.com/khaosoimaesai",
      "instagram": "@khaosoimaesai"
    },
    "openingHours": "เปิด จันทร์ - เสาร์ 08:00 - 16:00 น. (ปิดอาทิตย์)",
    "capacityPerSlot": 20,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/ข้าวซอยแม่สาย.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ข้าวซอยแม่สาย1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ข้าวซอยแม่สาย2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ข้าวซอยแม่สาย3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ก๋วยเตี๋ยวเพ็ญพริกเผ็ด4.jpg"
    ],
    "lat": 18.8023,
    "lng": 98.9765,
    "rating": 4.5,
    "reviewCount": 1100,
    "tags": ["thai", "ของคาว", "noodle"]
  },
  {
    "name": "เฮือนเพ็ญ",
    "description": "ขันโตกและอาหารเหนือย่านคูเมือง",
    "address": "112 ถ.ราชมรรคา ต.พระสิงห์ อ.เมือง จ.เชียงใหม่ 50200",
    "phoneNumber": "053-814-548",
    "socialLinks": {
      "facebook": "fb.com/huenpen",
      "instagram": "@huenpen"
    },
    "openingHours": "เปิดทุกวัน 08:30 - 16:00 น., 17:00 - 22:00 น.",
    "capacityPerSlot": 60,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/เฮือนเพ็ญ.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/เฮือนเพ็ญ1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/เฮือนเพ็ญ2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/เฮือนเพ็ญ3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/เฮือนเพ็ญ4.jpg"
    ],
    "lat": 18.7845,
    "lng": 98.9845,
    "rating": 4.3,
    "reviewCount": 1800,
    "tags": ["thai", "ของคาว", "local"]
  },
  {
    "name": "ครัวกรรณิการ์",
    "description": "ขนมจีนน้ำยาปูกับไก่ทอดสูตรเด็ดเฉพาะตัว",
    "address": "190/7 ซ.ชูพงษ์ ถ.เพชรเกษม อ.หัวหิน จ.ประจวบคีรีขันธ์ 77110",
    "phoneNumber": "032-512-069",
    "socialLinks": {
      "facebook": "fb.com/kruakannikar",
      "instagram": "@kruakannikar"
    },
    "openingHours": "เปิดทุกวัน 08:30 - 15:30 น.",
    "capacityPerSlot": 30,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/ครัวกรรณิการ์.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ครัวกรรณิการ์1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ครัวกรรณิการ์2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ครัวกรรณิการ์3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ครัวกรรณิการ์4.jpg"
    ],
    "lat": 12.5694,
    "lng": 99.9576,
    "rating": 4.5,
    "reviewCount": 850,
    "tags": ["thai", "ของคาว", "local"]
  },
  {
    "name": "ไก่ย่างวิเชียรบุรี (ตาแป๊ะ)",
    "description": "ไก่ย่างหนังกรอบน้ำจิ้มรสเด็ด",
    "address": "ริม ถ.สระบุรี-หล่มสัก อ.วิเชียรบุรี จ.เพชรบูรณ์ 67130",
    "phoneNumber": "056-928-026",
    "socialLinks": {
      "facebook": "fb.com/kaiyangvichienburi",
      "instagram": "@kaiyangvichienburi"
    },
    "openingHours": "เปิดทุกวัน 08:00 - 17:00 น.",
    "capacityPerSlot": 40,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/ไก่ย่างวิเชียรบุรี.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ไก่ย่างวิเชียรบุรี1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ไก่ย่างวิเชียรบุรี2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ไก่ย่างวิเชียรบุรี3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ไก่ย่างวิเชียรบุรี4.jpg"
    ],
    "lat": 15.6515,
    "lng": 101.0558,
    "rating": 4.4,
    "reviewCount": 600,
    "tags": ["thai", "isan", "ของคาว"]
  },
  {
    "name": "ลาบเป็ดอุดร",
    "description": "ลาบเป็ดรสแซ่บและอาหารอีสานดั้งเดิม",
    "address": "ซ.รามคำแหง 14 ถ.รามคำแหง แขวงหัวหมาก เขตบางกะปิ กรุงเทพมหานคร 10240",
    "phoneNumber": "02-314-2576",
    "socialLinks": {
      "facebook": "fb.com/larbpedudon",
      "instagram": "@larbpedudon"
    },
    "openingHours": "เปิดทุกวัน 10:00 - 22:00 น.",
    "capacityPerSlot": 45,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/ลาบเป็ดอุดร1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ลาบเป็ดอุดร.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ลาบเป็ดอุดร2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ลาบเป็ดอุดร3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ลาบเป็ดอุดร4.jpg"
    ],
    "lat": 17.4138,
    "lng": 102.7958,
    "rating": 4.3,
    "reviewCount": 720,
    "tags": ["thai", "isan", "ของคาว"]
  },
  {
    "name": "ก๋วยเตี๋ยวเรือป้าเล็ก",
    "description": "ก๋วยเตี๋ยวเรือน้ำตกเข้มข้นหน้าวัดมหาธาตุ",
    "address": "ถ.มหาราช ต.ท่าวาสุกรี อ.พระนครศรีอยุธยา จ.พระนครศรีอยุธยา 13000",
    "phoneNumber": "081-432-6997",
    "socialLinks": {
      "facebook": "fb.com/palekayutthaya",
      "instagram": "@paleknoodle"
    },
    "openingHours": "เปิด พฤหัสบดี - อังคาร 08:00 - 17:00 น. (ปิดพุธ)",
    "capacityPerSlot": 20,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/ก๋วยเตี๋ยวเรือป้าเล็ก.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ก๋วยเตี๋ยวเรือป้าเล็ก1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ก๋วยเตี๋ยวเรือป้าเล็ก2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ก๋วยเตี๋ยวเรือป้าเล็ก3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ก๋วยเตี๋ยวเรือป้าเล็ก4.jpg"
    ],
    "lat": 14.3567,
    "lng": 100.5678,
    "rating": 4.5,
    "reviewCount": 980,
    "tags": ["thai", "ของคาว", "noodle"]
  },
  {
    "name": "Le Du (ฤดู)",
    "description": "อาหารไทยร่วมสมัยสไตล์ Modern Dining sss",
    "address": "399/3 ซ.สีลม 7 แขวงสีลม เขตบางรัก กรุงเทพมหานคร 10500",
    "phoneNumber": "092-919-9969",
    "socialLinks": {
      "facebook": "fb.com/LeDuBkk",
      "instagram": "@ledubkk"
    },
    "openingHours": "เปิด จันทร์ - เสาร์ 18:00 - 23:00 น. (ปิดอาทิตย์)",
    "capacityPerSlot": 20,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/LeDu.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/LeDu1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/LeDu2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/LeDu3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/LeDu4.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ledu5.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ledu6.jpg"
    ],
    "lat": 13.7237,
    "lng": 100.5284,
    "rating": 4.8,
    "reviewCount": 450,
    "tags": ["thai", "modern", "ของคาว", "michelin"]
  },
  {
    "name": "Peppina",
    "description": "พิซซ่าสไตล์นาโปลีแท้ อบเตาถ่าน sss",
    "address": "27/1 ซ.สุขุมวิท 33 แขวงคลองตันเหนือ เขตวัฒนา กรุงเทพมหานคร 10110",
    "phoneNumber": "02-119-7677",
    "socialLinks": {
      "facebook": "fb.com/peppinapizza",
      "instagram": "@peppinabkk"
    },
    "openingHours": "เปิดทุกวัน 11:30 - 23:00 น.",
    "capacityPerSlot": 45,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/Peppina.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Peppina1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Peppina2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Peppina3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Peppina4.jpg"
    ],
    "lat": 13.7383,
    "lng": 100.5694,
    "rating": 4.5,
    "reviewCount": 1150,
    "tags": ["italian", "ของคาว", "pizza"]
  },
  {
    "name": "Isao",
    "description": "ซูชิฟิวชั่นสไตล์ญี่ปุ่น-อเมริกัน เมนูเด็ด Jackie Roll",
    "address": "5 ซ.สุขุมวิท 31 แขวงคลองตันเหนือ เขตวัฒนา กรุงเทพมหานคร 10110",
    "phoneNumber": "02-258-0645",
    "socialLinks": {
      "facebook": "fb.com/isaobkk",
      "instagram": "@isaobkk"
    },
    "openingHours": "เปิดทุกวัน 11:00 - 14:30 น., 17:00 - 21:30 น.",
    "capacityPerSlot": 25,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/Isao.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Isao1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Isao2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Isao3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Isao4.jpg"
    ],
    "lat": 13.7335,
    "lng": 100.5709,
    "rating": 4.6,
    "reviewCount": 1250,
    "tags": ["japanese", "fusion", "ของคาว"]
  },
  {
    "name": "Sushi Masato",
    "description": "โอมากาเสะพรีเมียมโดยเชฟชาวญี่ปุ่น",
    "address": "3/22 ซ.สวัสดี 1 ถ.สุขุมวิท 31 เขตวัฒนา กรุงเทพมหานคร 10110",
    "phoneNumber": "02-040-0015",
    "socialLinks": {
      "facebook": "fb.com/sushimasato",
      "instagram": "@sushimasato"
    },
    "openingHours": "เปิด อังคาร - อาทิตย์ 12:00 - 14:00 น., 17:00 - 22:00 น. (ปิดจันทร์)",
    "capacityPerSlot": 10,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/SushiMasato.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/SushiMasato1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/SushiMasato2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/SushiMasato3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/SushiMasato4.jpg"
    ],
    "lat": 13.7345,
    "lng": 100.5656,
    "rating": 4.8,
    "reviewCount": 340,
    "tags": ["japanese", "omakase", "ของคาว"]
  },
  {
    "name": "Daniel Thaiger",
    "description": "เบอร์เกอร์เนื้อบดฉ่ำๆ สไตล์อเมริกัน",
    "address": "ซ.สุขุมวิท 11 แขวงคลองเตยเหนือ เขตวัฒนา กรุงเทพมหานคร 10110",
    "phoneNumber": "084-549-0995",
    "socialLinks": {
      "facebook": "fb.com/DanielThaiger",
      "instagram": "@danielthaiger"
    },
    "openingHours": "เปิดทุกวัน 11:00 - 21:30 น.",
    "capacityPerSlot": 15,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/Daniel.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Daniel1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Daniel2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Daniel3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Daniel4.jpg"
    ],
    "lat": 13.7431,
    "lng": 100.5552,
    "rating": 4.6,
    "reviewCount": 890,
    "tags": ["american", "burger", "ของคาว"]
  },
  {
    "name": "El Gaucho",
    "description": "สเต๊กเนื้อเกรดพรีเมียมสไตล์อาร์เจนตินา",
    "address": "8/4-7 ซ.สุขุมวิท 19 แขวงคลองเตยเหนือ เขตวัฒนา กรุงเทพมหานคร 10110",
    "phoneNumber": "02-255-2864",
    "socialLinks": {
      "facebook": "fb.com/ElGauchoThailand",
      "instagram": "@elgaucho_steakhouse"
    },
    "openingHours": "เปิดทุกวัน 11:00 - 24:00 น.",
    "capacityPerSlot": 50,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/El.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/El1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/El2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/El3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/El4.jpg"
    ],
    "lat": 13.7385,
    "lng": 100.5601,
    "rating": 4.5,
    "reviewCount": 1200,
    "tags": ["steak", "argentinian", "ของคาว"]
  },
  {
    "name": "Cocotte Farm Roast & Winery",
    "description": "ร้านสเต๊กและอาหารฝรั่งเศสสไตล์บิสโทร sss",
    "address": "39 บูเลอวาร์ด ซ.สุขุมวิท 39 แขวงคลองตันเหนือ เขตวัฒนา กรุงเทพมหานคร 10110",
    "phoneNumber": "092-664-6777",
    "socialLinks": {
      "facebook": "fb.com/cocottebkk",
      "instagram": "@cocottebkk"
    },
    "openingHours": "เปิดทุกวัน 11:00 - 23:00 น.",
    "capacityPerSlot": 60,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/Cocotte.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Cocotte1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Cocotte2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Cocotte3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Cocotte4.jpg"
    ],
    "lat": 13.7351,
    "lng": 100.5731,
    "rating": 4.6,
    "reviewCount": 1400,
    "tags": ["french", "steak", "ของคาว"]
  },
  {
    "name": "Zanotti",
    "description": "ร้านอาหารอิตาเลียนระดับตำนานย่านสีลม",
    "address": "21/2 ซ.ศาลาแดง 1 ถ.สีลม แขวงสีลม เขตบางรัก กรุงเทพมหานคร 10500",
    "phoneNumber": "02-236-8802",
    "socialLinks": {
      "facebook": "fb.com/ZanottiIlRistoranteItaliano",
      "instagram": "@zanottibangkok"
    },
    "openingHours": "เปิดทุกวัน 11:30 - 14:00 น., 18:00 - 22:30 น.",
    "capacityPerSlot": 50,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/Zanotti.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Zanotti4.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Zanotti3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Zanotti2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Zanotti1.jpg"
    ],
    "lat": 13.7272,
    "lng": 100.5361,
    "rating": 4.5,
    "reviewCount": 850,
    "tags": ["italian", "ของคาว"]
  },
  {
    "name": "เนื้อแท้ (Nuathea)",
    "description": "สารพัดเมนูเนื้อวัวรสเข้มข้น",
    "address": "หนองจอก ถ.มิตรไมตรี แขวงหนองจอก เขตหนองจอก กรุงเทพมหานคร 10530",
    "phoneNumber": "02-026-6666",
    "socialLinks": {
      "facebook": "fb.com/Nuathea",
      "instagram": "@nuathea"
    },
    "openingHours": "เปิดทุกวัน 10:00 - 21:30 น.",
    "capacityPerSlot": 40,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/Nuathea.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Nuathea1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Nuathea2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Nuathea3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Nuathea4.jpg"
    ],
    "lat": 13.8402,
    "lng": 100.6781,
    "rating": 4.4,
    "reviewCount": 980,
    "tags": ["thai", "beef", "ของคาว"]
  },
  {
    "name": "Greyhound Café",
    "description": "อาหารสไตล์เอเชียน-สตรีทฟิวชั่นร่วมสมัย",
    "address": "ชั้น 1 สยามเซ็นเตอร์ ถ.พระราม 1 เขตปทุมวัน กรุงเทพมหานคร 10330",
    "phoneNumber": "02-251-4907",
    "socialLinks": {
      "facebook": "fb.com/GreyhoundCafe",
      "instagram": "@greyhoundcafe"
    },
    "openingHours": "เปิดทุกวัน 10:00 - 22:00 น.",
    "capacityPerSlot": 60,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/Greyhound.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Greyhound1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Greyhound3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Greyhound4.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Greyhound2.jpg"
    ],
    "lat": 13.7314,
    "lng": 100.5694,
    "rating": 4.3,
    "reviewCount": 1800,
    "tags": ["fusion", "cafe", "ของคาว"]
  },
  {
    "name": "อาฟเตอร์ยู (After You)",
    "description": "คากิโกริ ชิบูย่าฮันนี่โทสต์ยอดฮิต",
    "address": "ชั้น G สยามพารากอน ถ.พระราม 1 เขตปทุมวัน กรุงเทพมหานคร 10330",
    "phoneNumber": "02-610-7659",
    "socialLinks": {
      "facebook": "fb.com/afteryoucafe",
      "instagram": "@afteryoudessertcafe"
    },
    "openingHours": "เปิดทุกวัน 10:00 - 22:00 น.",
    "capacityPerSlot": 40,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/After%20You.webp",
      "https://raw.githubusercontent.com/aphipatb/photo/main/AfterYou1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/AfterYou2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/AfterYou3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/AfterYou4.jpg"
    ],
    "lat": 13.7291,
    "lng": 100.5312,
    "rating": 4.7,
    "reviewCount": 3500,
    "tags": ["dessert", "cafe", "ของหวาน"]
  },
  {
    "name": "มนต์ นมสด",
    "description": "ขนมปังปิ้งนมหอมและนมสดหน้าลานคนเมือง",
    "address": "160/1-3 ถ.ดินสอ แขวงเสาชิงช้า เขตพระนคร กรุงเทพมหานคร 10200",
    "phoneNumber": "02-224-1147",
    "socialLinks": {
      "facebook": "fb.com/montnomsod.bkk",
      "instagram": "@montnomsod"
    },
    "openingHours": "เปิดทุกวัน 13:00 - 22:00 น.",
    "capacityPerSlot": 30,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/มน.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/มน1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/มน2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/มน3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/มน4.jpg"
    ],
    "lat": 13.7538,
    "lng": 100.5015,
    "rating": 4.5,
    "reviewCount": 2800,
    "tags": ["dessert", "cafe", "ของหวาน"]
  },
  {
    "name": "สิงคโปร์โภชนา (ลอดช่องสิงคโปร์)",
    "description": "ลอดช่องเส้นนุ่มน้ำกะทิหอมหวาน ย่านสามแยกเจริญกรุง",
    "address": "680-682 ถ.เจริญกรุง แขวงสัมพันธวงศ์ เขตสัมพันธวงศ์ กรุงเทพมหานคร 10110",
    "phoneNumber": "02-221-5794",
    "socialLinks": {
      "facebook": "fb.com/lodchongsingapore",
      "instagram": "@lodchongsingapore"
    },
    "openingHours": "เปิด ศุกร์ - พุธ 10:30 - 21:30 น. (ปิดพฤหัสบดี)",
    "capacityPerSlot": 20,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/สิงคโปร์โภชนา.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/สิงคโปร์โภชนา1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/สิงคโปร์โภชนา2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/สิงคโปร์โภชนา3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/สิงคโปร์โภชนา4.jpg"
    ],
    "lat": 13.7385,
    "lng": 100.5108,
    "rating": 4.4,
    "reviewCount": 1200,
    "tags": ["thai", "dessert", "ของหวาน"]
  },
  {
    "name": "Factory Coffee",
    "description": "Specialty Coffee ดีกรีแชมป์บาริสต้า sss",
    "address": "49 ถ.พญาไท แขวงถนนพญาไท เขตราชเทวี กรุงเทพมหานคร 10400",
    "phoneNumber": "080-402-2222",
    "socialLinks": {
      "facebook": "fb.com/factorybkk",
      "instagram": "@factorybkk"
    },
    "openingHours": "เปิดทุกวัน 08:00 - 17:00 น.",
    "capacityPerSlot": 25,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/Factory.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Factory1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Factory2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Factory3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Factory4.jpg"
    ],
    "lat": 13.7571,
    "lng": 100.5372,
    "rating": 4.8,
    "reviewCount": 1650,
    "tags": ["coffee", "cafe", "เครื่องดื่ม"]
  },
  {
    "name": "Roots",
    "description": "กาแฟคราฟต์เมล็ดไทยคุณภาพระดับพรีเมียม",
    "address": "33/31 ซ.สาทร 11 แขวงยานนาวา เขตสาทร กรุงเทพมหานคร 10120",
    "phoneNumber": "097-058-6846",
    "socialLinks": {
      "facebook": "fb.com/RootsBkk",
      "instagram": "@rootsbkk"
    },
    "openingHours": "เปิดทุกวัน 08:00 - 17:00 น.",
    "capacityPerSlot": 30,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/Roots.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Roots1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Roots2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Roots3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Roots4.jpg"
    ],
    "lat": 13.7332,
    "lng": 100.5824,
    "rating": 4.7,
    "reviewCount": 980,
    "tags": ["coffee", "cafe", "เครื่องดื่ม"]
  },
  {
    "name": "ลอดช่องน้ำกะทิป้าปรางค์",
    "description": "ขนมหวานน้ำกะทิลอดช่องเมืองเพชรแท้",
    "address": "ริม ถ.คลองกระแซง ต.คลองกระแซง อ.เมือง จ.เพชรบุรี 76000",
    "phoneNumber": "032-425-666",
    "socialLinks": {
      "facebook": "fb.com/papranglodchong",
      "instagram": "@paprang_phetchaburi"
    },
    "openingHours": "เปิดทุกวัน 09:00 - 17:00 น.",
    "capacityPerSlot": 15,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/kanom1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/kanom.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/kanom2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/kanom3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/kanom4.jpg"
    ],
    "lat": 13.1123,
    "lng": 99.9458,
    "rating": 4.6,
    "reviewCount": 420,
    "tags": ["thai", "dessert", "ของหวาน", "local"]
  },
  {
    "name": "แม่กิมลั้ง",
    "description": "ขนมหม้อแกงและขนมไทยเมืองเพชรของฝากชื่อดัง",
    "address": "ริม ถ.เพชรเกษม ต.ท่ายาง อ.ท่ายาง จ.เพชรบุรี 76130",
    "phoneNumber": "032-461-123",
    "socialLinks": {
      "facebook": "fb.com/Maekimlung",
      "instagram": "@maekimlung"
    },
    "openingHours": "เปิดทุกวัน 07:00 - 20:00 น.",
    "capacityPerSlot": 50,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/แม่กิมลั้ง.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/แม่กิมลั้ง1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/แม่กิมลั้ง2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/แม่กิมลั้ง3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/แม่กิมลั้ง4.jpg"
    ],
    "lat": 13.0619,
    "lng": 99.9412,
    "rating": 4.3,
    "reviewCount": 800,
    "tags": ["thai", "dessert", "ของหวาน", "souvenir"]
  },
  {
    "name": "Chocolate Ville",
    "description": "ร้านอาหารบรรยากาศหมู่บ้านยุโรป",
    "address": "23, 1-16 ถ.ประเสริฐมนูกิจ แขวงรามอินทรา เขตคันนายาว กรุงเทพมหานคร 10230",
    "phoneNumber": "081-921-2016",
    "socialLinks": {
      "facebook": "fb.com/chocolateville",
      "instagram": "@chocolateville"
    },
    "openingHours": "เปิดทุกวัน 15:00 - 24:00 น.",
    "capacityPerSlot": 150,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/Ville.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Ville1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Ville3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Ville2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/Ville4.jpg"
    ],
    "lat": 13.8118,
    "lng": 100.6806,
    "rating": 4.4,
    "reviewCount": 5500,
    "tags": ["international", "ของคาว", "attraction"]
  },
  {
    "name": "ร้านกาแฟชายทุ่ง",
    "description": "กาแฟรสชาติเยี่ยม บรรยากาศสวนร่มรื่น",
    "address": "คลองสี่ ถ.รังสิต-นครนายก อ.ธัญบุรี จ.ปทุมธานี 12110",
    "phoneNumber": "02-123-4567",
    "socialLinks": {
      "facebook": "fb.com/ChaithungCoffee",
      "instagram": "@chaithungcoffee"
    },
    "openingHours": "เปิดทุกวัน 07:30 - 17:30 น.",
    "capacityPerSlot": 40,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/ร้านกาแฟชายทุ่ง.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ร้านกาแฟชายทุ่ง1.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ร้านกาแฟชายทุ่ง2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ร้านกาแฟชายทุ่ง3.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ร้านกาแฟชายทุ่ง4.jpg"
    ],
    "lat": 14.0416,
    "lng": 100.7302,
    "rating": 4.5,
    "reviewCount": 1100,
    "tags": ["coffee", "cafe", "เครื่องดื่ม"]
  },
  {
    "name": "ชาตรามือ (ChaTraMue)",
    "description": "ชาไทยเย็นรสเข้มข้นและไอศกรีมชาไทย",
    "address": "ชั้น LG ศูนย์การค้าเทอร์มินอล 21 อโศก เขตวัฒนา กรุงเทพมหานคร 10110",
    "phoneNumber": "02-108-0888",
    "socialLinks": {
      "facebook": "fb.com/ChaTraMue",
      "instagram": "@chatramue"
    },
    "openingHours": "เปิดทุกวัน 10:00 - 21:00 น.",
    "capacityPerSlot": 10,
    "imageUrl": [
      "https://raw.githubusercontent.com/aphipatb/photo/main/ChaTraMue.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ChaTraMue1.png",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ChaTraMue2.jpg",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ChaTraMue3.png",
      "https://raw.githubusercontent.com/aphipatb/photo/main/ChaTraMue4.png"
    ],
    "lat": 13.7388,
    "lng": 100.5604,
    "rating": 4.6,
    "reviewCount": 1500,
    "tags": ["tea", "dessert", "เครื่องดื่ม"]
  }
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
                      // --- เอา InkWell มาครอบ ListTile เพื่อให้กดแล้วไปหน้า Detail ได้ ---
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RestaurantDetailPage(restaurant: restaurant),
                            ),
                          );
                        },
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
                                      .doc(
                                        FirebaseAuth.instance.currentUser?.uid,
                                      )
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
                                        UserService().toggleFavorite(
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
                                        content: Text(
                                          'กรุณาล็อกอินก่อนให้คะแนน',
                                        ),
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
                                                      restaurantId:
                                                          restaurant.id,
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

                              // ปล่อยปุ่มจองไว้ตรงนี้เหมือนเดิม (หรือจะลบออกก็ได้เพราะในหน้า Detail ก็มีปุ่มจองใหญ่ๆ แล้ว)
                              ElevatedButton(
                                onPressed: () {
                                  final userId =
                                      FirebaseAuth.instance.currentUser?.uid;
                                  if (userId == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'กรุณาล็อกอินก่อนจองโต๊ะ',
                                        ),
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
