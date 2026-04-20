class UserProfileModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? profileImage;
  final String? bio;
  final String? phoneNumber;
  final bool isVerified;
  
  // Données Client
  final Map<String, dynamic>? measurements;
  final List<String> favorites;
  
  // Données Couturier
  final String? tailorCode;
  final String? shopName;
  final String? shopAddress;
  final String? city;

  UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profileImage,
    this.bio,
    this.phoneNumber,
    this.isVerified = false,
    this.measurements,
    this.favorites = const [],
    this.tailorCode,
    this.shopName,
    this.shopAddress,
    this.city,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'client',
      profileImage: json['profile_image'],
      bio: json['bio'],
      phoneNumber: json['phone_number'],
      isVerified: json['is_verified'] ?? false,
      measurements: json['measurements'],
      favorites: List<String>.from(json['favorites'] ?? []),
      tailorCode: json['tailor_code'],
      shopName: json['shop_name'],
      shopAddress: json['shop_address'],
      city: json['city'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'profile_image': profileImage,
      'bio': bio,
      'phone_number': phoneNumber,
      'is_verified': isVerified,
      'measurements': measurements,
      'favorites': favorites,
      'tailor_code': tailorCode,
      'shop_name': shopName,
      'shop_address': shopAddress,
      'city': city,
    };
  }

  bool get isTailor =\u003e role == 'tailor';
}
