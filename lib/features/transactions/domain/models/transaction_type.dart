/// Tipo de transacción financiera: Ingreso o Gasto.
enum TransactionType {
  income,
  expense;

  bool get isIncome => this == TransactionType.income;
  bool get isExpense => this == TransactionType.expense;

  String get displayName => switch (this) {
        TransactionType.income => 'Ingreso',
        TransactionType.expense => 'Gasto',
      };
}
