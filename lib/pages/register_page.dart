import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // เพิ่ม Controller สำหรับ Username และ Phone
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();

  final AuthService _authService = AuthService();

  void _handleRegister() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final username = _usernameController.text.trim();
    final phone = _phoneController.text.trim();

    // ดักไว้ก่อน เผื่อกรอกข้อมูลไม่ครบ
    if (email.isEmpty ||
        password.isEmpty ||
        username.isEmpty ||
        phone.isEmpty) {
      print('❌ กรุณากรอกข้อมูลให้ครบทุกช่อง');
      return;
    }

    // เรียกใช้ฟังก์ชัน register ตัวใหม่ที่เราเพิ่งเขียนไป
    final user = await _authService.register(email, password, username, phone);

    if (user != null) {
      print('✅ สมัครสมาชิกสำเร็จ! (UID: ${user.uid})');
      print('ลองไปเช็กที่ Firestore Database ดูสิ!');
      // ถ้าทำแอปจริง ตรงนี้จะสั่งเด้งกลับไปหน้า Home
    } else {
      print('❌ สมัครไม่สำเร็จ ลองเช็กอีเมลหรือรหัสผ่านดู');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'ชื่อผู้ใช้งาน (Username)',
              ),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'เบอร์โทรศัพท์'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'อีเมล'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'รหัสผ่าน'),
              obscureText: true, // ซ่อนรหัสผ่านเป็นจุดๆ
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleRegister,
              child: const Text('สมัครสมาชิก'),
            ),
          ],
        ),
      ),
    );
  }
}
