// lib/models/product_model.dart
class ProductModel {
  final int? id;
  final String name;
  final String sku;
  final String category;
  final String description;
  final List<String> availableSizes;
  final List<String> availableColors;
  final double price;
  final String imageUrl;
  final String material;
  final String gender; // 'men', 'women', 'kids', 'unisex'
  final bool isActive;
  final DateTime createdAt;

  ProductModel({
    this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.description,
    required this.availableSizes,
    required this.availableColors,
    required this.price,
    required this.imageUrl,
    required this.material,
    required this.gender,
    this.isActive = true,
    required this.createdAt,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      name: map['name'],
      sku: map['sku'],
      category: map['category'],
      description: map['description'],
      availableSizes: (map['available_sizes'] as String).split(','),
      availableColors: (map['available_colors'] as String).split(','),
      price: double.parse(map['price'].toString()),
      imageUrl: map['image_url'] ?? '',
      material: map['material'] ?? '',
      gender: map['gender'] ?? 'unisex',
      isActive: map['is_active'] ?? true,
      createdAt: map['created_at'] is DateTime
          ? map['created_at']
          : DateTime.parse(map['created_at'].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sku': sku,
      'category': category,
      'description': description,
      'available_sizes': availableSizes.join(','),
      'available_colors': availableColors.join(','),
      'price': price,
      'image_url': imageUrl,
      'material': material,
      'gender': gender,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ProductModel copyWith({
    int? id,
    String? name,
    String? sku,
    String? category,
    String? description,
    List<String>? availableSizes,
    List<String>? availableColors,
    double? price,
    String? imageUrl,
    String? material,
    String? gender,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      description: description ?? this.description,
      availableSizes: availableSizes ?? this.availableSizes,
      availableColors: availableColors ?? this.availableColors,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      material: material ?? this.material,
      gender: gender ?? this.gender,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
