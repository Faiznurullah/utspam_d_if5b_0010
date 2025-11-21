import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper{
   static const String dbName = "medicine_app.db";

   DbHelper._init();
   static final DbHelper instance = DbHelper._init();
   static Database? _database;

   factory DbHelper(){
      return instance;
   }

   Future<Database> get database async{
    _database = await _initDatabase(dbName); 
     return _database!;
   }

    Future<Database> _initDatabase(String dbName) async{
      
      
        final dbPath = await getDatabasesPath();
        final path = join(dbPath, dbName);
        return await openDatabase(
          path,
          version: 9, 
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
        ); 
      
    }

    Future _onCreate(Database db, int version) async{ 
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            fullname VARCHAR(255) NOT NULL,
            username VARCHAR(255) NOT NULL,
            email VARCHAR(255) NOT NULL,
            password VARCHAR(255) NOT NULL,
            phone VARCHAR(20) NOT NULL,
            address TEXT
          )
        ''');

        // Buat tabel transactions
        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            transaction_id VARCHAR(50) UNIQUE NOT NULL,
            user_id INTEGER NOT NULL,
            buyer_name VARCHAR(255) NOT NULL,
            drug_id INTEGER NOT NULL,
            drug_name VARCHAR(255) NOT NULL,
            drug_category VARCHAR(100) NOT NULL,
            drug_price REAL NOT NULL,
            quantity INTEGER NOT NULL,
            total_cost REAL NOT NULL,
            purchase_method VARCHAR(50) NOT NULL DEFAULT 'langsung',
            prescription_number VARCHAR(100),
            prescription_image_path TEXT,
            additional_notes TEXT,
            status VARCHAR(20) NOT NULL DEFAULT 'selesai',
            purchase_date DATETIME NOT NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');
        
        print('Database tables created successfully');
    }

    Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
      print('Database upgrade from version $oldVersion to $newVersion');
      
      // Selalu drop dan buat ulang untuk memastikan structure yang benar
      try {
        await db.execute('DROP TABLE IF EXISTS transactions');
        print('Dropped transactions table');
      } catch (e) {
        print('Error dropping transactions table: $e');
      }
      
      try {
        await db.execute('DROP TABLE IF EXISTS users');
        print('Dropped users table');
      } catch (e) {
        print('Error dropping users table: $e');
      }
      
      // Buat ulang semua tabel
      await _onCreate(db, newVersion);
      print('Database upgrade completed successfully');
    }

    // Method untuk debug database
    Future<List<String>> getTableNames() async {
      final db = await database;
      final List<Map<String, dynamic>> tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'"
      );
      return tables.map((table) => table['name'].toString()).toList();
    }

    // Method untuk mendapatkan schema tabel
    Future<List<Map<String, dynamic>>> getTableSchema(String tableName) async {
      final db = await database;
      return await db.rawQuery("PRAGMA table_info($tableName)");
    }

    // Method untuk memverifikasi tabel transactions
    Future<bool> verifyTransactionsTable() async {
      try {
        final db = await database;
        final tableExists = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='transactions'"
        );
        
        if (tableExists.isNotEmpty) {
          final schema = await getTableSchema('transactions');
          print('Transactions table schema: $schema');
          return true;
        }
        return false;
      } catch (e) {
        print('Error verifying transactions table: $e');
        return false;
      }
    }

    
    Future<void> clearDatabase() async {
      final db = await database;
      await db.execute('DELETE FROM users');
      await db.execute('DELETE FROM transactions');
    }
 
    Future<void> deleteDatabase() async {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, dbName);
      await databaseFactory.deleteDatabase(path);
      _database = null;
    }

    
   
}