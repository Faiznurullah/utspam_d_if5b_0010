import 'package:flutter/material.dart';
import '../data/model/product.dart';
import '../widget/card_product.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  // Data dummy produk obat-obatan
  List<Product> get dummyProducts => [
    Product(
      id: 1,
      name: "Vitamin C",
      description: "Boosts immune system",
      price: 15.99,
      imageUrl: "assets/images/medicine1.png",
    ),
    Product(
      id: 2,
      name: "Bodrex Herbal",
      description: "Relieves headaches",
      price: 7.99,
      imageUrl: "assets/images/medicine2.png",
    ),
    Product(
      id: 3,
      name: "Konidin",
      description: "Cough relief",
      price: 5.99,
      imageUrl: "assets/images/medicine3.png",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List'), 
        elevation: 0,
      ),
      body: Container(
         
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               
              const SizedBox(height: 4),
              Text(
                '${dummyProducts.length} products available.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              
              // GridView Products
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: dummyProducts.length,
                itemBuilder: (context, index) {
                  final product = dummyProducts[index];
                  return productCard(
                    name: product.name,
                    type: product.description,
                    price: 'Rp ${product.price.toInt().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}',
                    image: product.imageUrl,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}