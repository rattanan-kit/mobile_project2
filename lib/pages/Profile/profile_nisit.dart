import 'package:flutter/material.dart';

class TeamPage extends StatelessWidget {
  const TeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'เกี่ยวกับผู้จัดทำ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- ไอคอนโลโก้ด้านบน ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.code,
                size: 60,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'ทีมผู้พัฒนา',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'รายชื่อผู้จัดทำแอปพลิเคชันจองโต๊ะร้านอาหาร',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // --- ส่วนของการ์ดรายชื่อสมาชิก ---
            // 📝 เพิ่มอีเมลเข้าไปตรงนี้ได้เลย
            _buildMemberCard(
              context,
              name: 'รัฐนันท์ กิติวงษ์ไพศาล',
              studentId: 'รหัสนิสิต: 6721652587',
              email: 'rattnan.kit@ku.th.com',
              role: 'Developer / UI Design / Database',
            ),
            const SizedBox(height: 16),

            _buildMemberCard(
              context,
              name: 'อภิภัทร บุญมาก',
              studentId: '672165281',
              email: 'aom@gmail.com',
              role: 'Frontend Developer / UI Design / Testing',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // Widget สำหรับสร้างการ์ดรายชื่อแบบใช้ซ้ำได้
  // ==========================================
  Widget _buildMemberCard(
    BuildContext context, {
    required String name,
    required String studentId,
    required String email, // <-- รับค่าอีเมลเพิ่มตรงนี้
    required String role,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
            child: Icon(
              Icons.person,
              color: Theme.of(context).primaryColor,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          // ใช้ Expanded ป้องกันกรณีข้อมูลยาวเกินไปจนดันขอบจอ
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  studentId,
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    role,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
