import 'package:flutter/material.dart';
import '../data/model/product.dart';
import '../presentation/transaction_add_page.dart';

Widget productCard({
  required String name,
  required String type,
  required String price,
  required String image,
  Product? product,
  BuildContext? context,
}) {
  return GestureDetector(
    onTap: () {
      if (context != null && product != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionAddPage(selectedProduct: product),
          ),
        );
      }
    },
    child: Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(image, height: 70),

          const SizedBox(height: 12),

          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),

          Text(type, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                price,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),

              Container(
                height: 28,
                width: 28,
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 18),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
