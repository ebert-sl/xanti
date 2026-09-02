import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/medicamento.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._interno();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._interno();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _iniciarBanco();
    return _database!;
  }

  Future<Database> _iniciarBanco() async {
    String caminho = join(await getDatabasesPath(), 'xanti_db.db');
    return await openDatabase(
      caminho,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE medicamentos(id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT, diasSemana TEXT, horario TEXT)',
        );
      },
    );
  }

  Future<int> inserirMedicamento(Medicamento medicamento) async {
    final db = await database;
    return await db.insert('medicamentos', medicamento.toMap());
  }

  Future<List<Medicamento>> buscarMedicamentos() async {
    final db = await database;
    final List<Map<String, dynamic>> mapas = await db.query('medicamentos');
    return mapas.map((mapa) => Medicamento.fromMap(mapa)).toList();
  }

  Future<int> atualizarMedicamento(Medicamento medicamento) async {
    final db = await database;
    return await db.update(
      'medicamentos',
      medicamento.toMap(),
      where: 'id = ?',
      whereArgs: [medicamento.id],
    );
  }

  Future<int> deletarMedicamento(int id) async {
    final db = await database;
    return await db.delete(
      'medicamentos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

