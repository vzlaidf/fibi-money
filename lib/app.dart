import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_theme.dart';
import 'core/theme/bloc/theme_bloc.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/models/app_user.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/screens/auth_screen.dart';
import 'features/transactions/data/repositories/transaction_repository_impl.dart';
import 'features/transactions/domain/repositories/transaction_repository.dart';
import 'features/transactions/presentation/bloc/transaction_bloc.dart';
import 'features/transactions/presentation/screens/home_screen.dart';

/// Punto de entrada del widget raíz de la aplicación con inyección de repositorios y BLoCs.
class App extends StatelessWidget {
  const App({
    super.key,
    this.authRepository,
    this.transactionRepository,
  });

  final AuthRepository? authRepository;
  final TransactionRepository? transactionRepository;

  @override
  Widget build(BuildContext context) {
    final effectiveAuthRepo = authRepository ??
        (transactionRepository != null
            ? _TestAuthRepositoryFallback()
            : AuthRepositoryImpl());

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(
          value: effectiveAuthRepo,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeBloc>(
            create: (_) => ThemeBloc(),
          ),
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(
              authRepository: effectiveAuthRepo,
            )..add(const AuthSubscriptionRequested()),
          ),
        ],
        child: AppView(
          customTransactionRepository: transactionRepository,
        ),
      ),
    );
  }
}

/// Vista principal que escucha al [ThemeBloc] y al [AuthBloc] para enrutar entre autenticación y home.
class AppView extends StatelessWidget {
  const AppView({
    super.key,
    this.customTransactionRepository,
  });

  final TransactionRepository? customTransactionRepository;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp(
          title: 'Fibi Money',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeState.themeMode,
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState.status.isAuthenticated && authState.user != null) {
                final userId = authState.user!.id;
                final repository = customTransactionRepository ??
                    TransactionRepositoryImpl(userId: userId);

                return RepositoryProvider<TransactionRepository>.value(
                  value: repository,
                  child: BlocProvider<TransactionBloc>(
                    key: ValueKey('tx_bloc_$userId'),
                    create: (ctx) => TransactionBloc(
                      transactionRepository: repository,
                    )..add(const TransactionSubscriptionRequested()),
                    child: const HomeScreen(title: 'Fibi Money'),
                  ),
                );
              }

              if (authState.status.isLoading || authState.status.isInitial) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              return const AuthScreen();
            },
          ),
        );
      },
    );
  }
}

/// Repositorio de autenticación de respaldo para pruebas aisladas sin inicialización de Firebase.
class _TestAuthRepositoryFallback implements AuthRepository {
  static const _mockUser = AppUser(
    id: 'test_user_id',
    displayName: 'Usuario de Prueba',
    isAnonymous: true,
  );

  @override
  Stream<AppUser?> get user => Stream.value(_mockUser);

  @override
  AppUser? get currentUser => _mockUser;

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signInAnonymously() async {}

  @override
  Future<void> signOut() async {}
}
