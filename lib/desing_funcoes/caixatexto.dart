import 'cores.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// File: lib/desing_funcoes/caixatexto.dart

Widget caixaTexto(
  bool? bloqueado,
  BuildContext context,
  TextEditingController controle,
  TextInputType teclado,
  int tamanho,
  String texto, {
  Color? corTexto, // Cor do texto, vai pegar a cor do tema se não for passado
  // Adicione o parâmetro validator aqui
  String? Function(String?)? validator, // <--- ADICIONE ESTA LINHA
}) {
  // Pega a cor do texto com base no tema atual (claro ou escuro)
  // Certifique-se de que AppColors esteja definido ou remova se não for usado.
  final textColor = corTexto ?? (Theme.of(context).brightness == Brightness.dark
      ? Colors.white // Substitua AppColors.branco se não estiver definido
      : Colors.black87);
  
  return TextFormField( // <--- Mude de TextField para TextFormField
    controller: controle,
    keyboardType: teclado,
    enabled: bloqueado ?? true, // Use true como padrão para 'enabled' se for null
    maxLength: tamanho == 0 ? null : tamanho,
    // Passe o validator para o TextFormField
    validator: validator, // <--- ADICIONE ESTA LINHA
    decoration: InputDecoration(
      hintText: texto,
      hintStyle: const TextStyle(fontSize: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.blue : Colors.blue),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.blue : Colors.blue),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.blue : Colors.blue,
        ),
      ),
      errorBorder: OutlineInputBorder( // Adicione um estilo para borda de erro
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder( // Adicione um estilo para borda de erro focada
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    ),    
    cursorColor: Theme.of(context).brightness == Brightness.dark ? Colors.blue : Colors.blueAccent,
    style: TextStyle(color: textColor, fontSize: 14),
  );
}

Widget caixaTextoOnChanged(
  bool bloqueado,
  BuildContext context,
  TextEditingController controle,
  TextInputType teclado,
  int tamanho,
  String texto, {
  required void Function(String) onChanged,
  Color? corTexto,
  String? Function(String?)? validator, // <-- Adicionado o validador aqui
  List<TextInputFormatter>? inputFormatters, // <-- Adicionado inputFormatters
  int? maxLines, // <-- Adicionado maxLines
}) {
  final textColor = corTexto ??
      (Theme.of(context).brightness == Brightness.dark
          ? AppColors.branco // Supondo que AppColors.branco esteja definido
          : Colors.black87);

  return TextFormField( // <-- Mudado para TextFormField
    controller: controle,
    keyboardType: teclado,
    enabled: bloqueado,
    maxLength: tamanho == 0 ? null : tamanho,
    onChanged: onChanged,
    validator: validator, // <-- Passando o validador
    inputFormatters: inputFormatters, // <-- Passando inputFormatters
    maxLines: maxLines, // <-- Passando maxLines
    decoration: InputDecoration(
      hintText: texto,
      hintStyle: const TextStyle(fontSize: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.blue
                : Colors.blue),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.blue
                : Colors.blue),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.blue
              : Colors.blue,
        ),
      ),
      // Adiciona o estilo para a borda de erro
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    ),
    cursorColor: Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.blueAccent,
    style: TextStyle(color: textColor, fontSize: 14),
  );
}

Widget caixaTextoOnTap(
  bool bloqueado,
  BuildContext context,
  TextEditingController controle,
  TextInputType teclado,
  int tamanho,
  String texto,
  Function funcao, {
  Color? corTexto, // Cor do texto
}) {
  // Pega a cor do texto com base no tema atual (claro ou escuro)
  final textColor = corTexto ?? (Theme.of(context).brightness == Brightness.dark
      ? AppColors.branco
      : Colors.black87);

  return TextField(
    controller: controle,
    keyboardType: teclado,
    enabled: bloqueado,
    maxLength: tamanho == 0 ? null : tamanho,
    decoration: InputDecoration(
      hintText: texto,
      hintStyle: const TextStyle( fontSize: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.blue: Colors.blue),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.blue : Colors.blue),
      ),
      disabledBorder: OutlineInputBorder(  // <-- Adicione isso
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(
          color: Theme.of(context).brightness == Brightness.dark ?  Colors.blue : Colors.blue,
          //width: 2,
        ),
      ),
    ),
    cursorColor: Theme.of(context).brightness == Brightness.dark ? Colors.blue : Colors.blueAccent,
    style: TextStyle(color: textColor, fontSize: 14),
    onTap: () => funcao(),
  );
}