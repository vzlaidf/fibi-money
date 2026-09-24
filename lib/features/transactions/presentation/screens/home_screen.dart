import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app_theme.dart';
import '../../../../core/theme/bloc/theme_bloc.dart';
import '../bloc/transaction_bloc.dart';
import '../widgets/add_transaction_sheet.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_list_view.dart';
import '../widgets/transaction_summary_card.dart';

/// Pantalla principal de Fibi Money construida sobre la arquitectura BLoC.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.title = 'Fibi Money',
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;

    return BlocListener<TransactionBloc, TransactionState>(
      listenWhen: (previous, current) =>
          previous.status != current.status && current.status.isFailure,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: context.financialColors.expense,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, themeState) {
                  final brightness = Theme.of(context).brightness;
                  final isDark = themeState.isDark(brightness);

                  return ActionChip(
                    avatar: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      size: 16,
                      color: isDark ? Colors.amber : colorScheme.primary,
                    ),
                    label: Text(
                      isDark ? 'Oscuro' : 'Claro',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      context.read<ThemeBloc>().add(const ThemeModeToggled());
                    },
                  );
                },
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tarjeta de Balance reactiva con BLoC
              const BalanceCard(),
              const SizedBox(height: 20),

              // Tarjeta de Resumen y contador de transacciones reactivo
              const TransactionSummaryCard(),
              const SizedBox(height: 24),

              // Encabezado de Movimientos Recientes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Movimientos recientes',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  BlocBuilder<TransactionBloc, TransactionState>(
                    builder: (context, state) {
                      return Text(
                        '${state.filteredTransactions.length} items',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.outline,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Lista interactiva de transacciones
              const TransactionListView(),
              const SizedBox(height: 80), // Margen para el FAB
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => AddTransactionSheet.show(context),
          tooltip: 'Nueva transacción',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
