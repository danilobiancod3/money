class Categorias {
  Categorias({
    this.id,
    required this.tipo,
    required this.categoria,
  });

  factory Categorias.fromMap(Map<String, dynamic> map) => Categorias(
    id: map['id'],
    tipo: map['tipo'],
    categoria: map['categoria'],
  );

  int? id;
  String tipo;
  String categoria;

  Map<String, dynamic> toMap() => {
    'id': id,
    'tipo': tipo,
    'categoria': categoria,
  };
}