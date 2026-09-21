import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    // المسار المحمول الذي طلبته أنت: خارج التطبيق
    String customPath = '/storage/emulated/0/SmartDMS_PRO/database';
    await Directory(customPath).create(recursive: true);
    String path = join(customPath, 'smartdms.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE documents(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        category TEXT,
        path TEXT NOT NULL,
        created_at TEXT,
        status TEXT,
        size TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        role TEXT,
        username TEXT UNIQUE,
        password TEXT
      )
    ''');
    // مستخدم افتراضي
    await db.insert('users', {
      'name': 'أحمد العلي',
      'role': 'مسؤول النظام',
      'username': 'admin',
      'password': 'admin'
    });
  }

  Future<List<Map>> getDocuments() async {
    var client = await db;
    return await client.query('documents', orderBy: 'id DESC');
  }

  Future<int> addDocument(Map<String, dynamic> doc) async {
    var client = await db;
    return await client.insert('documents', doc);
  }
}
