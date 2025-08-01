class Bancos {
  int? id;
  String banco;
  String tipodeconta;
  double valornaconta;
  String icone;
  bool oculto;

  Bancos({
    this.id,
    required this.banco,
    required this.tipodeconta,
    required this.valornaconta,
    required this.icone,
    required this.oculto,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'banco': banco,
      'tipodeconta': tipodeconta,
      'valornaconta': valornaconta,
      'icone': icone,
      'oculto': oculto,
    };
  }

  factory Bancos.fromMap(Map<String, dynamic> map) {
  return Bancos(
    id: map['id'],
    banco: map['banco'],
    tipodeconta: map['tipodeconta'],
    valornaconta: map['valornaconta'] is double
        ? map['valornaconta']
        : double.tryParse(map['valornaconta'].toString()) ?? 0.0,
    icone: map['icone'],
    oculto: map['oculto'] == 1,
  );
}

  copyWith({required bool oculto}) {}
}
