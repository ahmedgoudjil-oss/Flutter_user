import 'dart:convert';

class Cart {
  final String productName;
  final int productPrice;
  final String category;
  final List<String> image;
  final String vendorId;
  final int productQuantity;
  int quantity; // هذا متغير يمكن تغييره أثناء الاستخدام
  final String productId;
  final String description;
  final String fullName;

  Cart({
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
  });

  // تحويل إلى Map
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
    };
  }

  // تحويل من Map
  factory Cart.fromMap(Map<String, dynamic> map) {
    return Cart(
      productName: map['productName'],
      productPrice: map['productPrice'],
      category: map['category'],
      image: List<String>.from(map['image'] ?? []),
      vendorId: map['vendorId'],
      productQuantity: map['productQuantity'],
      quantity: map['quantity'],
      productId: map['productId'],
      description: map['description'],
      fullName: map['fullName'],
    );
  }

  // تحويل إلى JSON
  String toJson() => json.encode(toMap());

  // تحويل من JSON
  factory Cart.fromJson(String source) => Cart.fromMap(json.decode(source));
}
