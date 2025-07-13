class Product {
  final String id;
  final String name;
  final String description;
  final int price;

  Product({required this.id, required this.name, required this.description, required this.price});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'],
      price: int.tryParse(json['price'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'price': price,
  };
}
