import 'dart:convert';

class Category {
  final String id;
  final String name;
  final String image;
  final String banner;

  Category({
    required this.id,
    required this.name,
    required this.image,
    required this.banner,
  });

  // لتحويل كائن Category إلى JSON
  Map<String, dynamic> toMap() {
    return <String, dynamic>{

      'name': name,
      'image': image,
      'banner': banner,
    };
  }
  String toJson()=> json.encode(toMap());
  // لتحويل JSON إلى كائن Category
  factory Category.fromJson(Map<String, dynamic> map) {
    return Category(
      id: map['_id'] as String,           // قيمة افتراضية إذا لم يوجد المفتاح
      name: map['name'] as String,
      image: map['image'] as String,
      banner: map['banner'] as String,
    );
  }


}
