import 'dart:async';

import '../../domain/models/balance_summary.dart';
import '../../domain/models/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/firestore_transaction_datasource.dart';
import '../datasources/local_transaction_datasource.dart';

/// Implementación del repositorio de transacciones que soporta Cloud Firestore y fuente local.
class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl({
    String? userId,
    FirestoreTransactionDatasource? firestoreDatasource,
    LocalTransactionDatasource? datasource,
    LocalTransactionDatasource? localDatasource,
  })  : _userId = userId,
        _firestoreDatasource = firestoreDatasource ??
            (userId != null ? FirestoreTransactionDatasource() : null),
        _localDatasource = datasource ??
            localDatasource ??
            (userId == null ? LocalTransactionDatasource() : null);

  final String? _userId;
  final FirestoreTransactionDatasource? _firestoreDatasource;
  final LocalTransactionDatasource? _localDatasource;

  List<Transaction> _currentTransactions = const [];

  @override
  Stream<List<Transaction>> getTransactions() {
    if (_userId != null && _firestoreDatasource != null) {
      return _firestoreDatasource
          .getTransactionsStream(_userId)
          .map((transactions) {
        _currentTransactions = List.unmodifiable(transactions);
        return transactions;
      });
    }

    return _localDatasource!.transactionsStream.map((transactions) {
      _currentTransactions = List.unmodifiable(transactions);
      return transactions;
    });
  }

  @override
  Future<void> saveTransaction(Transaction transaction) async {
    if (_userId != null && _firestoreDatasource != null) {
      final updated = List<Transaction>.from(_currentTransactions);
      final index = updated.indexWhere((t) => t.id == transaction.id);
      if (index >= 0) {
        updated[index] = transaction;
      } else {
        updated.insert(0, transaction);
      }
      _currentTransactions = List.unmodifiable(updated);
      await _firestoreDatasource.save(_userId, transaction);
      return;
    }
    await _localDatasource!.save(transaction);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    if (_userId != null && _firestoreDatasource != null) {
      final updated = List<Transaction>.from(_currentTransactions)
        ..removeWhere((t) => t.id == id);
      _currentTransactions = List.unmodifiable(updated);
      await _firestoreDatasource.delete(_userId, id);
      return;
    }
    await _localDatasource!.delete(id);
  }

  @override
  Future<BalanceSummary> getBalanceSummary() async {
    if (_userId != null && _firestoreDatasource != null) {
      return BalanceSummary.fromTransactions(_currentTransactions);
    }
    return BalanceSummary.fromTransactions(_localDatasource!.currentTransactions);
  }
}
