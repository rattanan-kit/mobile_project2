import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  // ฟังก์ชันสำหรับอัปเดตสถานะใน Firestore
  Future<void> _updateBookingStatus(
    BuildContext context,
    String docId,
    String newStatus,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(docId).update(
        {'status': newStatus},
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == 'cancelled' ? 'ยกเลิกการจองแล้ว' : 'เช็คอินสำเร็จ!',
            ),
            backgroundColor: newStatus == 'cancelled'
                ? Colors.red
                : Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ==========================================
  // ฟังก์ชันแสดง Pop-up Dialog สำหรับเขียนรีวิว
  // ==========================================
  void _showReviewDialog(
    BuildContext context,
    Map<String, dynamic> bookingData,
    String bookingId,
  ) {
    int selectedRating = 5; // ค่าเริ่มต้น 5 ดาว
    final commentController = TextEditingController();
    final restaurantId = bookingData['restaurantId'] ?? '';
    final restaurantName = bookingData['restaurantName'] ?? 'ร้านอาหาร';
    final user = FirebaseAuth.instance.currentUser;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Column(
                children: [
                  const Text(
                    'ให้คะแนน & รีวิว',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurantName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),

                    // --- ดาว 5 ดวง สามารถกดเลือกได้ ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starValue = index + 1;
                        return IconButton(
                          iconSize: 32,
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            starValue <= selectedRating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            setState(() {
                              selectedRating = starValue;
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 16),

                    // --- ช่องกรอกความคิดเห็น ---
                    TextField(
                      controller: commentController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'แชร์ประสบการณ์ความประทับใจของคุณที่นี่...',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'ยกเลิก',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (user == null) return;

                          try {
                            // 1. บันทึกรีวิวไปยังคอลเลกชัน reviews ใน Firestore
                            await FirebaseFirestore.instance
                                .collection('reviews')
                                .add({
                                  'bookingId': bookingId,
                                  'restaurantId': restaurantId,
                                  'restaurantName': restaurantName,
                                  'userId': user.uid,
                                  'userName': user.displayName ?? 'ผู้ใช้งาน',
                                  'rating': selectedRating,
                                  'comment': commentController.text.trim(),
                                  'createdAt': FieldValue.serverTimestamp(),
                                });

                            // 2. อัปเดตการจองว่าถูกรีวิวแล้ว
                            await FirebaseFirestore.instance
                                .collection('bookings')
                                .doc(bookingId)
                                .update({'isReviewed': true});

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'ส่งรีวิวเรียบร้อยแล้ว ขอบคุณครับ!',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('เกิดข้อผิดพลาด: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'ส่งรีวิว',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('การจองของฉัน'),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'คุณยังไม่ได้เข้าสู่ระบบ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'เข้าสู่ระบบเพื่อดูประวัติการจองของคุณ',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('เข้าสู่ระบบ'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'การจองของฉัน',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'ยังไม่มีประวัติการจอง',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          var bookings = snapshot.data!.docs.toList();
          bookings.sort((a, b) {
            var dateA =
                (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
            var dateB =
                (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
            if (dateA == null || dateB == null) return 0;
            return dateB.compareTo(dateA);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              var booking = bookings[index];
              var data = booking.data() as Map<String, dynamic>;
              String docId = booking.id;
              String status = data['status'] ?? 'confirmed';
              bool isReviewed = data['isReviewed'] ?? false;

              Color statusColor;
              String statusText;
              if (status == 'completed') {
                statusColor = Colors.green;
                statusText = 'ทานเสร็จแล้ว';
              } else if (status == 'cancelled') {
                statusColor = Colors.red;
                statusText = 'ยกเลิกแล้ว';
              } else {
                statusColor = Colors.orange;
                statusText = 'รอยืนยัน (กำลังจะไป)';
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              data['restaurantName'] ?? 'ไม่ทราบชื่อร้าน',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'วันที่: ${data['date']}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'เวลา: ${data['time']}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.people,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${data['guestCount']} ท่าน',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),

                      // ปุ่มควบคุมสำหรับสถานะ confirmed
                      if (status == 'confirmed') ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('ยกเลิกการจอง?'),
                                      content: const Text(
                                        'คุณแน่ใจหรือไม่ว่าต้องการยกเลิกการจองนี้?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('ไม่'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(ctx);
                                            _updateBookingStatus(
                                              context,
                                              docId,
                                              'cancelled',
                                            );
                                          },
                                          child: const Text(
                                            'ยืนยัน',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                ),
                                child: const Text('ยกเลิกจอง'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _updateBookingStatus(
                                  context,
                                  docId,
                                  'completed',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Demo Check-in'),
                              ),
                            ),
                          ],
                        ),
                      ],

                      // ปุ่มกดเปิด Pop-up รีวิวเมื่อสถานะเป็น completed
                      if (status == 'completed') ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isReviewed
                                ? null // ถ้าเคยรีวิวแล้วจะกดไม่ได้
                                : () => _showReviewDialog(context, data, docId),
                            icon: Icon(
                              Icons.star_rounded,
                              color: isReviewed ? Colors.grey : Colors.amber,
                            ),
                            label: Text(
                              isReviewed
                                  ? 'รีวิวเรียบร้อยแล้ว'
                                  : 'รีวิวร้านอาหาร',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isReviewed
                                  ? Colors.grey[300]
                                  : Theme.of(context).primaryColor,
                              foregroundColor: isReviewed
                                  ? Colors.grey[600]
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
