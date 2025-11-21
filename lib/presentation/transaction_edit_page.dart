import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/model/transaction.dart';
import '../data/repository/transaction.dart';

class TransactionEditPage extends StatefulWidget {
  final Transaction transaction;
  
  const TransactionEditPage({super.key, required this.transaction});

  @override
  State<TransactionEditPage> createState() => _TransactionEditPageState();
}

class _TransactionEditPageState extends State<TransactionEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  final _prescriptionNumberController = TextEditingController();
  final TransactionRepository _transactionRepository = TransactionRepository();
  
  String _purchaseMethod = 'langsung';
  String? _prescriptionImagePath;
  bool _isLoading = false;
  double _totalCost = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _quantityController.addListener(_calculateTotal);
  }

  void _initializeFields() {
    _quantityController.text = widget.transaction.quantity.toString();
    _notesController.text = widget.transaction.additionalNotes ?? '';
    _purchaseMethod = widget.transaction.purchaseMethod;
    _prescriptionNumberController.text = widget.transaction.prescriptionNumber ?? '';
    _prescriptionImagePath = widget.transaction.prescriptionImagePath;
    _calculateTotal();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    _prescriptionNumberController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    if (_quantityController.text.isNotEmpty) {
      final quantity = int.tryParse(_quantityController.text) ?? 0;
      setState(() {
        _totalCost = widget.transaction.drugPrice * quantity;
      });
    } else {
      setState(() {
        _totalCost = 0.0;
      });
    }
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

  Future<void> _updateTransaction() async {
    if (!_formKey.currentState!.validate()) {
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
      final updatedTransaction = widget.transaction.copyWith(
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
      );

      await _transactionRepository.updateTransaction(updatedTransaction);
      
      if (mounted) {
        _showSnackBar('Transaksi berhasil diupdate!');
        Navigator.pop(context, updatedTransaction); // Return updated transaction
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Gagal mengupdate transaksi: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Transaksi'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cancel and go back
            },
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.white),
            ),
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
                    Icon(Icons.edit, color: Colors.blue[600], size: 28),
                    const SizedBox(width: 8),
                    const Text(
                      'Edit Detail Transaksi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Transaction Info (Read Only)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          const Text(
                            'Informasi Transaksi',
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
                          const Text('ID Transaksi: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(widget.transaction.transactionId),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text('Pembeli: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(widget.transaction.buyerName),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text('Tanggal: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(widget.transaction.formattedPurchaseDate),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Data Obat (Read Only)
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
                            'Data Obat',
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.transaction.drugName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  widget.transaction.drugCategory,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rp ${widget.transaction.drugPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')} / unit',
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
                const SizedBox(height: 20),
                
                // Jumlah Pembelian (Editable)
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
                
                // Metode Pembelian (Editable)
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
                                    'Foto Resep Tersimpan',
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
                
                // Catatan Tambahan (Editable)
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
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context); // Cancel
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateTransaction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Simpan Perubahan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
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