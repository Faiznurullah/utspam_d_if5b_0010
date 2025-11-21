import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'profile_page.dart';
import 'transaction_history_page.dart';
import 'transaction_detail_page.dart';
import 'product_page.dart';
import '../data/model/product.dart';
import '../data/model/transaction.dart';
import '../data/model/user.dart';
import '../data/repository/transaction.dart';
import '../widget/card_product.dart';

class HomePage extends StatefulWidget {
  final User? currentUser;
  
  const HomePage({super.key, this.currentUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TransactionRepository _transactionRepository = TransactionRepository();
  List<Transaction> _recentTransactions = [];
  bool _isLoadingTransactions = false;

  @override
  void initState() {
    super.initState();
    _loadRecentTransactions();
  }

  Future<void> _loadRecentTransactions() async {
    setState(() {
      _isLoadingTransactions = true;
    });

    try {
      if (widget.currentUser != null) {
        final userTransactions = await _transactionRepository.getRecentTransactionsByUserId(
          widget.currentUser!.id!,
          limit: 3,
        );
        setState(() {
          _recentTransactions = userTransactions;
          _isLoadingTransactions = false;
        });
      } else {
        setState(() {
          _recentTransactions = [];
          _isLoadingTransactions = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingTransactions = false;
      });
      print('Error loading transactions: $e');
    }
  }

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
                              MaterialPageRoute(builder: (context) => ProfilePage(currentUser: widget.currentUser)),
                            );
                          },
                        ),
                        SizedBox(width: 10),
                        Text(
                          '${widget.currentUser?.fullname ?? ''}',
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
                          product: product,
                          currentUser: widget.currentUser,
                          context: context,
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
                        MaterialPageRoute(builder: (context) => TransactionHistoryPage(currentUser: widget.currentUser)),
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

              _isLoadingTransactions
                  ? Container(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.blue[600],
                        ),
                      ),
                    )
                  : _recentTransactions.isEmpty
                      ? Container(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Belum ada transaksi',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Transaksi akan muncul di sini setelah Anda melakukan pembelian',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: _recentTransactions.map((transaction) {
                            return Card(
                              margin: EdgeInsets.only(bottom: 8),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TransactionDetailPage(
                                        transaction: transaction,
                                      ),
                                    ),
                                  );
                                },
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.medication,
                                    color: Colors.blue[700],
                                    size: 24,
                                  ),
                                ),
                                title: Text(
                                  transaction.drugName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Purchased on ${_formatDate(transaction.purchaseDate)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      '${transaction.quantity} items • ${transaction.buyerName}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Text(
                                  transaction.formattedTotalCost,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
        
        
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

