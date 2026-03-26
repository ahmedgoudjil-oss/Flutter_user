import 'dart:convert';

class BannerModel {
  final String id;
  final String image;

  BannerModel({required this.id, required this.image});
  // we are converting the banner model object into a map.
  // because we want to convert easily to other formats like JSON.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{'image': image}; // فقط الصورة، لا ترسل id
  }

  //JSON function is to convert the map to JSON
  String toJson() => json.encode(toMap());

//And over here we are converting the map back to the banner model objects
  factory BannerModel.fromJson(Map<String, dynamic> map) {
    return BannerModel(
      id: map['_id'] as String,

      image: map['image'] as String,
    );
  }


}