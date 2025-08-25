import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/formatters.dart';
import '../../database/models/lancamentos.dart';
import '../../database/models/bancos.dart';
import '../../database/models/contas_a_pagar.dart';
import '../../database/models/investimentos.dart';

class ExportService {
  static const int _maxFileNameLength = 100;
  static const int _maxDataSize = 10000;

  static Future<bool> requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<String> getExportDirectory() async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('Diretório de armazenamento não disponível');
      }
      
      final exportDir = Directory('${directory.path}/MoneyExports');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }
      return exportDir.path;
    } catch (e) {
      throw ExportException('Erro ao obter diretório de exportação: $e');
    }
  }

  static Future<String> exportToExcel({
    required List<Lancamento> lancamentos,
    required List<Bancos> bancos,
    required List<ContasAPagar> contasAPagar,
    required List<Investimento> investimentos,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      _validateExportData(lancamentos, bancos, contasAPagar, investimentos);
      
      final excel = Excel.createExcel();
      
      await _createLancamentosSheet(excel, lancamentos);
      await _createBancosSheet(excel, bancos);
      await _createContasAPagarSheet(excel, contasAPagar);
      await _createInvestimentosSheet(excel, investimentos);
      await _createResumoSheet(excel, lancamentos, startDate, endDate);

      final exportDir = await getExportDirectory();
      final fileName = _sanitizeFileName('relatorio_financeiro_${Formatters.formatDate(startDate)}_${Formatters.formatDate(endDate)}.xlsx');
      final filePath = '$exportDir/$fileName';
      
      final file = File(filePath);
      final bytes = excel.encode();
      if (bytes == null) {
        throw ExportException('Erro ao codificar arquivo Excel');
      }
      
      await file.writeAsBytes(bytes);
      return filePath;
    } catch (e) {
      throw ExportException('Erro ao exportar para Excel: $e');
    }
  }

  static Future<String> exportToPDF({
    required List<Lancamento> lancamentos,
    required List<Bancos> bancos,
    required List<ContasAPagar> contasAPagar,
    required List<Investimento> investimentos,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      _validateExportData(lancamentos, bancos, contasAPagar, investimentos);
      
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            _buildPDFHeader(),
            _buildPDFResumo(lancamentos, startDate, endDate),
            _buildPDFLancamentos(lancamentos),
            _buildPDFBancos(bancos),
            _buildPDFContasAPagar(contasAPagar),
            _buildPDFInvestimentos(investimentos),
          ],
        ),
      );

      final exportDir = await getExportDirectory();
      final fileName = _sanitizeFileName('relatorio_financeiro_${Formatters.formatDate(startDate)}_${Formatters.formatDate(endDate)}.pdf');
      final filePath = '$exportDir/$fileName';
      
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      
      return filePath;
    } catch (e) {
      throw ExportException('Erro ao exportar para PDF: $e');
    }
  }

  static Future<void> shareFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw ExportException('Arquivo não encontrado: $filePath');
      }
      await Share.shareXFiles([XFile(filePath)]);
    } catch (e) {
      throw ExportException('Erro ao compartilhar arquivo: $e');
    }
  }

  static void _validateExportData(
    List<Lancamento> lancamentos,
    List<Bancos> bancos,
    List<ContasAPagar> contasAPagar,
    List<Investimento> investimentos,
  ) {
    if (lancamentos.length > _maxDataSize) {
      throw ExportException('Quantidade de lançamentos excede o limite permitido');
    }
    if (bancos.length > _maxDataSize) {
      throw ExportException('Quantidade de bancos excede o limite permitido');
    }
    if (contasAPagar.length > _maxDataSize) {
      throw ExportException('Quantidade de contas a pagar excede o limite permitido');
    }
    if (investimentos.length > _maxDataSize) {
      throw ExportException('Quantidade de investimentos excede o limite permitido');
    }
  }

  static String _sanitizeFileName(String fileName) {
    final sanitized = fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    if (sanitized.length > _maxFileNameLength) {
      return sanitized.substring(0, _maxFileNameLength);
    }
    return sanitized;
  }

  static Future<void> _createLancamentosSheet(Excel excel, List<Lancamento> lancamentos) async {
    try {
      final sheet = excel['Lançamentos'];
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = 'Data';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value = 'Tipo';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value = 'Nome';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value = 'Categoria';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0)).value = 'Valor';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0)).value = 'Descrição';
      
      for (int i = 0; i < lancamentos.length; i++) {
        final lancamento = lancamentos[i];
        final row = i + 1;
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = Formatters.formatDate(lancamento.data);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = lancamento.entrada ? 'Entrada' : 'Saída';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = _sanitizeString(lancamento.nome);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = _sanitizeString(lancamento.categoria);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value = lancamento.valor;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row)).value = _sanitizeString(lancamento.descricao ?? '');
      }
    } catch (e) {
      throw ExportException('Erro ao criar planilha de lançamentos: $e');
    }
  }

  static Future<void> _createBancosSheet(Excel excel, List<Bancos> bancos) async {
    try {
      final sheet = excel['Contas'];
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = 'Banco';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value = 'Tipo de Conta';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value = 'Saldo';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value = 'Visível';
      
      for (int i = 0; i < bancos.length; i++) {
        final banco = bancos[i];
        final row = i + 1;
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = _sanitizeString(banco.banco);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = _sanitizeString(banco.tipodeconta);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = banco.valornaconta;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = banco.oculto ? 'Não' : 'Sim';
      }
    } catch (e) {
      throw ExportException('Erro ao criar planilha de bancos: $e');
    }
  }

  static Future<void> _createContasAPagarSheet(Excel excel, List<ContasAPagar> contasAPagar) async {
    try {
      final sheet = excel['Contas a Pagar'];
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = 'Nome';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value = 'Tipo de Conta';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value = 'Valor da Conta';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value = 'Data de Início';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0)).value = 'Status';
      
      for (int i = 0; i < contasAPagar.length; i++) {
        final conta = contasAPagar[i];
        final row = i + 1;
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = _sanitizeString(conta.nome);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = _sanitizeString(conta.tipoDeConta);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = conta.valorDaConta;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = Formatters.formatDate(conta.dataInicio);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value = conta.quitado ? 'Quitado' : 'Pendente';
      }
    } catch (e) {
      throw ExportException('Erro ao criar planilha de contas a pagar: $e');
    }
  }

  static Future<void> _createInvestimentosSheet(Excel excel, List<Investimento> investimentos) async {
    try {
      final sheet = excel['Investimentos'];
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = 'Nome';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value = 'Descrição';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value = 'Valor';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value = 'Data';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0)).value = 'Recorrente';
      
      for (int i = 0; i < investimentos.length; i++) {
        final investimento = investimentos[i];
        final row = i + 1;
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = _sanitizeString(investimento.nome);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = _sanitizeString(investimento.descricao ?? 'Sem descrição');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = investimento.valor;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = Formatters.formatDate(investimento.data);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value = investimento.recorrente ? 'Sim' : 'Não';
      }
    } catch (e) {
      throw ExportException('Erro ao criar planilha de investimentos: $e');
    }
  }

  static Future<void> _createResumoSheet(Excel excel, List<Lancamento> lancamentos, DateTime startDate, DateTime endDate) async {
    try {
      final sheet = excel['Resumo'];
      
      final receitas = lancamentos.where((l) => l.entrada).fold(0.0, (sum, l) => sum + l.valor);
      final despesas = lancamentos.where((l) => !l.entrada).fold(0.0, (sum, l) => sum + l.valor);
      final saldo = receitas - despesas;
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = 'Período';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value = '${Formatters.formatDate(startDate)} a ${Formatters.formatDate(endDate)}';
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2)).value = 'Receitas';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2)).value = receitas;
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3)).value = 'Despesas';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 3)).value = despesas;
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 4)).value = 'Saldo';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 4)).value = saldo;
    } catch (e) {
      throw ExportException('Erro ao criar planilha de resumo: $e');
    }
  }

  static String _sanitizeString(String input) {
    if (input.length > 255) {
      return input.substring(0, 255);
    }
    return input;
  }

  static pw.Widget _buildPDFHeader() {
    return pw.Header(
      level: 0,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Relatório Financeiro', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.Text('Gerado em: ${Formatters.formatDateTime(DateTime.now())}', style: const pw.TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  static pw.Widget _buildPDFResumo(List<Lancamento> lancamentos, DateTime startDate, DateTime endDate) {
    final receitas = lancamentos.where((l) => l.entrada).fold(0.0, (sum, l) => sum + l.valor);
    final despesas = lancamentos.where((l) => !l.entrada).fold(0.0, (sum, l) => sum + l.valor);
    final saldo = receitas - despesas;
    
    return pw.Container(
      margin: const pw.EdgeInsets.all(10),
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Resumo do Período', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text('Período: ${Formatters.formatDate(startDate)} a ${Formatters.formatDate(endDate)}'),
          pw.Text('Receitas: ${Formatters.formatCurrency(receitas)}'),
          pw.Text('Despesas: ${Formatters.formatCurrency(despesas)}'),
          pw.Text('Saldo: ${Formatters.formatCurrency(saldo)}', 
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: saldo >= 0 ? PdfColors.green : PdfColors.red)),
        ],
      ),
    );
  }

  static pw.Widget _buildPDFLancamentos(List<Lancamento> lancamentos) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            pw.Text('Data', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Tipo', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Nome', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Valor', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ],
        ),
        ...lancamentos.map((l) => pw.TableRow(
          children: [
            pw.Text(Formatters.formatDate(l.data)),
            pw.Text(l.entrada ? 'Entrada' : 'Saída'),
            pw.Text(_sanitizeString(l.nome)),
            pw.Text(Formatters.formatCurrency(l.valor)),
          ],
        )),
      ],
    );
  }

  static pw.Widget _buildPDFBancos(List<Bancos> bancos) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            pw.Text('Banco', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Tipo', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Saldo', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ],
        ),
        ...bancos.map((b) => pw.TableRow(
          children: [
            pw.Text(_sanitizeString(b.banco)),
            pw.Text(_sanitizeString(b.tipodeconta)),
            pw.Text(Formatters.formatCurrency(b.valornaconta)),
          ],
        )),
      ],
    );
  }

  static pw.Widget _buildPDFContasAPagar(List<ContasAPagar> contasAPagar) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            pw.Text('Nome', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Tipo', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Valor', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ],
        ),
        ...contasAPagar.map((c) => pw.TableRow(
          children: [
            pw.Text(_sanitizeString(c.nome)),
            pw.Text(_sanitizeString(c.tipoDeConta)),
            pw.Text(Formatters.formatCurrency(c.valorDaConta)),
            pw.Text(c.quitado ? 'Quitado' : 'Pendente'),
          ],
        )),
      ],
    );
  }

  static pw.Widget _buildPDFInvestimentos(List<Investimento> investimentos) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            pw.Text('Nome', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Descrição', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Valor', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Recorrente', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ],
        ),
        ...investimentos.map((i) => pw.TableRow(
          children: [
            pw.Text(_sanitizeString(i.nome)),
            pw.Text(_sanitizeString(i.descricao ?? 'Sem descrição')),
            pw.Text(Formatters.formatCurrency(i.valor)),
            pw.Text(i.recorrente ? 'Sim' : 'Não'),
          ],
        )),
      ],
    );
  }
}

class ExportException implements Exception {
  ExportException(this.message);

  final String message;

  @override
  String toString() => 'ExportException: $message';
}
