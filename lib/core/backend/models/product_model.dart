class ProductModel {
  final String id;
  final String tailorId;
  final String? categoryId;
  final String name;
  final String description;
  final double price;
  final String currency;
  final List<String> imageUrls;
  final String type; // 'custom' or 'readyToWear'
  final String gender; // 'male', 'female', 'unisex'
  final String? confectionTime;
  
  final List<String>? sizes;
  final List<String>? colors;
  final List<String>? fabrics;
  final Map<String, dynamic>? measurements;
  
  final bool isAvailable;
  final bool isCustomizable;
  final bool requiresMeasurements;
  final bool isFeatured;

  ProductModel({
    required this.id,
    required this.tailorId,
    this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    this.currency = 'XAF',
    this.imageUrls = const [],
    required this.type,
    required this.gender,
    this.confectionTime,
    this.sizes,
    this.colors,
    this.fabrics,
    this.measurements,
    this.isAvailable = true,
    this.isCustomizable = true,
    this.requiresMeasurements = false,
    this.isFeatured = false,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      tailorId: json['tailor_id'],
      categoryId: json['category_id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'XAF',
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      type: json['type'] ?? 'readyToWear',
      gender: json['gender'] ?? 'unisex',
      confectionTime: json['confection_time'],
      sizes: json['sizes'] != null ? List<String>.from(json['sizes']) : null,
      colors: json['colors'] != null ? List<String>.from(json['colors']) : null,
      fabrics: json['fabrics'] != null ? List<String>.from(json['fabrics']) : null,
      measurements: json['measurements'],
      isAvailable: json['is_available'] ?? true,
      isCustomizable: json['is_customizable'] ?? true,
      requiresMeasurements: json['requires_measurements'] ?? false,
      isFeatured: json['is_featured'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tailor_id': tailorId,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'image_urls': imageUrls,
      'type': type,
      'gender': gender,
      'confection_time': confectionTime,
      'sizes': sizes,
      'colors': colors,
      'fabrics': fabrics,
      'measurements': measurements,
      'is_available': isAvailable,
      'is_customizable': isCustomizable,
      'requires_measurements': requiresMeasurements,
      'is_featured': isFeatured,
    };
  }

  String get firstImage =\u003e imageUrls.isNotEmpty ? imageUrls[0] : '';
}
