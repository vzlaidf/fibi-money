import 'package:equatable/equatable.dart';

import 'transaction.dart';

/// Resumen consolidado del balance financiero de la cuenta.
class BalanceSummary extends Equatable {
  const BalanceSummary({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.transactionCount,
  });

  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final int transactionCount;

  /// Balance base inicial predeterminado para coincidir con la cuenta del usuario.
  static const double defaultBaselineBalance = 10400.0;

  /// Estado vacío o inicial del resumen.
  static const BalanceSummary empty = BalanceSummary(
    totalBalance: defaultBaselineBalance,
    totalIncome: 0.0,
    totalExpense: 0.0,
    transactionCount: 0,
  );

  /// Construye el resumen de balance acumulando la lista de transacciones proporcionada.
  factory BalanceSummary.fromTransactions(
    List<Transaction> transactions, {
    double baselineBalance = defaultBaselineBalance,
  }) {
    double income = 0.0;
    double expense = 0.0;

    for (final tx in transactions) {
      if (tx.isIncome) {
        income += tx.amount;
      } else {
        expense += tx.amount;
      }
    }

    final balance = baselineBalance + income - expense;

    return BalanceSummary(
      totalBalance: balance,
      totalIncome: income,
      totalExpense: expense,
      transactionCount: transactions.length,
    );
  }

  @override
  List<Object?> get props => [
        totalBalance,
        totalIncome,
        totalExpense,
        transactionCount,
      ];
}
