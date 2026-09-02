import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnaliseIAScreen extends ConsumerWidget {
  const AnaliseIAScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Análise IA')),
      body: const Center(child: Text('Insights e análises baseadas na IA')),
    );
  }
}