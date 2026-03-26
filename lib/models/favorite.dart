import 'dart:convert';

class Favorite {
  final String productName;
  final int productPrice;
  final String category;
  final List<String> image;
  final String vendorId;
  final int productQuantity;
  final int quantity;
  final String productId;
  final String description;
  final String fullName;
  final double averageRating;
  final int totalRatings;

  Favorite({
    required this.productName,
    required this.productPrice,
    required this.category,
    required this.image,
    required this.vendorId,
    required this.productQuantity,
    required this.quantity,
    required this.productId,
    required this.description,
    required this.fullName,
    this.averageRating = 0.0,
    this.totalRatings = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'productPrice': productPrice,
      'category': category,
      'image': image,
      'vendorId': vendorId,
      'productQuantity': productQuantity,
      'quantity': quantity,
      'productId': productId,
      'description': description,
      'fullName': fullName,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
    };
  }

  String toJson() => json.encode(toMap());

  factory Favorite.fromMap(Map<String, dynamic> map) {
    return Favorite(
      productName: map['productName'],
      productPrice: map['productPrice'],
      category: map['category'],
      image: List<String>.from(map['image']),
      vendorId: map['vendorId'],
      productQuantity: map['productQuantity'],
      quantity: map['quantity'],
      productId: map['productId'],
      description: map['description'],
      fullName: map['fullName'],
      averageRating: map['averageRating'] != null
          ? (map['averageRating'] is int
              ? (map['averageRating'] as int).toDouble()
              : map['averageRating'] as double)
          : 0.0,
      totalRatings: map['totalRatings'] ?? 0,
    );
  }

  factory Favorite.fromJson(String source) =>
      Favorite.fromMap(json.decode(source));
}
