import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/medicamentos_screen.dart';
import 'screens/diario_screen.dart';
import 'screens/analise_ia_screen.dart';

class IndiceNavegacaoNotifier extends Notifier<int> {
  @override
  int build() {
    return 0;
  }

  void alterarAba(int novoIndice) {
    state = novoIndice;
  }
}

final indiceNavegacaoProvider = NotifierProvider<IndiceNavegacaoNotifier, int>(() {
  return IndiceNavegacaoNotifier();
});

void main() {
  runApp(const ProviderScope(child: XantiApp()));
}

class XantiApp extends StatelessWidget {
  const XantiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xanti',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const NavegacaoPrincipal(),
    );
  }
}

class NavegacaoPrincipal extends ConsumerWidget {
  const NavegacaoPrincipal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final indiceAtual = ref.watch(indiceNavegacaoProvider);

    final telas = const [
      MedicamentosScreen(),
      DiarioScreen(),
      AnaliseIAScreen(),
    ];

    return Scaffold(
      body: telas[indiceAtual],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: indiceAtual,
        onTap: (index) {
          ref.read(indiceNavegacaoProvider.notifier).alterarAba(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: 'Medicamentos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Diário',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Análise IA',
          ),
        ],
      ),
    );
  }
}