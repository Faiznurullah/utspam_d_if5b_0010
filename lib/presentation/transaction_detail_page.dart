import 'package:flutter/material.dart';
import '../data/model/transaction.dart';
import '../data/repository/transaction.dart';
import 'transaction_edit_page.dart';

class TransactionDetailPage extends StatefulWidget {
  final Transaction transaction;

  const TransactionDetailPage({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  final TransactionRepository _transactionRepository = TransactionRepository();
  late Transaction _currentTransaction;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentTransaction = widget.transaction;
  }

  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  Future<void> _deleteTransaction() async {
    // Show confirmation dialog
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Apakah Anda yakin ingin membatalkan transaksi ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Ya, Batalkan'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _transactionRepository.cancelTransaction(_currentTransaction.transactionId);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi berhasil dibatalkan'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Return to previous page with result
        Navigator.of(context).pop(true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membatalkan transaksi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _editTransaction() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionEditPage(transaction: _currentTransaction),
      ),
    );

    if (result == true) { 
      try {
        final updatedTransaction = await _transactionRepository.getTransactionByTransactionId(_currentTransaction.transactionId);
        if (updatedTransaction != null) {
          setState(() {
            _currentTransaction = updatedTransaction;
          });
        }
      } catch (e) {
        print('Error refreshing transaction: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isCancelled = _currentTransaction.status?.toLowerCase() == 'dibatalkan';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Transaksi', 
        ), 
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Transaction Status Card
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: isCancelled 
                                  ? Colors.red
                                  : Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Status: ${isCancelled ? "Dibatalkan" : "Selesai"}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isCancelled 
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),

                  // Transaction ID Card
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.confirmation_number, color: Colors.blue[600]),
                              const SizedBox(width: 8),
                              const Text(
                                'ID Transaksi',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currentTransaction.transactionId,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Buyer Information Card
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person, color: Colors.blue[600]),
                              const SizedBox(width: 8),
                              const Text(
                                'Informasi Pembeli',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow('Nama Pembeli', _currentTransaction.buyerName),
                          _buildDetailRow('Tanggal Pembelian', _formatDate(_currentTransaction.purchaseDate.toIso8601String())),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Product Information Card
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.medical_services, color: Colors.blue[600]),
                              const SizedBox(width: 8),
                              const Text(
                                'Informasi Obat',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow('Nama Obat', _currentTransaction.drugName),
                          _buildDetailRow('Kategori', _currentTransaction.drugCategory),
                          _buildDetailRow('Harga Satuan', _formatCurrency(_currentTransaction.drugPrice)),
                          _buildDetailRow('Jumlah', '${_currentTransaction.quantity} unit'),
                          const Divider(),
                          _buildDetailRow(
                            'Total Harga', 
                            _formatCurrency(_currentTransaction.totalCost),
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Purchase Method Card
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.payment, color: Colors.blue[600]),
                              const SizedBox(width: 8),
                              const Text(
                                'Metode Pembelian',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            'Jenis Pembelian', 
                            _currentTransaction.purchaseMethod == 'langsung' 
                                ? 'Pembelian Langsung' 
                                : 'Dengan Resep Dokter'
                          ),
                          if (_currentTransaction.purchaseMethod == 'resep' && 
                              _currentTransaction.prescriptionNumber != null &&
                              _currentTransaction.prescriptionNumber!.isNotEmpty) ...[
                            _buildDetailRow('Nomor Resep', _currentTransaction.prescriptionNumber!),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Additional Notes (if any)
                  if (_currentTransaction.additionalNotes != null &&
                      _currentTransaction.additionalNotes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.note, color: Colors.blue[600]),
                                const SizedBox(width: 8),
                                const Text(
                                  'Catatan Tambahan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _currentTransaction.additionalNotes!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Action Buttons
                  if (!isCancelled) ...[
                    // Edit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _editTransaction,
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text(
                          'Edit Transaksi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Cancel Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _deleteTransaction,
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        label: const Text(
                          'Batalkan Transaksi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],

                  if (isCancelled) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: const Text(
                        'Transaksi ini telah dibatalkan dan tidak dapat diedit.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Back to History Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.arrow_back, color: Colors.grey[600]),
                      label: Text(
                        'Kembali ke Riwayat',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? Colors.blue[600] : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}