import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_theme.dart';
import 'core/theme/bloc/theme_bloc.dart';
import 'features/transactions/data/repositories/transaction_repository_impl.dart';
import 'features/transactions/domain/repositories/transaction_repository.dart';
import 'features/transactions/presentation/bloc/transaction_bloc.dart';
import 'features/transactions/presentation/screens/home_screen.dart';

/// Punto de entrada del widget raíz de la aplicación con inyección de repositorios y BLoCs.
class App extends StatelessWidget {
  const App({
    super.key,
    this.transactionRepository,
  });

  final TransactionRepository? transactionRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<TransactionRepository>(
      create: (_) => transactionRepository ?? TransactionRepositoryImpl(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeBloc>(
            create: (_) => ThemeBloc(),
          ),
          BlocProvider<TransactionBloc>(
            create: (context) => TransactionBloc(
              transactionRepository: context.read<TransactionRepository>(),
            )..add(const TransactionSubscriptionRequested()),
          ),
        ],
        child: const AppView(),
      ),
    );
  }
}

/// Vista principal que escucha al [ThemeBloc] y configura el [MaterialApp].
class AppView extends StatelessWidget {
  const AppView({super.key});

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
          home: const HomeScreen(title: 'Fibi Money'),
        );
      },
    );
  }
}
