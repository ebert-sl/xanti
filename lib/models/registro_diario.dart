class RegistroDiario {
  const RegistroDiario({this.id, required this.data, required this.nivelAnsiedade, required this.anotacao});

  final int? id;
  final String data;
  final int nivelAnsiedade;
  final String anotacao;

  Map<String, dynamic> toMap() => {'id': id, 'data': data, 'nivelAnsiedade': nivelAnsiedade, 'anotacao': anotacao};

  factory RegistroDiario.fromMap(Map<String, dynamic> map) => RegistroDiario(
        id: map['id'] as int?,
        data: map['data'] as String,
        nivelAnsiedade: map['nivelAnsiedade'] as int,
        anotacao: map['anotacao'] as String,
      );
}
