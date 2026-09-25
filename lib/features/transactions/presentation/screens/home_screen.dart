import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app_theme.dart';
import '../../../../core/theme/bloc/theme_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
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
            // Selector de tema claro / oscuro
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
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

            // Acciones de usuario y cierre de sesión
            _buildAuthActions(context),
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

  Widget _buildAuthActions(BuildContext context) {
    try {
      final authBloc = context.watch<AuthBloc>();
      final state = authBloc.state;
      if (!state.status.isAuthenticated || state.user == null) {
        return const SizedBox.shrink();
      }

      final user = state.user!;
      return Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicador de usuario
            Tooltip(
              message: user.isAnonymous
                  ? 'Modo Invitado'
                  : (user.email ?? user.visibleName),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  user.isAnonymous
                      ? Icons.person_outline
                      : Icons.person_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 4),

            // Botón de salir
            IconButton(
              icon: const Icon(Icons.logout_rounded, size: 20),
              tooltip: 'Cerrar sesión',
              onPressed: () => _confirmSignOut(context),
            ),
          ],
        ),
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar tu sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      context.read<AuthBloc>().add(const AuthSignOutRequested());
    }
  }
}
