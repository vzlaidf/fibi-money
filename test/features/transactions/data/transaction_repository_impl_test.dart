import 'package:fibi_money/features/transactions/data/datasources/local_transaction_datasource.dart';
import 'package:fibi_money/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:fibi_money/features/transactions/domain/models/transaction.dart';
import 'package:fibi_money/features/transactions/domain/models/transaction_category.dart';
import 'package:fibi_money/features/transactions/domain/models/transaction_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TransactionRepositoryImpl', () {
    late LocalTransactionDatasource datasource;
    late TransactionRepositoryImpl repository;

    final testTransaction = Transaction(
      id: 'test_tx_1',
      title: 'Consultoría externa',
      amount: 1500.0,
      type: TransactionType.income,
      category: TransactionCategory.freelance,
      date: DateTime(2026, 9, 18),
    );

    setUp(() {
      datasource = LocalTransactionDatasource(initialData: []);
      repository = TransactionRepositoryImpl(datasource: datasource);
    });

    tearDown(() {
      datasource.dispose();
    });

    test('getTransactions emits initially empty list when seeded with empty data', () async {
      expect(repository.getTransactions(), emits(isEmpty));
    });

    test('saveTransaction emits updated list with the new item', () async {
      expectLater(
        repository.getTransactions(),
        emitsInOrder([
          isEmpty,
          [testTransaction],
        ]),
      );

      await repository.saveTransaction(testTransaction);
    });

    test('deleteTransaction removes transaction from stream', () async {
      await repository.saveTransaction(testTransaction);

      expectLater(
        repository.getTransactions(),
        emitsInOrder([
          [testTransaction],
          isEmpty,
        ]),
      );

      await repository.deleteTransaction(testTransaction.id);
    });

    test('getBalanceSummary calculates correct totals', () async {
      await repository.saveTransaction(testTransaction);
      await repository.saveTransaction(
        Transaction(
          id: 'test_tx_2',
          title: 'Almuerzo',
          amount: 50.0,
          type: TransactionType.expense,
          category: TransactionCategory.food,
          date: DateTime(2026, 9, 18),
        ),
      );

      final summary = await repository.getBalanceSummary();
      expect(summary.totalIncome, equals(1500.0));
      expect(summary.totalExpense, equals(50.0));
      expect(summary.transactionCount, equals(2));
      // Base (10400) + 1500 - 50 = 11850
      expect(summary.totalBalance, equals(11850.0));
    });
  });
}
