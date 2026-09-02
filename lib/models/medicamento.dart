class Medicamento {
  final int? id;
  final String nome;
  final String diasSemana;
  final String horario;

  Medicamento({this.id, required this.nome, required this.diasSemana, required this.horario});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'diasSemana': diasSemana,
      'horario': horario,
    };
  }

  factory Medicamento.fromMap(Map<String, dynamic> map) {
    return Medicamento(
      id: map['id'],
      nome: map['nome'],
      diasSemana: map['diasSemana'],
      horario: map['horario'],
    );
  }
}