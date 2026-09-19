class RestaurantModel {
  final String id;
  final String name;
  final String description; // <-- เพิ่มตรงนี้
  final List<String> images;
  final List<String> tags;
  final double rating;
  final int reviewCount;
  final double lat;
  final double lng;
  final int capacityPerSlot;

  // == เพิ่มฟิลด์ใหม่สำหรับที่อยู่และเบอร์โทรศัพท์ == 
  final String address;
  final String phoneNumber;
  final Map<String, dynamic> socialLinks;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.description, // <-- เพิ่มตรงนี้
    required this.images,
    required this.tags,
    required this.rating,
    required this.reviewCount,
    required this.lat,
    required this.lng,
    required this.capacityPerSlot,

    // == เพิ่มฟิลด์ใหม่สำหรับที่อยู่และเบอร์โทรศัพท์ ==
    required this.address, 
    required this.phoneNumber, 
    required this.socialLinks,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json, String id) {
    return RestaurantModel(
      id: id,
      name: json['name'] ?? 'ไม่มีชื่อร้าน',
      description: json['description'] ?? '', // <-- เพิ่มดึงข้อมูลตรงนี้
      images: List<String>.from(
        json['imageUrl'] ?? [],
      ), // ใช้ imageUrl ตามที่คุณตั้งไว้
      tags: List<String>.from(json['tags'] ?? []),
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      lat: (json['lat'] ?? 0.0).toDouble(),
      lng: (json['lng'] ?? 0.0).toDouble(),
      capacityPerSlot: json['capacityPerSlot'] ?? 0,

      // --- ดึงข้อมูลใหม่จาก Firebase พร้อมใส่ค่า Default กันแอปพัง (ถ้า Database เก่ายังไม่มีข้อมูล) ---
      address: json['address'] ?? 'ไม่ระบุที่อยู่',
      phoneNumber: json['phoneNumber'] ?? 'ไม่มีเบอร์ติดต่อ',
      socialLinks: json['socialLinks'] ?? {},
    );
  }
}
