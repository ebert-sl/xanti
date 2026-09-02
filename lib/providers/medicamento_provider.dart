import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medicamento.dart';
import '../database/db_helper.dart';

class MedicamentoNotifier extends Notifier<List<Medicamento>> {
  final dbHelper = DatabaseHelper();

  @override
  List<Medicamento> build() {
    carregarMedicamentos();
    return [];
  }

  Future<void> carregarMedicamentos() async {
    final dados = await dbHelper.buscarMedicamentos();
    state = dados;
  }

  Future<void> adicionar(String nome, String dias, String horario) async {
    final novoMed = Medicamento(nome: nome, diasSemana: dias, horario: horario);
    await dbHelper.inserirMedicamento(novoMed);
    await carregarMedicamentos();
  }

  Future<void> atualizar(int id, String nome, String dias, String horario) async {
    final medEditado = Medicamento(id: id, nome: nome, diasSemana: dias, horario: horario);
    await dbHelper.atualizarMedicamento(medEditado);
    await carregarMedicamentos();
  }

  Future<void> deletar(int id) async {
    await dbHelper.deletarMedicamento(id);
    await carregarMedicamentos();
  }
}

final medicamentoProvider = NotifierProvider<MedicamentoNotifier, List<Medicamento>>(() {
  return MedicamentoNotifier();
});