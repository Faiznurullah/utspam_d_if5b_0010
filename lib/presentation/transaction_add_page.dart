import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../data/model/product.dart';
import '../data/model/transaction.dart';
import '../data/repository/transaction.dart';
import '../data/db/db_helper.dart';
import 'transaction_history_page.dart';

class TransactionAddPage extends StatefulWidget {
  final Product? selectedProduct;
  
  const TransactionAddPage({super.key, this.selectedProduct});

  @override
  State<TransactionAddPage> createState() => _TransactionAddPageState();
}

class _TransactionAddPageState extends State<TransactionAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _buyerNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  final _prescriptionNumberController = TextEditingController();
  final TransactionRepository _transactionRepository = TransactionRepository();
  
  Product? _selectedProduct;
  String _purchaseMethod = 'langsung';
  String? _prescriptionImagePath;
  bool _isLoading = false;
  double _totalCost = 0.0;

  @override
  void initState() {
    super.initState();
    _selectedProduct = widget.selectedProduct;
    _quantityController.addListener(_calculateTotal);
  }

  @override
  void dispose() {
    _buyerNameController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    _prescriptionNumberController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    if (_selectedProduct != null && _quantityController.text.isNotEmpty) {
      final quantity = int.tryParse(_quantityController.text) ?? 0;
      setState(() {
        _totalCost = _selectedProduct!.price * quantity;
      });
    } else {
      setState(() {
        _totalCost = 0.0;
      });
    }
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }

  String? _validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Jumlah pembelian wajib diisi';
    }
    final quantity = int.tryParse(value);
    if (quantity == null || quantity <= 0) {
      return 'Jumlah pembelian harus berupa angka positif';
    }
    return null;
  }

  String? _validatePrescriptionNumber(String? value) {
    if (_purchaseMethod == 'resep_dokter') {
      if (value == null || value.isEmpty) {
        return 'Nomor resep wajib diisi';
      }
      if (value.length < 6) {
        return 'Nomor resep minimal 6 karakter';
      }
      if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*[0-9]).+$').hasMatch(value)) {
        return 'Nomor resep harus mengandung kombinasi huruf dan angka';
      }
    }
    return null;
  }

  void _showPrescriptionUploadDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Upload Foto Resep'),
          content: const Text('Fitur upload foto akan tersedia dalam versi mendatang. Untuk sementara, masukkan path file resep.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tutup'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _prescriptionImagePath = 'assets/images/prescription_sample.jpg';
                });
                Navigator.of(context).pop();
              },
              child: const Text('Gunakan Sample'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedProduct == null) {
      _showSnackBar('Silakan pilih produk terlebih dahulu', isError: true);
      return;
    }

    if (_purchaseMethod == 'resep_dokter' && _prescriptionImagePath == null) {
      _showSnackBar('Foto resep dokter wajib diupload', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Debug: Check database tables first
      final dbHelper = DbHelper.instance;
      final tables = await dbHelper.getTableNames();
      final transactionTableExists = await dbHelper.verifyTransactionsTable();
      print('Available tables before transaction: $tables');
      print('Transactions table verified: $transactionTableExists');
      
      if (!transactionTableExists) {
        print('Transactions table not found, forcing recreation...');
        await dbHelper.deleteDatabase();
        final newTables = await dbHelper.getTableNames(); // This will recreate the database
        print('Tables after recreation: $newTables');
      }
      
      final transactionId = _transactionRepository.generateTransactionId();
      final now = DateTime.now();
      
      final transaction = Transaction(
        transactionId: transactionId,
        buyerName: _buyerNameController.text.trim(),
        drugId: _selectedProduct!.id,
        drugName: _selectedProduct!.name,
        drugCategory: _selectedProduct!.description,
        drugPrice: _selectedProduct!.price,
        quantity: int.parse(_quantityController.text),
        totalCost: _totalCost,
        purchaseMethod: _purchaseMethod,
        prescriptionNumber: _purchaseMethod == 'resep_dokter' 
            ? _prescriptionNumberController.text.trim() 
            : null,
        prescriptionImagePath: _prescriptionImagePath,
        additionalNotes: _notesController.text.trim().isNotEmpty 
            ? _notesController.text.trim() 
            : null,
        purchaseDate: now,
      );

      await _transactionRepository.insertTransaction(transaction);

      // log result
      print('Transaction saved: $transaction');
      
      if (mounted) {
        _showSnackBar('Transaksi berhasil disimpan!');
        
        // Navigate to transaction history and remove all previous routes
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const TransactionHistoryPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Gagal menyimpan transaksi: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulir Pembelian Obat'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Debug button untuk check tables
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () async {
              final dbHelper = DbHelper.instance;
              try {
                final tables = await dbHelper.getTableNames();
                final transactionTableExists = await dbHelper.verifyTransactionsTable();
                print('Available tables: $tables');
                print('Transactions table exists: $transactionTableExists');
                _showSnackBar('Tables: ${tables.join(', ')}. Transactions: $transactionTableExists');
              } catch (e) {
                _showSnackBar('Database error: $e', isError: true);
              }
            },
          ),
          // Reset database button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final dbHelper = DbHelper.instance;
              try {
                await dbHelper.deleteDatabase();
                final tables = await dbHelper.getTableNames();
                _showSnackBar('Database recreated. Tables: ${tables.join(', ')}');
              } catch (e) {
                _showSnackBar('Failed to recreate: $e', isError: true);
              }
            },
          ),
          // Force delete database button  
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () async {
              // Show confirmation dialog
              bool? confirm = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Reset Database'),
                    content: const Text('Hapus database dan buat ulang? Ini akan mengatasi error table.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Reset'),
                      ),
                    ],
                  );
                },
              );
              
              if (confirm == true) {
                final dbHelper = DbHelper.instance;
                try {
                  await dbHelper.deleteDatabase();
                  final tables = await dbHelper.getTableNames();
                  _showSnackBar('Database reset berhasil! Tables: ${tables.join(', ')}');
                } catch (e) {
                  _showSnackBar('Failed to reset: $e', isError: true);
                }
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(Icons.shopping_cart, color: Colors.blue[600], size: 28),
                    const SizedBox(width: 8),
                    const Text(
                      'Detail Pembelian',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Nama Pembeli
                TextFormField(
                  controller: _buyerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Pembeli',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) => _validateRequired(value, 'Nama pembeli'),
                ),
                const SizedBox(height: 16),
                
                // Data Obat yang Dipilih
                if (_selectedProduct != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      border: Border.all(color: Colors.green[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.medication, color: Colors.green[600]),
                            const SizedBox(width: 8),
                            const Text(
                              'Obat yang Dipilih',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Image.asset(
                              _selectedProduct!.imageUrl,
                              height: 60,
                              width: 60,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedProduct!.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _selectedProduct!.description,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rp ${_selectedProduct!.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')} / unit',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                if (_selectedProduct != null) const SizedBox(height: 16),
                
                if (_selectedProduct == null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      border: Border.all(color: Colors.orange[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange[600]),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Tidak ada obat yang dipilih. Pilih obat dari halaman utama terlebih dahulu.',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_selectedProduct == null) const SizedBox(height: 16),
                
                // Jumlah Pembelian
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Jumlah Pembelian',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.shopping_basket),
                    suffixText: 'unit',
                  ),
                  validator: _validateQuantity,
                ),
                const SizedBox(height: 16),
                
                // Metode Pembelian
                const Text(
                  'Metode Pembelian',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        title: const Text('Pembelian Langsung'),
                        subtitle: const Text('Beli obat bebas tanpa resep'),
                        value: 'langsung',
                        groupValue: _purchaseMethod,
                        onChanged: (value) {
                          setState(() {
                            _purchaseMethod = value!;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('Pembelian dengan Resep Dokter'),
                        subtitle: const Text('Memerlukan resep dokter'),
                        value: 'resep_dokter',
                        groupValue: _purchaseMethod,
                        onChanged: (value) {
                          setState(() {
                            _purchaseMethod = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Nomor Resep (hanya muncul jika metode resep dokter)
                if (_purchaseMethod == 'resep_dokter')
                  Column(
                    children: [
                      TextFormField(
                        controller: _prescriptionNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Nomor Resep Dokter',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.medical_services),
                          hintText: 'Contoh: ABC123456',
                        ),
                        validator: _validatePrescriptionNumber,
                      ),
                      const SizedBox(height: 16),
                      
                      // Upload Foto Resep
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.camera_alt, color: Colors.blue[600]),
                                const SizedBox(width: 8),
                                const Text(
                                  'Foto Resep Dokter',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_prescriptionImagePath != null)
                              Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Foto Resep Terupload',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            if (_prescriptionImagePath != null) const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _showPrescriptionUploadDialog,
                                icon: const Icon(Icons.add_a_photo),
                                label: Text(
                                  _prescriptionImagePath != null 
                                      ? 'Ganti Foto Resep' 
                                      : 'Upload Foto Resep',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                
                // Catatan Tambahan
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Catatan Tambahan (Opsional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                    hintText: 'Tambahkan catatan jika diperlukan...',
                  ),
                ),
                const SizedBox(height: 16),
                
                // Total Biaya
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    border: Border.all(color: Colors.blue[200]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.attach_money, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          const Text(
                            'Total Biaya',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Rp ${_totalCost.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Simpan Transaksi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}