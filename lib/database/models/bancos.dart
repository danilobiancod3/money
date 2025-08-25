class Bancos {
  Bancos({
    this.id,
    required this.banco,
    required this.tipodeconta,
    required this.valornaconta,
    required this.icone,
    required this.oculto,
    this.agencia,
    this.numeroConta,
    this.descricao,
  });

  factory Bancos.fromMap(Map<String, dynamic> map) => Bancos(
    id: map['id'] != null ? map['id'] as int : null,
    banco: map['banco']?.toString() ?? '',
    tipodeconta: map['tipodeconta']?.toString() ?? '',
    valornaconta: map['valornaconta'] is double
        ? map['valornaconta']
        : double.tryParse(map['valornaconta']?.toString() ?? '0') ?? 0.0,
    icone: map['icone']?.toString() ?? '',
    oculto: map['oculto'] == 1 || map['oculto'] == true,
    agencia: map['agencia']?.toString(),
    numeroConta: map['numero_conta']?.toString(),
    descricao: map['descricao']?.toString(),
  );

  int? id;
  String banco;
  String tipodeconta;
  double valornaconta;
  String icone;
  bool oculto;
  String? agencia;
  String? numeroConta;
  String? descricao;

  Map<String, dynamic> toMap() => {
    'id': id,
    'banco': banco,
    'tipodeconta': tipodeconta,
    'valornaconta': valornaconta,
    'icone': icone,
    'oculto': oculto ? 1 : 0,
    'agencia': agencia,
    'numero_conta': numeroConta,
    'descricao': descricao,
  };

  Bancos copyWith({
    int? id,
    String? banco,
    String? tipodeconta,
    double? valornaconta,
    String? icone,
    bool? oculto,
    String? agencia,
    String? numeroConta,
    String? descricao,
  }) => Bancos(
    id: id ?? this.id,
    banco: banco ?? this.banco,
    tipodeconta: tipodeconta ?? this.tipodeconta,
    valornaconta: valornaconta ?? this.valornaconta,
    icone: icone ?? this.icone,
    oculto: oculto ?? this.oculto,
    agencia: agencia ?? this.agencia,
    numeroConta: numeroConta ?? this.numeroConta,
    descricao: descricao ?? this.descricao,
  );
}
