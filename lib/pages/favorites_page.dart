import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/restaurant_model.dart';
import '../services/user_service.dart'; 

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('ร้านโปรด')),
        body: const Center(child: Text('กรุณาล็อกอินเพื่อดูร้านโปรด')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('ร้านโปรดของฉัน 💖')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<dynamic> favorites = [];
          if (userSnapshot.hasData && userSnapshot.data!.exists) {
            try {
              favorites = userSnapshot.data!.get('favorites') ?? [];
            } catch (e) {
              favorites = [];
            }
          }

          if (favorites.isEmpty) {
            return const Center(
              child: Text('คุณยังไม่มีร้านโปรดเลย ลองไปกดหัวใจดูสิ!'),
            );
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('restaurants')
                .where(FieldPath.documentId, whereIn: favorites)
                .snapshots(),
            builder: (context, restSnapshot) {
              if (restSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final restaurants = restSnapshot.data?.docs ?? [];

              return ListView.builder(
                itemCount: restaurants.length,
                itemBuilder: (context, index) {
                  final doc = restaurants[index];
                  final restaurant = RestaurantModel.fromJson(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  );

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: restaurant.images.isNotEmpty
                          ? Image.network(
                              restaurant.images[0],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (c, o, s) =>
                                  const Icon(Icons.restaurant, size: 50),
                            )
                          : const Icon(Icons.restaurant, size: 50),
                      title: Text(restaurant.name),
                      trailing: IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () {
                          // แก้ไขให้มาเรียก UserService ตรงนี้
                          UserService().toggleFavorite(restaurant.id);
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
