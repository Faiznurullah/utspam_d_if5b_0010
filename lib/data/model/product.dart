import 'dart:convert';

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  factory Product.fromJson(String source) => Product.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());
}

 List<Product> products = [
    Product(
      id: 1,
      name: "Vitamin C",
      description: "Boosts immune system",
      price: 15000,
      imageUrl: "assets/images/medicine1.png",
    ),
    Product(
      id: 2,
      name: "Bodrex Herbal",
      description: "Relieves headaches",
      price: 10000,
      imageUrl: "assets/images/medicine2.png",
    ),
    Product(
      id: 3,
      name: "Konidin",
      description: "Cough relief",
      price: 2000,
      imageUrl: "assets/images/medicine3.png",
    ),
  ];