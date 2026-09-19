import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart'; // เพิ่ม Google Fonts
import 'firebase_options.dart';

import 'pages/login_page.dart';
import 'pages/main_screen.dart'; // ไฟล์ใหม่ท

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
      // --- ใส่ Theme หลักของตรงนี้ ---
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF5722), // สีส้ม
          primary: const Color(0xFFFF5722),
          background: const Color(0xFFF8F9FA),
        ),
        textTheme: GoogleFonts.promptTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      // -----------------------------
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // ถ้าล็อกอินแล้ว ไปหน้า MainScreen เลย
          if (snapshot.hasData) {
            return const MainScreen();
          }
          // ถ้ายังไม่ล็อกอิน ไปหน้า LoginPage
          return const LoginPage();
        },
      ),
    );
  }
}
