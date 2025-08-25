class Usuario {
  Usuario({
    this.id,
    required this.nomeUsuario,
    required this.nomefantazia,
    required this.enderecoUsuario,
    required this.emailUsuario,
    required this.telefoneUsuario,
    required this.cpfcnpjUsuario,
    required this.mostrarValorTotal,
    required this.grafico,
    required this.modoescuro,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) => Usuario(
    id: map['id'],
    nomeUsuario: map['nomeUsuario'],
    nomefantazia: map['nomefantazia'],
    enderecoUsuario: map['enderecoUsuario'],
    emailUsuario: map['emailUsuario'],
    telefoneUsuario: map['telefoneUsuario'],
    cpfcnpjUsuario: map['cpfcnpjUsuario'],
    modoescuro: map['modoescuro'],
    mostrarValorTotal: map['mostrarValorTotal'] == 1,
    grafico: map['grafico'],
  );

  int? id;
  String nomeUsuario, nomefantazia, enderecoUsuario, emailUsuario, telefoneUsuario, cpfcnpjUsuario;
  int grafico, modoescuro;
  bool mostrarValorTotal;

  Map<String, dynamic> toMap() => {
    'id': id,
    'nomeUsuario': nomeUsuario,
    'nomefantazia': nomefantazia,
    'enderecoUsuario': enderecoUsuario,
    'emailUsuario': emailUsuario,
    'telefoneUsuario': telefoneUsuario,
    'cpfcnpjUsuario': cpfcnpjUsuario,
    'modoescuro': modoescuro,
    'mostrarValorTotal': mostrarValorTotal ? 1 : 0,
    'grafico': grafico,
  };
}
