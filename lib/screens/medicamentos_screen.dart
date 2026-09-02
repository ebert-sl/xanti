import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/medicamento_provider.dart';
import 'adicionar_medicamento_screen.dart';

class MedicamentosScreen extends ConsumerWidget {
  const MedicamentosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listaMedicamentos = ref.watch(medicamentoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicamentos'),
      ),
      body: listaMedicamentos.isEmpty
          ? const Center(child: Text('Nenhum medicamento cadastrado.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: listaMedicamentos.length,
              itemBuilder: (context, index) {
                final med = listaMedicamentos[index];
                return Card(
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.medication, size: 40, color: Colors.blue),
                    title: Text(med.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(child: Text(med.diasSemana)),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(med.horario),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdicionarMedicamentoScreen(medicamentoParaEditar: med),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Excluir Medicamento'),
                                content: Text('Deseja realmente excluir o medicamento "${med.nome}"?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      ref.read(medicamentoProvider.notifier).deletar(med.id!);
                                      Navigator.pop(ctx);
                                    },
                                    child: const Text('Excluir', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text(
                'Adicionar Medicamento',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdicionarMedicamentoScreen()),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}