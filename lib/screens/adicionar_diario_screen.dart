import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/registro_diario.dart';
import '../providers/diario_provider.dart';

class AdicionarDiarioScreen extends ConsumerStatefulWidget {
  const AdicionarDiarioScreen({super.key, this.registroParaEditar});

  final RegistroDiario? registroParaEditar;

  @override
  ConsumerState<AdicionarDiarioScreen> createState() => _AdicionarDiarioScreenState();
}

class _AdicionarDiarioScreenState extends ConsumerState<AdicionarDiarioScreen> {
  static const _niveis = ['Não ansioso', 'Levemente ansioso', 'Ansioso', 'Muito ansioso', 'Extremamente ansioso'];

  final _anotacaoController = TextEditingController();
  DateTime _diaSelecionado = DateTime.now();
  int _nivelAnsiedade = 3;

  bool get _editando => widget.registroParaEditar != null;

  @override
  void initState() {
    super.initState();
    final registro = widget.registroParaEditar;
    if (registro != null) {
      _diaSelecionado = DateTime.parse(registro.data);
      _nivelAnsiedade = registro.nivelAnsiedade.clamp(1, 5);
      _anotacaoController.text = registro.anotacao;
    }
  }

  @override
  void dispose() {
    _anotacaoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarDia() async {
    final dia = await showDatePicker(context: context, initialDate: _diaSelecionado, firstDate: DateTime(2020), lastDate: DateTime.now());
    if (dia != null) setState(() => _diaSelecionado = dia);
  }

  String get _dataFormatada => '${_diaSelecionado.day.toString().padLeft(2, '0')}/${_diaSelecionado.month.toString().padLeft(2, '0')}/${_diaSelecionado.year}';

  Future<void> _salvar() async {
    final diario = ref.read(diarioProvider.notifier);
    if (_editando) {
      await diario.atualizar(id: widget.registroParaEditar!.id!, data: _diaSelecionado, nivelAnsiedade: _nivelAnsiedade, anotacao: _anotacaoController.text);
    } else {
      await diario.adicionar(data: _diaSelecionado, nivelAnsiedade: _nivelAnsiedade, anotacao: _anotacaoController.text);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(_editando ? 'Editar registro' : 'Adicionar registro')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Dia do registro', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            OutlinedButton.icon(onPressed: _selecionarDia, icon: const Icon(Icons.calendar_today_outlined), label: Text(_dataFormatada), style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 52), alignment: Alignment.centerLeft)),
            const SizedBox(height: 28),
            const Text('Nível de ansiedade', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_niveis.length, (index) {
                final nivel = index + 1;
                return ChoiceChip(
                  label: Text(_niveis[index]),
                  selected: _nivelAnsiedade == nivel,
                  onSelected: (_) => setState(() => _nivelAnsiedade = nivel),
                );
              }),
            ),
            const SizedBox(height: 32),
            const Text('Anotações', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: _anotacaoController, minLines: 7, maxLines: 10, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(hintText: 'Escreva sobre como foi o seu dia, seus sintomas ou o que pode ter influenciado seu bem-estar...', border: OutlineInputBorder())),
          ]),
        ),
        bottomNavigationBar: SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: SizedBox(height: 52, child: ElevatedButton.icon(onPressed: _salvar, icon: const Icon(Icons.save_outlined), label: Text(_editando ? 'Salvar alterações' : 'Salvar registro', style: const TextStyle(fontSize: 16))))),
      )
  );
}
