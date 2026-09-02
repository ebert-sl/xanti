import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medicamento.dart';
import '../providers/medicamento_provider.dart';

class AdicionarMedicamentoScreen extends ConsumerStatefulWidget {
  final Medicamento? medicamentoParaEditar;

  const AdicionarMedicamentoScreen({super.key, this.medicamentoParaEditar});

  @override
  ConsumerState<AdicionarMedicamentoScreen> createState() => _AdicionarMedicamentoScreenState();
}

class _AdicionarMedicamentoScreenState extends ConsumerState<AdicionarMedicamentoScreen> {
  final _nomeController = TextEditingController();
  
  final List<String> _todosOsDias = [
    'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'
  ];
  
  final List<String> _diasSelecionados = [];
  TimeOfDay? _horarioSelecionado;

  @override
  void initState() {
    super.initState();
    if (widget.medicamentoParaEditar != null) {
      final med = widget.medicamentoParaEditar!;
      _nomeController.text = med.nome;
      
      if (med.diasSemana == 'Todos os dias') {
        _diasSelecionados.addAll(_todosOsDias);
      } else {
        _diasSelecionados.addAll(med.diasSemana.split(', '));
      }

      final partesHora = med.horario.split(':');
      if (partesHora.length == 2) {
        _horarioSelecionado = TimeOfDay(
          hour: int.parse(partesHora[0]),
          minute: int.parse(partesHora[1]),
        );
      }
    }
  }

  Future<void> _selecionarHorario() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _horarioSelecionado ?? TimeOfDay.now(),
    );
    if (hora != null) {
      setState(() {
        _horarioSelecionado = hora;
      });
    }
  }

  void _salvar() {
    if (_nomeController.text.isEmpty || _diasSelecionados.isEmpty || _horarioSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o nome, selecione os dias e o horário')),
      );
      return;
    }

    final horarioFormatado = _horarioSelecionado!.format(context);
    
    final String diasFormatados;
    if (_diasSelecionados.length == _todosOsDias.length) {
      diasFormatados = 'Todos os dias';
    } else {
      diasFormatados = _diasSelecionados.join(', ');
    }
    
    if (widget.medicamentoParaEditar == null) {
      ref.read(medicamentoProvider.notifier).adicionar(
        _nomeController.text,
        diasFormatados,
        horarioFormatado,
      );
    } else {
      ref.read(medicamentoProvider.notifier).atualizar(
        widget.medicamentoParaEditar!.id!,
        _nomeController.text,
        diasFormatados,
        horarioFormatado,
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditando = widget.medicamentoParaEditar != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditando ? 'Editar Medicamento' : 'Adicionar Medicamento')),
      
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Medicamento',
                  prefixIcon: Icon(Icons.vaccines),
                ),
              ),
              const SizedBox(height: 24),
              
              const Text(
                'Dias de Uso:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _todosOsDias.map((dia) {
                  final selecionado = _diasSelecionados.contains(dia);
                  return FilterChip(
                    label: Text(dia),
                    selected: selecionado,
                    onSelected: (bool isSelected) {
                      setState(() {
                        if (isSelected) {
                          _diasSelecionados.add(dia);
                        } else {
                          _diasSelecionados.remove(dia);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24), 
              
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule),
                title: Text(
                  _horarioSelecionado == null
                      ? 'Selecione o horário'
                      : 'Horário: ${_horarioSelecionado!.format(context)}',
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: const Icon(Icons.edit),
                onTap: _selecionarHorario,
              ),
            ],
          ),
        ),
      ),
      
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              icon: Icon(isEditando ? Icons.update : Icons.save),
              label: Text(
                isEditando ? 'Atualizar Medicamento' : 'Salvar Medicamento',
                style: const TextStyle(fontSize: 16),
              ),
              onPressed: _salvar,
            ),
          ),
        ),
      ),
    );
  }
}