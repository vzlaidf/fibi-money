import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'core/observers/app_bloc_observer.dart';
import 'features/transactions/data/repositories/transaction_repository_impl.dart';
import 'features/transactions/domain/repositories/transaction_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Configura el observer global para auditoría de BLoCs
  Bloc.observer = const AppBlocObserver();

  // Instancia el repositorio de transacciones
  final transactionRepository = TransactionRepositoryImpl();

  runApp(App(transactionRepository: transactionRepository));
}

/// Alias retrocompatible de la aplicación para tests y componentes existentes.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    this.transactionRepository,
  });

  final TransactionRepository? transactionRepository;

  @override
  Widget build(BuildContext context) {
    return App(transactionRepository: transactionRepository);
  }
}
