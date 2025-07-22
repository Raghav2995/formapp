import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/form_model.dart';

class FormDatabase {
  static final FormDatabase instance = FormDatabase._init();
  static Database? _database;

  FormDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('forms.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE forms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName TEXT,
        middleName TEXT,
        lastName TEXT,
        phone TEXT,
        address TEXT
      )
    ''');
  }

  Future<FormModel> insertForm(FormModel form) async {
    final db = await instance.database;
    final id = await db.insert('forms', form.toMap());
    return form.copyWith(id: id);
  }

  Future<List<FormModel>> getAllForms() async {
    final db = await instance.database;
    final result = await db.query('forms');
    return result.map((e) => FormModel.fromMap(e)).toList();
  }

  Future<int> updateForm(FormModel form) async {
    final db = await instance.database;
    return db.update(
      'forms',
      form.toMap(),
      where: 'id = ?',
      whereArgs: [form.id],
    );
  }

  Future<int> deleteForm(int id) async {
    final db = await instance.database;
    return await db.delete(
      'forms',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

extension on FormModel {
  FormModel copyWith({int? id}) {
    return FormModel(
      id: id ?? this.id,
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
      phone: phone,
      address: address,
    );
  }
}
