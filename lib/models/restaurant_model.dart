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
    );
  }
}
