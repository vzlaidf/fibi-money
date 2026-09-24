import '../models/balance_summary.dart';
import '../models/transaction.dart';

/// Contrato de repositorio abstracto para operaciones sobre transacciones financieras.
abstract interface class TransactionRepository {
  /// Emite un flujo reactivo con la lista actualizada de transacciones.
  Stream<List<Transaction>> getTransactions();

  /// Guarda o actualiza una transacción.
  Future<void> saveTransaction(Transaction transaction);

  /// Elimina una transacción por su identificador único.
  Future<void> deleteTransaction(String id);

  /// Obtiene el resumen de balance consolidado actual.
  Future<BalanceSummary> getBalanceSummary();
}
