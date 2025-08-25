//import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'package:xml/xml.dart' as xml;
//import 'package:url_launcher/url_launcher.dart';
//import '/desing/caixatexto.dart';
// Variáveis globais

// Funções de texto
String maiusculo(String texto) => texto.toUpperCase().trim();
String minusculo(String texto) => texto.toLowerCase().trim();

// Limpa todos os caracteres não numéricos
String limparNumero(String valor) {
  return valor.replaceAll(RegExp(r'[^0-9]'), '');
}

String limparNumeroMenosPontoEVirguala(String valor) {
  return valor.replaceAll(RegExp(r'[^0-9,\.]'), '');
}

// Formata um valor double como moeda brasileira (BRL)
String brl(double valor) {
  final formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  return formatador.format(valor);
}

// Substitui vírgulas por pontos em números
String corrigeVirgula(String valor) {
  valor = valor.replaceAll(RegExp(r'[^0-9,\.]'), '');
  valor = valor.replaceAll(',', '.');
  final List<String> partes = valor.split('.');
  if (partes.length > 2) {
    final String parteInteira = partes.sublist(0, partes.length - 1).join();
    final String parteDecimal = partes.last;
    valor = '$parteInteira.$parteDecimal';
  }
  if (valor.trim().isEmpty || double.tryParse(valor) == null) {
    return '0.0';
  }
  return valor;
}

// Função que formata o telefone para o formato (XX) XXXXX-XXXX
String telefone(String numero) {
  // Remove todos os caracteres não numéricos
  numero = numero.replaceAll(RegExp(r'\D'), '');

  if (numero.length <= 8) {
    // Telefone local sem DDD (formato XXXX-XXXX)
    return numero.replaceAllMapped(
      RegExp(r'(\d{4})(\d{0,4})'),
      (Match m) => '${m[1]}${m[2]!.isNotEmpty ? '-${m[2]}' : ''}',
    );
  } else if (numero.length <= 9) {
    // Telefone local sem DDD (formato XXXX-XXXX)
    return numero.replaceAllMapped(
      RegExp(r'(\d{5})(\d{0,5})'),
      (Match m) => '${m[1]}${m[2]!.isNotEmpty ? '-${m[2]}' : ''}',
    );
  }else if (numero.length <= 10) {
    // Telefone com DDD e número de 8 dígitos (formato (XX) XXXX-XXXX)
    return numero.replaceAllMapped(
      RegExp(r'(\d{2})(\d{4})(\d{4})'),
      (Match m) => '(${m[1]}) ${m[2]}-${m[3]}',
    );
  } else {
    // Telefone com DDD e número de 9 dígitos (formato (XX) XXXXX-XXXX)
    return numero.replaceAllMapped(
      RegExp(r'(\d{2})(\d{5})(\d{4})'),
      (Match m) => '(${m[1]}) ${m[2]}-${m[3]}',
    );
  }
}

String data(String numero) {
  // Remove todos os caracteres não numéricos
  numero = numero.replaceAll(RegExp(r'\D'), '');

  // Limita o comprimento máximo a 8 dígitos
  if (numero.length > 8) {
    numero = numero.substring(0, 8);
  }

  // Insere as barras dinamicamente
  if (numero.length >= 5) {
    return '${numero.substring(0, 2)}/${numero.substring(2, 4)}/${numero.substring(4)}';
  } else if (numero.length >= 3) {
    return '${numero.substring(0, 2)}/${numero.substring(2)}';
  } else {
    return numero;
  }
}


