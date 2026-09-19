import 'package:flutter/material.dart';

// ==========================================
// หน้า MainScreen (สำหรับจัดการแถบด้านล่าง)
// ==========================================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const Center(child: Text('หน้าการจองของฉัน (รอสร้าง)')),
    const Center(child: Text('หน้าโปรไฟล์ (รอสร้าง)')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'หน้าหลัก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'การจองของฉัน',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'โปรไฟล์',
          ),
        ],
      ),
    );
  }
}

// ==========================================
// หน้า HomePage (เนื้อหาหลักหน้าแรก)
// ==========================================
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // ใช้ SafeArea จัดการขอบจอด้านบนอัตโนมัติ
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ส่วน Header (สีส้ม) ---
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 180, // ลดความสูงลงจากเดิม 190
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
                      // แถบบนสุด: โลเคชั่น + ปุ่ม Fav + ปุ่ม Profile
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.location_on_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'ท่าคอย, เพชรบุรี',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              // ปุ่ม Favorite
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
                                          const FavoritePage(),
                                    ),
                                  );
                                },
                              ),
                              // ปุ่ม Profile Picture
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ProfileSettingsPage(),
                                    ),
                                  );
                                },
                                child: const CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.white24,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'สวัสดี รัฐนันท์',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'เลือกร้านที่ใช่ จองโต๊ะที่ชอบ',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),

                // --- แถบค้นหา ---
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
                          Text(
                            'ค้นหาร้านอาหาร...',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
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

            // --- ส่วนเมนู 4 ช่อง (แก้ปัญหาการจัดเรียงเบี้ยวแล้ว) ---
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
                          'ร้านเปิดใหม่',
                          'อัปเดตล่าสุด',
                          Colors.green,
                          () {
                            // TODO: ใส่ Action
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
                          () {
                            // TODO: ใส่ Action สำหรับเปิดแผนที่ + GPS
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Center(
              child: Text("เดี๋ยวเราจะมาดึงข้อมูล Firestore ใส่ตรงนี้"),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Widget สำหรับสร้างเมนูย่อย 4 ช่อง (ปรับแก้โครงสร้างให้จัดเรียงตรงกัน)
  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start, // บังคับชิดซ้าย
          children: [
            const SizedBox(width: 16), // เว้นระยะจากขอบซ้ายให้เท่ากัน
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              // ป้องกันข้อความล้นและบังคับโครงสร้าง
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// Dummy Pages (หน้าจอจำลองสำหรับทดสอบการกดปุ่ม)
// ==========================================

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ค้นหาร้านอาหาร')),
      body: const Center(child: Text('หน้าจอสำหรับค้นหาร้าน')),
    );
  }
}

class ArticlePage extends StatelessWidget {
  const ArticlePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('บทความแนะนำ')),
      body: const Center(
        child: Text('หน้าจออ่านบทความรีวิวร้านอาหาร (ไม่มี Interactive)'),
      ),
    );
  }
}

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ร้านที่บันทึกไว้')),
      body: const Center(child: Text('หน้าจอแสดงร้านโปรด')),
    );
  }
}

class ProfileSettingsPage extends StatelessWidget {
  const ProfileSettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ตั้งค่าโปรไฟล์')),
      body: const Center(child: Text('หน้าจอเปลี่ยนรูปโปรไฟล์ ชื่อ อีเมล')),
    );
  }
}
