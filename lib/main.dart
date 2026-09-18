import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// Import หน้าจอที่เราสร้างไฟล์เปล่าๆ ไว้ (เดี๋ยวเราไปเติมโค้ดทีหลัง)
import 'pages/login_page.dart';
import 'pages/test_booking_page.dart';

void main() async {
  // คำสั่งบังคับให้ Flutter รอการเชื่อมต่อ Firebase ให้เสร็จก่อนเปิดแอป
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Restaurant Reservation PoC',
      theme: ThemeData(primarySwatch: Colors.blue),
      // ใช้ StreamBuilder เช็กว่า "ล็อกอินหรือยัง?"
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // ถ้ามีข้อมูล User = ล็อกอินแล้ว ให้ไปหน้าเทสจองโต๊ะ
          if (snapshot.hasData) {
            return const TestBookingPage();
          }
          // ถ้าไม่มีข้อมูล = ยังไม่ล็อกอิน ให้ไปหน้า Login
          return const LoginPage();
        },
      ),
    );
  }
}
