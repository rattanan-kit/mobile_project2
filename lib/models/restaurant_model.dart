class RestaurantModel {
  final String id;
  final String name;
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
      // ดึงข้อมูลเป็น List ถ้าไม่มีให้เป็น List ว่าง
      images: List<String>.from(json['imageUrl'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      lat: (json['lat'] ?? 0.0).toDouble(),
      lng: (json['lng'] ?? 0.0).toDouble(),
      capacityPerSlot: json['capacityPerSlot'] ?? 0,
    );
  }
}
