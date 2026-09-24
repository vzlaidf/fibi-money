import '../../domain/models/balance_summary.dart';
import '../../domain/models/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/local_transaction_datasource.dart';

/// Implementación del repositorio de transacciones utilizando la fuente local.
class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl({
    LocalTransactionDatasource? datasource,
  }) : _datasource = datasource ?? LocalTransactionDatasource();

  final LocalTransactionDatasource _datasource;

  @override
  Stream<List<Transaction>> getTransactions() {
    return _datasource.transactionsStream;
  }

  @override
  Future<void> saveTransaction(Transaction transaction) {
    return _datasource.save(transaction);
  }

  @override
  Future<void> deleteTransaction(String id) {
    return _datasource.delete(id);
  }

  @override
  Future<BalanceSummary> getBalanceSummary() async {
    return BalanceSummary.fromTransactions(_datasource.currentTransactions);
  }
}
