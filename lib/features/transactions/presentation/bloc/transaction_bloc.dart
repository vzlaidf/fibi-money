import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/balance_summary.dart';
import '../../domain/repositories/transaction_repository.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

export 'transaction_event.dart';
export 'transaction_state.dart';

/// BLoC que gestiona el estado de las transacciones financieras y el balance contable.
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc({
    required this.transactionRepository,
  }) : super(const TransactionState()) {
    on<TransactionSubscriptionRequested>(_onSubscriptionRequested);
    on<TransactionAdded>(_onTransactionAdded);
    on<TransactionDeleted>(_onTransactionDeleted);
    on<TransactionFilterChanged>(_onFilterChanged);
  }

  final TransactionRepository transactionRepository;

  Future<void> _onSubscriptionRequested(
    TransactionSubscriptionRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(status: TransactionStatus.loading));

    await emit.forEach(
      transactionRepository.getTransactions(),
      onData: (transactions) {
        final summary = BalanceSummary.fromTransactions(transactions);
        return state.copyWith(
          status: TransactionStatus.success,
          transactions: transactions,
          balanceSummary: summary,
        );
      },
      onError: (error, stackTrace) {
        return state.copyWith(
          status: TransactionStatus.failure,
          errorMessage: error.toString(),
        );
      },
    );
  }

  Future<void> _onTransactionAdded(
    TransactionAdded event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await transactionRepository.saveTransaction(event.transaction);
    } catch (e) {
      emit(
        state.copyWith(
          status: TransactionStatus.failure,
          errorMessage: 'No se pudo guardar la transacción: $e',
        ),
      );
    }
  }

  Future<void> _onTransactionDeleted(
    TransactionDeleted event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await transactionRepository.deleteTransaction(event.id);
    } catch (e) {
      emit(
        state.copyWith(
          status: TransactionStatus.failure,
          errorMessage: 'No se pudo eliminar la transacción: $e',
        ),
      );
    }
  }

  void _onFilterChanged(
    TransactionFilterChanged event,
    Emitter<TransactionState> emit,
  ) {
    emit(state.copyWith(filter: event.filter));
  }
}
