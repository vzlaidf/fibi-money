import 'dart:async';

import '../../domain/models/transaction.dart';
import '../../domain/models/transaction_category.dart';
import '../../domain/models/transaction_type.dart';

/// Fuente de datos local en memoria para transacciones con emisión reactiva vía Stream.
class LocalTransactionDatasource {
  LocalTransactionDatasource({List<Transaction>? initialData}) {
    final seed = initialData ?? _defaultSeedData();
    _transactions = List.of(seed);
  }

  late final List<Transaction> _transactions;
  final StreamController<List<Transaction>> _streamController =
      StreamController<List<Transaction>>.broadcast();

  /// Emite inmediatamente el estado actual de las transacciones al suscribirse,
  /// y luego emite todas las actualizaciones subsecuentes.
  Stream<List<Transaction>> get transactionsStream {
    late final StreamSubscription<List<Transaction>> subscription;
    final controller = StreamController<List<Transaction>>(
      onCancel: () {
        subscription.cancel();
      },
    );

    // Emite el snapshot actual de forma síncrona/inmediata
    controller.add(List.unmodifiable(_transactions));

    // Escucha futuras actualizaciones de la fuente global
    subscription = _streamController.stream.listen(
      (data) {
        if (!controller.isClosed) {
          controller.add(data);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!controller.isClosed) {
          controller.addError(error, stackTrace);
        }
      },
      onDone: () {
        if (!controller.isClosed) {
          controller.close();
        }
      },
    );

    return controller.stream;
  }

  List<Transaction> get currentTransactions => List.unmodifiable(_transactions);

  Future<void> save(Transaction transaction) async {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index >= 0) {
      _transactions[index] = transaction;
    } else {
      // Las transacciones más recientes van primero en la lista
      _transactions.insert(0, transaction);
    }
    _streamController.add(List.unmodifiable(_transactions));
  }

  Future<void> delete(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    _streamController.add(List.unmodifiable(_transactions));
  }

  Future<void> clear() async {
    _transactions.clear();
    _streamController.add(List.unmodifiable(_transactions));
  }

  void dispose() {
    _streamController.close();
  }

  static List<Transaction> _defaultSeedData() {
    final now = DateTime.now();
    return [
      Transaction(
        id: 'tx_seed_1',
        title: 'Nómina quincenal',
        amount: 2500.00,
        type: TransactionType.income,
        category: TransactionCategory.salary,
        date: now,
        note: 'Depósito directo de empresa',
      ),
      Transaction(
        id: 'tx_seed_2',
        title: 'Rendimientos de inversión',
        amount: 700.00,
        type: TransactionType.income,
        category: TransactionCategory.investment,
        date: now.subtract(const Duration(days: 1)),
        note: 'Fondo indexado S&P500',
      ),
      Transaction(
        id: 'tx_seed_3',
        title: 'Supermercado mensual',
        amount: 650.00,
        type: TransactionType.expense,
        category: TransactionCategory.food,
        date: now.subtract(const Duration(hours: 4)),
        note: 'Víveres y despensa del mes',
      ),
      Transaction(
        id: 'tx_seed_4',
        title: 'Servicios del hogar (Luz y Fibra)',
        amount: 300.00,
        type: TransactionType.expense,
        category: TransactionCategory.bills,
        date: now.subtract(const Duration(days: 2)),
        note: 'Factura mensual domiciliada',
      ),
      Transaction(
        id: 'tx_seed_5',
        title: 'Suscripciones digitales',
        amount: 200.00,
        type: TransactionType.expense,
        category: TransactionCategory.entertainment,
        date: now.subtract(const Duration(days: 3)),
        note: 'Música, streaming y almacenamiento',
      ),
    ];
  }
}
