import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // ฟังก์ชันออกจากระบบ
  Future<void> _logout(BuildContext context) async {
    // 1. สั่ง Firebase ให้ออกจากระบบ
    await FirebaseAuth.instance.signOut();

    if (context.mounted) {
      // 2. เคลียร์ Navigation Stack ทั้งหมด และเด้งกลับไปหน้า Login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ดึงข้อมูล User ปัจจุบัน (เพื่อให้รู้ว่าอีเมลอะไรล็อกอินอยู่)
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
            // ไอคอนรูปโปรไฟล์แบบง่ายๆ
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

            // โชว์อีเมลที่ใช้ล็อกอิน (หรือข้อความแจ้งเตือนถ้าหาไม่เจอ)
            Text(
              user?.email ?? 'ไม่พบข้อมูลอีเมล',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'User ID: ${user?.uid.substring(0, 8) ?? '...'}', // โชว์ UID ย่อๆ
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),

            const SizedBox(height: 40),

            // ปุ่มออกจากระบบ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // โชว์กล่องยืนยันก่อนออกจากระบบ (กันผู้ใช้กดผิด)
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
                              onPressed: () =>
                                  Navigator.pop(context), // ปิดกล่องข้อความ
                              child: const Text(
                                'ยกเลิก',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // ปิดกล่องข้อความก่อน
                                _logout(context); // เรียกฟังก์ชัน Logout
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
          ],
        ),
      ),
    );
  }
}
