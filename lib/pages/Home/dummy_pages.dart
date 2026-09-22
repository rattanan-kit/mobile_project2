import 'package:flutter/material.dart';


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
