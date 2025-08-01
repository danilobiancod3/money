class Investimento {
  int? id;
  String nome;
  double valor;
  DateTime data;
  DateTime? dataFim;
  String? descricao;
  int idBanco;
  int idconta;
  bool recorrente;
  String? recorrencia;
  bool oculto;


  Investimento({
    this.id,
    required this.nome,
    required this.valor,
    required this.data,
    this.dataFim,
    this.descricao,
    required this.idBanco,
    required this.idconta,
    this.recorrente = false,
    this.recorrencia,
    required this.oculto,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'valor': valor,
      'data': data.toIso8601String(),
      'dataFim': dataFim?.toIso8601String(),
      'descricao': descricao,
      'idBanco': idBanco,
      'idconta': idconta,
      'recorrente': recorrente ? 1 : 0,
      'recorrencia': recorrencia,
      'oculto': oculto,
    };
  }

  factory Investimento.fromMap(Map<String, dynamic> map) {
    return Investimento(
      id: map['id'] != null ? map['id'] as int : null,
      nome: map['nome'] ?? '',
      valor: (map['valor'] as num?)?.toDouble() ?? 0.0,
      data: DateTime.tryParse(map['data'] ?? '') ?? DateTime.now(),
      dataFim: map['dataFim'] != null ? DateTime.tryParse(map['dataFim']) : null,
      descricao: map['descricao'],
      idBanco: map['idBanco'] ?? 0,
      idconta: map['idconta'] ?? 0,
      recorrente: (map['recorrente'] ?? 0) == 1,
      recorrencia: map['recorrencia'],
      oculto: map['oculto'] == 1,
    );
  }
}
