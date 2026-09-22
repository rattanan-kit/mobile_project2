import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // ฟังก์ชันออกจากระบบแบบใหม่ (ไม่เตะข้ามหน้าแล้ว แค่รีเฟรชตัวเอง)
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    setState(() {}); // สั่งให้รีเฟรชหน้าจอ เพื่อซ่อนปุ่ม Logout
  }

  @override
  Widget build(BuildContext context) {
    // ดึงสถานะปัจจุบันว่าล็อกอินอยู่หรือไม่ (ถ้ายังไม่ล็อกอิน user จะมีค่าเป็น null)
    final user = FirebaseAuth.instance.currentUser;

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 50,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),

            // ==========================================
            // เช็กเงื่อนไข: ถ้าล็อกอินแล้ว (user != null)
            // ==========================================
            if (user != null) ...[
              Text(
                user.email ?? 'ไม่พบข้อมูลอีเมล',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'User ID: ${user.uid.substring(0, 8)}...',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),

              // ปุ่ม "ออกจากระบบ"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('ยืนยันการออกจากระบบ'),
                            content: const Text(
                              'คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบ?',
                            ),
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
                                  _logout(); // เรียกฟังก์ชัน Logout
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
              ),
            ]
            // ==========================================
            // เช็กเงื่อนไข: ถ้ายังไม่ล็อกอิน (user == null)
            // ==========================================
            else ...[
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

              // ปุ่ม "เข้าสู่ระบบ"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // รอผู้ใช้กลับมาจากหน้า Login
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                      // พอกลับมาถึงหน้านี้ สั่งรีเฟรชหน้าจอ 1 รอบเพื่อให้ปุ่ม Logout โผล่ขึ้นมา
                      setState(() {});
                    },
                    icon: const Icon(Icons.login, color: Colors.white),
                    label: const Text(
                      'เข้าสู่ระบบ / สมัครสมาชิก',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
