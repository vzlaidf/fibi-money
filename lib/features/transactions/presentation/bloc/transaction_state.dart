import 'package:equatable/equatable.dart';

import '../../domain/models/balance_summary.dart';
import '../../domain/models/transaction.dart';
import 'transaction_event.dart';

/// Estado de carga y ejecución de operaciones del BLoC.
enum TransactionStatus {
  initial,
  loading,
  success,
  failure;

  bool get isInitial => this == TransactionStatus.initial;
  bool get isLoading => this == TransactionStatus.loading;
  bool get isSuccess => this == TransactionStatus.success;
  bool get isFailure => this == TransactionStatus.failure;
}

/// Estado inmutable de [TransactionBloc].
class TransactionState extends Equatable {
  const TransactionState({
    this.status = TransactionStatus.initial,
    this.transactions = const [],
    this.filter = TransactionFilter.all,
    this.balanceSummary = BalanceSummary.empty,
    this.errorMessage,
  });

  final TransactionStatus status;
  final List<Transaction> transactions;
  final TransactionFilter filter;
  final BalanceSummary balanceSummary;
  final String? errorMessage;

  /// Retorna las transacciones según el filtro seleccionado.
  List<Transaction> get filteredTransactions {
    return transactions.where(filter.apply).toList();
  }

  /// Cantidad total de transacciones registradas sin filtrar.
  int get totalTransactionsCount => transactions.length;

  TransactionState copyWith({
    TransactionStatus? status,
    List<Transaction>? transactions,
    TransactionFilter? filter,
    BalanceSummary? balanceSummary,
    String? errorMessage,
  }) {
    return TransactionState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      filter: filter ?? this.filter,
      balanceSummary: balanceSummary ?? this.balanceSummary,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        transactions,
        filter,
        balanceSummary,
        errorMessage,
      ];
}
