import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/diario_provider.dart';
import 'adicionar_diario_screen.dart';

class DiarioScreen extends ConsumerWidget {
  const DiarioScreen({super.key});

  static const _niveis = [
    'Não ansioso',
    'Levemente ansioso',
    'Ansioso',
    'Muito ansioso',
    'Extremamente ansioso',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registros = ref.watch(diarioProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Diário')),
      body: registros.isEmpty
          ? const Center(child: Text('Nenhum registro no diário ainda.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: registros.length,
              itemBuilder: (context, index) {
                final registro = registros[index];
                final data = DateTime.parse(registro.data);
                final nivel = registro.nivelAnsiedade.clamp(1, 5);
                final cor = nivel <= 2 ? Colors.green : nivel <= 3 ? Colors.orange : Colors.red;
                return Card(child: ListTile(
                  titleAlignment: ListTileTitleAlignment.center,
                  leading: const Icon(Icons.menu_book_outlined, size: 40, color: Colors.blue),
                  title: Text('${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}'),
                  subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_niveis[nivel - 1], style: TextStyle(color: cor, fontWeight: FontWeight.w600)),
                    if (registro.anotacao.isEmpty) const Text('Sem anotações') else Text(registro.anotacao, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ]),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdicionarDiarioScreen(registroParaEditar: registro))),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirmar = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Excluir registro'),
                              content: const Text('Deseja realmente excluir este registro do diário?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
                                TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Excluir', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          );
                          if (confirmar == true) await ref.read(diarioProvider.notifier).deletar(registro.id!);
                        },
                      ),
                    ],
                  ),
                ));
              },
            ),
      bottomNavigationBar: SafeArea(child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(height: 50, child: ElevatedButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdicionarDiarioScreen())),
          icon: const Icon(Icons.add),
          label: const Text('Adicionar registro', style: TextStyle(fontSize: 16)),
        )),
      )),
    );
  }
}
