import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'core/observers/app_bloc_observer.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/transactions/domain/repositories/transaction_repository.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase con las opciones de fibi-money
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configura el observer global para auditoría de BLoCs
  Bloc.observer = const AppBlocObserver();

  // Instancia el repositorio de autenticación principal
  final authRepository = AuthRepositoryImpl();

  runApp(App(authRepository: authRepository));
}

/// Alias retrocompatible de la aplicación para tests y componentes existentes.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    this.authRepository,
    this.transactionRepository,
  });

  final AuthRepository? authRepository;
  final TransactionRepository? transactionRepository;

  @override
  Widget build(BuildContext context) {
    return App(
      authRepository: authRepository,
      transactionRepository: transactionRepository,
    );
  }
}
