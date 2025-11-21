import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'profile_page.dart';
import 'transaction_history_page.dart';

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
                    Text(
                      'See All',
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ],
                ),
        
                SizedBox(height: 10),
        
                SizedBox(
                  height: 220, // tinggi list agar ListView punya ruang
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      productCard(
                        name: "Vitamin C",
                        type: "vitamins",
                        price: "\$15.99",
                        image: "assets/images/medicine1.png",
                      ),
                      productCard(
                        name: "Bodrex Herbal",
                        type: "Antibiotics",
                        price: "\$7.99",
                        image: "assets/images/medicine2.png",
                      ),
                      productCard(
                        name: "Konidin",
                        type: "Cough Medicine",
                        price: "\$5.99",
                        image: "assets/images/medicine3.png",
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

Widget productCard({
  required String name,
  required String type,
  required String price,
  required String image,
}) {
  return Container(
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
  );
}
