import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'profile_page.dart';
import 'transaction_history_page.dart';
import 'product_page.dart';
import '../data/model/product.dart';
import '../widget/card_product.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(child: Icon(Icons.account_circle, size: 25,),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>  ProfilePage()),
                            );
                          },
                        ),
                        SizedBox(width: 10),
                        Text(
                          'John Doe',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
        
                    Row(
                      children: [
                        Icon(Icons.notifications, size: 25),
                        SizedBox(width: 10),
                        Icon(Icons.settings, size: 25),
                      ],
                    ),
                  ],
                ),
        
                SizedBox(height: 20),
        
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search Medicine & Health Products',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                  ),
                ),
        
                SizedBox(height: 20),
        
                Image.asset('assets/images/banner.png'),
        
                SizedBox(height: 10),
        
                CarouselSlider(
                  items: [
                    Image.asset('assets/images/banner1.png'),
                    Image.asset('assets/images/banner2.png'),
                    Image.asset('assets/images/banner3.png'),
                  ],
                  options: CarouselOptions(
                    height: 150,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 0.9,
                    autoPlayInterval: const Duration(seconds: 3),
                    autoPlayAnimationDuration: const Duration(milliseconds: 600),
                  ),
                ),
        
                SizedBox(height: 10),
        
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Product for You',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProductPage()),
                        );
                      },
                      child: Text(
                        'See All',
                        style: TextStyle(fontSize: 16, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
        
                SizedBox(height: 10),
        
                SizedBox(
                  height: 220, // tinggi list agar ListView punya ruang
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (var product in products)
                        productCard(
                          name: product.name,
                          type: product.description,
                          price: '\Rp.${product.price.toStringAsFixed(2)}',
                          image: product.imageUrl,
                        ),
                    ],
                  ),
                ),
        
              SizedBox(height: 10),
        
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transaction History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TransactionHistoryPage()),
                      );
                    },
                    child: Text(
                      'See All',
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10),

              Column(
                children: [
                  ListTile(
                    tileColor: Colors.white,
                    leading: Image.asset('assets/images/medicine1.png', height: 40),
                    title: Text('Vitamin C'),
                    subtitle: Text('Purchased on 12 Jan 2024'),
                    trailing: Text('\$15.99'),
                  ),
                  ListTile(
                    tileColor: Colors.white,
                    leading: Image.asset('assets/images/medicine2.png', height: 40),
                    title: Text('Bodrex Herbal'),
                    subtitle: Text('Purchased on 10 Jan 2024'),
                    trailing: Text('\$7.99'),
                  ),
                  ListTile(
                    tileColor: Colors.white,
                    leading: Image.asset('assets/images/medicine3.png', height: 40),
                    title: Text('Konidin'),
                    subtitle: Text('Purchased on 08 Jan 2024'),
                    trailing: Text('\$5.99'),
                  ),
                ],
              ),
        
        
              ],
            ),
          ),
        ),
      ),
    );
  }
}