// Formata CPF ou CNPJ
String formatarDocumento(String documento) {
  // Remove tudo que não for número
  documento = documento.replaceAll(RegExp(r'\D'), '');

  if (documento.length <= 11) {
    // Formatar como CPF (suporta até 11 dígitos)
    return documento.replaceAllMapped(
      RegExp(r'(\d{0,3})(\d{0,3})(\d{0,3})(\d{0,2})'),
      (Match m) {
        final part1 = m[1] ?? '';
        final part2 = m[2] ?? '';
        final part3 = m[3] ?? '';
        final part4 = m[4] ?? '';
        String result = '';
        if (part1.isNotEmpty) result += part1;
        if (part2.isNotEmpty) result += (result.isNotEmpty ? '.' : '') + part2;
        if (part3.isNotEmpty) result += (result.isNotEmpty ? '.' : '') + part3;
        if (part4.isNotEmpty) result += '-$part4';
        return result;
      },
    );
  } else {
    // Formatar como CNPJ (suporta até 14 dígitos)
    return documento.replaceAllMapped(
      RegExp(r'(\d{0,2})(\d{0,3})(\d{0,3})(\d{0,4})(\d{0,2})'),
      (Match m) {
        final part1 = m[1] ?? '';
        final part2 = m[2] ?? '';
        final part3 = m[3] ?? '';
        final part4 = m[4] ?? '';
        final part5 = m[5] ?? '';
        String result = '';
        if (part1.isNotEmpty) result += part1;
        if (part2.isNotEmpty) result += (result.isNotEmpty ? '.' : '') + part2;
        if (part3.isNotEmpty) result += (result.isNotEmpty ? '.' : '') + part3;
        if (part4.isNotEmpty) result += (result.isNotEmpty ? '/' : '') + part4;
        if (part5.isNotEmpty) result += '-$part5';
        return result;
      },
    );
  }
}

// Formata CEP no padrão 00000-000
String formatarCEP(String valor) {
  valor = limparNumero(valor);
  if (valor.length == 8) {
    return '${valor.substring(0, 5)}-${valor.substring(5)}';
  }
  return valor;
}


// Converte valor numérico de campo para moeda BRL
String valorReal(String valor) {
  String texto = limparNumero(valor);

  if (texto.isEmpty) return '';

  // Garante que o número não ultrapasse 10 dígitos
  if (texto.length > 10) {
    texto = texto.substring(0, 10);
  }

  // Preenche com zeros à esquerda se necessário
  while (texto.length < 3) {
    texto = '0$texto';
  }

  // Insere ponto antes dos dois últimos dígitos
  final String textoComPonto = '${texto.substring(0, texto.length - 2)}.${texto.substring(texto.length - 2)}';

  final double valorNumerico = double.tryParse(textoComPonto) ?? 0.0;
  return brl(valorNumerico);
}

/*Future<void> whatsapp(BuildContext context, String mensagem, String fone) async {
  fone = limparNumero(fone);

  if (fone.length != 11) {
    final txtNumero = TextEditingController(text: fone);

    final resultado = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('DDD não informado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Por favor, informe o DDD e confirme o número."),
            const SizedBox(height: 10),
            caixaTextoBordaOnChanged(
              true,
              context,
              txtNumero,
              TextInputType.phone,
              15,
              "(00) 00000-0000",
              onChanged: (value) {
                txtNumero.text = telefone(txtNumero.text);
              },
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(txtNumero.text);
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );

    if (resultado == null) return;

    fone = limparNumero(txtNumero.text);
    txtNumero.clear();
  }

  final whatsappUrl = Uri.parse("whatsapp://send?phone=55$fone&text=$mensagem");

  final launched = await launchUrl(whatsappUrl);

  // ⚠️ Verificação segura antes de usar context após await
  if (!context.mounted) return;

  if (!launched) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Não foi possível abrir o WhatsApp.')),
    );
  }
}

String gerarXML(List<Map<String, dynamic>> dados) {
  final builder = xml.XmlBuilder();

  builder.processing('xml', 'version="1.0" encoding="UTF-8"');
  builder.element('produtos', nest: () {
    for (var item in dados) {
      builder.element('produto', nest: () {
        item.forEach((chave, valor) {
          builder.element(chave, nest: valor.toString());
        });
      });
    }
  });

  final document = builder.buildDocument();
  return document.toXmlString(pretty: true);
}*/




// Placeholder para função futura
void fechar() {}