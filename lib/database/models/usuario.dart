class Usuario {
  int? id;
  String nomeUsuario, nomefantazia, enderecoUsuario, emailUsuario, telefoneUsuario, cpfcnpjUsuario;
  int grafico, modoescuro;
  bool  mostrarValorTotal;
  Usuario(
      {this.id,
      required this.nomeUsuario,
      required this.nomefantazia,
      required this.enderecoUsuario,
      required this.emailUsuario,
      required this.telefoneUsuario,
      required this.cpfcnpjUsuario,
      required this.mostrarValorTotal,
      required this.grafico,
      required this.modoescuro,});


  // Converte o objeto em um Map para poder salvar no banco de dados
  Map<String, dynamic> toMap() {
    return {
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

  // Converte o Map de volta para um objeto Usuario
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
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
  }
}
