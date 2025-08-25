import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );
  
  static final NumberFormat _numberFormatter = NumberFormat.decimalPattern('pt_BR');
  
  static final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _monthYearFormatter = DateFormat('MMM/yyyy', 'pt_BR');
  
  static String formatCurrency(double value) {
    if (value.isNaN || value.isInfinite) {
      return 'R\$ 0,00';
    }
    try {
      return _currencyFormatter.format(value);
    } catch (e) {
      return 'R\$ 0,00';
    }
  }
  
  static String formatNumber(double value) {
    if (value.isNaN || value.isInfinite) {
      return '0';
    }
    try {
      return _numberFormatter.format(value);
    } catch (e) {
      return '0';
    }
  }
  
  static String formatDate(DateTime date) {
    try {
      return _dateFormatter.format(date);
    } catch (e) {
      return 'Data inválida';
    }
  }
  
  static String formatDateTime(DateTime dateTime) {
    try {
      return _dateTimeFormatter.format(dateTime);
    } catch (e) {
      return 'Data/hora inválida';
    }
  }
  
  static String formatMonthYear(DateTime date) {
    try {
      return _monthYearFormatter.format(date);
    } catch (e) {
      return 'Mês/ano inválido';
    }
  }
  
  static String formatPercentage(double value) {
    if (value.isNaN || value.isInfinite) {
      return '0,0%';
    }
    try {
      return '${value.toStringAsFixed(1)}%';
    } catch (e) {
      return '0,0%';
    }
  }
  
  static String formatFileSize(int bytes) {
    if (bytes < 0) {
      return '0 B';
    }
    
    try {
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    } catch (e) {
      return '0 B';
    }
  }
}
