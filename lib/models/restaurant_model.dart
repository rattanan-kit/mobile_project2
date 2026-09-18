class RestaurantModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final int capacityPerSlot;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.capacityPerSlot,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json, String docId) {
    return RestaurantModel(
      id: docId,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      capacityPerSlot: json['capacityPerSlot'] ?? 0,
    );
  }
}
