import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/registro_diario.dart';

class IaService {
  Future<String> analisarDiario(List<RegistroDiario> registros) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    
    if (apiKey == null || apiKey.isEmpty) {
      return "Erro: Chave da API não configurada.";
    }
    
    if (registros.isEmpty) {
      return "Não há registros suficientes para análise. Escreva no seu diário para receber dicas!";
    }

    final instrucaoSistema = Content.system(
      'Você é um assistente virtual empático, acolhedor e focado no bem-estar. '
      'Sua função é ler os registros de diário do usuário e oferecer uma reflexão gentil '
      'e 3 dicas práticas para melhorar os próximos dias. '
      'REGRAS ÉTICAS ABSOLUTAS: '
      '1. NUNCA forneça diagnósticos médicos, psicológicos ou psiquiátricos. '
      '2. Se notar sinais de sofrimento extremo, sugira gentilmente que o usuário procure apoio profissional (terapia ou médicos). '
      '3. Use um tom encorajador, não julgador e valide os sentimentos do usuário. '
      '4. Seja conciso, usando tópicos para facilitar a leitura.'
    );

    String textoDiario = registros.map((r) => "Data: ${r.data} - Relato: ${r.anotacao}").join('\n\n');
    final prompt = 'Aqui estão meus últimos registros do diário. Por favor, analise e me dê dicas para os próximos dias:\n\n$textoDiario';

    // Lista de modelos ordenados do mais rápido/barato para os mais robustos (fallback)
    final modelosDisponiveis = [
      'models/gemini-flash-latest',
      'models/gemini-flash-lite-latest',
      'models/gemini-pro-latest'
    ];

    String? ultimoErro;

    // Tenta cada modelo sequencialmente
    for (String nomeModelo in modelosDisponiveis) {
      try {
        final model = GenerativeModel(
          model: nomeModelo,
          apiKey: apiKey,
          systemInstruction: instrucaoSistema,
        );

        final response = await model.generateContent([Content.text(prompt)]);
        
        if (response.text != null && response.text!.isNotEmpty) {
          return response.text!; // Retorna imediatamente se der sucesso
        }
      } catch (e) {
        ultimoErro = e.toString();
        // O código falhou neste modelo (ex: sobrecarga). O loop avança para tentar o próximo.
      }
    }

    // Se o loop terminar sem retornar, significa que TODOS os modelos falharam.
    return "Os servidores da IA estão sobrecarregados no momento. Por favor, tente novamente mais tarde.\n\nDetalhe técnico: $ultimoErro";
  }
}