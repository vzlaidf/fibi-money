import 'package:intl/intl.dart';

/// Formateador de moneda y números para Fibi Money.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: r'$',
    decimalDigits: 2,
  );

  static final NumberFormat _compactCurrencyFormat = NumberFormat.currency(
    symbol: r'$',
    decimalDigits: 0,
  );

  /// Formatea un valor numérico como moneda estándar (ej. $12,450.00).
  static String format(double amount) {
    return _currencyFormat.format(amount);
  }

  /// Formatea un valor numérico con prefijo de signo (+ o -).
  /// Útil para ingresos (+$3,200) o gastos (-$1,150).
  static String formatSigned(double amount, {required bool isIncome}) {
    final formatted = _currencyFormat.format(amount.abs());
    if (amount == 0) return formatted;
    return isIncome ? '+$formatted' : '-$formatted';
  }

  /// Formatea un valor numérico sin centavos si son 0 (ej. $3,200).
  static String formatWholeOrDecimal(double amount) {
    if (amount % 1 == 0) {
      return _compactCurrencyFormat.format(amount);
    }
    return _currencyFormat.format(amount);
  }

  /// Formatea un valor numérico sin centavos con signo (ej. +$3,200 o -$1,150).
  static String formatSignedWholeOrDecimal(double amount, {required bool isIncome}) {
    final formatted = formatWholeOrDecimal(amount.abs());
    if (amount == 0) return formatted;
    return isIncome ? '+$formatted' : '-$formatted';
  }

  /// Formatea una fecha de forma legible (ej. "Hoy", "Ayer", o "18 sep 2026").
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(date.year, date.month, date.day);

    if (itemDate == today) {
      return 'Hoy';
    } else if (itemDate == today.subtract(const Duration(days: 1))) {
      return 'Ayer';
    } else {
      return DateFormat('d MMM yyyy').format(date);
    }
  }
}
