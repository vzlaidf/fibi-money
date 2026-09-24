import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app_theme.dart';
import '../bloc/transaction_bloc.dart';
import 'transaction_tile.dart';

/// Lista que renderiza las transacciones filtradas por [TransactionBloc].
class TransactionListView extends StatelessWidget {
  const TransactionListView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;

    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        final items = state.filteredTransactions;

        if (state.status.isLoading && items.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 56,
                  color: colorScheme.outline.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'Sin transacciones registradas',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Presiona el botón + para agregar tu primer movimiento.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final tx = items[index];
            return TransactionTile(
              key: ValueKey(tx.id),
              transaction: tx,
            );
          },
        );
      },
    );
  }
}
