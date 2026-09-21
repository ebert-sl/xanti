import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/medicamento.dart';
import '../models/registro_diario.dart';

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
      version: 2,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE medicamentos(id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT, diasSemana TEXT, horario TEXT)');
        await _criarTabelaDiario(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) await _criarTabelaDiario(db);
      },
    );
  }

  Future<void> _criarTabelaDiario(Database db) => db.execute(
        'CREATE TABLE diario(id INTEGER PRIMARY KEY AUTOINCREMENT, data TEXT NOT NULL, nivelAnsiedade INTEGER NOT NULL, anotacao TEXT NOT NULL)',
      );

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

  Future<int> inserirRegistroDiario(RegistroDiario registro) async {
    final db = await database;
    return db.insert('diario', registro.toMap());
  }

  Future<List<RegistroDiario>> buscarRegistrosDiario() async {
    final db = await database;
    final registros = await db.query('diario', orderBy: 'data DESC, id DESC');
    return registros.map(RegistroDiario.fromMap).toList();
  }

  Future<int> atualizarRegistroDiario(RegistroDiario registro) async {
    final db = await database;
    return db.update('diario', registro.toMap(), where: 'id = ?', whereArgs: [registro.id]);
  }

  Future<int> deletarRegistroDiario(int id) async {
    final db = await database;
    return db.delete('diario', where: 'id = ?', whereArgs: [id]);
  }
}

