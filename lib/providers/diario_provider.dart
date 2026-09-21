import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/db_helper.dart';
import '../models/registro_diario.dart';

class DiarioNotifier extends Notifier<List<RegistroDiario>> {
  final _dbHelper = DatabaseHelper();

  @override
  List<RegistroDiario> build() {
    carregarRegistros();
    return [];
  }

  Future<void> carregarRegistros() async => state = await _dbHelper.buscarRegistrosDiario();

  Future<void> adicionar({required DateTime data, required int nivelAnsiedade, required String anotacao}) async {
    await _dbHelper.inserirRegistroDiario(RegistroDiario(
      data: data.toIso8601String().split('T').first,
      nivelAnsiedade: nivelAnsiedade,
      anotacao: anotacao.trim(),
    ));
    await carregarRegistros();
  }

  Future<void> atualizar({required int id, required DateTime data, required int nivelAnsiedade, required String anotacao}) async {
    await _dbHelper.atualizarRegistroDiario(RegistroDiario(
      id: id,
      data: data.toIso8601String().split('T').first,
      nivelAnsiedade: nivelAnsiedade,
      anotacao: anotacao.trim(),
    ));
    await carregarRegistros();
  }

  Future<void> deletar(int id) async {
    await _dbHelper.deletarRegistroDiario(id);
    await carregarRegistros();
  }
}

final diarioProvider = NotifierProvider<DiarioNotifier, List<RegistroDiario>>(DiarioNotifier.new);
