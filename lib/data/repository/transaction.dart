import '../db/db_helper.dart';
import '../model/transaction.dart';

class TransactionRepository {
  static const String tableName = 'transactions';
  final DbHelper _dbHelper = DbHelper.instance;

  // Insert transaksi baru
  Future<int> insertTransaction(Transaction transaction) async {
    try {
      // Pastikan database sudah siap
      final db = await _dbHelper.database;
      
      // Verify transactions table exists dengan cara yang lebih robust
      try {
        final tableCheck = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='transactions'"
        );
        
        if (tableCheck.isEmpty) {
          print('Transactions table not found, forcing database recreation...');
          throw Exception('Table not found');
        }
        
        print('Transactions table exists, proceeding with insert');
        final result = await db.insert(tableName, transaction.toMapForInsert());
        print('Transaction inserted successfully with ID: $result');
        return result;
      } catch (e) {
        print('Error during table verification or insert: $e');
        print('Attempting database recreation...');
        
        // Force database recreation
        await _dbHelper.deleteDatabase();
        final newDb = await _dbHelper.database;
        
        // Verify table was created
        final verifyTableCheck = await newDb.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='transactions'"
        );
        
        if (verifyTableCheck.isEmpty) {
          throw Exception('Failed to create transactions table after database recreation');
        }
        
        final result = await newDb.insert(tableName, transaction.toMapForInsert());
        print('Transaction inserted after database recreation with ID: $result');
        return result;
      }
    } catch (e) {
      print('Final error in insertTransaction: $e');
      throw Exception('Failed to insert transaction: $e');
    }
  }

  // Get transaksi berdasarkan user ID
  Future<List<Transaction>> getTransactionsByUserId(int userId) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'purchase_date DESC',
      );
      return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Failed to get transactions by user ID: $e');
    }
  }

  // Get recent transactions untuk user tertentu
  Future<List<Transaction>> getRecentTransactionsByUserId(int userId, {int limit = 3}) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'purchase_date DESC',
        limit: limit,
      );
      return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Failed to get recent transactions by user ID: $e');
    }
  }

  // Get semua transaksi
  Future<List<Transaction>> getAllTransactions() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        orderBy: 'purchase_date DESC',
      );
      return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Failed to get transactions: $e');
    }
  }

  // Get transaksi berdasarkan ID
  Future<Transaction?> getTransactionById(int id) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isNotEmpty) {
        return Transaction.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get transaction by id: $e');
    }
  }

  // Get transaksi berdasarkan transaction_id
  Future<Transaction?> getTransactionByTransactionId(String transactionId) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'transaction_id = ?',
        whereArgs: [transactionId],
        limit: 1,
      );
      if (maps.isNotEmpty) {
        return Transaction.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get transaction by transaction_id: $e');
    }
  }

  // Get transaksi berdasarkan nama pembeli
  Future<List<Transaction>> getTransactionsByBuyerName(String buyerName) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'buyer_name LIKE ?',
        whereArgs: ['%$buyerName%'],
        orderBy: 'purchase_date DESC',
      );
      return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Failed to get transactions by buyer name: $e');
    }
  }

  // Get transaksi berdasarkan obat
  Future<List<Transaction>> getTransactionsByDrugName(String drugName) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'drug_name LIKE ?',
        whereArgs: ['%$drugName%'],
        orderBy: 'purchase_date DESC',
      );
      return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Failed to get transactions by drug name: $e');
    }
  }

  // Get transaksi berdasarkan metode pembelian
  Future<List<Transaction>> getTransactionsByPurchaseMethod(String purchaseMethod) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'purchase_method = ?',
        whereArgs: [purchaseMethod],
        orderBy: 'purchase_date DESC',
      );
      return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Failed to get transactions by purchase method: $e');
    }
  }

  // Get transaksi berdasarkan tanggal
  Future<List<Transaction>> getTransactionsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'purchase_date BETWEEN ? AND ?',
        whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
        orderBy: 'purchase_date DESC',
      );
      return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Failed to get transactions by date range: $e');
    }
  }

  // Update transaksi
  Future<int> updateTransaction(Transaction transaction) async {
    try {
      final db = await _dbHelper.database;
      return await db.update(
        tableName,
        transaction.toMapForUpdate(),
        where: 'id = ?',
        whereArgs: [transaction.id],
      );
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  // Delete transaksi
  Future<int> deleteTransaction(int id) async {
    try {
      final db = await _dbHelper.database;
      return await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }

  // Delete transaksi berdasarkan transaction_id
  Future<int> deleteTransactionByTransactionId(String transactionId) async {
    try {
      final db = await _dbHelper.database;
      return await db.delete(
        tableName,
        where: 'transaction_id = ?',
        whereArgs: [transactionId],
      );
    } catch (e) {
      throw Exception('Failed to delete transaction by transaction_id: $e');
    }
  }

  // Update status transaksi menjadi 'dibatalkan'
  Future<int> cancelTransaction(String transactionId) async {
    try {
      final db = await _dbHelper.database;
      return await db.update(
        tableName,
        {
          'status': 'dibatalkan',
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'transaction_id = ?',
        whereArgs: [transactionId],
      );
    } catch (e) {
      throw Exception('Failed to cancel transaction: $e');
    }
  }

  // Get transaksi berdasarkan status
  Future<List<Transaction>> getTransactionsByStatus(String status) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'status = ?',
        whereArgs: [status],
        orderBy: 'purchase_date DESC',
      );
      return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Failed to get transactions by status: $e');
    }
  }

  // Get total penjualan
  Future<double> getTotalSales() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT SUM(total_cost) as total FROM $tableName',
      );
      return result.first['total']?.toDouble() ?? 0.0;
    } catch (e) {
      throw Exception('Failed to get total sales: $e');
    }
  }

  // Get jumlah transaksi
  Future<int> getTransactionCount() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName',
      );
      return result.first['count'] ?? 0;
    } catch (e) {
      throw Exception('Failed to get transaction count: $e');
    }
  }

  // Get transaksi dengan resep dokter
  Future<List<Transaction>> getTransactionsWithPrescription() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'purchase_method = ? AND prescription_number IS NOT NULL',
        whereArgs: ['resep_dokter'],
        orderBy: 'purchase_date DESC',
      );
      return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Failed to get transactions with prescription: $e');
    }
  }

  // Get statistik penjualan obat
  Future<List<Map<String, dynamic>>> getDrugSalesStatistics() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> result = await db.rawQuery(
        '''SELECT drug_name, drug_category, 
           SUM(quantity) as total_quantity,
           SUM(total_cost) as total_revenue,
           COUNT(*) as transaction_count
           FROM $tableName 
           GROUP BY drug_id, drug_name, drug_category 
           ORDER BY total_revenue DESC''',
      );
      return result;
    } catch (e) {
      throw Exception('Failed to get drug sales statistics: $e');
    }
  }

  // Generate unique transaction ID
  String generateTransactionId() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    return 'TXN${timestamp.toString().substring(timestamp.toString().length - 8)}';
  }

  // Clear all transactions (untuk testing)
  Future<int> clearAllTransactions() async {
    try {
      final db = await _dbHelper.database;
      return await db.delete(tableName);
    } catch (e) {
      throw Exception('Failed to clear all transactions: $e');
    }
  }
}