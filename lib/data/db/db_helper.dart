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
          version:3,
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
            phone VARCHAR(20) NOT NULL
          );

          
           


        ''');
    }

    Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
      if (oldVersion < 3) { 
        await db.execute('DROP TABLE IF EXISTS items');
        await db.execute('DROP TABLE IF EXISTS transactions');
        await _onCreate(db, newVersion);
      }
    }

    
   
}