import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;

import '../../domain/models/transaction.dart';
import '../../domain/models/transaction_category.dart';
import '../../domain/models/transaction_type.dart';

/// Fuente de datos de Cloud Firestore para transacciones en tiempo real.
class FirestoreTransactionDatasource {
  FirestoreTransactionDatasource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _userTransactionsRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('transactions');
  }

  /// Retorna un stream reactivo con las transacciones del usuario ordenadas por fecha.
  Stream<List<Transaction>> getTransactionsStream(String userId) {
    return _userTransactionsRef(userId)
        .snapshots()
        .map((snapshot) {
          final List<Transaction> transactions = snapshot.docs.map((doc) {
            final data = doc.data();
            return _mapDocToTransaction(doc.id, data);
          }).toList();

          // Orden descendente por fecha en memoria (más recientes primero)
          transactions.sort((a, b) => b.date.compareTo(a.date));
          return transactions;
        });
  }

  /// Guarda o actualiza una transacción en la colección personal del usuario.
  Future<void> save(String userId, Transaction transaction) async {
    final docRef = _userTransactionsRef(userId).doc(transaction.id);
    await docRef.set(transaction.toJson(), SetOptions(merge: true));
  }

  /// Elimina una transacción por su ID en la colección del usuario.
  Future<void> delete(String userId, String id) async {
    final docRef = _userTransactionsRef(userId).doc(id);
    await docRef.delete();
  }

  /// Transforma un documento de Firestore en un modelo [Transaction].
  Transaction _mapDocToTransaction(String id, Map<String, dynamic> data) {
    DateTime parsedDate;
    final rawDate = data['date'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return Transaction(
      id: id,
      title: data['title'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      type: TransactionType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => TransactionType.expense,
      ),
      category: TransactionCategory.values.firstWhere(
        (c) => c.name == data['category'],
        orElse: () => TransactionCategory.otherExpense,
      ),
      date: parsedDate,
      note: data['note'] as String?,
    );
  }
}
