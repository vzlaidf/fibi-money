import 'package:equatable/equatable.dart';

import '../../domain/models/transaction.dart';

/// Filtros para la lista de transacciones.
enum TransactionFilter {
  all(label: 'Todas'),
  incomeOnly(label: 'Ingresos'),
  expenseOnly(label: 'Gastos');

  const TransactionFilter({required this.label});
  final String label;

  bool apply(Transaction transaction) {
    return switch (this) {
      TransactionFilter.all => true,
      TransactionFilter.incomeOnly => transaction.isIncome,
      TransactionFilter.expenseOnly => transaction.isExpense,
    };
  }
}

/// Eventos para el [TransactionBloc].
sealed class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para solicitar la suscripción al stream de transacciones del repositorio.
class TransactionSubscriptionRequested extends TransactionEvent {
  const TransactionSubscriptionRequested();
}

/// Evento para agregar o actualizar una transacción.
class TransactionAdded extends TransactionEvent {
  const TransactionAdded(this.transaction);

  final Transaction transaction;

  @override
  List<Object?> get props => [transaction];
}

/// Evento para eliminar una transacción por ID.
class TransactionDeleted extends TransactionEvent {
  const TransactionDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

/// Evento para cambiar el filtro activo de la lista.
class TransactionFilterChanged extends TransactionEvent {
  const TransactionFilterChanged(this.filter);

  final TransactionFilter filter;

  @override
  List<Object?> get props => [filter];
}
