import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fibi_money/features/transactions/domain/models/balance_summary.dart';
import 'package:fibi_money/features/transactions/domain/models/transaction.dart';
import 'package:fibi_money/features/transactions/domain/models/transaction_category.dart';
import 'package:fibi_money/features/transactions/domain/models/transaction_type.dart';
import 'package:fibi_money/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:fibi_money/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  group('TransactionBloc', () {
    late TransactionRepository transactionRepository;
    late StreamController<List<Transaction>> streamController;

    final sampleTransaction = Transaction(
      id: 'tx_sample_1',
      title: 'Honorarios',
      amount: 1000.0,
      type: TransactionType.income,
      category: TransactionCategory.freelance,
      date: DateTime(2026, 9, 18),
    );

    setUp(() {
      transactionRepository = MockTransactionRepository();
      streamController = StreamController<List<Transaction>>.broadcast();

      when(() => transactionRepository.getTransactions())
          .thenAnswer((_) => streamController.stream);
    });

    tearDown(() {
      streamController.close();
    });

    test('initial state is TransactionState with empty values', () {
      final bloc = TransactionBloc(transactionRepository: transactionRepository);
      expect(bloc.state.status, equals(TransactionStatus.initial));
      expect(bloc.state.transactions, isEmpty);
      expect(bloc.state.filter, equals(TransactionFilter.all));
      bloc.close();
    });

    blocTest<TransactionBloc, TransactionState>(
      'subscribes to stream and emits loading then success when data arrives',
      setUp: () {
        when(() => transactionRepository.getTransactions())
            .thenAnswer((_) => Stream.value([sampleTransaction]));
      },
      build: () => TransactionBloc(transactionRepository: transactionRepository),
      act: (bloc) => bloc.add(const TransactionSubscriptionRequested()),
      expect: () => [
        const TransactionState(status: TransactionStatus.loading),
        TransactionState(
          status: TransactionStatus.success,
          transactions: [sampleTransaction],
          balanceSummary: BalanceSummary.fromTransactions([sampleTransaction]),
        ),
      ],
    );

    blocTest<TransactionBloc, TransactionState>(
      'calls saveTransaction on repository when TransactionAdded is dispatched',
      build: () {
        when(() => transactionRepository.saveTransaction(sampleTransaction))
            .thenAnswer((_) async {});
        return TransactionBloc(transactionRepository: transactionRepository);
      },
      act: (bloc) => bloc.add(TransactionAdded(sampleTransaction)),
      verify: (_) {
        verify(() => transactionRepository.saveTransaction(sampleTransaction))
            .called(1);
      },
    );

    blocTest<TransactionBloc, TransactionState>(
      'calls deleteTransaction on repository when TransactionDeleted is dispatched',
      build: () {
        when(() => transactionRepository.deleteTransaction('tx_sample_1'))
            .thenAnswer((_) async {});
        return TransactionBloc(transactionRepository: transactionRepository);
      },
      act: (bloc) => bloc.add(const TransactionDeleted('tx_sample_1')),
      verify: (_) {
        verify(() => transactionRepository.deleteTransaction('tx_sample_1'))
            .called(1);
      },
    );

    blocTest<TransactionBloc, TransactionState>(
      'updates filter state when TransactionFilterChanged is dispatched',
      build: () => TransactionBloc(transactionRepository: transactionRepository),
      act: (bloc) =>
          bloc.add(const TransactionFilterChanged(TransactionFilter.incomeOnly)),
      expect: () => [
        const TransactionState(filter: TransactionFilter.incomeOnly),
      ],
    );

    blocTest<TransactionBloc, TransactionState>(
      'emits failure state when saveTransaction throws error',
      build: () {
        when(() => transactionRepository.saveTransaction(sampleTransaction))
            .thenThrow(Exception('Error de base de datos'));
        return TransactionBloc(transactionRepository: transactionRepository);
      },
      act: (bloc) => bloc.add(TransactionAdded(sampleTransaction)),
      expect: () => [
        predicate<TransactionState>((state) =>
            state.status.isFailure &&
            state.errorMessage!.contains('Error de base de datos')),
      ],
    );
  });
}
