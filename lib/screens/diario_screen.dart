import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiarioScreen extends ConsumerWidget {
  const DiarioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diário de Sintomas')),
      body: const Center(child: Text('Registro diário de sintomas')),
    );
  }
}