import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/auth_service.dart';
import '../login_page.dart';
import '../favorites_page.dart';
import 'profile_edit.dart';
import 'profile_nisit.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> _logout() async {
    // 🛠️ 2. เปลี่ยนมาใช้ AuthService ของเราจัดการแทน
    await AuthService().logout();
    setState(() {}); // สั่งให้รีเฟรชหน้าจอ เพื่อซ่อนเมนูสมาชิก
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'โปรไฟล์ของฉัน',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: user != null
          ? _buildLoggedInBody(context, user, primary)
          : _buildLoggedOutBody(context, primary),
    );
  }

  // ==========================================
  // กรณีล็อกอินแล้ว: การ์ดข้อมูล + เมนูต่างๆ
  // ==========================================
  Widget _buildLoggedInBody(BuildContext context, User user, Color primary) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // --- การ์ดข้อมูลผู้ใช้ (ฟังข้อมูล real-time จาก Firestore) ---
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            String username = user.email ?? 'ไม่พบชื่อผู้ใช้';
            String phone = '';

            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>;
              username = (data['username'] ?? username).toString();
              phone = (data['phone'] ?? '').toString();
            }

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: primary.withOpacity(0.1),
                    child: Icon(Icons.person, size: 44, color: primary),
                  ),
                  const SizedBox(height: 16),
                  // 🛠️ 3. ป้องกันชื่อล้น
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // 🛠️ 3. ป้องกันอีเมลล้น
                  Text(
                    user.email ?? '-',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (phone.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      phone,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 20),

        // --- เมนู: แก้ไขข้อมูลส่วนตัว ---
        _buildMenuTile(
          context,
          icon: Icons.edit_outlined,
          title: 'แก้ไขข้อมูลส่วนตัว',
          subtitle: 'เปลี่ยนชื่อผู้ใช้และเบอร์โทรศัพท์',
          color: primary,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileEditPage(),
            ), // ชี้ไปหน้าดัมมี่
          ),
        ),
        const SizedBox(height: 12),

        // --- เมนู: ร้านที่บันทึกไว้ (ร้านโปรด) ---
        _buildMenuTile(
          context,
          icon: Icons.favorite_border,
          title: 'ร้านที่บันทึกไว้',
          subtitle: 'ดูร้านอาหารที่คุณกดหัวใจเก็บไว้',
          color: Colors.redAccent,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FavoritesPage(),
            ), // ชี้ไปหน้าดัมมี่
          ),
        ),
        const SizedBox(height: 12),

        // --- เมนู: เกี่ยวกับผู้จัดทำ ---
        _buildMenuTile(
          context,
          icon: Icons.groups_outlined,
          title: 'เกี่ยวกับผู้จัดทำ',
          subtitle: 'ข้อมูลทีมผู้พัฒนาแอปนี้',
          color: Colors.blueAccent,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TeamPage(),
            ), // ชี้ไปหน้าดัมมี่
          ),
        ),
        const SizedBox(height: 28),

        // --- ปุ่มออกจากระบบ ---
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('ยืนยันการออกจากระบบ'),
                    content: const Text('คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'ยกเลิก',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // ปิด Dialog
                          _logout();
                        },
                        child: const Text(
                          'ออกจากระบบ',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text(
              'ออกจากระบบ',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // กรณียังไม่ล็อกอิน
  // ==========================================
  Widget _buildLoggedOutBody(BuildContext context, Color primary) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: primary.withOpacity(0.1),
            child: Icon(Icons.person, size: 50, color: primary),
          ),
          const SizedBox(height: 24),
          const Text(
            'ยังไม่ได้เข้าสู่ระบบ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'เข้าสู่ระบบเพื่อจัดการโปรไฟล์และการจองของคุณ',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                  setState(() {});
                },
                icon: const Icon(Icons.login, color: Colors.white),
                label: const Text(
                  'เข้าสู่ระบบ / สมัครสมาชิก',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // การ์ดเมนูแบบใช้ซ้ำได้ (icon + title + subtitle + arrow)
  // ==========================================
  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🛠️ 3. ป้องกันชื่อเมนูล้น
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // 🛠️ 3. ป้องกันคำอธิบายเมนูล้น
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
