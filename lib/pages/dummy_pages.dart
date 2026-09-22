import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ค้นหาร้านอาหาร')),
      body: const Center(child: Text('หน้าจอสำหรับค้นหาร้าน')),
    );
  }
}

class ArticlePage extends StatelessWidget {
  const ArticlePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('บทความแนะนำ')),
      body: const Center(child: Text('หน้าจออ่านบทความรีวิวร้านอาหาร')),
    );
  }
}

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ร้านที่บันทึกไว้')),
      body: const Center(child: Text('หน้าจอแสดงร้านโปรด')),
    );
  }
}

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
