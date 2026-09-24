/**
==============================================================================
หน้าที่: แสดงรายละเอียดของร้านอาหารที่ถูกส่งต่อมาจากหน้า Home

จุดเด่นและสถาปัตยกรรมสำคัญในหน้านี้:
1. UI Parallax Effect: ใช้ CustomScrollView + SliverAppBar รูปปกยืดหดได้
2. Deep Linking (url_launcher): เปิดลิงก์ Facebook, IG, LINE เด้งเข้าแอปจริง
3. Map Rendering: ปักหมุดแผนที่ OpenStreetMap 
4. Real-time Reviews: ใช้ StreamBuilder ฟังการเปลี่ยนแปลงคอมเมนต์รีวิวจาก Firestore
5. Route Protection: บังคับผ่าน AuthService เช็กล็อกอินก่อนเปิดหน้าต่างจองโต๊ะ
==============================================================================
 */

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart'; 

import '../../models/restaurant_model.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import 'widgets/menu_carousel.dart';
import 'widgets/booking_bottom_sheet.dart';

class RestaurantDetailPage extends StatelessWidget {
  final RestaurantModel restaurant;

  const RestaurantDetailPage({super.key, required this.restaurant});

  // ฟังก์ชันสำหรับเปิด URL
Future<void> _launchSocialUrl(BuildContext context, String urlString) async {
    if (urlString.trim().isEmpty) return;

    String formattedUrl = urlString.trim();
    if (!formattedUrl.startsWith('http://') &&
        !formattedUrl.startsWith('https://')) {
      formattedUrl = 'https://$formattedUrl';
    }

    final Uri url = Uri.parse(formattedUrl);

    try {
      // ลองเปิดแบบเด้งข้ามแอปก่อน
      bool launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      // ถ้าเปิดแอปตรงไม่ติด ให้เปิดผ่านเบราว์เซอร์ในเครื่องแทน
      if (!launched) {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      // กรณีที่ canLaunchUrl หรือ launchUrl มีปัญหา ให้ลองโหมดเปิดเว็บทั่วไปอีกรอบ
      try {
        await launchUrl(url, mode: LaunchMode.inAppBrowserView);
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ไม่สามารถเปิดลิงก์ได้')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String storefrontImage = restaurant.images.isNotEmpty // รูปปก
        ? restaurant.images[0]
        : '';
    final List<String> menuImages = restaurant.images.length > 1 // รูปที่เหลือยกเว้นรูปแรก
        ? restaurant.images.skip(1).toList()
        : [];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280.0,
            pinned: true,
            backgroundColor: Theme.of(context).primaryColor,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  storefrontImage.isNotEmpty
                      ? Image.network(storefrontImage, fit: BoxFit.cover)
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.restaurant, size: 80),
                        ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black38,
                          Colors.transparent,
                          Colors.black45,
                        ],
                        stops: [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [_FavoriteButton(restaurantId: restaurant.id)],
          ),
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0.0, -20.0, 0.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                restaurant.name,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${restaurant.rating}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    ' (${restaurant.reviewCount})',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: restaurant.tags
                              .map(
                                (tag) => Chip(
                                  label: Text(
                                    tag.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  backgroundColor: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1),
                                  side: BorderSide.none,
                                  padding: EdgeInsets.zero,
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildFacilityIcon(
                              context,
                              Icons.directions_car,
                              'ที่จอดรถ',
                            ),
                            _buildFacilityIcon(
                              context,
                              Icons.wifi,
                              'ฟรี Wi-Fi',
                            ),
                            _buildFacilityIcon(
                              context,
                              Icons.credit_card,
                              'รับบัตรเครดิต',
                            ),
                            _buildFacilityIcon(
                              context,
                              Icons.ac_unit,
                              'ห้องแอร์',
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Divider(),
                        ),
                        const Text(
                          'เกี่ยวกับร้าน',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          restaurant.description,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (menuImages.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'เมนูแนะนำ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    MenuCarousel(images: menuImages),
                    const SizedBox(height: 30),
                  ],

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'สถานที่ตั้ง',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            height: 200,
                            width: double.infinity,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: FlutterMap(
                                options: MapOptions(
                                  initialCenter: LatLng(
                                    restaurant.lat,
                                    restaurant.lng,
                                  ),
                                  initialZoom: 15.0,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName:
                                        'com.rattnan.foodbookingapp',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: LatLng(
                                          restaurant.lat,
                                          restaurant.lng,
                                        ),
                                        width: 80,
                                        height: 80,
                                        child: const Icon(
                                          Icons.location_on,
                                          color: Colors.red,
                                          size: 45,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                restaurant.address,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.phone,
                              color: Colors.green,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                restaurant.phoneNumber,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        // ==========================================
                        // ส่วนแสดง Social Links (ดึงจาก restaurant.socialLinks)
                        // ==========================================
                        if (restaurant.socialLinks.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'ช่องทางการติดต่อออนไลน์',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: restaurant.socialLinks.entries.map((
                              entry,
                            ) {
                              final platform = entry.key.toLowerCase();
                              final link = entry.value.toString();

                              return _buildSocialButton(
                                context,
                                platform: platform,
                                url: link,
                              );
                            }).toList(),
                          ),
                        ],

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Divider(),
                        ),
                      ],
                    ),
                  ),

                  // ==========================================
                  // ส่วนแสดงคอมเมนต์รีวิวจากผู้ใช้จริง (StreamBuilder)
                  // ==========================================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'รีวิวจากลูกค้า',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text('ดูทั้งหมด'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('reviews')
                              .where('restaurantId', isEqualTo: restaurant.id)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: Text(
                                    'ยังไม่มีรีวิวสำหรับร้านนี้\nมาเป็นคนแรกที่รีวิวสิ!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              );
                            }

                            var reviews = snapshot.data!.docs.toList();
                            reviews.sort((a, b) {
                              var dateA =
                                  (a.data()
                                          as Map<String, dynamic>)['createdAt']
                                      as Timestamp?;
                              var dateB =
                                  (b.data()
                                          as Map<String, dynamic>)['createdAt']
                                      as Timestamp?;
                              if (dateA == null || dateB == null) return 0;
                              return dateB.compareTo(dateA);
                            });

                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: reviews.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final reviewData =
                                    reviews[index].data()
                                        as Map<String, dynamic>;
                                final userName =
                                    reviewData['userName'] ?? 'ผู้ใช้งาน';
                                final rating = (reviewData['rating'] ?? 5)
                                    .toInt();
                                final comment = reviewData['comment'] ?? '';

                                final colors = [
                                  Colors.blue[200]!,
                                  Colors.pink[200]!,
                                  Colors.orange[200]!,
                                  Colors.green[200]!,
                                ];
                                final avatarColor =
                                    colors[index % colors.length];

                                return _buildCommentItem(
                                  name: userName,
                                  time: 'รีวิวใหม่',
                                  rating: rating,
                                  comment: comment,
                                  avatarColor: avatarColor,
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 12.0,
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              onPressed: () {
                AuthService().requireAuth(context, () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) =>
                        BookingBottomSheetWidget(restaurant: restaurant),
                  );
                });
              },
              child: const Text(
                'จองโต๊ะเลย',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper สร้างปุ่ม Social Media แต่ละแพลตฟอร์ม
  Widget _buildSocialButton(
    BuildContext context, {
    required String platform,
    required String url,
  }) {
    IconData iconData = Icons.language;
    Color buttonColor = Colors.blueGrey;
    String label = platform.toUpperCase();

    if (platform.contains('facebook')) {
      iconData = Icons.facebook;
      buttonColor = const Color(0xFF1877F2);
      label = 'Facebook';
    } else if (platform.contains('instagram') || platform.contains('ig')) {
      iconData = Icons.camera_alt;
      buttonColor = const Color(0xFFE4405F);
      label = 'Instagram';
    } else if (platform.contains('line')) {
      iconData = Icons.chat;
      buttonColor = const Color(0xFF06C755);
      label = 'LINE';
    } else if (platform.contains('website') || platform.contains('web')) {
      iconData = Icons.public;
      buttonColor = Colors.teal;
      label = 'Website';
    }

    return ActionChip(
      avatar: Icon(iconData, size: 18, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: buttonColor,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () => _launchSocialUrl(context, url),
    );
  }

  Widget _buildFacilityIcon(BuildContext context, IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildCommentItem({
    required String name,
    required String time,
    required int rating,
    required String comment,
    required Color avatarColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: avatarColor,
                radius: 20,
                child: Text(
                  name.isNotEmpty ? name[0] : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      time,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              comment,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final String restaurantId;

  const _FavoriteButton({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: StreamBuilder<bool>(
        stream: UserService().isFavoriteStream(restaurantId),
        builder: (context, snapshot) {
          final isFavorite = snapshot.data ?? false;

          return IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: () {
              AuthService().requireAuth(context, () {
                UserService().toggleFavorite(restaurantId);
              });
            },
          );
        },
      ),
    );
  }
}
