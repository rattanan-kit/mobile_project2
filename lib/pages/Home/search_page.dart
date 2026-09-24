import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/restaurant_model.dart';
import '../Detail/restaurant_detail_page.dart';

class SearchPage extends StatefulWidget {
  final String? initialQuery;

  const SearchPage({super.key, this.initialQuery});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late String _searchQuery;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _searchQuery = (widget.initialQuery ?? '').toLowerCase();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ==========================================
  // 🛠️ พจนานุกรมคำพ้องความหมาย (Dictionary)
  // ==========================================
  List<String> _getSearchTerms(String query) {
    if (query.isEmpty) return [];

    // เริ่มต้นด้วยคำที่ผู้ใช้พิมพ์มา
    List<String> terms = [query];

    // กำหนดคำพ้องความหมาย
    Map<String, List<String>> dictionary = {
      'ญี่ปุ่น': ['japan', 'japanese'],
      'japan': ['ญี่ปุ่น', 'japanese'],
      'japanese': ['ญี่ปุ่น', 'japan'],
      'ไทย': ['thai'],
      'thai': ['ไทย'],
      'นานาชาติ': ['international'],
      'international': ['นานาชาติ'],
      'อิตาเลียน': ['italian', 'italy'],
      'italian': ['อิตาเลียน', 'italy'],
      'ฟิวชั่น': ['fusion'],
      'fusion': ['ฟิวชั่น'],
      'คาเฟ่': ['cafe', 'coffee', 'ร้านกาแฟ'],
      'cafe': ['คาเฟ่', 'ร้านกาแฟ'],
      'พิซซ่า': ['pizza'],
      'pizza': ['พิซซ่า'],
      'ปิ้งย่าง': ['grill', 'bbq', 'บาร์บีคิว'],
      'ชาบู': ['shabu', 'hotpot'],
    };

    // ถ้าคำค้นหามีใน Dictionary ให้ดึงคำพ้องความหมายมาต่อท้ายลิสต์
    if (dictionary.containsKey(query)) {
      terms.addAll(dictionary[query]!);
    }

    return terms;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: TextField(
          controller: _controller,
          autofocus:
              widget.initialQuery == null || widget.initialQuery!.isEmpty,
          decoration: InputDecoration(
            hintText: 'ค้นหาชื่อร้านอาหาร, ประเภท...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey[400]),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
        ),
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _controller.clear();
                });
              },
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('restaurants')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("ไม่มีข้อมูลร้านอาหาร"));
          }

          // 🛠️ 1. ดึงคำค้นหาทั้งหมด (รวมคำพ้องความหมาย) มาใช้งาน
          List<String> searchTerms = _getSearchTerms(_searchQuery);

          // 🛠️ 2. ระบบกรองข้อมูลด้วย List ของคำค้นหา
          final restaurants = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = (data['name'] ?? '').toString().toLowerCase();
            final desc = (data['description'] ?? '').toString().toLowerCase();

            List<String> tags = [];
            if (data['tags'] != null) {
              tags = List<String>.from(
                data['tags'],
              ).map((e) => e.toLowerCase()).toList();
            }

            // ถ้าช่องค้นหาว่าง ให้โชว์ร้านทั้งหมด
            if (searchTerms.isEmpty) return true;

            // เช็กว่า 'คำใดคำหนึ่ง' ใน searchTerms ไปตรงกับ ชื่อ, รายละเอียด หรือ Tag ไหม
            bool matchNameOrDesc = searchTerms.any(
              (term) => name.contains(term) || desc.contains(term),
            );
            bool matchTag = tags.any(
              (tag) => searchTerms.any((term) => tag.contains(term)),
            );

            return matchNameOrDesc || matchTag;
          }).toList();

          if (restaurants.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'ไม่พบร้านอาหารที่ค้นหา',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              var doc = restaurants[index];
              var data = doc.data() as Map<String, dynamic>;
              String id = doc.id;
              String name = data['name'] ?? 'ไม่มีชื่อ';
              String desc = data['description'] ?? '';

              List<String> allImages = [];
              if (data['imageUrl'] != null) {
                if (data['imageUrl'] is List) {
                  allImages = List<String>.from(data['imageUrl']);
                } else if (data['imageUrl'] is String) {
                  allImages = [data['imageUrl']];
                }
              }
              String coverImage = allImages.isNotEmpty ? allImages[0] : '';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: InkWell(
                  onTap: () {
                    final restaurantData = RestaurantModel(
                      id: id,
                      name: name,
                      description: desc,
                      lat: (data['lat'] ?? 13.0234).toDouble(),
                      lng: (data['lng'] ?? 99.9912).toDouble(),
                      address: data['address'] ?? 'ไม่ระบุที่อยู่',
                      phoneNumber: data['phoneNumber'] ?? '-',
                      images: allImages,
                      tags: data['tags'] != null
                          ? List<String>.from(data['tags'])
                          : ['แนะนำ'],
                      rating: (data['rating'] ?? 4.5).toDouble(),
                      reviewCount: data['reviewCount'] ?? 0,
                      capacityPerSlot: data['capacityPerSlot'] ?? 0,
                      socialLinks: data['socialLinks'] ?? {},
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RestaurantDetailPage(restaurant: restaurantData),
                      ),
                    );
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: coverImage.isNotEmpty
                            ? Image.network(coverImage, fit: BoxFit.cover)
                            : Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.restaurant,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                desc,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
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
