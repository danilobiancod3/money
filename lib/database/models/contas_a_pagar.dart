class ContasAPagar {
  ContasAPagar({
    this.id,
    required this.nome,
    required this.tipoDeConta,
    required this.valorDaConta,
    required this.valorPago,
    required this.dataInicio,
    this.dataTermino,
    required this.parcelas,
    this.frequenciaEmDias,
    this.dataPrimeiraParcela,
    required this.icone,
    this.quitado = false,
    this.oculto = false,
  });

  factory ContasAPagar.fromMap(Map<String, dynamic> map) => ContasAPagar(
    id: map['id'],
    nome: map['nome'],
    tipoDeConta: map['tipoDeConta'],
    valorDaConta: map['valordaconta']?.toDouble() ?? 0.0,
    valorPago: map['valorPago']?.toDouble() ?? 0.0,
    dataInicio: DateTime.parse(map['dataInicio']),
    dataTermino: map['dataTermino'] != null ? DateTime.tryParse(map['dataTermino']) : null,
    parcelas: map['parcelas'] ?? 1,
    frequenciaEmDias: map['frequenciaEmDias'],
    dataPrimeiraParcela: map['dataPrimeiraParcela'] != null
        ? DateTime.tryParse(map['dataPrimeiraParcela'])
        : null,
    icone: map['icone'] ?? 'wallet',
    quitado: map['quitado'] == 1,
    oculto: map['oculto'] == 1,
  );

  int? id;
  String nome;
  String tipoDeConta;
  double valorDaConta;
  double valorPago;
  DateTime dataInicio;
  DateTime? dataTermino;
  int parcelas;
  int? frequenciaEmDias;
  DateTime? dataPrimeiraParcela;
  String icone;
  bool quitado;
  bool oculto;

  ContasAPagar copyWith({
    int? id,
    String? nome,
    String? tipoDeConta,
    double? valorDaConta,
    double? valorPago,
    DateTime? dataInicio,
    DateTime? dataTermino,
    int? parcelas,
    int? frequenciaEmDias,
    DateTime? dataPrimeiraParcela,
    String? icone,
    bool? quitado,
    bool? oculto,
  }) => ContasAPagar(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    tipoDeConta: tipoDeConta ?? this.tipoDeConta,
    valorDaConta: valorDaConta ?? this.valorDaConta,
    valorPago: valorPago ?? this.valorPago,
    dataInicio: dataInicio ?? this.dataInicio,
    dataTermino: dataTermino ?? this.dataTermino,
    parcelas: parcelas ?? this.parcelas,
    frequenciaEmDias: frequenciaEmDias ?? this.frequenciaEmDias,
    dataPrimeiraParcela: dataPrimeiraParcela ?? this.dataPrimeiraParcela,
    icone: icone ?? this.icone,
    quitado: quitado ?? this.quitado,
    oculto: oculto ?? this.oculto,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'nome': nome,
    'tipoDeConta': tipoDeConta,
    'valordaconta': valorDaConta,
    'valorPago': valorPago,
    'dataInicio': dataInicio.toIso8601String(),
    'dataTermino': dataTermino?.toIso8601String(),
    'parcelas': parcelas,
    'frequenciaEmDias': frequenciaEmDias,
    'dataPrimeiraParcela': dataPrimeiraParcela?.toIso8601String(),
    'icone': icone,
    'quitado': quitado ? 1 : 0,
    'oculto': oculto ? 1 : 0,
  };
}
