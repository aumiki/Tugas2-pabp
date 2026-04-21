class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final String category;
  final String? image;
  final int stock;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.category,
    this.image,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      image: json['image'] as String?,
      stock: (json['stock'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'image': image,
      'stock': stock,
    };
  }
}
