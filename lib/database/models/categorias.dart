class Categorias {
  int? id;
  String tipo;
  String categoria;

  Categorias({
    this.id,
    required this.tipo,
    required this.categoria,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo': tipo,
      'categoria': categoria,
    };
  }

  factory Categorias.fromMap(Map<String, dynamic> map) {
  return Categorias(
    id: map['id'],
    tipo: map['tipo'],
    categoria: map['categoria'],
  );
}
}