import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class TestBookingPage extends StatelessWidget {
  const TestBookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ดึงอีเมลของคนที่ล็อกอินอยู่มาแสดง
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? 'No Email';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Booking Flow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AuthService()
                  .logout(); // พอกดปุ่มนี้ มันจะเด้งกลับไปหน้า Login เอง
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'ยินดีต้อนรับ: $userEmail\n\n(เดี๋ยวเราจะเอาข้อมูลร้านมาดึงแสดงที่นี่)',
        ),
      ),
    );
  }
}
