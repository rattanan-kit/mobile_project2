import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// TODO: อย่าลืมแก้ path import หน้า Login ของคุณให้ถูกต้อง
import '../pages/login_page.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==========================================
  // 1. ตัวช่วยตรวจสอบสถานะ (Auth Guard)
  // ==========================================

  // เช็กว่ามี User ล็อกอินอยู่หรือไม่
  bool get isLoggedIn {
    return _auth.currentUser != null;
  }

  // ฟังก์ชันพระเอก: ดักเช็กก่อนทำรายการสำคัญ
  void requireAuth(BuildContext context, VoidCallback onAuthenticated) {
    if (isLoggedIn) {
      // ถ้าล็อกอินแล้ว ให้ทำคำสั่งที่ส่งเข้ามาได้เลย
      onAuthenticated();
    } else {
      // ถ้ายังไม่ล็อกอิน ให้โชว์เตือนและพาไปหน้า Login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาล็อกอินเพื่อใช้งานฟีเจอร์นี้'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  // ==========================================
  // 2. ระบบจัดการบัญชี (Register, Login, Logout)
  // ==========================================

  // ฟังก์ชันสมัครสมาชิก
  Future<User?> register(
    String email,
    String password,
    String username,
    String phone,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'username': username,
          'phone': phone,
          'favorites': [],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } catch (e) {
      print("Error Register: $e");
      return null;
    }
  }

  // ฟังก์ชันล็อกอิน
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print("Error Login: $e");
      return null;
    }
  }

  // ฟังก์ชันออกจากระบบ
  Future<void> logout() async {
    await _auth.signOut();
  }
}
