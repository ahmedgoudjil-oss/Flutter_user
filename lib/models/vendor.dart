import 'dart:convert';

class Vendor {
  final String id;
  final String fullName;
  final String email;
  final String state;
  final String city;
  final String locality;
  final String role;
  final String password;
  final String? phone;
  final String? description;
  final double? rating;
  final int? totalRatings;
  final String? businessHours;
  final String? website;
  final List<String>? categories;
  final String? logo;
  final bool? isVerified;
  final DateTime? createdAt;

  Vendor({
    required this.id,
    required this.fullName,
    required this.email,
    required this.state,
    required this.city,
    required this.locality,
    required this.role,
    required this.password,
    this.phone,
    this.description,
    this.rating,
    this.totalRatings,
    this.businessHours,
    this.website,
    this.categories,
    this.logo,
    this.isVerified,
    this.createdAt,
  });

  // converting to map so that we can easily convert to json because data will be sent to mongodb
  Map<String, dynamic> toMap() {
    return <String, dynamic> {
      'id': id,
      'fullName': fullName,
      'email': email,
      'state': state,
      'city': city,
      'locality': locality,
      'role': role,
      'password': password,
      'phone': phone,
      'description': description,
      'rating': rating,
      'totalRatings': totalRatings,
      'businessHours': businessHours,
      'website': website,
      'categories': categories,
      'logo': logo,
      'isVerified': isVerified,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // converting to json because data will be sent with json
  String toJson() => jsonEncode(toMap());

  // converting back to Vendor user object to use it within application
  factory Vendor.fromJson(Map<String, dynamic> map) {
    return Vendor(
      id: map['_id'] as String,
      fullName: map['fullName'] as String? ?? "",
      email: map['email'] as String? ?? "",
      state: map['state'] as String? ?? "",
      city: map['city'] as String? ?? "",
      locality: map['locality'] as String? ?? "",
      role: map['role'] as String? ?? "",
      password: map['password'] as String? ?? "",
      phone: map['phone'] as String?,
      description: map['description'] as String?,
      rating: map['rating'] != null ? (map['rating'] is int ? (map['rating'] as int).toDouble() : map['rating'] as double) : null,
      totalRatings: map['totalRatings'] as int?,
      businessHours: map['businessHours'] as String?,
      website: map['website'] as String?,
      categories: map['categories'] != null ? List<String>.from(map['categories']) : null,
      logo: map['logo'] as String?,
      isVerified: map['isVerified'] as bool?,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
    );
  }

  // Get display name (full name or business name)
  String get displayName => fullName.isNotEmpty ? fullName : 'Unknown Store';

  // Get location string
  String get location {
    final parts = <String>[];
    if (city.isNotEmpty) parts.add(city);
    if (state.isNotEmpty) parts.add(state);
    return parts.join(', ');
  }

  // Get rating display
  String get ratingDisplay {
    if (rating == null) return 'No ratings';
    return '${rating!.toStringAsFixed(1)} (${totalRatings ?? 0} reviews)';
  }

  // Check if vendor is verified
  bool get isVerifiedVendor => isVerified ?? false;

  // Get business hours display
  String get businessHoursDisplay {
    if (businessHours == null || businessHours!.isEmpty) return 'Hours not available';
    return businessHours!;
  }

  // Get phone display
  String get phoneDisplay {
    if (phone == null || phone!.isEmpty) return 'Phone not available';
    return phone!;
  }

  // Get description display
  String get descriptionDisplay {
    if (description == null || description!.isEmpty) return 'No description available';
    return description!;
  }

  // Get categories display
  String get categoriesDisplay {
    if (categories == null || categories!.isEmpty) return 'General Store';
    return categories!.join(', ');
  }
}
