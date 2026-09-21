import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../providers/diario_provider.dart';
import '../services/ia_service.dart';

class AnaliseIAScreen extends ConsumerStatefulWidget {
  const AnaliseIAScreen({super.key});

  @override
  ConsumerState<AnaliseIAScreen> createState() => _AnaliseIAScreenState();
}

class _AnaliseIAScreenState extends ConsumerState<AnaliseIAScreen> {
  final IaService _iaService = IaService();
  String? _resultadoAnalise;
  bool _isLoading = false;

  Future<void> _gerarAnalise() async {
    setState(() {
      _isLoading = true;
      _resultadoAnalise = null;
    });

    try {
      final todosRegistros = ref.read(diarioProvider);
      final ultimosRegistros = todosRegistros.take(5).toList();

      final resultado = await _iaService.analisarDiario(ultimosRegistros);

      if (mounted) {
        setState(() {
          _resultadoAnalise = resultado;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _resultadoAnalise = "Ocorreu um erro ao gerar a análise.\nErro: $e";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conselheiro Virtual (IA)'),
        elevation: 0,
      ),
      // Adicionado um fundo ligeiramente cinza para destacar o cartão branco da resposta
      backgroundColor: Colors.grey.shade50,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Gere reflexões éticas baseadas nos seus últimos dias.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Aviso de privacidade
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.privacy_tip_outlined, color: Colors.blue.shade700, size: 22),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Os textos dos últimos dias serão enviados anonimamente para os servidores do Google/IA para gerar a análise, mas não serão salvos por eles.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            ElevatedButton.icon(
              icon: const Icon(Icons.auto_awesome),
              label: const Text(
                'Gerar Análise dos Últimos Dias',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isLoading ? null : _gerarAnalise,
            ),
            
            const SizedBox(height: 24),
            
            // Caixa de texto da IA aprimorada
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _resultadoAnalise == null
                      ? const Center(
                          child: Text(
                            'Toque no botão acima para receber\nseus conselhos de bem-estar.',
                            style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: MarkdownBody(
                              data: _resultadoAnalise!,
                              styleSheet: MarkdownStyleSheet(
                                p: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
                                h1: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                                h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.blueAccent),
                                h3: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                                listBullet: const TextStyle(fontSize: 16, color: Colors.blue),
                                blockquote: TextStyle(
                                  fontSize: 15, 
                                  fontStyle: FontStyle.italic, 
                                  color: Colors.grey.shade700,
                                ),
                                blockquoteDecoration: BoxDecoration(
                                  border: Border(left: BorderSide(color: Colors.blue.shade200, width: 4)),
                                  color: Colors.blue.withValues(alpha: 0.03),
                                ),
                              ),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}