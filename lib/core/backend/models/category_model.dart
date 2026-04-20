class CategoryModel {
  final String id;
  final String name;
  final String? iconName;
  final String? imageUrl;

  CategoryModel({
    required this.id,
    required this.name,
    this.iconName,
    this.imageUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      iconName: json['icon_name'],
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon_name': iconName,
      'image_url': imageUrl,
    };
  }
}
