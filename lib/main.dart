import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // คอมเมนต์ไว้ก่อนเพราะยังไม่ได้ใช้เช็กสถานะหน้าแรก
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';

// import 'pages/login_page.dart'; // คอมเมนต์ไว้ก่อนชั่วคราว
import 'pages/main_screen.dart';

void main() async {
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
      title: 'Restaurant Booking',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF5722), // สีส้ม
          primary: const Color(0xFFFF5722),
          background: const Color(0xFFF8F9FA),
        ),
        textTheme: GoogleFonts.promptTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      // --- เปลี่ยนตรงนี้ให้วิ่งไปหน้า MainScreen ทันที ---
      home: const MainScreen(),
    );
  }
}
