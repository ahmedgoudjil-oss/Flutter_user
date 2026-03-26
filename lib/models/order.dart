class Order {
  final String id;
  final String fullName;
  final String email;
  final String state;
  final String city;
  final String locality;
  final String productName;
  final String productId;
  final int productPrice;
  final int quantity;
  final String category;
  final String image;
  final String buyerId;
  final String vendorId;
  final bool processing;
  final bool delivered;
  final String paymentStatus;
  final String paymentIntentId;
  final String paymentMethod;

  Order({
    required this.id,
    required this.fullName,
    required this.email,
    required this.state,
    required this.city,
    required this.locality,
    required this.productName,
    required this.productId,
    required this.productPrice,
    required this.quantity,
    required this.category,
    required this.image,
    required this.buyerId,
    required this.vendorId,
    required this.processing,
    required this.delivered,
    required this.paymentStatus,
    required this.paymentIntentId,
    required this.paymentMethod,
  });

  // ✅ للتحويل من كائن إلى JSON لإرساله إلى الخادم
  Map<String, dynamic> toJson() {
    return {
      "_id": id, // تأكد أن السيرفر يتعامل مع _id وليس id
      "fullName": fullName,
      "email": email,
      "state": state,
      "city": city,
      "locality": locality,
      "productName": productName,
      "productId": productId,
      "productPrice": productPrice,
      "quantity": quantity,
      "category": category,
      "image": image,
      "buyerId": buyerId,
      "vendorId": vendorId,
      "processing": processing,
      "delivered": delivered,
      "paymentStatus": paymentStatus,
      "paymentIntentId": paymentIntentId, 
      "paymentMethod": paymentMethod,
    };
  }

  // ✅ للتحويل من JSON إلى كائن Dart (مثلاً عند جلب الطلبات)
  factory Order.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    bool toBool(dynamic value) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final normalized = value.toLowerCase().trim();
        return normalized == 'true' || normalized == '1' || normalized == 'yes';
      }
      return false;
    }

    String toStr(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    return Order(
      id: toStr(json['_id'] ?? json['id']),
      fullName: toStr(json['fullName']),
      email: toStr(json['email']),
      state: toStr(json['state']),
      city: toStr(json['city']),
      locality: toStr(json['locality']),
      productName: toStr(json['productName']),
      productId: toStr(json['productId'] ?? json['product_id']),
      productPrice: toInt(json['productPrice']),
      quantity: toInt(json['quantity']),
      category: toStr(json['category']),
      image: toStr(json['image']),
      buyerId: toStr(json['buyerId'] ?? json['buyer_id']),
      vendorId: toStr(json['vendorId'] ?? json['vendor_id']),
      processing: toBool(json['processing']),
      delivered: toBool(json['delivered']),
      paymentStatus: toStr(json['paymentStatus'] ?? json['payment_status']),
      paymentIntentId: toStr(json['paymentIntentId'] ?? json['payment_intent_id']),
      paymentMethod: toStr(json['paymentMethod'] ?? json['payment_method']),
    );
  }
}
