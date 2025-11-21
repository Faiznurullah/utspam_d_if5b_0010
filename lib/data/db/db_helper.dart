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
          version:4,
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
          );

          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            transaction_id VARCHAR(50) UNIQUE NOT NULL,
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
            purchase_date DATETIME NOT NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
          );

        ''');
    }

    Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
      if (oldVersion < 4) { 
        await db.execute('DROP TABLE IF EXISTS users');
        await db.execute('DROP TABLE IF EXISTS transactions');
        await _onCreate(db, newVersion);
      }
    }

    
   
}