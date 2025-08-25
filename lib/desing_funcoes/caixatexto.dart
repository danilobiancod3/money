import 'cores.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ModernTextField extends StatelessWidget {
  const ModernTextField({
    super.key,
    this.enabled,
    required this.controller,
    required this.keyboardType,
    this.maxLength,
    required this.hintText,
    this.textColor,
    this.validator,
    this.onChanged,
    this.onTap,
    this.inputFormatters,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.labelText,
    this.filled = true,
    this.fillColor,
  });

  final bool? enabled;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final int? maxLength;
  final String hintText;
  final Color? textColor;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final String? labelText;
  final bool filled;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveTextColor = textColor ?? (isDark ? AppColors.branco : AppColors.preto);
    final effectiveFillColor = fillColor ?? (isDark 
        ? AppColors.corcardescuro.withOpacity(0.1)
        : AppColors.cinzaClaro.withOpacity(0.3));

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled ?? true,
        maxLength: maxLength,
        validator: validator,
        onChanged: onChanged,
        onTap: onTap,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        obscureText: obscureText,
        style: TextStyle(
          color: effectiveTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          filled: filled,
          fillColor: effectiveFillColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          labelStyle: TextStyle(
            color: isDark ? AppColors.corcardletrasescuro : AppColors.cor3,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          hintStyle: TextStyle(
            color: isDark 
                ? AppColors.branco.withOpacity(0.6)
                : AppColors.preto.withOpacity(0.5),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: isDark 
                  ? AppColors.corcardletrasescuro.withOpacity(0.3)
                  : AppColors.cor3.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.cor1,
              width: 2.5,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: isDark 
                  ? AppColors.corcardletrasescuro.withOpacity(0.1)
                  : AppColors.cor3.withOpacity(0.1),
              width: 1,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.vermelho,
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.vermelho,
              width: 2.5,
            ),
          ),
          errorStyle: const TextStyle(
            color: AppColors.vermelho,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          counterStyle: TextStyle(
            color: isDark 
                ? AppColors.branco.withOpacity(0.6)
                : AppColors.preto.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
        cursorColor: AppColors.cor1,
        cursorWidth: 2,
        cursorRadius: const Radius.circular(2),
      ),
    );
  }
}

Widget caixaTexto(
  bool? bloqueado,
  BuildContext context,
  TextEditingController controle,
  TextInputType teclado,
  int tamanho,
  String texto, {
  Color? corTexto,
  String? Function(String?)? validator,
  Widget? prefixIcon,
  Widget? suffixIcon,
  String? labelText,
  bool filled = true,
  Color? fillColor,
}) {
  return ModernTextField(
    enabled: bloqueado,
    controller: controle,
    keyboardType: teclado,
    maxLength: tamanho == 0 ? null : tamanho,
    hintText: texto,
    textColor: corTexto,
    validator: validator,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    labelText: labelText,
    filled: filled,
    fillColor: fillColor,
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
  String? Function(String?)? validator,
  List<TextInputFormatter>? inputFormatters,
  int? maxLines,
  Widget? prefixIcon,
  Widget? suffixIcon,
  String? labelText,
  bool filled = true,
  Color? fillColor,
}) {
  return ModernTextField(
    enabled: bloqueado,
    controller: controle,
    keyboardType: teclado,
    maxLength: tamanho == 0 ? null : tamanho,
    hintText: texto,
    textColor: corTexto,
    validator: validator,
    onChanged: onChanged,
    inputFormatters: inputFormatters,
    maxLines: maxLines,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    labelText: labelText,
    filled: filled,
    fillColor: fillColor,
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
  Color? corTexto,
  Widget? prefixIcon,
  Widget? suffixIcon,
  String? labelText,
  bool filled = true,
  Color? fillColor,
}) {
  return ModernTextField(
    enabled: bloqueado,
    controller: controle,
    keyboardType: teclado,
    maxLength: tamanho == 0 ? null : tamanho,
    hintText: texto,
    textColor: corTexto,
    onTap: () => funcao(),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    labelText: labelText,
    filled: filled,
    fillColor: fillColor,
  );
}

Widget caixaTextoSenha(
  bool bloqueado,
  BuildContext context,
  TextEditingController controle,
  int tamanho,
  String texto, {
  Color? corTexto,
  String? Function(String?)? validator,
  String? labelText,
  bool filled = true,
  Color? fillColor,
}) {
  return StatefulBuilder(
    builder: (context, setState) {
      bool obscureText = true;
      
      return ModernTextField(
        enabled: bloqueado,
        controller: controle,
        keyboardType: TextInputType.visiblePassword,
        maxLength: tamanho == 0 ? null : tamanho,
        hintText: texto,
        textColor: corTexto,
        validator: validator,
        obscureText: obscureText,
        labelText: labelText,
        filled: filled,
        fillColor: fillColor,
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: AppColors.corcardletrasescuro,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility : Icons.visibility_off,
            color: Theme.of(context).brightness == Brightness.dark 
                ? AppColors.corcardletrasescuro 
                : AppColors.cor3,
          ),
          onPressed: () => setState(() => obscureText = !obscureText),
        ),
      );
    },
  );
}

Widget caixaTextoEmail(
  bool bloqueado,
  BuildContext context,
  TextEditingController controle,
  int tamanho,
  String texto, {
  Color? corTexto,
  String? Function(String?)? validator,
  String? labelText,
  bool filled = true,
  Color? fillColor,
}) {
  return ModernTextField(
    enabled: bloqueado,
    controller: controle,
    keyboardType: TextInputType.emailAddress,
    maxLength: tamanho == 0 ? null : tamanho,
    hintText: texto,
    textColor: corTexto,
    validator: validator,
    labelText: labelText,
    filled: filled,
    fillColor: fillColor,
    prefixIcon: const Icon(
      Icons.email_outlined,
      color: AppColors.corcardletrasescuro,
    ),
  );
}

Widget caixaTextoTelefone(
  bool bloqueado,
  BuildContext context,
  TextEditingController controle,
  int tamanho,
  String texto, {
  Color? corTexto,
  String? Function(String?)? validator,
  String? labelText,
  bool filled = true,
  Color? fillColor,
}) {
  return ModernTextField(
    enabled: bloqueado,
    controller: controle,
    keyboardType: TextInputType.phone,
    maxLength: tamanho == 0 ? null : tamanho,
    hintText: texto,
    textColor: corTexto,
    validator: validator,
    labelText: labelText,
    filled: filled,
    fillColor: fillColor,
    prefixIcon: const Icon(
      Icons.phone_outlined,
      color: AppColors.corcardletrasescuro,
    ),
  );
}

Widget caixaTextoNumerica(
  bool bloqueado,
  BuildContext context,
  TextEditingController controle,
  int tamanho,
  String texto, {
  Color? corTexto,
  String? Function(String?)? validator,
  String? labelText,
  bool filled = true,
  Color? fillColor,
}) {
  return ModernTextField(
    enabled: bloqueado,
    controller: controle,
    keyboardType: TextInputType.number,
    maxLength: tamanho == 0 ? null : tamanho,
    hintText: texto,
    textColor: corTexto,
    validator: validator,
    labelText: labelText,
    filled: filled,
    fillColor: fillColor,
    prefixIcon: const Icon(
      Icons.numbers,
      color: AppColors.corcardletrasescuro,
    ),
  );
}