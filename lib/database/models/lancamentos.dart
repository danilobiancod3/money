// Modelo de dados correto para os lançamentos no app Money

class Lancamento {
  Lancamento({
    this.id,
    required this.entrada,
    required this.nome,
    required this.categoria,
    required this.valor,
    required this.descricao,
    required this.data,
    required this.idbanco,
  });

  factory Lancamento.fromMap(Map<String, dynamic> map) => Lancamento(
    id: map['id'],
    entrada: map['entrada'] == 1,
    nome: map['nome'],
    categoria: map['categoria'],
    valor: map['valor'],
    descricao: map['descricao'],
    data: DateTime.parse(map['data']),
    idbanco: map['idbanco'],
  );

  int? id;
  bool entrada;
  String nome;
  String categoria;
  double valor;
  String descricao;
  DateTime data;
  int idbanco;

  Map<String, dynamic> toMap() => {
    'id': id,
    'entrada': entrada ? 1 : 0,
    'nome': nome,
    'categoria': categoria,
    'valor': valor,
    'descricao': descricao,
    'data': data.toIso8601String(),
    'idbanco': idbanco,
  };
}