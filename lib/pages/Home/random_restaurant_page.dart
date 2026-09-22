import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/restaurant_model.dart';
import '../restaurant_detail_page.dart';

class RandomRestaurantPage extends StatefulWidget {
  const RandomRestaurantPage({super.key});

  @override
  State<RandomRestaurantPage> createState() => _RandomRestaurantPageState();
}

class _RandomRestaurantPageState extends State<RandomRestaurantPage>
    with SingleTickerProviderStateMixin {
  final List<String> _availableTags = [
    'ทั้งหมด',
    'thai',
    'coffee',
    'local',
    'street food',
    'noodle',
    'michelin',
    'isan',
  ];

  String _selectedTag = 'ทั้งหมด';
  bool _isSpinning = false;
  RestaurantModel? _resultRestaurant;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _randomizeRestaurant() async {
    setState(() {
      _isSpinning = true;
      _resultRestaurant = null;
    });

    _animController.repeat(period: const Duration(milliseconds: 200));

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('restaurants')
          .get();

      List<RestaurantModel> matchedList = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        List<String> tags = data['tags'] != null
            ? List<String>.from(data['tags'])
            : [];

        if (_selectedTag == 'ทั้งหมด' || tags.contains(_selectedTag)) {
          List<String> images = [];
          if (data['imageUrl'] != null) {
            if (data['imageUrl'] is List) {
              images = List<String>.from(data['imageUrl']);
            } else if (data['imageUrl'] is String) {
              images = [data['imageUrl']];
            }
          }

          matchedList.add(
            RestaurantModel(
              id: doc.id,
              name: data['name'] ?? 'ไม่มีชื่อร้าน',
              description: data['description'] ?? '',
              images: images,
              tags: tags,
              rating: (data['rating'] ?? 4.5).toDouble(),
              reviewCount: data['reviewCount'] ?? 0,
              lat: (data['lat'] ?? 13.0).toDouble(),
              lng: (data['lng'] ?? 99.0).toDouble(),
              capacityPerSlot: data['capacityPerSlot'] ?? 0,
              address: data['address'] ?? 'ไม่ระบุที่อยู่',
              phoneNumber: data['phoneNumber'] ?? '-',
              socialLinks: data['socialLinks'] ?? {},
            ),
          );
        }
      }

      await Future.delayed(const Duration(milliseconds: 1500));
      _animController.stop();

      setState(() {
        _isSpinning = false;
        if (matchedList.isNotEmpty) {
          final randomIndex = Random().nextInt(matchedList.length);
          _resultRestaurant = matchedList[randomIndex];
        } else {
          _resultRestaurant = null;
        }
      });

      if (matchedList.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ไม่พบร้านอาหารตรงกับแท็ก "$_selectedTag"'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _animController.stop();
      setState(() => _isSpinning = false);
      print('Error randomizing restaurant: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'วันนี้กินอะไรดี? 🎲',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'อยากกินแนวไหนเป็นพิเศษไหม?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableTags.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final tag = _availableTags[index];
                    final isSelected = _selectedTag == tag;
                    return ChoiceChip(
                      label: Text(tag),
                      selected: isSelected,
                      selectedColor: Theme.of(context).colorScheme.primary,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300,
                        ),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedTag = tag);
                        }
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // 🛠️ จุดที่แก้ไข: ครอบด้วย SingleChildScrollView ป้องกันหน้าจอเล็กแล้วการ์ดล้นขอบล่าง
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: _isSpinning
                        ? _buildSpinningView()
                        : _resultRestaurant != null
                        ? _buildResultCard(context, _resultRestaurant!)
                        : _buildInitialPlaceholder(),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isSpinning ? null : _randomizeRestaurant,
                  icon: RotationTransition(
                    turns: Tween(begin: 0.0, end: 1.0).animate(_animController),
                    child: const Icon(Icons.casino, size: 28),
                  ),
                  label: Text(
                    _resultRestaurant == null
                        ? 'สุ่มร้านอาหารเลย!'
                        : 'สุ่มใหม่อีกรอบ',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.restaurant_menu_rounded,
            size: 70,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'เลือกประเภทแล้วกดสุ่มได้เลย!',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'ระบบจะช่วยเลือกมื้อเด็ดที่คุณต้องชอบให้อย่างแม่นยำ',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSpinningView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: Tween(begin: 0.85, end: 1.15).animate(
            CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.ramen_dining_rounded,
              size: 80,
              color: Colors.orange,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'กำลังสุ่มเมนูเด็ดให้คุณ...',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(BuildContext context, RestaurantModel item) {
    String coverImg = item.images.isNotEmpty ? item.images[0] : '';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: coverImg.isNotEmpty
                      ? Image.network(coverImg, fit: BoxFit.cover)
                      : Container(color: Colors.grey[200]),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${item.rating}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing:
                      6, // 🛠️ เพิ่ม runSpacing กัน Tag ล้นบรรทัดแล้วเบียดกัน
                  children: item.tags
                      .map(
                        (t) => Chip(
                          label: Text('#$t'),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          labelStyle: const TextStyle(
                            fontSize: 11,
                            color: Colors.deepOrange,
                          ),
                          backgroundColor: Colors.deepOrange.shade50,
                          side: BorderSide.none,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RestaurantDetailPage(restaurant: item),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'ดูรายละเอียดร้าน & จองโต๊ะ',
                      style: TextStyle(fontWeight: FontWeight.bold),
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
